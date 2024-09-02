pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {StableEngine} from "../src/StableEngine.sol";
import {NFTMock} from "../src/NFTMock.sol";
import {StableCoin} from "../src/StableCoin.sol";

interface StableEngineOapp {
    function setPeer(uint32, bytes32) external;
}

contract DeployToOptimism is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory BASE_LZ_ENDPOINT = "BASE_SEPOLIA_LZ_ENDPOINT";
        string memory OPTIMISM_LZ_ENDPOINT = "OPTIMISM_SEPOLIA_LZ_ENDPOINT";

        // string memory opLzEndIdString = "OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID";
        uint256 opLzEndIdUint = vm.envUint("OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID = uint32(opLzEndIdUint);
        bytes32 OPTIMISM_SEPOLIA_OAPP_BYTES32 = "OPTIMISM_SEPOLIA_OAPP_BYTES32";

        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // ============================
        // === OPTIMISM DEPLOYMENTS ===
        // ============================

        console2.log("###########################################");
        console2.log("########## Deploying to Optimism ##########");
        console2.log("###########################################");

        vm.createSelectFork("optimism");

        vm.startBroadcast(deployerPrivateKey);

        // deploy StableEngine OAPP contract
        StableEngine optimismOapp =
            new StableEngine{salt: "jkl"}(vm.envAddress(OPTIMISM_LZ_ENDPOINT), vm.envAddress(DEPLOYER_PUBLIC_ADDRESS));
        console2.log("StableEngine Address: ", address(optimismOapp));

        // deploy StableCoin OFT contract
        StableCoin optimismOft = new StableCoin{salt: "jkl"}(
            "Membrane USD",
            "memUSD",
            vm.envAddress(OPTIMISM_LZ_ENDPOINT),
            address(optimismOapp),
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS)
        );
        console2.log("OFT Address: ", address(optimismOft));

        // deploy NFTMock
        NFTMock optimismNft = new NFTMock{salt: "jkl"}();
        console2.log("NFT Address: ", address(optimismNft));

        // whitelist the NFT on StableEngine
        optimismOapp.setNftAsCollateral(address(optimismNft), address(0x0), 0);

        // set the StableCoin address on the StableEngine (so it can find it and mint)
        optimismOapp.setStableCoin(address(optimismOft));

        // mint 10 NFTs to the deployer
        for (uint256 i = 0; i < 10; i++) {
            optimismNft.mint();
        }

        vm.stopBroadcast();

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        // vm.createSelectFork("base");

        // vm.startBroadcast(deployerPrivateKey);

        // baseOapp.setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OPTIMISM_SEPOLIA_OAPP_BYTES32);

        // vm.stopBroadcast();
    }
}
