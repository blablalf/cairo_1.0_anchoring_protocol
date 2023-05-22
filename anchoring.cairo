#[contract]
mod Anchoring {

    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::ContractAddress;
    use array::ArrayTrait;

    // Storage variable used to store the anchored value
    struct Storage {
        whitelisted: ContractAddress, // The address of the whitelisted contract
        size_index: u128, // size of the array
        message_values: LegacyMap<u128, felt252>, // index, message
        message_timestamp: LegacyMap<felt252, u64> // message, timestamp
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
        assert(!(message_timestamp::read(message) > 0), 'already_anchored');
        assert(get_caller_address() == whitelisted::read() , 'not_whitelisted_caller');
        message_values::write(size_index::read(), message);
        message_timestamp::write(message, get_block_timestamp());
        size_index::write(size_index::read() + 1);
    }

    #[view]
    fn get_anchored_timestamps() -> Array::<u64> {
        let mut values = ArrayTrait::new();
        construct_anchored_timestamps_array(values, 0_u128)
    }

    fn construct_anchored_timestamps_array(mut values: Array::<u64>, index: u128) -> Array::<u64> {
        if index < size_index::read() {
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
        if index < size_index::read() {
            values.append(message_values::read(index));
            construct_anchored_values_array(values, index + 1)
        } else { values }
    }

    #[view]
    fn get_anchored_timestamp(message: felt252) -> u64 {
        message_timestamp::read(message)
    }

}
