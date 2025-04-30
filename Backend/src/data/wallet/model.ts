import { Blockchain } from '../uid/model';

/**
 * Represents a wallet type and its metadata.
 */
export interface WalletModel {
  /**
   * Wallet identifier, e.g., "mask", "trust".
   */
  walletId: string;

  /**
   * Human-readable wallet name, e.g., "MetaMask".
   */
  name: string;

  /**
   * Supported blockchain networks.
   */
  supportedChains: Blockchain[];

  /**
   * Optional API endpoint for wallet integration.
   */
  apiEndpoint?: string;

  /**
   * Timestamp when the wallet type was added.
   */
  createdAt: Date;
}

/**
 * Validates a WalletModel instance.
 * @param wallet - The WalletModel to validate.
 * @throws Error if validation fails.
 */
export function validateWalletModel(wallet: WalletModel): void {
  if (!wallet.walletId.match(/^[a-z]+$/)) {
    throw new Error('Invalid wallet ID format');
  }
  if (!wallet.name.match(/^[A-Za-z ]+$/)) {
    throw new Error('Invalid wallet name format');
  }
  if (!Array.isArray(wallet.supportedChains) || wallet.supportedChains.some((c) => !Object.values(Blockchain).includes(c))) {
    throw new Error('Invalid supported chains');
  }
}