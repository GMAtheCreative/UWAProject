#[test_only]
module uidcontract::uidcontract_tests {
    use sui::test_scenario;
    use sui::object;
    use std::string;
    use std::vector;
    use uidcontract::uidcontract::{Self, UIDRegistry};

    #[test]
    fun test_register_uid() {
        let scenario_val = test_scenario::begin(@0x1);
        let scenario = &mut scenario_val;
        let sender = @0x1;
        let uid = string::utf8(b"alice.sui");
        let networks = vector[string::utf8(b"sui"), string::utf8(b"eth")];
        let addresses = vector[
            string::utf8(b"0xsui123"),
            string::utf8(b"0xeth456")
        ];

        // Initialize registry
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::register_uid(&mut registry, uid, networks, addresses, ctx);
            test_scenario::return_shared(registry);
        };

        // Verify registration
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let (nft_address, addr_map) = uidcontract::get_all_addresses(&registry, uid);
            assert!(&nft_address != &@0x0, 0);
            assert!(vector::length(vec_map::keys(addr_map)) == 2, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = 1000)]
    fun test_duplicate_uid() {
        let scenario_val = test_scenario::begin(@0x1);
        let scenario = &mut scenario_val;
        let sender = @0x1;
        let uid = string::utf8(b"bob.sui");
        let networks = vector[string::utf8(b"sui")];
        let addresses = vector[string::utf8(b"0xsui789")];

        // First registration
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::register_uid(&mut registry, uid, networks, addresses, ctx);
            test_scenario::return_shared(registry);
        };

        // Attempt duplicate (should fail)
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::register_uid(&mut registry, uid, networks, addresses, ctx);
            test_scenario::return_shared(registry);
        };
    }

    #[test]
    fun test_add_address() {
        let scenario_val = test_scenario::begin(@0x1);
        let scenario = &mut scenario_val;
        let sender = @0x1;
        let uid = string::utf8(b"charlie.sui");
        let networks = vector[string::utf8(b"sui")];
        let addresses = vector[string::utf8(b"0xsui456")];

        // Register UID
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::register_uid(&mut registry, uid, networks, addresses, ctx);
            test_scenario::return_shared(registry);
        };

        // Add new address
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::add_address(
                &registry,
                uid,
                string::utf8(b"btc"),
                string::utf8(b"1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"),
                ctx
            );
            test_scenario::return_shared(registry);
        };

        // Verify new address
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let (_, addr_map) = uidcontract::get_all_addresses(&registry, uid);
            assert!(vector::length(vec_map::keys(addr_map)) == 2, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = 1004)]
    fun test_unauthorized_add_address() {
        let scenario_val = test_scenario::begin(@0x1);
        let scenario = &mut scenario_val;
        let sender1 = @0x1;
        let sender2 = @0x2;
        let uid = string::utf8(b"dave.sui");
        let networks = vector[string::utf8(b"sui")];
        let addresses = vector[string::utf8(b"0xsui789")];

        // Register UID with sender1
        test_scenario::next_tx(scenario, sender1);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::register_uid(&mut registry, uid, networks, addresses, ctx);
            test_scenario::return_shared(registry);
        };

        // Attempt to add address with sender2 (should fail)
        test_scenario::next_tx(scenario, sender2);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::add_address(
                &registry,
                uid,
                string::utf8(b"eth"),
                string::utf8(b"0xeth123"),
                ctx
            );
        };
    }

    #[test]
    fun test_get_specific_address() {
        let scenario_val = test_scenario::begin(@0x1);
        let scenario = &mut scenario_val;
        let sender = @0x1;
        let uid = string::utf8(b"eve.sui");
        let networks = vector[string::utf8(b"sui"), string::utf8(b"eth")];
        let addresses = vector[
            string::utf8(b"0xsui123"),
            string::utf8(b"0xeth456")
        ];

        // Register UID
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let ctx = test_scenario::ctx(scenario);
            uidcontract::register_uid(&mut registry, uid, networks, addresses, ctx);
            test_scenario::return_shared(registry);
        };

        // Get specific address
        test_scenario::next_tx(scenario, sender);
        {
            let registry = test_scenario::take_shared<UIDRegistry>(scenario);
            let (_, eth_addr) = uidcontract::get_address(
                &registry,
                uid,
                string::utf8(b"eth")
            );
            assert!(eth_addr == &string::utf8(b"0xeth456"), 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario_val);
    }
}