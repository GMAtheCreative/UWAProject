import { UidModel, validateUidModel, Blockchain } from '../../../../src/data/uid/model';
import { AddressMapping } from '../../../../src/data/addressMapping/model';

describe('UidModel', () => {
  let validUid: UidModel;

  beforeEach(() => {
    validUid = {
      uid: 'johndoe.mask',
      walletId: 'mask',
      username: 'johndoe',
      addresses: [
        { chain: Blockchain.Ethereum, address: '0x1234567890abcdef1234567890abcdef12345678' },
        { chain: Blockchain.Bitcoin, address: '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa' },
      ],
      createdAt: new Date(),
    };
  });

  describe('validateUidModel', () => {
    it('should pass for a valid UidModel', () => {
      expect(() => validateUidModel(validUid)).not.toThrow();
    });

    it('should throw for invalid uid format', () => {
      const invalidUid = { ...validUid, uid: 'johndoe_invalid' };
      expect(() => validateUidModel(invalidUid)).toThrow('Invalid UID format. Expected "username.wallet"');
    });

    it('should throw for uid not matching username and walletId', () => {
      const invalidUid = { ...validUid, uid: 'janedoe.mask' };
      expect(() => validateUidModel(invalidUid)).toThrow('Username must match UID prefix');
    });

    it('should throw for invalid walletId format', () => {
      const invalidUid = { ...validUid, walletId: 'mask123' };
      expect(() => validateUidModel(invalidUid)).toThrow('Invalid wallet ID format');
    });

    it('should throw for invalid blockchain in addresses', () => {
      const invalidUid = {
        ...validUid,
        addresses: [{ chain: 'invalid' as Blockchain, address: '0x1234567890abcdef1234567890abcdef12345678' }],
      };
      expect(() => validateUidModel(invalidUid)).toThrow('Invalid blockchain in address mappings');
    });

    it('should pass for empty addresses array', () => {
      const validEmptyAddresses = { ...validUid, addresses: [] };
      expect(() => validateUidModel(validEmptyAddresses)).not.toThrow();
    });

    it('should throw for non-array addresses', () => {
      const invalidUid = { ...validUid, addresses: 'not an array' as any };
      expect(() => validateUidModel(invalidUid)).toThrow('Invalid addresses format');
    });
  });

  describe('Blockchain Enum', () => {
    it('should contain supported blockchains', () => {
      expect(Blockchain.Ethereum).toBe('ethereum');
      expect(Blockchain.Bitcoin).toBe('bitcoin');
    });
  });
});
// ```