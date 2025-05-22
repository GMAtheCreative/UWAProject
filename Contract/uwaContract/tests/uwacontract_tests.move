// #[test_only]
// module uwacontract::uidregistry_tests {
//     use sui::tx_context;
//     use std::string::{Self, String};
//     use std::option;
//     use sui::table;
//     use uwacontract::uwacontract::{
//         create_registry, set_addresses,
//         get_userUid, get_address, get_uid,
//         EUID_ALREADY_EXISTS
//     };
//     use uwacontract::uid_helpers::{new_directory, new_registry};

//     #[test]
//     public fun test_create_directory() {
//         let mut ctx = tx_context::new();
//         let directory = new_directory(&mut ctx);
//         assert!(table::length(&directory.user_uids) == 0, b"Directory should be empty on creation");
//     }

//     #[test]
//     public fun test_create_registry_success() {
//         let mut ctx = tx_context::new();
//         let mut directory = new_directory(&mut ctx);
//         let user_uid = string::utf8(b"user123");

//         create_registry(&mut directory, user_uid.clone(), &mut ctx);
//         assert!(table::contains(&directory.user_uids, user_uid), b"UID should be added to directory");
//     }

//     #[test]
//     public fun test_duplicate_registry_creation_fails() {
//         let mut ctx = tx_context::new();
//         let mut directory = new_directory(&mut ctx);
//         let user_uid = string::utf8(b"user123");

//         create_registry(&mut directory, user_uid.clone(), &mut ctx);
//         assert_abort!(create_registry(&mut directory, user_uid.clone(), &mut ctx), EUID_ALREADY_EXISTS);
//     }

//     #[test]
//     public fun test_set_addresses() {
//         let mut ctx = tx_context::new();
//         let mut registry = new_registry(string::utf8(b"user123"), &mut ctx);

//         let network = string::utf8(b"Ethereum");
//         let address = string::utf8(b"0x123456");

//         set_addresses(&mut registry, network.clone(), address.clone());

//         let stored = get_address(&registry, network).expect();
//         assert_eq!(stored, address, b"Stored address did not match");
//     }

//     #[test]
//     public fun test_get_userUid() {
//         let mut ctx = tx_context::new();
//         let uid = string::utf8(b"user999");
//         let registry = new_registry(uid.clone(), &mut ctx);

//         let got = get_userUid(&registry);
//         assert_eq!(got, uid, b"Returned UID did not match");
//     }

//     #[test]
//     public fun test_get_address_found_and_not_found() {
//         let mut ctx = tx_context::new();
//         let mut registry = new_registry(string::utf8(b"user456"), &mut ctx);

//         let network = string::utf8(b"Solana");
//         let address = string::utf8(b"0xSOL123");
//         set_addresses(&mut registry, network.clone(), address.clone());

//         let found = get_address(&registry, network.clone()).expect();
//         assert_eq!(found, address, b"Address should be found");

//         let missing = get_address(&registry, string::utf8(b"Polygon"));
//         assert!(option::is_none(&missing), b"Expected None for missing network");
//     }

//     #[test]
//     public fun test_get_uid() {
//         let mut ctx = tx_context::new();
//         let registry = new_registry(string::utf8(b"user789"), &mut ctx);
//         let uid = get_uid(&registry);

//         assert!(!uid.id.id.bytes == object::new(&ctx).id.bytes, b"UID reference check failed");
//     }
// }
