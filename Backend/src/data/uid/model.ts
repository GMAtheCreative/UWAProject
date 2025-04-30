import { AddressMapping } from '../addressMapping/model';

/**
 * Supported blockchain networks for address mappings.
 */
export enum Blockchain {
  Ethereum = 'ethereum',
  Sui = 'sui',
}

/**
 * Represents a Universal Identifier (UID) and its metadata.
 */
export interface UidModel {
  /**
   * Full UID, e.g., "johndoe.mask".
   */
  uid: string;

  /**
   * Wallet identifier, e.g., "mask".
   */
  walletId: string;

  /**
   * Username portion of the UID, e.g., "johndoe".
   */
  username: string;

  /**
   * List of blockchain address mappings.
   */
  addresses: AddressMapping[];

  /**
   * Timestamp when the UID was created.
   */
  createdAt: Date;
}

/**
 * Validates a UidModel instance.
 * @param uid - The UidModel to validate.
 * @throws Error if validation fails.
 */
export function validateUidModel(uid: UidModel): void {
  if (!uid.uid.match(/^[a-z0-9]+\.[a-z]+$/)) {
    throw new Error('Invalid UID format. Expected "username.wallet"');
  }
  if (uid.username !== uid.uid.split('.')[0]) {
    throw new Error('Username must match UID prefix');
  }
  if (!uid.walletId.match(/^[a-z]+$/)) {
    throw new Error('Invalid wallet ID format');
  }
  if (!Array.isArray(uid.addresses)) {
    throw new Error('Invalid addresses format');
  }
  if (uid.addresses.some((a) => !Object.values(Blockchain).includes(a.chain))) {
    throw new Error('Invalid blockchain in address mappings');
  }
  if (uid.addresses.some((a) => !a.address.match(/^0x[a-fA-F0-9]+$/))) {
    throw new Error('Invalid address format');
  }
}