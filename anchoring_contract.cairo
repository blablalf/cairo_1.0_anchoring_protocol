#[contract]
mod Anchoring {

    use starknet::get_caller_address;
    use starknet::ContractAddress;

    // Storage variable used to store the anchored value
    struct Storage {
        whitelisted: ContractAddress, // The address of the whitelisted contract
        anchored_value: (felt252, u64) // hash, timestamp
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor(_whitelisted: ContractAddress) {
        whitelisted::write(_whitelisted);
    }

    // Function used to set a new anchored value
    #[external]
    fn anchor(message: felt252) {
        //assert(!anchored_values::read(message), 'Already_Anchored');
        anchored_value::write(felt252, get_block_timestamp());
    }

    // Function used to return if a specific message has beeen anchored before
    #[view]
    fn is_anchored(message: felt252) -> bool {e
        anchored_values::read(message)
    }

    // Function used to return the current anchored values
    #[view]
    fn my_anchored(message: felt252) -> bool {
        anchored_values::read(message)
    }
}
