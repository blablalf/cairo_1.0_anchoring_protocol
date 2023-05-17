#[contract]
mod Anchoring {

    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::ContractAddress;
    use array::ArrayTrait;
    use clone::Clone;

    // Storage variable used to store the anchored value
    struct Storage {
        whitelisted: ContractAddress, // The address of the whitelisted contract
        size_index: u128, // size of the array
        messages_value: LegacyMap<u128, felt252>, // message
        messages_timestamp: LegacyMap<u128, u64> // timestamp
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor(_whitelisted: ContractAddress) {
        whitelisted::write(_whitelisted);
        size_index::write(0);
    }

    // Function used to anchor a new value
    #[external]
    fn anchor(message: felt252) {
        assert(has_not_been_anchored(message), 'already_anchored');
        assert(get_caller_address() == whitelisted::read() , 'not_whitelisted_caller');
        messages_value::write(size_index::read(), message);
        messages_timestamp::write(size_index::read(), get_block_timestamp());
        size_index::write(size_index::read() + 1);
    }

    #[external]
    fn get_anchored_values() -> Array::<felt252> {
        let mut values = ArrayTrait::new();
        construct_anchored_values_array(values, 0_u128)
    }

    fn construct_anchored_values_array(mut values: Array::<felt252>, index: u128) -> Array::<felt252> {
        //let mut values = _values.clone();
        if size_index::read() < index {
            values.append(messages_value::read(index));
            construct_anchored_values_array(values, index + 1)
        } else { values }
    }

    #[external]
    fn get_anchored_timestamps() -> Array::<u64> {
        let mut values = ArrayTrait::new();
        construct_anchored_timestamps_array(values, 0_u128)
    }

    fn construct_anchored_timestamps_array(mut values: Array::<u64>, index: u128) -> Array::<u64> {
        //let mut values = _values.clone();
        if size_index::read() < index {
            values.append(messages_timestamp::read(index));
            construct_anchored_timestamps_array(values, index + 1)
        } else {
            values
        }
        
    }

    #[external]
    fn has_not_been_anchored(message: felt252) -> bool {
        check_value_at_index(message, 0_u128, true)
    }

    fn check_value_at_index(message: felt252, index: u128, current_state: bool) -> bool {
        if size_index::read() < index {
            if messages_value::read(index) == message { false } else { true }
        } else { current_state }
    }

}
