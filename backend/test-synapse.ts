import { Synapse } from '@filoz/synapse-sdk';
import { createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { filecoinCalibration } from 'viem/chains';

const account = privateKeyToAccount('0x952163c7529521e451c0eb03afa0a49e596d418a30fa926530a023b7e2f23fe8');

async function test() {
  const synapse = Synapse.create({ account, chain: filecoinCalibration, transport: http() });
  console.log(Object.keys(synapse));
  if (synapse.payment) {
      console.log('Payment:', Object.keys(synapse.payment));
  }
  if (synapse.storage) {
      console.log('Storage:', Object.keys(synapse.storage));
  }
}

test().catch(console.error);
