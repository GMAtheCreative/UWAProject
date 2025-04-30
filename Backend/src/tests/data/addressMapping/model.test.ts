import { AddressMapping } from '../../../../src/data/addressMapping';
import { Blockchain } from '../../../../src/data/uid';

describe('AddressMapping', () => {
  let validAddressMapping: AddressMapping;

  beforeEach(() => {
    validAddressMapping = {
      chain: Blockchain.Ethereum,
      address: '0x1234567890abcdef1234567890abcdef12345678',
    };
  });

  it('should allow valid Ethereum address mapping', () => {
    expect(validAddressMapping.chain).toBe(Blockchain.Ethereum);
    expect(validAddressMapping.address).toBe('0x1234567890abcdef1234567890abcdef12345678');
  });

  it('should allow valid Sui address mapping', () => {
    const suiMapping: AddressMapping = {
      chain: Blockchain.Sui,
      address: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
    };
    expect(suiMapping.chain).toBe(Blockchain.Sui);
    expect(suiMapping.address).toBe('0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890');
  });

  it('should allow creation without validation', () => {
    const invalidMapping: AddressMapping = {
      chain: 'invalid' as Blockchain,
      address: 'invalid',
    };
    expect(invalidMapping.chain).toBe('invalid');
    expect(invalidMapping.address).toBe('invalid');
    // Note: Address format validation is handled by validateUidModel or WalletService
  });
});