#[contract]
mod Anchoring {

    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::ContractAddress;
    use array::ArrayTrait;

    // Storage variable used to store the anchored value
    struct Storage {
        contract_label: felt252, // The label of the client
        admin: ContractAddress, // The address of the admin of contract
        size_index: u128, // size of the array
        message_values: LegacyMap<u128, LegacyMap::<u32, felt252>>, // index, message
        message_array_length: LegacyMap<u128, u32>, // The length of the array
        message_timestamp: LegacyMap<u32, felt252>, // index, timestamp
        whitelisted: LegacyMap<ContractAddress, bool>, // The address of the whitelisted contract
        description_length: u32, // The length of the array
        description: LegacyMap::<u32, felt252>, // The description of the contract
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor(_admin: ContractAddress, _contract_label: felt252, _description: Array::<felt252>) {
        admin::write(_admin);
        size_index::write(0);
        contract_label::write(_contract_label);
        description_length::write(_description.len());
        deconstruct_description_array(_description, 0_u32);
    }

    // Function used to whitelist a contract
    #[external]
    fn add_in_whitelist(address_to_whitelist: ContractAddress) {
        assert(get_caller_address() == admin::read(), 'not_admin');
        whitelisted::write(address_to_whitelist, true);
    }

    // Function used to remove a contract from the whitelist
    #[external]
    fn remove_from_whitelist(address_to_remove: ContractAddress) {
        assert(get_caller_address() == admin::read(), 'not_admin');
        whitelisted::write(address_to_remove, false);
    }

    // Function used to anchor a new value
    #[external]
    fn anchor(message: Array::<felt252>) {
        assert(whitelisted::read(get_caller_address()) , 'not_whitelisted_caller');
        //assert(!(message_timestamp::read(message) > 0), 'already_anchored');
        write_anchored_message_array(message, 0_u32);
        message_timestamp::write(0_u32, get_block_timestamp());
        size_index::write(size_index::read() + 1);
    }

    // Write a new contract label
    #[external]
    fn set_contract_label(_contract_label: felt252) {
        assert(get_caller_address() == admin::read(), 'not_admin');
        contract_label::write(_contract_label);
    }

    // Write a new admin
    #[external]
    fn set_admin(_admin: ContractAddress) {
        assert(get_caller_address() == admin::read(), 'not_admin');
        admin::write(_admin);
    }
    
    fn deconstruct_description_array(mut values: Array::<felt252>, index: u32) {
        if index < description_length::read() {
            description::write(index, *values.at(0));
            // values.pop_front();
            construct_description_array(values, index + 1);
        }
    }

    #[view]
    fn get_description() -> Array::<felt252> {
        let mut values = ArrayTrait::new();
        construct_description_array(values, 0_u32)
    }

    fn construct_description_array(values: Array::<felt252>, index: u32) -> Array::<felt252> {
        if index < description_length::read() {
            values.append(description::read(index));
            construct_description_array(values, index + 1)
        } else { values }
    }

    #[view]
    fn get_contract_label() -> felt252 {
        contract_label::read()
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

    fn write_anchored_message_array(message: Array::<felt252>, index: u16) {
        if index < message.len() {
            message_values::write(size_index::read(), (index, *message.at(index)));
            write_anchored_message_array(message, index + 1)
        }
        size_index::write(size_index::read() + 1);
    }

    fn construct_anchored_message_array(message_index: u128, mut message: Array::<u64>, array_index: u128) -> Array::<felt252> {
        if array_index < message_values::read(message_index).len() {
            let message_part = message_values::read(message_index).at(array_index);
            message.append(message_part);
        } else { message }
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
    fn get_anchored_timestamp(message: Array::<felt252>) -> u64 {
        message_timestamp::read(message)
    }

    #[view]
    fn is_whitelisted(address_to_check: ContractAddress) -> bool {
        whitelisted::read(address_to_check)
    }

    // Get admin
    #[view]
    fn get_admin() -> ContractAddress {
        admin::read()
    }

    #[view]
    // Get metadatas about the contract
    fn get_metadatas() -> Array::<felt252> {
        let mut metadatas = ArrayTrait::new();
        metadatas.append('name: ');
        metadatas.append(contract_label::read()); // 31 char max
        metadatas.append(' | author: smart-chain <contact');
        metadatas.append('@smart-chain.fr> | version: 1.0');
        metadatas.append('.0 | license: MIT |  | descript');
        metadatas.append('ion: ');
        concatenate_arrays(metadatas, get_description())
    }

    fn concatenate_arrays(mut array1: Array::<felt252>, mut array2: Array::<felt252>) -> Array::<felt252> {
        if array2.len() > 0 {
            array1.append(*array2.at(0));
            array2.pop_front();
            concatenate_arrays(array1, array2)
        } else { array1 }
    }

}
