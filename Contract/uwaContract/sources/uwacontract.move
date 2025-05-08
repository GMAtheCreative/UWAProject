/// Module: uwacontract
#[allow(duplicate_alias)]
module uwacontract::uwacontract {
    use sui::object::{Self, UID};
    // use sui::object;
    use sui::tx_context::{Self, TxContext};
    // use sui::tx_context;
    use sui::table;
    use sui :: table::Table;
    use sui::transfer;
    use std::string::String;
    use std::option::Option;

  
    const EUID_ALREADY_EXISTS: u64 = 1;

    public struct UidDirectory has key, store {
        id: UID,
        user_uids: Table<String, address>
    }

    public struct UidRegistry has key, store {
        id: UID,
        userUid: String,
        addresses: Table<String, String>
    }

    public entry fun create_directory(ctx: &mut TxContext){
        let id = object::new(ctx);
        let map = table::new<String, address>(ctx);
        let directory =UidDirectory {
            id,
            user_uids: map
        };
        transfer::transfer(directory, tx_context::sender(ctx));
    }
    public entry fun create_registry(
        directory: &mut UidDirectory, 
        userUid: String, 
        ctx: &mut TxContext) {
      
        if (table::contains(&directory.user_uids, userUid)) {
            abort EUID_ALREADY_EXISTS
        };
        let registry_id = object::new(ctx);  
        let address_map = table::new<String, String>(ctx); 

        let registry = UidRegistry {
            id: registry_id,
            userUid,
            addresses: address_map,
        };
        table::add(&mut directory.user_uids, userUid,tx_context::sender(ctx));

        transfer::transfer(registry, tx_context::sender(ctx));
    }

    public entry fun set_addresses(registry : &mut UidRegistry, network: String, address: String){
      table::add(&mut registry.addresses, network, address);
    }

    public fun get_userUid(registry : &UidRegistry) : String {
        return registry.userUid
    }
    
    public fun get_address(registry: &UidRegistry, network: String): Option<String> {
        if (table::contains(&registry.addresses, network)) {
            option::some(*table::borrow(&registry.addresses, network))
        } 
        else {
            option::none()
        }
    }

    public fun get_uid(registry: &UidRegistry): &UID {
       return &registry.id
    }
}