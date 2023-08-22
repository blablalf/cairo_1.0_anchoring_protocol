use core::serde::Serde;
use core::traits::Into;
#[contract]
mod Factory {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::deploy_syscall;
    use starknet::class_hash::ClassHash;
    use starknet::get_block_timestamp;
    use array::ArrayTrait;
    use traits::Into;

    // Storage variable used to store the anchored value
    struct Storage {
        deployed_length: u128, // length of the deployed contracts array
        deployed: LegacyMap<u128, ContractAddress>, // anchored_contract_address, user_account_contract_address
        admin: ContractAddress, // account wallet authorized to push new contracts
        class_hash: ClassHash, // class hash of the anchoring contract
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor(_admin: ContractAddress, _class_hash: ClassHash) {
        admin::write(_admin);
        class_hash::write(_class_hash);
    }

    #[external]
    fn change_admin(new_admin: ContractAddress) {
        assert(get_caller_address() == admin::read() , 'not_whitelisted_caller');
        admin::write(new_admin);
    }

    // Function used to deploy and add a new contract to the whitelist
    #[external]
    fn deploy(_admin: ContractAddress, contract_label: felt252) -> ContractAddress { //, _description: Array::<felt252> 
        assert(get_caller_address() == admin::read() , 'not_whitelisted_caller');

        // Creating the call data for the deploy syscall
        let mut calldata_array = ArrayTrait::new();
        calldata_array.append(_admin.into());
        calldata_array.append(contract_label.into());
        //calldata_array.append(_description.into().);

        // Deploying the contract
        let result = deploy_syscall(
            class_hash::read(),
            get_block_timestamp().into(),
            // contract_address_salt: felt252, value used in order to calculate the futur contract address,
            // in the futur we need to add some randomness here otherwise we might be able to predict the
            // contract address and deploy a contract with the same address as an existing one.
            calldata_array.span(),// calldata: Span<felt252>, // Should contain whitelisted value
            false,
        );

        // Adding the contract to the whitelist mapping
        let (deployed_addr, _) = result.unwrap_syscall();
        deployed::write(deployed_length::read(), deployed_addr);
        deployed_length::write(deployed_length::read() + 1);

        // Returning the deployed contract address
        deployed_addr
    }

    #[view]
    fn get_admin() -> ContractAddress {
        admin::read()
    }

    #[view]
    // Get metadatas about the contract
    fn get_metadatas() -> Array::<felt252> {
        let mut metadatas = ArrayTrait::new();
        metadatas.append('name: Smart-chain / Secure Fact');
        metadatas.append('ory | author: smart-chain <cont');
        metadatas.append('act@smart-chain.fr> | version: ');
        metadatas.append('1.0.0 | license: MIT | homepage');
        metadatas.append(': https://secure.smart-chain.fr');
        metadatas.append(' | description: Factory for Sec');
        metadatas.append('ure product |');
        metadatas
    }

    #[view]
    fn get_deployed_address_array() -> Array::<felt252> {
        let mut deployed_addr = ArrayTrait::new();
        construct_deployed_address_array(deployed_addr, 0_u128)
    }

    fn construct_deployed_address_array(mut values: Array::<felt252>, index: u128) -> Array::<felt252> {
        if index < deployed_length::read() {
            values.append(deployed::read(index).into());
            construct_deployed_address_array(values, index + 1)
        } else { values }
    }

}
