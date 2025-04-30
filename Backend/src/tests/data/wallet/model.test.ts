import { WalletModel, validateWalletModel, } from '../../../../src/data/wallet/model';
import {Blockchain} from '../../../../src/data/uid/model'

describe('WalletModel', () => {
  let validWallet: WalletModel;

  beforeEach(() => {
    validWallet = {
      walletId: 'mask',
      name: 'MetaMask',
      supportedChains: [Blockchain.Ethereum, Blockchain.Sui],
      apiEndpoint: 'https://api.metamask.io',
      createdAt: new Date(),
    };
  });

  describe('validateWalletModel', () => {
    it('should pass for a valid WalletModel', () => {
      expect(() => validateWalletModel(validWallet)).not.toThrow();
    });

    it('should pass for WalletModel without apiEndpoint', () => {
      const validNoEndpoint = { ...validWallet, apiEndpoint: undefined };
      expect(() => validateWalletModel(validNoEndpoint)).not.toThrow();
    });

    it('should throw for invalid walletId format', () => {
      const invalidWallet = { ...validWallet, walletId: 'mask123' };
      expect(() => validateWalletModel(invalidWallet)).toThrow('Invalid wallet ID format');
    });

    it('should throw for invalid name format', () => {
      const invalidWallet = { ...validWallet, name: 'MetaMask123' };
      expect(() => validateWalletModel(invalidWallet)).toThrow('Invalid wallet name format');
    });

    it('should throw for invalid supported chains', () => {
      const invalidWallet = { ...validWallet, supportedChains: ['invalid' as Blockchain] };
      expect(() => validateWalletModel(invalidWallet)).toThrow('Invalid supported chains');
    });

    it('should throw for non-array supported chains', () => {
      const invalidWallet = { ...validWallet, supportedChains: 'invalid' as any };
      expect(() => validateWalletModel(invalidWallet)).toThrow('Invalid supported chains');
    });

    it('should pass for empty supported chains', () => {
      const validEmptyChains = { ...validWallet, supportedChains: [] };
      expect(() => validateWalletModel(validEmptyChains)).not.toThrow();
    });
  });
});