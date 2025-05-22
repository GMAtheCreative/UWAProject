// module uwacontract::uid_helpers {
//     use sui::object;
//     use sui::tx_context::{Self, TxContext};
//     use sui::table::{Self, Table};
//     use std::string::String;
//     use uwacontract::uwacontract::{UidDirectory, UidRegistry};

//     /// Helper to create a UidDirectory for testing
//     public fun new_directory(ctx: &mut TxContext): UidDirectory {
//         let id = object::new(ctx);
//         let map = Table::new<String, address>(ctx);
//         UidDirectory { id, user_uids: map }
//     }

//     /// Helper to create a UidRegistry for testing
//     public fun new_registry(uid: String, ctx: &mut TxContext): UidRegistry {
//         let id = object::new(ctx);
//         let addresses = Table::new<String, String>(ctx);
//         UidRegistry { id, userUid: uid, addresses }
//     }
// }