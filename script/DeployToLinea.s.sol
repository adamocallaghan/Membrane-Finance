pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {StableEngine} from "../src/StableEngine.sol";
import {NFTMock} from "../src/NFTMock.sol";
import {StableCoin} from "../src/StableCoin.sol";

interface StableEngineOapp {
    function setPeer(uint32, bytes32) external;
}

contract DeployToLinea is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory LINEA_LZ_ENDPOINT = "LINEA_SEPOLIA_LZ_ENDPOINT";
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // === LINEA ===
        uint256 lineaLzEndIdUint = vm.envUint("LINEA_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 LINEA_SEPOLIA_LZ_ENDPOINT_ID = uint32(lineaLzEndIdUint);

        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("###########################################");
        console2.log("########## Deploying to Linea #############");
        console2.log("###########################################");

        vm.createSelectFork("linea");

        vm.startBroadcast(deployerPrivateKey);

        // deploy StableEngine OAPP contract
        StableEngine lineaOapp =
            new StableEngine{salt: "red"}(vm.envAddress(LINEA_LZ_ENDPOINT), vm.envAddress(DEPLOYER_PUBLIC_ADDRESS));
        console2.log("StableEngine Address: ", address(lineaOapp));

        // deploy StableCoin OFT contract
        StableCoin lineaOft = new StableCoin{salt: "red"}(
            "Membrane USD",
            "memUSD",
            vm.envAddress(LINEA_LZ_ENDPOINT),
            address(lineaOapp),
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS)
        );
        console2.log("OFT Address: ", address(lineaOft));

        // deploy NFTMock
        NFTMock lineaNft = new NFTMock{salt: "red"}();
        console2.log("NFT Address: ", address(lineaNft));

        // whitelist the NFT on StableEngine
        lineaOapp.setNftAsCollateral(address(lineaNft), address(0x0), 0);

        // set the StableCoin address on the StableEngine (so it can find it and mint)
        lineaOapp.setStableCoin(address(lineaOft));

        // mint 10 NFTs to the deployer
        for (uint256 i = 0; i < 10; i++) {
            lineaNft.mint();
        }

        vm.stopBroadcast();
    }
}
