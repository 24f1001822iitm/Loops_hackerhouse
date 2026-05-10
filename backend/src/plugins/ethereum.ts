import fp from 'fastify-plugin';
import { FastifyInstance } from 'fastify';
import { createPublicClient, createWalletClient, http, type Address, type PublicClient, type WalletClient, type Transport, type Chain, type Account } from 'viem';
import { baseSepolia } from 'viem/chains';
import { privateKeyToAccount } from 'viem/accounts';
import { config } from '../config/environment.js';

declare module 'fastify' {
  interface FastifyInstance {
    ethereum: {
      publicClient: PublicClient;
      walletClient: WalletClient<Transport, Chain, Account> | null;
      account: Address | null;
    };
  }
}

export default fp(async function ethereumPlugin(fastify: FastifyInstance) {
  const publicClient = createPublicClient({
    chain: baseSepolia,
    transport: http(config.baseSepoliaRpcUrl),
  });
  let walletClient: WalletClient<Transport, Chain, Account> | null = null;
  let account: Address | null = null;
  if (config.agentPrivateKey) {
    const agentAccount = privateKeyToAccount(config.agentPrivateKey as Address);
    account = agentAccount.address;
    walletClient = createWalletClient({
      account: agentAccount,
      chain: baseSepolia,
      transport: http(config.baseSepoliaRpcUrl),
    });
  }

  fastify.decorate('ethereum', { publicClient, walletClient, account } as any);
}, {
  name: 'ethereum',
});
