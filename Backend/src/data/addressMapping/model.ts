import { Blockchain } from '../uid/model';

/**
 * Represents a blockchain address mapping for a UID.
 */
export interface AddressMapping {
  /**
   * Blockchain network, e.g., "ethereum".
   */
  chain: Blockchain;

  /**
   * Address on the blockchain, e.g., "0x1234567890abcdef1234567890abcdef12345678".
   */
  address: string;
}