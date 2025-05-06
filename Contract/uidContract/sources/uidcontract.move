module uidcontract::uidcontract {
    use sui::object::{UID};
    use sui::transfer;
    use sui::tx_context::{TxContext};
    use sui::event;
    use sui::table;
    use sui::vec_map;
    use std::string::{String};
    use std::vector;

    // One-time witness struct
    public struct UIDCONTRACT has drop {}

    // Error codes
    const E_UID_TAKEN: u64 = 1000;
    const E_INVALID_UID: u64 = 1001;
    const E_INVALID_ADDRESS: u64 = 1003;
    const E_NOT_OWNER: u64 = 1004;
    const E_UID_NOT_FOUND: u64 = 1005;

    // UID Registry
    public struct UIDRegistry has key {
        id: UID,
        uid_to_nft: table::Table<String, address>, // UID to NFT address mapping
        admin: address,
    }

    // Non-transferable UID NFT
    public struct UIDNFT has key {
        id: UID,
        uid: String,
        addresses: vec_map::VecMap<String, String>, // Network -> Address mapping
        owner: address,
    }

    // Events
    public struct UIDRegistered has copy, drop {
        uid: String,
        nft_id: address,
        owner: address,
    }

    public struct AddressAdded has copy, drop {
        uid: String,
        network: String,
        address: String,
    }

    /// Initialize the UID registry
    fun init(witness: UIDCONTRACT, ctx: &mut TxContext) {
        transfer::share_object(UIDRegistry {
            id: object::new(ctx),
            uid_to_nft: table::new(ctx),
            admin: tx_context::sender(ctx),
        });
    }

    /// Register a new UID with initial addresses
    public entry fun register_uid(
        registry: &mut UIDRegistry,
        uid: String,
        networks: vector<String>,
        addresses: vector<String>,
        ctx: &mut TxContext
    ) {
        // Validate inputs
        assert!(string::length(&uid) >= 3 && string::length(&uid) <= 255, E_INVALID_UID);
        assert!(!table::contains(&registry.uid_to_nft, uid), E_UID_TAKEN);
        assert!(vector::length(&networks) == vector::length(&addresses), E_INVALID_ADDRESS);

        let sender = tx_context::sender(ctx);
        let mut address_map = vec_map::empty();

        // Add all initial addresses
        let i = 0;
        let len = vector::length(&networks);
        while (i < len) {
            let network = vector::borrow(&networks, i);
            let address = vector::borrow(&addresses, i);
            vec_map::insert(&mut address_map, *network, *address);
            event::emit(AddressAdded {
                uid: copy uid,
                network: *network,
                address: *address
            });
            i = i + 1;
        };

        // Create the UID NFT
        let uid_nft = UIDNFT {
            id: object::new(ctx),
            uid,
            addresses: address_map,
            owner: sender,
        };

        // Store the mapping
        let nft_address = object::id_to_address(&uid_nft.id);
        table::add(&mut registry.uid_to_nft, uid, nft_address);

        // Transfer NFT to sender (non-transferable by design)
        transfer::transfer(uid_nft, sender);

        event::emit(UIDRegistered {
            uid,
            nft_id: nft_address,
            owner: sender
        });
    }

    /// Get all addresses for a UID
    public fun get_all_addresses(
        registry: &UIDRegistry,
        uid: String
    ): (address, &vec_map::VecMap<String, String>) {
        assert!(table::contains(&registry.uid_to_nft, uid), E_UID_NOT_FOUND);
        let nft_address = table::borrow(&registry.uid_to_nft, uid);
        let uid_nft = borrow_uid_nft(nft_address);
        (*nft_address, &uid_nft.addresses)
    }

    /// Get specific address for a UID and network
    public fun get_address(
        registry: &UIDRegistry,
        uid: String,
        network: String
    ): (address, &String) {
        assert!(table::contains(&registry.uid_to_nft, uid), E_UID_NOT_FOUND);
        let nft_address = table::borrow(&registry.uid_to_nft, uid);
        let uid_nft = borrow_uid_nft(nft_address);
        assert!(vec_map::contains(&uid_nft.addresses, &network), E_INVALID_ADDRESS);
        (*nft_address, vec_map::get(&uid_nft.addresses, &network))
    }

    /// Add new address to existing UID
    public entry fun add_address(
        registry: &UIDRegistry,
        uid: String,
        network: String,
        address: String,
        ctx: &mut TxContext
    ) {
        assert!(table::contains(&registry.uid_to_nft, uid), E_UID_NOT_FOUND);
        let nft_address = table::borrow(&registry.uid_to_nft, uid);
        let uid_nft = borrow_uid_nft_mut(nft_address);
        
        let sender = tx_context::sender(ctx);
        assert!(uid_nft.owner == sender, E_NOT_OWNER);

        vec_map::insert(&mut uid_nft.addresses, network, address);
        event::emit(AddressAdded {
            uid,
            network,
            address
        });
    }

    /// Helper to get UIDNFT reference
    fun borrow_uid_nft(nft_address: &address): &UIDNFT {
        let object = object::borrow<UIDNFT>(*nft_address);
        object
    }

    /// Helper to get mutable UIDNFT reference
    fun borrow_uid_nft_mut(nft_address: &address): &mut UIDNFT {
        let object = object::borrow_mut<UIDNFT>(*nft_address);
        object
    }
}