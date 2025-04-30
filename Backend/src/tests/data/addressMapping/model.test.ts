import { AddressMapping } from '../../../../src/data/addressMapping/model';
import { Blockchain } from '../../../../src/data/uid/model';

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

  it('should allow valid Bitcoin address mapping', () => {
    const bitcoinMapping: AddressMapping = {
      chain: Blockchain.Bitcoin,
      address: '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
    };
    expect(bitcoinMapping.chain).toBe(Blockchain.Bitcoin);
    expect(bitcoinMapping.address).toBe('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa');
  });

  it('should allow creation without validation', () => {
    const invalidMapping: AddressMapping = {
      chain: 'invalid' as Blockchain,
      address: 'invalid',
    };
    expect(invalidMapping.chain).toBe('invalid');
    expect(invalidMapping.address).toBe('invalid');
  });
});