-include .env

# DEPLOY OAPP CONTRACTS

deploy-to-base:
	forge create ./src/StableEngine.sol:StableEngine --rpc-url $(BASE_SEPOLIA_RPC) --constructor-args $(BASE_SEPOLIA_LZ_ENDPOINT) --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --verify --account deployer

deploy-to-optimism:
	forge create ./src/StableEngine.sol:StableEngine --rpc-url $(OPTIMISM_SEPOLIA_RPC) --constructor-args $(OPTIMISM_SEPOLIA_LZ_ENDPOINT) --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY) --verify --account deployer

# SET PEERS / WIRE UP

set-base-peer:
	cast send $(BASE_SEPOLIA_OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "setPeer(uint32, bytes32)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) $(OPTIMISM_SEPOLIA_OAPP_BYTES32) --account deployer

set-optimism-peer:
	cast send $(OPTIMISM_SEPOLIA_OAPP_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) "setPeer(uint32, bytes32)" $(BASE_SEPOLIA_LZ_ENDPOINT_ID) $(BASE_SEPOLIA_OAPP_BYTES32) --account deployer

# SET STABLECOIN ADDRESS ON OPTIMISM OAPP
# set-stablecoin-on-stableengine-optimism:
# 	cast send $(OPTIMISM_SEPOLIA_OAPP_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) "setStableCoin(address)" $(OPTIMISM_SEPOLIA_OFT_ADDRESS) --account deployer
approve-nft-to-oapp:
	cast send $(NFT_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "approve(address,uint)" $(OAPP_ADDRESS) 0 --value 0.001ether --account deployer

supply-nft-on-base:
	cast send $(OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "supply(address,uint)" $(NFT_ADDRESS) 0 --value 0.01ether --account deployer

# Send both Uint & Address from Base => Optimism
send-useful-data-from-base:
	cast send $(OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "sendToMinter(uint32, uint, address, uint8, bytes)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) 888000000000000000000 $(DEPLOYER_PUBLIC_ADDRESS) 1 $(MESSAGE_OPTIONS_BYTES) --value 0.1ether --account deployer

# READ MESSSAGE ON OP

read-number-var-on-optimism:
	cast call $(OPTIMISM_SEPOLIA_OAPP_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) "number()(uint)" --account deployer

read-user-var-on-optimism:
	cast call $(OPTIMISM_SEPOLIA_OAPP_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) "user()(address)" --account deployer

read-balance-of-stables-on-optimism:
	cast call $(OPTIMISM_SEPOLIA_OFT_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) "balanceOf(address)(uint)" $(DEPLOYER_PUBLIC_ADDRESS) --account deployer


# =========================
# === SCRIPT DEPLOYMENT ===
# =========================
deploy-contracts--to-base-and-set-addresses-for-collateral-and-stablecoin:
	forge script script/DeployToBase.s.sol:DeployToBase --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv  --via-ir

deploy-contracts--to-optimism-and-set-addresses-for-collateral-and-stablecoin:
	forge script script/DeployToOptimism.s.sol:DeployToOptimism --broadcast --verify --etherscan-api-key $(OPTIMISM_ETHERSCAN_API_KEY) --rpc-url $(OPTIMISM_SEPOLIA_RPC) --account deployer -vvvvv  --via-ir

deploy-contracts--to-arbitrum-and-set-addresses-for-collateral-and-stablecoin:
	forge script script/DeployToArbitrum.s.sol:DeployToArbitrum --broadcast --verify --etherscan-api-key $(ARBITRUM_ETHERSCAN_API_KEY) --rpc-url $(ARBITRUM_SEPOLIA_RPC) --account deployer -vvvvv  --via-ir

# ETHERSCAN API THROWING ERROR
deploy-contracts--to-linea-and-set-addresses-for-collateral-and-stablecoin:
	forge script script/DeployToLinea.s.sol:DeployToLinea --broadcast --rpc-url $(LINEA_SEPOLIA_RPC) --account deployer -vvvvv  --via-ir

# GAS COSTS OFF THE WALL!
# deploy-contracts--to-ethereum-and-set-addresses-for-collateral-and-stablecoin:
# 	forge script script/DeployToEthereum.s.sol:DeployToEthereum --broadcast --verify --etherscan-api-key $(ETHEREUM_ETHERSCAN_API_KEY) --rpc-url $(ETHEREUM_SEPOLIA_RPC) --account deployer -vvvvv

# deploy-contracts--to-zksync-and-set-addresses-for-collateral-and-stablecoin:
# 	forge script script/DeployToZkSync.s.sol:DeployToZkSync --broadcast --verify --etherscan-api-key $(ZKSYNC_ETHERSCAN_API_KEY) --rpc-url $(ZKSYNC_SEPOLIA_RPC) --account deployer -vvvvv

# *** NOTE: --via-ir IS ON BECAUSE OF A 'STACK TOO DEEP' ERROR USING THE SET PEERS SCRIPT AFTER ADDING ARB & LINEA ***
set-peer-on-both-using-script:
	forge script script/SetPeers.s.sol:SetPeers --broadcast --account deployer -vvvvv --via-ir

# read max mintable
read-max-mintable-for-user:
	cast call $(OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "getMaxMintableByUser(address)(uint)" $(DEPLOYER_PUBLIC_ADDRESS)

# failing
send-a-b-a:
	cast send $(OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "sendABA(uint32,uint16,uint256,address,uint8,bytes,bytes)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) 2 12345 $(DEPLOYER_PUBLIC_ADDRESS) 5 $(ABA_MESSAGE_OPTIONS_BYTES) $(ABO_MESSAGE_OPTIONS_BYTES) --value 0.2ether --account deployer