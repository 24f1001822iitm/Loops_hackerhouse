-- ============================================
-- Migration 0003: ClaimVault + ERC-8004 supporting tables
-- - agent_registrations : one row per ERC-8004 agent NFT
-- - filecoin_uploads    : per-claim Synapse/FOC upload + PDP tracking
-- - evidence_bundles    : canonical JSON bundle hashed and attested
-- ============================================

-- pgcrypto is assumed enabled (existing tables use gen_random_uuid()).
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. ERC-8004 Agent Registrations
CREATE TABLE IF NOT EXISTS agent_registrations (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id                  BIGINT UNIQUE NOT NULL,        -- ERC-8004 NFT id
  agent_card_cid            TEXT,                          -- IPFS CID of agent card JSON
  identity_registry_address TEXT,                          -- ERC-8004 IdentityRegistry contract address
  network                   TEXT,                          -- e.g. 'base-sepolia'
  owner_address             TEXT,                          -- EOA / smart-account that owns the agent NFT
  registered_at             TIMESTAMPTZ DEFAULT now(),
  registration_tx_hash      TEXT
);

CREATE INDEX IF NOT EXISTS idx_agent_registrations_owner   ON agent_registrations(owner_address);
CREATE INDEX IF NOT EXISTS idx_agent_registrations_network ON agent_registrations(network);

-- 2. Filecoin Uploads (Synapse + FOC + PDP lifecycle)
CREATE TABLE IF NOT EXISTS filecoin_uploads (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id           UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
  piece_cid          TEXT,
  dataset_id         TEXT,
  root_cid           TEXT,
  upload_status      TEXT,        -- 'pending' | 'uploading' | 'completed' | 'failed'
  pdp_status         TEXT,        -- 'pending' | 'verified' | 'failed'
  last_proven_epoch  BIGINT NULL,
  attempted_at       TIMESTAMPTZ DEFAULT now(),
  completed_at       TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_filecoin_uploads_claim         ON filecoin_uploads(claim_id);
CREATE INDEX IF NOT EXISTS idx_filecoin_uploads_piece_cid     ON filecoin_uploads(piece_cid);
CREATE INDEX IF NOT EXISTS idx_filecoin_uploads_upload_status ON filecoin_uploads(upload_status);
CREATE INDEX IF NOT EXISTS idx_filecoin_uploads_pdp_status    ON filecoin_uploads(pdp_status);

-- 3. Evidence Bundles (canonical JSON hashed and attested)
CREATE TABLE IF NOT EXISTS evidence_bundles (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id     UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
  bundle_json  JSONB NOT NULL,
  bundle_hash  TEXT  NOT NULL,                 -- keccak256(canonical(bundle_json)), 0x-prefixed
  photo_cids   TEXT[] DEFAULT ARRAY[]::TEXT[],
  created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_evidence_bundles_claim ON evidence_bundles(claim_id);
CREATE INDEX IF NOT EXISTS idx_evidence_bundles_hash  ON evidence_bundles(bundle_hash);
