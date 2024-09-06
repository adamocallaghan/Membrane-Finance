pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {StableEngine} from "../src/StableEngine.sol";
import {NFTMock} from "../src/NFTMock.sol";
import {StableCoin} from "../src/StableCoin.sol";

interface StableEngineOapp {
    function setPeer(uint32, bytes32) external;
}

contract DeployToBase is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory BASE_LZ_ENDPOINT = "BASE_SEPOLIA_LZ_ENDPOINT";
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // === BASE ===
        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);

        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("#######################################");
        console2.log("########## Deploying to Base ##########");
        console2.log("#######################################");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // deploy StableEngine OAPP contract
        StableEngine baseOapp =
            new StableEngine{salt: "pop"}(vm.envAddress(BASE_LZ_ENDPOINT), vm.envAddress(DEPLOYER_PUBLIC_ADDRESS));
        console2.log("StableEngine Address: ", address(baseOapp));

        // deploy StableCoin OFT contract
        StableCoin baseOft = new StableCoin{salt: "pop"}(
            "Membrane USD",
            "memUSD",
            vm.envAddress(BASE_LZ_ENDPOINT),
            address(baseOapp),
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS)
        );
        console2.log("OFT Address: ", address(baseOft));

        // deploy NFTMock
        NFTMock baseNft = new NFTMock{salt: "pop"}();
        console2.log("NFT Address: ", address(baseNft));

        // whitelist the NFT on StableEngine
        baseOapp.setNftAsCollateral(address(baseNft), address(0x0), 0);

        // set the StableCoin address on the StableEngine (so it can find it and mint)
        baseOapp.setStableCoin(address(baseOft));

        // mint 10 NFTs to the deployer
        for (uint256 i = 0; i < 10; i++) {
            baseNft.mint();
        }

        vm.stopBroadcast();
    }
}
