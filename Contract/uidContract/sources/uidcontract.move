#[allow(duplicate_alias)]
module uidcontract::uidcontract {
    use sui::object;
    use sui::table;
    use sui::transfer;
    use sui::tx_context;
    use std::string::{Self, String};
    use sui::event;
    use sui::vec_map;
    use std::vector;

    // Error codes
    const E_UID_TAKEN: u64 = 1000;
    const E_INVALID_UID: u64 = 1001;
    const E_INVALID_CHAIN: u64 = 1002;
    const E_INVALID_ADDRESS: u64 = 1003;
    const E_NOT_OWNER: u64 = 1004;
    const E_NOT_AUTHORIZED: u64 = 1005;

    // UID Registry: Stores all UIDs and their associated NFT addresses
    public struct UIDRegistry has key {
        id: object::UID,
        taken_uids: table::Table<vector<u8>, address>,
        admin: address,
    }

    // Non-transferable UID NFT
    public struct UserID has key {
        id: object::UID,
        uid: String,
        addresses: vec_map::VecMap<String, String>,
        owner: address,
    }

    // Event emitted when a UID is minted
    public struct UIDMinted has copy, drop {
        uid: String,
        nft_id: address,
        owner: address,
    }

    // Event emitted when an address is mapped
    public struct AddressMapped has copy, drop {
        uid: String,
        chain: String,
        address: String,
        is_system_generated: bool,
    }

    // Initialize UID Registry
    fun init(ctx: &mut tx_context::TxContext) {
        let admin = tx_context::sender(ctx);
        transfer::share_object(UIDRegistry {
            id: object::new(ctx),
            taken_uids: table::new(ctx),
            admin,
        });
    }

    // Create a new UIDRegistry instance (for testing)
    #[test_only]
    public fun new_uid_registry(ctx: &mut tx_context::TxContext): UIDRegistry {
        UIDRegistry {
            id: object::new(ctx),
            taken_uids: table::new(ctx),
            admin: tx_context::sender(ctx),
        }
    }

    // Share UIDRegistry (for testing)
    #[test_only]
    public fun share_uid_registry(registry: UIDRegistry) {
        transfer::share_object(registry);
    }

    // Mint UID NFT and store address mappings
    public entry fun register_uid(
        registry: &mut UIDRegistry,
        uid: String,
        chains: vector<String>,
        addresses: vector<String>,
        ctx: &mut tx_context::TxContext
    ) {
        // Validate UID: 3-255 chars, contains a dot
        assert!(string::length(&uid) >= 3 && string::length(&uid) <= 255, E_INVALID_UID);
        let dot = string::utf8(b".");
        assert!(string::index_of(&uid, &dot) != string::length(&uid), E_INVALID_UID);
        // Check uniqueness
        let uid_bytes = *string::as_bytes(&uid);
        assert!(!table::contains(&registry.taken_uids, uid_bytes), E_UID_TAKEN);
        // Validate inputs
        assert!(vector::length(&chains) == vector::length(&addresses), E_INVALID_ADDRESS);
        let mut i = 0;
        while (i < vector::length(&chains)) {
            let chain = *vector::borrow(&chains, i);
            let address = *vector::borrow(&addresses, i);
            assert!(string::length(&chain) >= 1 && string::length(&chain) <= 50, E_INVALID_CHAIN);
            assert!(string::length(&address) >= 1 && string::length(&address) <= 255, E_INVALID_ADDRESS);
            i = i + 1;
        };
        // Create UserID NFT
        let mut user_addresses = vec_map::empty();
        let mut i = 0;
        while (i < vector::length(&chains)) {
            let chain = *vector::borrow(&chains, i);
            let address = *vector::borrow(&addresses, i);
            vec_map::insert(&mut user_addresses, chain, address);
            event::emit(AddressMapped {
                uid,
                chain,
                address,
                is_system_generated: false,
            });
            i = i + 1;
        };
        let sender = tx_context::sender(ctx);
        let user_id = UserID {
            id: object::new(ctx),
            uid,
            addresses: user_addresses,
            owner: sender,
        };
        let nft_id = object::id_address(&user_id);
        // Register
        table::add(&mut registry.taken_uids, uid_bytes, nft_id);
        // Freeze NFT to make it non-transferable
        transfer::freeze_object(user_id);
        // Emit event
        event::emit(UIDMinted {
            uid,
            nft_id,
            owner: sender,
        });
    }

    // Securely update address mappings (user-initiated)
    public entry fun update_address(
        user_id: &mut UserID,
        chain: String,
        address: String,
        ctx: &mut tx_context::TxContext
    ) {
        // Verify ownership
        assert!(tx_context::sender(ctx) == user_id.owner, E_NOT_OWNER);
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

    // Update address mappings (system-initiated, e.g., future generated Polkadot address)
    public entry fun update_system_addresses(
        registry: &UIDRegistry,
        user_id: &mut UserID,
        chain: String,
        address: String,
        ctx: &mut tx_context::TxContext
    ) {
        // Verify admin
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

    // Retrieve the NFT address associated with a UID
    public fun get_uid_nft(registry: &UIDRegistry, uid: String): address {
        let uid_bytes = *string::as_bytes(&uid);
        if (table::contains(&registry.taken_uids, uid_bytes)) {
            *table::borrow(&registry.taken_uids, uid_bytes)
        } else {
            @0x0
        }
    }

    // Resolve UID to Blockchain Address
    public fun resolve_address(user_id: &UserID, chain: String): String {
        if (vec_map::contains(&user_id.addresses, &chain)) {
            *vec_map::get(&user_id.addresses, &chain)
        } else {
            string::utf8(b"")
        }
    }
}