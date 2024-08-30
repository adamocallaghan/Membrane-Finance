// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OApp, Origin, MessagingFee, MessagingReceipt} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import {IStableCoin} from "./interfaces/IStableCoin.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IChainlinkDataFeed {
    function latestAnswer() external returns (int256);
}

contract StableEngine is OApp, IERC721Receiver {
    // ====================
    // === STORAGE VARS ===
    // ====================

    string public data;
    uint256 public number;
    address public user;

    // Stablecoin vars
    address public stableCoinContract;

    // NFT vars
    address[] public whitelistedNFTs;
    address[] public nftOracles;
    mapping(address nftAddress => mapping(uint256 tokenId => address supplier)) public
        nftCollectionTokenIdToSupplierAddress;
    mapping(address user => mapping(address nftAddress => uint256 count)) public userAddressToNftCollectionSuppliedCount;
    mapping(address supplier => uint256 nftSupplied) public numberOfNftsUserHasSupplied;
    mapping(address user => uint256 stablecoinsMinted) public userAddressToNumberOfStablecoinsMinted;

    // CR and Health Factor vars
    uint256 public COLLATERALISATION_RATIO = 5e17; // aka 50%
    uint256 public MIN_HEALTH_FACTOR = 1e18; // aka 1.0

    enum ChainSelection {
        Base,
        Optimism,
        Arbitrum,
        Scroll,
        Linea
    }

    // ==============
    // === ERRORS ===
    // ==============

    error UserDidNotSupplyTheNFTOriginally(uint256 tokenId);
    error UserHasOutstandingDebt(uint256 outstandingDebt);
    error mintFailed();
    error ChainNotSpecified();
    error NoNftsCurrentlySupplied();
    error Error__NftIsNotAcceptedCollateral();

    // ==============
    // === EVENTS ===
    // ==============

    event NftSuppliedToContract(address indexed _nftAddress, uint256 indexed _tokenId);
    event NftWithdrawnByUser(address indexed user, uint256 indexed tokenId);
    event MintOnChainFunctionSuccessful();

    event MintContractCalled();

    // test events - remove
    event OptimismSelected();
    event ArbitrumSelected();
    event Received();

    constructor(address _endpoint) OApp(_endpoint, msg.sender) Ownable(msg.sender) {}

    // ================================
    // === SUPPLY NFT AS COLLATERAL ===
    // ================================

    // @todo MAKE NON-REENTRANT
    function supply(address _nftAddress, uint256 _tokenId) public {
        // *** EOA has to call approve() on the NFT contract to allow this contract to take control of the NFT id number ***

        // check if nft is acceptable collateral
        for (uint256 i = 0; i < whitelistedNFTs.length; i++) {
            if (whitelistedNFTs[i] == _nftAddress) {
                break;
            } else {
                revert Error__NftIsNotAcceptedCollateral();
            }
        }

        // accept NFT into the contract
        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        // update mapping to account for who can withdraw a specific NFT tokenId
        nftCollectionTokenIdToSupplierAddress[_nftAddress][_tokenId] = msg.sender;

        // we always liquidate at floor price, so just need to count how many of each collection they've supplied
        userAddressToNftCollectionSuppliedCount[msg.sender][_nftAddress]++;

        numberOfNftsUserHasSupplied[msg.sender]++;

        emit NftSuppliedToContract(_nftAddress, _tokenId);
    }

    // ====================
    // === WITHDRAW NFT ===
    // ====================

    function withdraw(address _nftAddress, uint256 _tokenId) public {
        // check that the requested tokenId is the one the user supplied initially
        if (msg.sender == nftCollectionTokenIdToSupplierAddress[_nftAddress][_tokenId]) {
            // check if a user has an outstanding loan (stablecoin minted) balance
            if (userAddressToNumberOfStablecoinsMinted[msg.sender] == 0) {
                // if both are ok, transfer the NFT to them
                IERC721(_nftAddress).transferFrom(address(this), msg.sender, _tokenId);

                nftCollectionTokenIdToSupplierAddress[_nftAddress][_tokenId] = address(0x0); // zero out address that supplied this NFT token id
                userAddressToNftCollectionSuppliedCount[msg.sender][_nftAddress]--;
                numberOfNftsUserHasSupplied[msg.sender]--;

                emit NftWithdrawnByUser(msg.sender, _tokenId);
            } else {
                revert UserHasOutstandingDebt(userAddressToNumberOfStablecoinsMinted[msg.sender]);
            }
        } else {
            revert UserDidNotSupplyTheNFTOriginally(_tokenId);
        }
    }

    // =========================
    // === MINT OMNI-STABLES ===
    // =========================

    function mintOnOptimism(
        uint32 _dstEid,
        string memory _message,
        uint256 _numberToMint,
        uint256 _selection,
        address _recipient,
        bytes calldata _options
    ) external payable {
        // has user supplied an nft as collateral
        if (numberOfNftsUserHasSupplied[msg.sender] == 0) {
            revert NoNftsCurrentlySupplied();
        }

        uint256 maxStablecoinCanBeMinted = _calculateMaxMintableByUser();

        if (_numberToMint <= maxStablecoinCanBeMinted) {
            bytes memory _payload = abi.encode(_message, _numberToMint, _selection, _recipient); // Encode the message as bytes
            _lzSend(
                _dstEid,
                _payload,
                _options,
                MessagingFee(msg.value, 0), // Fee for the message (nativeFee, lzTokenFee)
                payable(msg.sender) // The refund address in case the send call reverts
            );
        }

        userAddressToNumberOfStablecoinsMinted[msg.sender] += _numberToMint;
    }

    function _calculateMaxMintableByUser() internal returns (uint256) {
        // @todo when other NFTs as collateral is being implemented...
        // - it should loop over all the user's deposited NFTs (from each collection) and get the floor price for each
        // - it should then calculate the value of their entire colllateral

        // calculate amount of stables that user can mint against their entire collateral
        uint256 totalValueOfAllCollateral = nftPriceInUsd() * numberOfNftsUserHasSupplied[msg.sender]; // @todo change to account of different collections and prices
        uint256 availableToBorrowAtMaxCR = (totalValueOfAllCollateral * COLLATERALISATION_RATIO) / 1e18; // 50% of nft price
        uint256 maxStablecoinCanBeMinted = availableToBorrowAtMaxCR - userAddressToNumberOfStablecoinsMinted[msg.sender];
        return maxStablecoinCanBeMinted;
    }

    // ======================
    // === NFT PRICE FEED ===
    // ======================

    function nftPriceInUsd() internal returns (uint256) {
        IChainlinkDataFeed nftPriceFeed = IChainlinkDataFeed(nftOracles[0]);
        uint256 nftPrice = uint256(nftPriceFeed.latestAnswer());
        return nftPrice * 1e10; // bring it up as chainlink returns it with 8 decimals only
            // return 36000e18;
    }

    // ===============================
    // === LAYERZERO FUNCTIONALITY ===
    // ===============================

    // ===============
    // === LZ SEND ===
    // ===============

    function send(uint32 _dstEid, string memory _message, uint256 _amount, bytes calldata _options)
        external
        payable
        returns (MessagingReceipt memory receipt)
    {
        // has user supplied an nft as collateral
        if (numberOfNftsUserHasSupplied[msg.sender] == 0) {
            revert NoNftsCurrentlySupplied();
        }

        // calculate max amount user can mint
        uint256 maxStablecoinCanBeMinted = _calculateMaxMintableByUser();

        // check + send to destination chain
        if (_amount <= maxStablecoinCanBeMinted) {
            bytes memory _payload = abi.encode(_message);
            receipt = _lzSend(_dstEid, _payload, _options, MessagingFee(msg.value, 0), payable(msg.sender));
        }

        // increment user's stable balance
        userAddressToNumberOfStablecoinsMinted[msg.sender] += _amount;
    }

    function sendToMinter(uint32 _dstEid, uint256 _amount, address _recipient, bytes calldata _options)
        external
        payable
        returns (MessagingReceipt memory receipt)
    {
        bytes memory _payload = abi.encode(_amount, _recipient);
        receipt = _lzSend(_dstEid, _payload, _options, MessagingFee(msg.value, 0), payable(msg.sender));
    }

    // ================
    // === LZ QUOTE ===
    // ================

    function quote(uint32 _dstEid, string memory _message, bytes memory _options, bool _payInLzToken)
        public
        view
        returns (MessagingFee memory fee)
    {
        bytes memory payload = abi.encode(_message);
        fee = _quote(_dstEid, payload, _options, _payInLzToken);
    }

    // ==================
    // === LZ RECEIVE ===
    // ==================

    function _lzReceive(
        Origin calldata, /*_origin*/
        bytes32, /*_guid*/
        bytes calldata payload,
        address, /*_executor*/
        bytes calldata /*_extraData*/
    ) internal override {
        (uint256 amount, address recipient) = abi.decode(payload, (uint256, address));
        number = amount;
        user = recipient;
        callStableEngineContractAndMint(recipient, amount);
        // emit Received();
    }

    function callStableEngineContractAndMint(address _recipient, uint256 _numberOfCoins) internal {
        IStableCoin(stableCoinContract).mint(_recipient, _numberOfCoins);
        emit MintContractCalled();
    }

    function setStableCoin(address _stableCoin) external onlyOwner {
        stableCoinContract = _stableCoin;
    }

    function setNftAsCollateral(address _nftAddress, address _nftOracle, uint256 _index) external onlyOwner {
        whitelistedNFTs.push(_nftAddress);
        nftOracles.push(_nftOracle);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
