import { Copy, Database, Link as LinkIcon, Clock, CheckCircle2, ExternalLink } from 'lucide-react'

interface FilecoinPanelProps {
  cid?: string | null
  pieceCid?: string | null
  datasetId?: string | null
  txHash?: string | null
  easUid?: string | null
}

function copyToClipboard(value: string) {
  if (!navigator?.clipboard) return
  navigator.clipboard.writeText(value)
}

function DataRow({ label, value, link }: { label: string; value?: string | null; link?: string }) {
  return (
    <div className="flex items-start justify-between gap-2 text-xs py-1.5 border-b border-gray-50 last:border-0">
      <span className="text-gray-500 shrink-0 pt-0.5">{label}</span>
      {value ? (
        <div className="flex items-center gap-1 min-w-0">
          <span className="font-mono text-gray-700 truncate max-w-[150px]" title={value}>
            {value}
          </span>
          {link && (
            <a href={link} target="_blank" rel="noreferrer" className="text-blue-500 shrink-0">
              <ExternalLink className="w-3 h-3" />
            </a>
          )}
          <button onClick={() => copyToClipboard(value)} className="text-gray-400 hover:text-gray-600 shrink-0">
            <Copy className="w-3 h-3" />
          </button>
        </div>
      ) : (
        <span className="text-gray-300 italic">not yet available</span>
      )}
    </div>
  )
}

export function FilecoinPanel({ cid, pieceCid, datasetId, txHash, easUid }: FilecoinPanelProps) {
  const isStored = !!cid
  const isAttested = !!txHash

  return (
    <div className="bg-white rounded-xl border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
          <Database className="w-5 h-5 text-blue-500" />
          Filecoin &amp; Blockchain
        </h2>
        <div className="flex items-center gap-1.5">
          {isStored ? (
            <span className="inline-flex items-center gap-1 text-xs font-medium text-green-700 bg-green-50 px-2 py-0.5 rounded-full">
              <CheckCircle2 className="w-3 h-3" /> Stored
            </span>
          ) : (
            <span className="inline-flex items-center gap-1 text-xs font-medium text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full">
              <Clock className="w-3 h-3" /> Pending
            </span>
          )}
        </div>
      </div>

      {!isStored && (
        <div className="mb-4 p-3 bg-amber-50 border border-amber-100 rounded-lg">
          <p className="text-xs text-amber-700">
            Filecoin storage is triggered automatically when the AI agent files or processes this claim via a call. Make a call using the widget below to trigger it.
          </p>
        </div>
      )}

      <div className="space-y-0">
        <DataRow
          label="Root CID"
          value={cid}
          link={cid ? `https://explore.synapse.storage/${cid}` : undefined}
        />
        <DataRow label="Piece CID" value={pieceCid} />
        <DataRow label="Dataset ID" value={datasetId} />
        <DataRow
          label="Attestation Tx"
          value={txHash}
          link={txHash ? `https://sepolia.basescan.org/tx/${txHash}` : undefined}
        />
        <DataRow
          label="EAS UID"
          value={easUid}
          link={easUid ? `https://base-sepolia.easscan.org/attestation/view/${easUid}` : undefined}
        />
      </div>

      {isAttested && (
        <div className="mt-4 pt-3 border-t border-gray-100 flex items-center gap-1.5">
          <CheckCircle2 className="w-3.5 h-3.5 text-green-500" />
          <span className="text-xs text-green-700 font-medium">On-chain attestation verified</span>
          <a
            href={`https://sepolia.basescan.org/tx/${txHash}`}
            target="_blank"
            rel="noreferrer"
            className="ml-auto text-xs text-blue-600 hover:underline inline-flex items-center gap-1"
          >
            <LinkIcon className="w-3 h-3" />
            View on BaseScan
          </a>
        </div>
      )}
    </div>
  )
}
