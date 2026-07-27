# Agent Tabs

<p align="center">
  <img src="public/agent-tabs-logo.png" width="88" alt="Agent Tabs logo" />
</p>

<p align="center">
  <strong>Give agents a tab. Keep the wallet in control.</strong><br />
  A GIWA Sepolia MVP for controlled, receipt-based stablecoin settlement by AI research agents.
</p>

<p align="center">
  <a href="https://agent-tabs-eta.vercel.app/"><strong>Live demo</strong></a> | 
  <a href="#giwa-sepolia-deployment"><strong>Contracts</strong></a> | 
  <a href="#local-development"><strong>Run locally</strong></a>
</p>

---

## The problem

A DeFi researcher may let an AI agent purchase paid on-chain signals: whale-flow snapshots, liquidity-pool scans, or token-risk reports. Those calls can be inexpensive individually, but giving the agent an unrestricted wallet is unsafe.

**Agent Tabs** sits between the agent and a paid data endpoint. The owner creates a limited payment tab: one approved merchant, a maximum payment per request, and a daily spending cap. The agent can only spend within that signed policy.

Agent Tabs is **not** an AI model, trading platform, or API marketplace. It is the payment-control layer for agents that already use paid services.

## What this MVP demonstrates

- Owner-funded settlement vault
- Per-call and daily spending limits
- Approved-merchant allowlist
- Pausable policy controls
- Signed receipts for completed requests
- Batch-settlement design for valid receipts
- MetaMask-compatible owner and agent signatures
- A guided interface for successful calls, blocked calls, timeout releases, and settlement preview

## How it works

```text
Owner signs policy -> Agent requests paid data -> Policy checks merchant + limits
-> Completed work creates a receipt -> Valid receipts settle together on GIWA
```

The front end demonstrates an **x402-style** payment and receipt flow on GIWA Sepolia. It is a testnet simulation and does not claim production x402 interoperability or live merchant integrations.

## Live demo

Open the public MVP here: [agent-tabs-eta.vercel.app](https://agent-tabs-eta.vercel.app/)

Suggested walkthrough:

1. Connect the owner wallet on GIWA Sepolia.
2. Fund the tab with the project test settlement token.
3. Save and sign a policy for the approved on-chain data source.
4. Run a whale-flow snapshot or pool scan.
5. Review the receipt and settlement preview.

## GIWA Sepolia deployment

| Contract | Address | Explorer |
| --- | --- | --- |
| AgentTabsFinal | `0x1b63A6FA0638Eeb9334710Cae2B59f6Ed39F9c70` | [View](https://sepolia-explorer.giwa.io/address/0x1b63A6FA0638Eeb9334710Cae2B59f6Ed39F9c70) |
| AgentTabsTestToken (ATST) | `0x945a8d9ac7B375D0a27BaA761a9B995eA9d6fdEB` | [View](https://sepolia-explorer.giwa.io/address/0x945a8d9ac7B375D0a27BaA761a9B995eA9d6fdEB) |

**ATST** is a project-issued test settlement token used to simulate stablecoin settlement on GIWA Sepolia. It has no value and is not represented as a real stablecoin.

## Repository structure

```text
app/                         Next.js entry point
public/demo.html             Interactive product demo
contracts/AgentTabsFinal.sol Payment vault, policy, and receipt settlement
contracts/AgentTabsTestToken.sol
                             Test settlement token for GIWA Sepolia
docs/                        Architecture and demo notes
```

## Local development

```bash
npm install
npm run dev
```

Then open `http://localhost:3000`.

## Network

| Item | Value |
| --- | --- |
| Network | GIWA Sepolia Testnet |
| Chain ID | `91342` |
| RPC | `https://sepolia-rpc.giwa.io` |
| Explorer | `https://sepolia-explorer.giwa.io` |

## Scope and safety

This is an unaudited testnet MVP. It is built to demonstrate delegated spending controls and receipt-based settlement, not to hold real user funds. A production version would require audited contracts, real service-provider integrations, stronger key management, and a fully implemented payment-protocol adapter.
