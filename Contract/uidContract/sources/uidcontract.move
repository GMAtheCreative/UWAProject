module uidcontract::uidcontract {
    use sui::object::{Self, ID};
    use sui::tx_context::TxContext;
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::vector;
    use sui::string;

    //
    // Structs
    //

    struct UidNFT has key, store {
        id: ID,
        name: String, // the UID
    }

    struct UserProfile has key, store {
        id: ID,
        uid_nft: ID,
        addresses: vector<String>,
    }

    struct UidRegistry has key {
        id: ID,
        name_to_id: Table<String, ID>,
    }

    //
    // Errors
    //
    const E_UID_ALREADY_EXISTS: u64 = 0;
    const E_UID_NOT_FOUND: u64 = 1;

    //
    // Initialization function
    //
    public entry fun init_registry(ctx: &mut TxContext) {
        let id = object::new(ctx);
        let map = Table::new<String, ID>(ctx);
        let registry = UidRegistry {
            id,
            name_to_id: map,
        };
        move_to(&ctx.sender(), registry);
    }

    //
    // Main registration logic
    //
    public entry fun register_user(
        name: String,
        addresses: vector<String>,
        registry: &mut UidRegistry,
        ctx: &mut TxContext
    ): ID {
        if (Table::contains_key(&registry.name_to_id, &name)) {
            abort E_UID_ALREADY_EXISTS;
        }

        let uid_id = object::new(ctx);
        let profile_id = object::new(ctx);

        let nft = UidNFT {
            id: uid_id,
            name: name.clone(),
        };

        let profile = UserProfile {
            id: profile_id,
            uid_nft: uid_id,
            addresses,
        };

        Table::add(&mut registry.name_to_id, name, profile_id);
        transfer::transfer(nft, ctx.sender());
        transfer::transfer(profile, ctx.sender());

        uid_id
    }

    //
    // View: Get a user's profile ID by UID name
    //
    public fun get_profile_id(
        registry: &UidRegistry,
        name: String
    ): ID {
        if (!Table::contains_key(&registry.name_to_id, &name)) {
            abort E_UID_NOT_FOUND;
        }
        Table::borrow(&registry.name_to_id, &name)
    }
}
