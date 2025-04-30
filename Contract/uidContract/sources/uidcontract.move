
/// Module: uidcontract
module uidcontract::uidcontract{
     use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::string::{Self, String};
    use sui::event;
    use sui::vec_map::{Self, VecMap};

    // Error codes
    const E_UID_TAKEN: u64 = 1000;
    const E_INVALID_UID: u64 = 1001;
    const E_INVALID_CHAIN: u64 = 1002;
    const E_INVALID_ADDRESS: u64 = 1003;
    const E_NOT_OWNER: u64 = 1004;
    const E_NOT_AUTHORIZED: u64 = 1005;

    // Shared registry for all UIDs
    struct UIDRegistry has key {
        id: UID,
        taken_uids: Table<String, address>, // UID -> UserID NFT address
        admin: address, // Backend admin for system-generated addresses
    }

    // UID NFT
    struct UserID has key, store {
        id: UID,
        uid: String, // e.g., "johndoe.mask"
        addresses: VecMap<String, String>, // chain -> address
    }

    // Events for backend sync
    struct UIDMinted has copy, drop {
        uid: String,
        nft_id: address,
        owner: address,
    }

    struct AddressMapped has copy, drop {
        uid: String,
        chain: String,
        address: String,
        is_system_generated: bool,
    }

    // Initialize registry
    fun init(ctx: &mut TxContext) {
        let admin = tx_context::sender(ctx);
        transfer::share_object(UIDRegistry {
            id: object::new(ctx),
            taken_uids: table::new(ctx),
            admin,
        });
    }

    // Mint UID as NFT with address mappings
    public entry fun register_uid_with_addresses(
        registry: &mut UIDRegistry,
        uid: String,
        chains: vector<String>,
        addresses: vector<String>,
        ctx: &mut TxContext
    ) {
        // Validate UID: 3-255 chars, contains a dot
        assert!(string::length(&uid) >= 3 && string::length(&uid) <= 255, E_INVALID_UID);
        assert!(string::index_of(&uid, string::utf8(b".")) != string::length(&uid), E_INVALID_UID);
        // Check uniqueness
        assert!(!table::contains(&registry.taken_uids, uid), E_UID_TAKEN);
        // Validate inputs
        assert!(vector::length(&chains) == vector::length(&addresses), E_INVALID_ADDRESS);
        let i = 0;
        while (i < vector::length(&chains)) {
            let chain = *vector::borrow(&chains, i);
            let address = *vector::borrow(&addresses, i);
            assert!(string::length(&chain) >= 1 && string::length(&chain) <= 50, E_INVALID_CHAIN);
            assert!(string::length(&address) >= 1 && string::length(&address) <= 255, E_INVALID_ADDRESS);
            i = i + 1;
        };
        // Create UserID NFT
        let addresses_map = vec_map::empty();
        let i = 0;
        while (i < vector::length(&chains)) {
            vec_map::insert(&mut addresses_map, *vector::borrow(&chains, i), *vector::borrow(&addresses, i));
            i = i + 1;
        };
        let user_id = UserID {
            id: object::new(ctx),
            uid,
            addresses: addresses_map,
        };
        let nft_id = object::id_address(&user_id);
        // Register
        table::add(&mut registry.taken_uids, uid, nft_id);
        // Transfer NFT to owner
        transfer::transfer(user_id, tx_context::sender(ctx));
        // Emit events
        event::emit(UIDMinted {
            uid,
            nft_id,
            owner: tx_context::sender(ctx),
        });
        let i = 0;
        while (i < vector::length(&chains)) {
            let chain = *vector::borrow(&chains, i);
            let address = *vector::borrow(&addresses, i);
            event::emit(AddressMapped {
                uid,
                chain,
                address,
                is_system_generated: false,
            });
            i = i + 1;
        };
    }

    // Update address mappings (user-initiated)
    public entry fun update_addresses(
        user_id: &mut UserID,
        chain: String,
        address: String,
        ctx: &mut TxContext
    ) {
        // Verify ownership
        assert!(tx_context::sender(ctx) == object::owner(user_id), E_NOT_OWNER);
        // Validate inputs
        assert!(string::length(&chain) >= 1 && string::length(&chain) <= 50, E_INVALID_CHAIN);
        assert!(string::length(&address) >= 1 && string::length(&address) <= 255, E_INVALID_ADDRESS);
        // Update or add mapping
        vec_map::insert(&mut user_id.addresses, chain, address);
        // Emit event
        event::emit(AddressMapped {
            uid: user_id.uid,
            chain,
            address,
            is_system_generated: false,
        });
    }

    // Update address mappings (system-initiated, e.g., generated Polkadot address)
    public entry fun update_system_addresses(
        registry: &UIDRegistry,
        user_id: &mut UserID,
        chain: String,
        address: String,
        ctx: &mut TxContext
    ) {
        // Verify admin (backend)
        assert!(tx_context::sender(ctx) == registry.admin, E_NOT_AUTHORIZED);
        // Validate inputs
        assert!(string::length(&chain) >= 1 && string::length(&chain) <= 50, E_INVALID_CHAIN);
        assert!(string::length(&address) >= 1 && string::length(&address) <= 255, E_INVALID_ADDRESS);
        // Update or add mapping
        vec_map::insert(&mut user_id.addresses, chain, address);
        // Emit event
        event::emit(AddressMapped {
            uid: user_id.uid,
            chain,
            address,
            is_system_generated: true,
        });
    }

    // Resolve UID to address
    public fun resolve(user_id: &UserID, chain: String): String {
        if (vec_map::contains(&user_id.addresses, &chain)) {
            *vec_map::get(&user_id.addresses, &chain)
        } else {
            string::utf8(b"")
        }
    }

    // Get UserID NFT address
    public fun get_user_id_address(registry: &UIDRegistry, uid: String): address {
        if (table::contains(&registry.taken_uids, uid)) {
            *table::borrow(&registry.taken_uids, uid)
        } else {
            0x0
        }
    }

}
