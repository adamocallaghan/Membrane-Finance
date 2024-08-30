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

# Send both Uint & Address from Base => Optimism
send-useful-data-from-base:
	cast send $(BASE_SEPOLIA_OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "sendToMinter(uint32, uint, address, bytes)" $(OPTIMISM_SEPOLIA_LZ_ENDPOINT_ID) 7878 $(DEPLOYER_PUBLIC_ADDRESS) $(MESSAGE_OPTIONS_BYTES) --value 0.01ether --account deployer

# READ MESSSAGE ON OP

read-number-var-on-optimism:
	cast call $(OPTIMISM_SEPOLIA_OAPP_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) "number()(uint)" --account deployer

read-user-var-on-optimism:
	cast call $(OPTIMISM_SEPOLIA_OAPP_ADDRESS) --rpc-url $(OPTIMISM_SEPOLIA_RPC) "user()(address)" --account deployer