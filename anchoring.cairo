#[contract]
mod Anchoring {

    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::ContractAddress;
    use array::ArrayTrait;

    // Storage variable used to store the anchored value
    struct Storage {
        messages_size_index: u128, // size of the messages array
        message_values: LegacyMap<u128, felt252>, // index, message
        message_timestamp: LegacyMap<felt252, u64>, // message, timestamp
        whitelisted: LegacyMap<ContractAddress, bool>, // whitelisted ContractAddress, is it ?
        use_whitelist: bool,
        admin: ContractAddress,
        factory: ContractAddress,
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor(_factory: ContractAddress, _use_whitelist: bool) {
        admin::write(_factory);
        use_whitelist::write(_use_whitelist);
    }

    // Function used to anchor a new value
    #[external]
    fn anchor(message: felt252) {
        assert(!(message_timestamp::read(message) > 0), 'already_anchored');
        assert(whitelisted::read(get_caller_address()) , 'not_whitelisted_caller');
        message_values::write(messages_size_index::read(), message);
        message_timestamp::write(message, get_block_timestamp());
        messages_size_index::write(messages_size_index::read() + 1);
    }

    #[external]
    fn AddInWhitelist(address: ContractAddress) {
        assert(get_caller_address() == admin::read() , 'not_admin_caller');
        whitelisted::write(address, true);
    }

    #[external]
    fn RemoveFromWhitelist(address: ContractAddress) {
        assert(get_caller_address() == admin::read() , 'not_admin_caller');
        whitelisted::write(address, false);
    }

    #[view]
    fn get_anchored_timestamps() -> Array::<u64> {
        let mut values = ArrayTrait::new();
        construct_anchored_timestamps_array(values, 0_u128)
    }

    fn construct_anchored_timestamps_array(mut values: Array::<u64>, index: u128) -> Array::<u64> {
        if index < messages_size_index::read() {
            let message = message_values::read(index);
            values.append(message_timestamp::read(message));
            construct_anchored_timestamps_array(values, index + 1)
        } else { values }
    }

    #[view]
    fn get_anchored_values() -> Array::<felt252> {
        let mut values = ArrayTrait::new();
        construct_anchored_values_array(values, 0_u128)
    }

    fn construct_anchored_values_array(mut values: Array::<felt252>, index: u128) -> Array::<felt252> {
        if index < messages_size_index::read() {
            values.append(message_values::read(index));
            construct_anchored_values_array(values, index + 1)
        } else { values }
    }

    #[view]
    fn get_anchored_timestamp(message: felt252) -> u64 {
        message_timestamp::read(message)
    }

}
