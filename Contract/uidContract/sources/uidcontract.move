module uidcontract::uidcontract {
    use sui::event;
    use sui::table;
    use sui::vec_map;
    use std::string::{Self, String};

    // One-time witness struct required for initialization
    public struct UIDCONTRACT has drop {}

    // Error codes
    const E_UID_TAKEN: u64 = 1000;
    const E_INVALID_UID: u64 = 1001;
    const E_INVALID_ADDRESS: u64 = 1003;
    const E_NOT_OWNER: u64 = 1004;

    // UID Registry: Stores all UIDs and their associated NFT addresses
    public struct UIDRegistry has key {
        id: UID,
        taken_uids: table::Table<String, address>,
        admin: address,
    }

    // Non-transferable UID NFT
    public struct UserID has key {
        id: UID,
        uid: String,
        addresses: vec_map::VecMap<String, String>,
        owner: address,
    }

    // Events
    public struct UIDMinted has copy, drop {
        uid: String,
        nft_id: address,
        owner: address,
    }

    public struct AddressMapped has copy, drop {
        uid: String,
        chain: String,
        address: String,
    }

    // Initialize UID Registry
    fun init(_contract: UIDCONTRACT, ctx: &mut tx_context::TxContext) {
        transfer::share_object(UIDRegistry {
            id: object::new(ctx),
            taken_uids: table::new(ctx),
            admin: tx_context::sender(ctx),
        });
    }

    // Mint UID NFT and store address mappings
    public entry fun register_uid(
        registry: &mut UIDRegistry,
        uid: String,
        chains: vector<String>,
        addresses: vector<String>,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(string::length(&uid) >= 3 && string::length(&uid) <= 255, E_INVALID_UID);
        assert!(!table::contains(&registry.taken_uids, uid), E_UID_TAKEN);
        assert!(vector::length(&chains) == vector::length(&addresses), E_INVALID_ADDRESS);

        let mut user_addresses = vec_map::empty();
        let sender = tx_context::sender(ctx);
        let mut i = 0;
        while (i < vector::length(&chains)) {
            let chain = *vector::borrow(&chains, i);
            let address = *vector::borrow(&addresses, i);
            vec_map::insert(&mut user_addresses, chain, address);
            event::emit(AddressMapped { uid, chain, address });
            i = i + 1;
        }

        let user_id = UserID {
            id: object::new(ctx),
            uid,
            addresses: user_addresses,
            owner: sender,
        };

        let nft_id = object::id_address(&user_id);
        table::add(&mut registry.taken_uids, uid, nft_id);
        transfer::freeze_object(user_id);

        event::emit(UIDMinted { uid, nft_id, owner: sender });
    }

    // Fetch UID NFT from the blockchain
    public fun get_uid_nft(registry: &UIDRegistry, uid: String): address {
        if (table::contains(&registry.taken_uids, uid)) {
            *table::borrow(&registry.taken_uids, uid)
        } else {
            @0x0
        }
    }

    // Fetch all addresses tied to a UID
    public fun get_addresses(user_id: &UserID): vec_map::VecMap<String, String> {
        user_id.addresses
    }

    // Resolve blockchain address for a UID
    public fun resolve_address(user_id: &UserID, chain: String): String {
        if (vec_map::contains(&user_id.addresses, &chain)) {
            *vec_map::get(&user_id.addresses, &chain)
        } else {
            string::utf8(b"")
        }
    }

    // Update address mapping
    public entry fun update_address(
        user_id: &mut UserID,
        chain: String,
        address: String,
        ctx: &mut tx_context::TxContext
    ) {
        assert!(tx_context::sender(ctx) == user_id.owner, E_NOT_OWNER);
        vec_map::insert(&mut user_id.addresses, chain, address);
        event::emit(AddressMapped { uid: user_id.uid, chain, address });
    }
}