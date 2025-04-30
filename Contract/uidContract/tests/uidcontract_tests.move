#[test_only]
#[allow(duplicate_alias, unused_use, unused_mut_ref, unused_const)]
module uidcontract::uidcontract_test {
    use sui::test_scenario;
    use std::string::{Self, String};
    use std::vector;
    use uidcontract::uidcontract::{Self, UIDRegistry, UserID, new_uid_registry, share_uid_registry, register_uid, resolve_address, update_address, get_uid_nft};

    // Error codes
    const E_UID_TAKEN: u64 = 1000;
    const E_INVALID_NFT_ADDRESS: u64 = 1;
    const E_WRONG_ADDRESS: u64 = 2;
    const E_NOT_OWNER: u64 = 1004;

    // Helper to setup scenario
    fun setup_scenario(): test_scenario::Scenario {
        test_scenario::begin(@0x1)
    }

    // Helper to mint UID
    fun mint_uid(scenario: &mut test_scenario::Scenario, uid: String, chains: vector<String>, addresses: vector<String>, sender: address) {
        test_scenario::next_tx(scenario, sender);
        {
            let mut registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            register_uid(&mut registry, uid, chains, addresses, ctx);
            test_scenario::return_shared(registry);
        };
    }

    #[test]
    fun test_register_uid() {
        let mut scenario = setup_scenario();
        let sender = @0x1;

        // Initialize registry
        test_scenario::next_tx(&mut scenario, sender);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let registry = new_uid_registry(ctx);
            share_uid_registry(registry);
        };

        // Mint UID
        let uid = string::utf8(b"johndoe.mask");
        let chains = vector[string::utf8(b"ethereum")];
        let addresses = vector[string::utf8(b"0x1234567890abcdef1234567890abcdef12345678")];
        mint_uid(&mut scenario, uid, chains, addresses, sender);

        // Verify NFT address
        test_scenario::next_tx(&mut scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(&scenario);
            let nft_address = get_uid_nft(&registry, uid);
            assert!(nft_address != @0x0, E_INVALID_NFT_ADDRESS);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_resolve_address() {
        let mut scenario = setup_scenario();
        let sender = @0x1;

        // Initialize registry
        test_scenario::next_tx(&mut scenario, sender);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let registry = new_uid_registry(ctx);
            share_uid_registry(registry);
        };

        // Mint UID
        let uid = string::utf8(b"johndoe.mask");
        let chains = vector[string::utf8(b"ethereum")];
        let addresses = vector[string::utf8(b"0x1234567890abcdef1234567890abcdef12345678")];
        mint_uid(&mut scenario, uid, chains, addresses, sender);

        // Resolve address
        test_scenario::next_tx(&mut scenario, sender);
        {
            let user_id = test_scenario::take_from_address<UserID>(&scenario, sender);
            let resolved = resolve_address(&user_id, string::utf8(b"ethereum"));
            assert!(resolved == string::utf8(b"0x1234567890abcdef1234567890abcdef12345678"), E_WRONG_ADDRESS);
            test_scenario::return_to_address(sender, user_id);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_address() {
        let mut scenario = setup_scenario();
        let sender = @0x1;

        // Initialize registry
        test_scenario::next_tx(&mut scenario, sender);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let registry = new_uid_registry(ctx);
            share_uid_registry(registry);
        };

        // Mint UID
        let uid = string::utf8(b"johndoe.mask");
        let chains = vector[string::utf8(b"ethereum")];
        let addresses = vector[string::utf8(b"0x1234567890abcdef1234567890abcdef12345678")];
        mint_uid(&mut scenario, uid, chains, addresses, sender);

        // Update address
        test_scenario::next_tx(&mut scenario, sender);
        {
            let mut user_id = test_scenario::take_from_address<UserID>(&scenario, sender);
            let ctx = test_scenario::ctx(&mut scenario);
            update_address(&mut user_id, string::utf8(b"bitcoin"), string::utf8(b"bc1qxyz7890abcdef1234567890abcdef12345678"), ctx);
            let resolved = resolve_address(&user_id, string::utf8(b"bitcoin"));
            assert!(resolved == string::utf8(b"bc1qxyz7890abcdef1234567890abcdef12345678"), E_WRONG_ADDRESS);
            test_scenario::return_to_address(sender, user_id);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = uidcontract::uidcontract::E_UID_TAKEN)]
    fun test_duplicate_uid() {
        let mut scenario = setup_scenario();
        let sender = @0x1;

        // Initialize registry
        test_scenario::next_tx(&mut scenario, sender);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let registry = new_uid_registry(ctx);
            share_uid_registry(registry);
        };

        // Mint UID
        let uid = string::utf8(b"johndoe.mask");
        let chains = vector[string::utf8(b"ethereum")];
        let addresses = vector[string::utf8(b"0x1234567890abcdef1234567890abcdef12345678")];
        mint_uid(&mut scenario, uid, chains, addresses, sender);

        // Try to mint same UID
        mint_uid(&mut scenario, uid, chains, addresses, sender);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = uidcontract::uidcontract::E_NOT_OWNER)]
    fun test_update_address_not_owner() {
        let mut scenario = setup_scenario();
        let sender = @0x1;
        let non_owner = @0x2;

        // Initialize registry
        test_scenario::next_tx(&mut scenario, sender);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let registry = new_uid_registry(ctx);
            share_uid_registry(registry);
        };

        // Mint UID
        let uid = string::utf8(b"johndoe.mask");
        let chains = vector[string::utf8(b"ethereum")];
        let addresses = vector[string::utf8(b"0x1234567890abcdef1234567890abcdef12345678")];
        mint_uid(&mut scenario, uid, chains, addresses, sender);

        // Try to update as non-owner
        test_scenario::next_tx(&mut scenario, non_owner);
        {
            let mut user_id = test_scenario::take_from_address<UserID>(&scenario, sender);
            let ctx = test_scenario::ctx(&mut scenario);
            update_address(&mut user_id, string::utf8(b"bitcoin"), string::utf8(b"bc1qxyz7890abcdef1234567890abcdef12345678"), ctx);
            test_scenario::return_to_address(sender, user_id);
        };

        test_scenario::end(scenario);
    }
}