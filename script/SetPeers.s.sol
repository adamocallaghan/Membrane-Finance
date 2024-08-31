pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {StableEngine} from "../src/StableEngine.sol";
import {NFTMock} from "../src/NFTMock.sol";
import {StableCoin} from "../src/StableCoin.sol";

interface StableEngineOapp {
    function setPeer(uint32, bytes32) external;
}

contract SetPeers is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        uint256 opLzEndIdUint = vm.envUint("OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID = uint32(opLzEndIdUint);
        bytes32 OPTIMISM_SEPOLIA_OAPP_BYTES32 = 0x000000000000000000000000E8429f469e66e10644a4F5Ec82EE890B808C5DC1;

        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);
        bytes32 BASE_SEPOLIA_OAPP_BYTES32 = 0x000000000000000000000000E8429f469e66e10644a4F5Ec82EE890B808C5DC1;

        // Base Oapp Address
        address BASE_SEPOLIA_OAPP_ADDRESS = vm.envAddress("BASE_SEPOLIA_OAPP_ADDRESS");
        address OPTIMISM_SEPOLIA_OAPP_ADDRESS = vm.envAddress("OPTIMISM_SEPOLIA_OAPP_ADDRESS");

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("########################################");
        console2.log("########## Setting Base Peers ##########");
        console2.log("########################################");
        console2.log("        ");
        console2.log("Setting Base Oapp Peer at: ", BASE_SEPOLIA_OAPP_ADDRESS);

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        StableEngineOapp(BASE_SEPOLIA_OAPP_ADDRESS).setPeer(
            OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OPTIMISM_SEPOLIA_OAPP_BYTES32
        );

        vm.stopBroadcast();

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("############################################");
        console2.log("########## Setting Optimism Peers ##########");
        console2.log("############################################");
        console2.log("        ");
        console2.log("Setting Optimism Oapp Peer at: ", OPTIMISM_SEPOLIA_OAPP_ADDRESS);
        // console2.log("The Peer bytes32 address is: ", BASE_SEPOLIA_OAPP_BYTES32);

        vm.createSelectFork("optimism");

        vm.startBroadcast(deployerPrivateKey);

        StableEngineOapp(OPTIMISM_SEPOLIA_OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, BASE_SEPOLIA_OAPP_BYTES32);

        vm.stopBroadcast();
    }
}
