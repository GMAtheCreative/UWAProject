#[test_only]
#[allow(unused_use, unused_const)]
module uidcontract::uidcontract_test {
    use sui::test_scenario;
    use std::string::{Self, String};
    use uidcontract::uidcontract::{Self, UIDRegistry, UserID, register_uid, resolve_address, update_address, get_uid_nft, get_addresses};

    // Error codes
    const E_UID_TAKEN: u64 = 1000;
    const E_NOT_OWNER: u64 = 1004;

    // Helper to setup scenario
    fun setup_scenario(): test_scenario::Scenario {
        test_scenario::begin(@0x1)
    }

    // Test Unique UID Validation
    #[test]
    fun test_duplicate_uid_minting() {
        let mut scenario = setup_scenario();
        let sender = @0x1;

        test_scenario::next_tx(&mut scenario, sender);
        let uid = string::utf8(b"johndoe.mask");
        let chains = vector[string::utf8(b"ethereum")];
        let addresses = vector[string::utf8(b"0x1234567890abcdef")];

        let mut registry = test_scenario::take_shared<UIDRegistry>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        register_uid(&mut registry, uid, chains, addresses, ctx);
        test_scenario::return_shared(registry);

        test_scenario::next_tx(&mut scenario, sender);
        let mut registry = test_scenario::take_shared<UIDRegistry>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        register_uid(&mut registry, uid, chains, addresses, ctx);
        assert!(get_uid_nft(&registry, uid) != @0x0, E_UID_TAKEN);
        test_scenario::return_shared(registry);

        test_scenario::end(scenario);
    }

    // Test Updating Addresses
    #[test]
    fun test_update_uid_address() {
        let mut scenario = setup_scenario();
        let sender = @0x1;

        test_scenario::next_tx(&mut scenario, sender);
        let uid = string::utf8(b"johndoe.mask");
        let chains = vector[string::utf8(b"ethereum")];
        let addresses = vector[string::utf8(b"0x1234567890abcdef")];

        let mut registry = test_scenario::take_shared<UIDRegistry>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        register_uid(&mut registry, uid, chains, addresses, ctx);
        test_scenario::return_shared(registry);

        test_scenario::next_tx(&mut scenario, sender);
        let mut user_id = test_scenario::take_from_address<UserID>(&scenario, sender);
        let ctx = test_scenario::ctx(&mut scenario);
        update_address(&mut user_id, string::utf8(b"bitcoin"), string::utf8(b"bc1xyz0987abcdef"), ctx);
        assert!(resolve_address(&user_id, string::utf8(b"bitcoin")) == string::utf8(b"bc1xyz0987abcdef"), E_NOT_OWNER);
        test_scenario::return_to_address(sender, user_id);

        test_scenario::end(scenario);
    }
}