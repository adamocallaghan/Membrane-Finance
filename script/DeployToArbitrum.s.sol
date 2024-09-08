pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {StableEngine} from "../src/StableEngine.sol";
import {NFTMock} from "../src/NFTMock.sol";
import {StableCoin} from "../src/StableCoin.sol";

interface StableEngineOapp {
    function setPeer(uint32, bytes32) external;
}

contract DeployToArbitrum is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory ARBITRUM_LZ_ENDPOINT = "ARBITRUM_SEPOLIA_LZ_ENDPOINT";
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // === ARBIRTUM ===
        uint256 arbLzEndIdUint = vm.envUint("ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID = uint32(arbLzEndIdUint);

        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("###########################################");
        console2.log("########## Deploying to Arbitrum ##########");
        console2.log("###########################################");

        vm.createSelectFork("arbitrum");

        vm.startBroadcast(deployerPrivateKey);

        // deploy StableEngine OAPP contract
        StableEngine arbOapp =
            new StableEngine{salt: "red"}(vm.envAddress(ARBITRUM_LZ_ENDPOINT), vm.envAddress(DEPLOYER_PUBLIC_ADDRESS));
        console2.log("StableEngine Address: ", address(arbOapp));

        // deploy StableCoin OFT contract
        StableCoin arbOft = new StableCoin{salt: "red"}(
            "Membrane USD",
            "memUSD",
            vm.envAddress(ARBITRUM_LZ_ENDPOINT),
            address(arbOapp),
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS)
        );
        console2.log("OFT Address: ", address(arbOft));

        // deploy NFTMock
        NFTMock arbNft = new NFTMock{salt: "red"}();
        console2.log("NFT Address: ", address(arbNft));

        // whitelist the NFT on StableEngine
        arbOapp.setNftAsCollateral(address(arbNft), address(0x0), 0);

        // set the StableCoin address on the StableEngine (so it can find it and mint)
        arbOapp.setStableCoin(address(arbOft));

        // mint 10 NFTs to the deployer
        for (uint256 i = 0; i < 10; i++) {
            arbNft.mint();
        }

        vm.stopBroadcast();
    }
}
