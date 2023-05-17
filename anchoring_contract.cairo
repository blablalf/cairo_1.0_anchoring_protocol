use starknet::StorageAccess;
use starknet::StorageBaseAddress;
use starknet::SyscallResult;
use starknet::storage_read_syscall;
use starknet::storage_write_syscall;
use starknet::storage_address_from_base_and_offset;
use traits::Into;
use traits::TryInto;
use option::OptionTrait;

struct Anchor<T> {
    message: felt252,
    timestamp: u64,
}

impl AnchorStorageAccess of StorageAccess::<Anchor> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<Anchor> {
        Result::Ok(
            Anchor {
                message: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, '')
                )?.try_into().unwrap(),
                timestamp: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 0_u64)
                )?.try_into().unwrap(),
            }
        )
    }

    fn write(address_domain: u32, base: StorageBaseAddress, value: Anchor) -> SyscallResult::<()> {
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 0_u8), value.message.into()
        )?;
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 0_u64), value.timestamp.into()
        )
    }
}


#[contract]
mod Anchoring {

    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::ContractAddress;
    use core::hash::TupleSize2LegacyHash;

    use super::Anchor;


    // Storage variable used to store the anchored value
    struct Storage {
        whitelisted: ContractAddress, // The address of the whitelisted contract
        size_index: u128, // size of the array
        messages: LegacyMap<u128, Anchor> // hash, timestamp
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor(_whitelisted: ContractAddress) {
        whitelisted::write(_whitelisted);
        size_index::write(0);
    }

    // Function used to set a new anchored value
    #[external]
    fn anchor(message: felt252) {
        //assert(!anchored_values::read(message), 'Already_Anchored');
        //messages.append(message);
        //timestamps.append(get_block_timestamp());
    }

    // fn fib(mut a: felt252, mut b: felt252, mut n: felt252) -> felt252 {
    //     while n > 0 {
    //         let c = a + b;
    //         a = b;
    //         b = c;
    //         n = n - 1;
    //     }
    //     return a;
    // }

}
