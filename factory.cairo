#[contract]
mod Factory {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::deploy_syscall;
    use starknet::class_hash::ClassHash;

    // Storage variable used to store the anchored value
    struct Storage {
        whitelist: LegacyMap<ContractAddress, ContractAddress>, // anchored_contract_address, user_account_contract_address
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
    fn deploy(whitelisted: ContractAddress) -> ContractAddress {
        assert(get_caller_address() == admin::read() , 'not_whitelisted_caller');
        let result = deploy_syscall(
            class_hash::read(),
            contract_address_salt: felt252,
            // calldata: Span<felt252>, // Should contain whitelisted value
            false,
        );
        let (deployed_addr, _) = result.unwrap_syscall();
        whitelist::write(deployed_addr, whitelisted);
        deployed_addr
    }

}
