pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {StableEngine} from "../src/StableEngine.sol";
import {NFTMock} from "../src/NFTMock.sol";
import {StableCoin} from "../src/StableCoin.sol";

interface StableEngineOapp {
    function setPeer(uint32, bytes32) external;
}

contract DeployToEthereum is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory ETHEREUM_LZ_ENDPOINT = "ETHEREUM_SEPOLIA_LZ_ENDPOINT";
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("###########################################");
        console2.log("########## Deploying to Ethereum ##########");
        console2.log("###########################################");

        vm.createSelectFork("ethereum");

        vm.startBroadcast(deployerPrivateKey);

        // deploy StableEngine OAPP contract
        StableEngine ethOapp =
            new StableEngine{salt: "yoyo"}(vm.envAddress(ETHEREUM_LZ_ENDPOINT), vm.envAddress(DEPLOYER_PUBLIC_ADDRESS));
        console2.log("StableEngine Address: ", address(ethOapp));

        // deploy StableCoin OFT contract
        StableCoin ethOft = new StableCoin{salt: "yoyo"}(
            "Membrane USD",
            "memUSD",
            vm.envAddress(ETHEREUM_LZ_ENDPOINT),
            address(ethOapp),
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS)
        );
        console2.log("OFT Address: ", address(ethOft));

        // deploy NFTMock
        NFTMock ethNft = new NFTMock{salt: "yoyo"}();
        console2.log("NFT Address: ", address(ethNft));

        // whitelist the NFT on StableEngine
        ethOapp.setNftAsCollateral(address(ethNft), address(0x0), 0);

        // set the StableCoin address on the StableEngine (so it can find it and mint)
        ethOapp.setStableCoin(address(ethOft));

        // mint 10 NFTs to the deployer
        for (uint256 i = 0; i < 10; i++) {
            ethNft.mint();
        }

        vm.stopBroadcast();
    }
}
