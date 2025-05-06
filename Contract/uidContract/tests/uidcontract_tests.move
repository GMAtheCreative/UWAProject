#[test_only]
module uidcontract::uidcontract_tests {
    use sui::tx_context::TxContext;
    use sui::vector;
    use sui::string;
    use sui::object;
    use sui::test_scenario;
    use uidcontract::uidcontract;

    #[test]
    public fun test_user_registration() {
        let mut scenario = test_scenario::begin();
        let mut ctx = TxContext::empty();

        // Initialize the UID registry
        uidcontract::init_registry(&mut ctx);
        let registry = test_scenario::take_from_sender<uidcontract::UidRegistry>(&mut scenario);

        // Register user
        let uid = string::utf8(b"Tim123");
        let addresses = vector::from_array([string::utf8(b"0xABC"), string::utf8(b"0xDEF")]);
        let result = uidcontract::register_user(uid, addresses, &mut registry, &mut ctx);

        test_scenario::return_to_sender(registry, &mut scenario);

        assert!(object::exists(result), b"UID NFT not created");
    }

    #[test]
    public fun test_duplicate_registration_fails() {
        let mut scenario = test_scenario::begin();
        let mut ctx = TxContext::empty();

        // Init registry and register user
        uidcontract::init_registry(&mut ctx);
        let mut registry = test_scenario::take_from_sender<uidcontract::UidRegistry>(&mut scenario);

        let uid = string::utf8(b"Tim123");
        let addresses = vector::from_array([string::utf8(b"0xABC")]);

        uidcontract::register_user(uid.clone(), addresses, &mut registry, &mut ctx);

        // Try registering same UID again
        let second_result = uidcontract::register_user(uid.clone(), vector::empty(), &mut registry, &mut ctx);
        // Should abort before this line
        assert!(false, b"Duplicate UID registration did not abort");
    }

    #[test]
    public fun test_register_multiple_unique_uids() {
        let mut scenario = test_scenario::begin();
        let mut ctx = TxContext::empty();

        uidcontract::init_registry(&mut ctx);
        let mut registry = test_scenario::take_from_sender<uidcontract::UidRegistry>(&mut scenario);

        let uid1 = string::utf8(b"Tim123");
        let uid2 = string::utf8(b"Alex999");

        let addr1 = vector::from_array([string::utf8(b"0xAAA")]);
        let addr2 = vector::from_array([string::utf8(b"0xBBB")]);

        let res1 = uidcontract::register_user(uid1, addr1, &mut registry, &mut ctx);
        let res2 = uidcontract::register_user(uid2, addr2, &mut registry, &mut ctx);

        assert!(object::exists(res1), b"UID 1 not created");
        assert!(object::exists(res2), b"UID 2 not created");
    }
}
