#[contract]
mod Anchoring {
    // Storage variable used to store the anchored value
    struct Storage {
        anchored_value: felt252 // <- will be initialized to 0
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor() {}

    // Function used to set a new anchored value
    #[external]
    fn set_value(message: felt252) {
        anchored_value::write(message);
    }

    // Function used to return the current anchored value
    #[view]
    fn my_anchored() -> felt252 {
        anchored_value::read()
    }
}
