class BlockchainConfig {
  // Ethereum networks - Use a free public RPC URL for development
  static const String mainnetRpcUrl = 'https://eth.llamarpc.com';
  static const String sepoliaRpcUrl = 'https://rpc.sepolia.org';
  static const String goerliRpcUrl = 'https://eth-goerli.public.blastapi.io';
  
  // Network IDs
  static const int mainnetChainId = 1;
  static const int sepoliaChainId = 11155111;
  static const int goerliChainId = 5;
  
  // Default network to use
  static const String defaultRpcUrl = sepoliaRpcUrl;
  static const int defaultChainId = sepoliaChainId;
  
  // Contract addresses for digital identity
  static const String identityContractAddress = '0x0000000000000000000000000000000000000000'; // Replace with actual contract address
  
  // Gas limits and prices
  static const int defaultGasLimit = 500000;
  static final BigInt defaultMaxPriorityFeePerGas = BigInt.from(3000000000); // 3 gwei
  static final BigInt defaultMaxFeePerGas = BigInt.from(30000000000); // 30 gwei
  
  // Wallet settings
  static const String walletStorageKey = 'encrypted_wallet';
  static const String mnemonicPhraseKey = 'mnemonic_backup';
  static const int mnemonicStrength = 128; // 12 words
}
