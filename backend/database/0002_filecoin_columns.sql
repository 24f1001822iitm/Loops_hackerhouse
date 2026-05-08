-- ============================================
-- Migration 0002: ClaimVault + ERC-8004 columns on `claims`
-- Adds Filecoin/Synapse upload metadata, on-chain attestation
-- references (Base Sepolia ClaimRegistry / EAS), evidence
-- bundle hash, PDP proof status, and ERC-8004 agent linkage.
-- ============================================

ALTER TABLE claims
  ADD COLUMN IF NOT EXISTS filecoin_cid         TEXT,        -- IPFS root CID returned by Synapse upload
  ADD COLUMN IF NOT EXISTS piece_cid            TEXT,        -- piece CID from FOC (Filecoin Onchain Cloud)
  ADD COLUMN IF NOT EXISTS dataset_id           TEXT,        -- Filecoin dataset id
  ADD COLUMN IF NOT EXISTS attestation_tx_hash  TEXT,        -- Base Sepolia tx hash from ClaimRegistry.attestClaim
  ADD COLUMN IF NOT EXISTS eas_uid              TEXT,        -- EAS attestation UID (nullable)
  ADD COLUMN IF NOT EXISTS evidence_hash        TEXT,        -- keccak256 of canonical evidence bundle (0x-prefixed)
  ADD COLUMN IF NOT EXISTS pdp_proof_status     TEXT,        -- 'pending' | 'verified' | 'failed'
  ADD COLUMN IF NOT EXISTS agent_id             BIGINT,      -- ERC-8004 agent NFT id
  ADD COLUMN IF NOT EXISTS attested_at          TIMESTAMPTZ; -- when on-chain attestation succeeded

-- Soft enum guard for pdp_proof_status (skip if values diverge later).
ALTER TABLE claims
  DROP CONSTRAINT IF EXISTS claims_pdp_proof_status_check;
ALTER TABLE claims
  ADD CONSTRAINT claims_pdp_proof_status_check
  CHECK (pdp_proof_status IS NULL OR pdp_proof_status IN ('pending', 'verified', 'failed'));

-- Lookup helpers for on-chain reconciliation and dashboard queries.
CREATE INDEX IF NOT EXISTS idx_claims_attestation_tx ON claims(attestation_tx_hash);
CREATE INDEX IF NOT EXISTS idx_claims_eas_uid        ON claims(eas_uid);
CREATE INDEX IF NOT EXISTS idx_claims_filecoin_cid   ON claims(filecoin_cid);
CREATE INDEX IF NOT EXISTS idx_claims_piece_cid      ON claims(piece_cid);
CREATE INDEX IF NOT EXISTS idx_claims_agent_id       ON claims(agent_id);
CREATE INDEX IF NOT EXISTS idx_claims_pdp_status     ON claims(pdp_proof_status);
