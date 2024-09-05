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
        // Oapp Bytes32 format Address (Same address all chains)
        bytes32 OAPP_BYTES32 = 0x00000000000000000000000057e56f6902c0273ef0694391998a860ea56CD7af;
        // Oapp Address (aame address all chains)
        address OAPP_ADDRESS = vm.envAddress("OAPP_ADDRESS");

        // === BASE ===
        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);
        // === OPTIMISM ===
        uint256 opLzEndIdUint = vm.envUint("OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID = uint32(opLzEndIdUint);
        // === ARBIRTUM ===
        uint256 arbLzEndIdUint = vm.envUint("ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID = uint32(arbLzEndIdUint);
        // === ZKSYNC ===
        uint256 zksLzEndIdUint = vm.envUint("ZKSYNC_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 ZKSYNC_SEPOLIA_LZ_ENDPOINT_ID = uint32(zksLzEndIdUint);
        // === LINEA ===
        uint256 lineaLzEndIdUint = vm.envUint("LINEA_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 LINEA_SEPOLIA_LZ_ENDPOINT_ID = uint32(lineaLzEndIdUint);
        // === ETHEREUM ===
        uint256 ethLzEndIdUint = vm.envUint("ETHEREUM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 ETHEREUM_SEPOLIA_LZ_ENDPOINT_ID = uint32(ethLzEndIdUint);

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("########################################");
        console2.log("########## Setting Base Peers ##########");
        console2.log("########################################");
        console2.log("        ");
        console2.log("Setting Base Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        StableEngineOapp(OAPP_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ZKSYNC_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(LINEA_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ETHEREUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        vm.stopBroadcast();

        // ========================
        // === OPTIMISM WIRE-UP ===
        // ========================

        console2.log("############################################");
        console2.log("########## Setting Optimism Peers ##########");
        console2.log("############################################");
        console2.log("        ");
        console2.log("Setting Optimism Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("optimism");

        vm.startBroadcast(deployerPrivateKey);

        StableEngineOapp(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ZKSYNC_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(LINEA_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ETHEREUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        vm.stopBroadcast();

        // ========================
        // === ARBITRUM WIRE-UP ===
        // ========================

        console2.log("############################################");
        console2.log("########## Setting Arbitrum Peers ##########");
        console2.log("############################################");
        console2.log("        ");
        console2.log("Setting Arbirtum Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("arbitrum");

        vm.startBroadcast(deployerPrivateKey);

        StableEngineOapp(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ZKSYNC_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(LINEA_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ETHEREUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        vm.stopBroadcast();

        // ========================
        // ==== ZKSYNC WIRE-UP ====
        // ========================

        // console2.log("############################################");
        // console2.log("########## Setting ZkSync Peers ###########");
        // console2.log("############################################");
        // console2.log("        ");
        // console2.log("Setting ZkSync Oapp Peer at: ", OAPP_ADDRESS);

        // vm.createSelectFork("zksync");

        // vm.startBroadcast(deployerPrivateKey);

        // StableEngineOapp(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(LINEA_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(ETHEREUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        // vm.stopBroadcast();

        // ========================
        // ==== LINEA WIRE-UP =====
        // ========================

        console2.log("############################################");
        console2.log("########## Setting Linea Peers ###########");
        console2.log("############################################");
        console2.log("        ");
        console2.log("Setting Linea Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("linea");

        vm.startBroadcast(deployerPrivateKey);

        StableEngineOapp(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ZKSYNC_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        StableEngineOapp(OAPP_ADDRESS).setPeer(ETHEREUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        vm.stopBroadcast();

        // ========================
        // ==== ETHEREUM WIRE-UP =====
        // ========================

        // console2.log("#############################################");
        // console2.log("########## Setting Ethereum Peers ###########");
        // console2.log("#############################################");
        // console2.log("        ");
        // console2.log("Setting Ethereum Oapp Peer at: ", OAPP_ADDRESS);

        // vm.createSelectFork("ethereum");

        // vm.startBroadcast(deployerPrivateKey);

        // StableEngineOapp(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(ZKSYNC_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);
        // StableEngineOapp(OAPP_ADDRESS).setPeer(LINEA_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        // vm.stopBroadcast();
    }
}
