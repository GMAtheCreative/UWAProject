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



    public struct UidRegistry has key, store {
        id: UID,
        userUid: String,
        addresses: Table<String, String>
    }
    public entry fun create_registry(userUid: String, ctx: &mut TxContext) {
        let registry_id = object::new(ctx);  
        let address_map = table::new<String, String>(ctx);   
    
        let existing_registry = table::borrow(&ctx.sender(), userUid)
        if (table::contains(&global_registry, userUid)){
            abort("User UID already exists");
        }

        let registry = UidRegistry {
            id: registry_id,
            userUid,
            addresses: address_map,
        };

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