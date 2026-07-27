# Agent Tabs

Agent Tabs is a GIWA Sepolia MVP for giving an AI research agent a limited payment tab. The owner funds a vault, selects an approved data source, and signs limits for each call and day.

The reference scenario is a DeFi research agent purchasing on-chain market signals. Agent Tabs is not an AI model or an API marketplace; it is the payment control layer between an agent and a paid endpoint.

## What the MVP demonstrates

- owner-funded payment vaults;
- per-call and daily spending limits;
- merchant allowlisting;
- pausable agent policies;
- receipt-based batch settlement design;
- MetaMask-compatible agent receipt signatures.

## GIWA Sepolia deployment

| Contract | Address |
| --- | --- |
| AgentTabsFinal | `0x1b63A6FA0638Eeb9334710Cae2B59f6Ed39F9c70` |
| ATST test settlement token | `0x945a8d9ac7B375D0a27BaA761a9B995eA9d6fdEB` |

ATST is a project-issued token used to simulate stablecoin settlement on GIWA Sepolia. It has no value and is not presented as a real stablecoin.

## Demo

Open `public/demo.html` locally, or run:

```bash
npm install
npm run dev
```

The interface includes the deployed-contract links and a guided simulation of policy checks, receipts, failed calls, and batch settlement.

## Contracts

- `contracts/AgentTabsFinal.sol` — vault, policy and receipt settlement logic.
- `contracts/AgentTabsTestToken.sol` — the ATST test settlement token.

## Network

- Chain ID: `91342`
- RPC: `https://sepolia-rpc.giwa.io`
- Explorer: `https://sepolia-explorer.giwa.io`

## Scope note

This is an unaudited testnet MVP. The UI demonstrates the intended x402-style request and receipt flow; it does not claim production x402 interoperability or real merchant integrations.
