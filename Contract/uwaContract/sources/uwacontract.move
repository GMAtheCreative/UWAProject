module uwacontract::uwacontract {
    use sui::object;
    use sui::tx_context;
    use sui::transfer;
    use sui::event;
    use sui::url;
    use std::vector;
    use std::string;
    use std::option;

    // One-time witness for module initialization
    public struct UWACONTRACT has drop {}

    public struct NetworkAddress has store, drop {
        name: string::String,
        address: string::String,
    }

    public struct WalletData has store, drop {
        name: string::String,
        networks: vector<NetworkAddress>,
    }

    /// NFT struct: only id and uid_name
    public struct UserProfileNft has key, store {
        id: object::UID,
        uid_name: string::String,
    }

    /// Stores all extra user data, linked to NFT by ID
    public struct UserProfileData has key, store {
        id: object::UID,
        nft_id: object::ID,
        sui_wallet_address: address,
        wallets: vector<WalletData>,
        image_url: option::Option<url::Url>,
    }

    /// Event for backend notification
    public struct ProfileNftMinted has copy, drop {
        object_id: object::ID,
        creator: address,
        recipient: address,
        uid_name: string::String,
    }

    /// Mint NFT and store user data
    public entry fun mint_profile_nft(
        uid_name_bytes: vector<u8>,
        sui_wallet_address: address,
        wallet_names_bytes: vector<vector<u8>>,
        network_data_bytes: vector<vector<vector<vector<u8>>>>,
        image_url_str: vector<u8>,
        ctx: &mut tx_context::TxContext
    ) {
        let uid_name_str = string::utf8(uid_name_bytes);

        // Mint NFT (only id and uid_name)
        let nft = UserProfileNft {
            id: object::new(ctx),
            uid_name: uid_name_str,
        };
        let nft_id = object::id(&nft);

        // Build wallets data
        let mut wallets: vector<WalletData> = vector::empty();
        let mut i = 0;
        while (i < vector::length(&wallet_names_bytes)) {
            let wallet_name = string::utf8(*vector::borrow(&wallet_names_bytes, i));
            let mut networks: vector<NetworkAddress> = vector::empty();
            let network_vec = *vector::borrow(&network_data_bytes, i);
            let mut j = 0;
            while (j < vector::length(&network_vec)) {
                let network = *vector::borrow(&network_vec, j);
                let network_name = string::utf8(*vector::borrow(&network, 0));
                let network_addr = string::utf8(*vector::borrow(&network, 1));
                vector::push_back(&mut networks, NetworkAddress {
                    name: network_name,
                    address: network_addr,
                });
                j = j + 1;
            };
            vector::push_back(&mut wallets, WalletData {
                name: wallet_name,
                networks,
            });
            i = i + 1;
        };

        // Build image_url option (CORRECTED)
        let image_url_opt = if (vector::length(&image_url_str) > 0) {
            option::some(url::new_unsafe_from_bytes(image_url_str))
        } else {
            option::none<url::Url>()
        };

        // Store user data object and transfer to user
        let user_data = UserProfileData {
            id: object::new(ctx),
            nft_id,
            sui_wallet_address,
            wallets,
            image_url: image_url_opt,
        };
        transfer::public_transfer(user_data, sui_wallet_address);

        // Transfer NFT to user
        transfer::public_transfer(nft, sui_wallet_address);

        // Emit event for backend
        event::emit(ProfileNftMinted {
            object_id: nft_id,
            creator: tx_context::sender(ctx),
            recipient: sui_wallet_address,
            uid_name: uid_name_str,
        });
    }
}
