// #[test_only]
// module uwacontract::uidregistry_tests {
//     use sui::tx_context::TxContext;
//     use uwacontract::uwacontract;
//     use sui::storage::Table;

//     #[test]
//     public fun test_create_registry() {
//         let ctx = TxContext::empty();
//         let user_uid = "Tim123";

//         let registry_id = uwacontract::create_registry(user_uid, &mut ctx);
//         assert!(object::exists(registry_id), "Registry should be created");
//     }

//     #[test]
//     public fun test_get_userId() {
//         let ctx = TxContext::empty();
//         let user_uid = "Tim123";

//         let registry_id = uwacontract::create_registry(user_uid, &mut ctx);
//         let registry = object::borrow<uwacontract::UidRegistry>(registry_id);

//         let retrieved_uid = uwacontract::get_userId(&registry);
//         assert!(retrieved_uid == user_uid, "User UID should match");
//     }

//     #[test]
//     public fun test_add_address() {
//         let ctx = TxContext::empty();
//         let user_uid = "Tim123";

//         let registry_id = uwacontract::create_registry(user_uid, &mut ctx);
//         let registry = object::borrow_mut<uwacontract::UidRegistry>(registry_id);

//         uwacontract::set_addresses(&mut registry, "Sui", "0xABC");

//         let stored_address = uwacontract::get_address(&registry, "Sui");
//         assert!(stored_address == "0xABC", "Address should be stored correctly");
//     }

//     #[test]
//     public fun test_get_uid() {
//         let ctx = TxContext::empty();
//         let user_uid = "Tim123";

//         let registry_id = uwacontract::create_registry(user_uid, &mut ctx);
//         let registry = object::borrow<uwacontract::UidRegistry>(registry_id);

//         let retrieved_uid = uwacontract::get_uid(&registry);
//         assert!(retrieved_uid == registry.id, "Blockchain UID should match");
//     }
// }