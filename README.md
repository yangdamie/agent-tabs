# Agent Tabs

<p align="center">
  <img src="public/agent-tabs-logo.png" width="88" alt="Agent Tabs logo" />
</p>

<p align="center">
  <strong>Give agents a tab. Keep the wallet in control.</strong><br />
  A GIWA Sepolia MVP for controlled, receipt-based stablecoin settlement by AI agents.
</p>

<p align="center">
  <a href="https://agent-tabs-eta.vercel.app/"><strong>Live demo</strong></a> | 
  <a href="#test-settlement-token"><strong>Test token</strong></a> | 
  <a href="#local-development"><strong>Run locally</strong></a>
</p>

---

## Why Agent Tabs on GIWA

As AI applications become more autonomous, agents increasingly need to pay for data, compute, and API calls on their own. Existing payment approaches create a gap: subscriptions and API keys are hard to scope per action, while giving an agent an unrestricted wallet makes a small bug or compromised key financially risky.

Agent Tabs uses GIWA Sepolia to demonstrate a stablecoin-settlement control layer for those payments. The owner gives an agent a bounded payment tab: they select an approved service, set a maximum payment per request and a daily cap, then sign the policy. The agent can make eligible payments without gaining control of the owner's full wallet.

The model is designed for services that support stablecoin, pay-per-request payment. It follows an **x402-style** request, quote, payment, and receipt narrative: a paid endpoint responds with an HTTP 402-style quote, the policy is checked before payment, and completed work produces a receipt for settlement.

## Demo scenario: paid on-chain research

The interface uses a DeFi research agent as a concrete example. It purchases on-chain signals such as whale-flow snapshots, liquidity-pool scans, and token-risk reports. Each call is inexpensive, but high-frequency automated requests can still exceed a research budget without clear limits.

In the demo, the owner creates one tab for an approved on-chain data source. The agent can request a signal only when its price and daily usage comply with the signed policy.

## What this MVP demonstrates

- Owner-funded settlement vault
- Per-call and daily spending limits
- Approved-merchant allowlist
- Pausable policy controls
- Signed receipts for completed requests
- Batch-settlement design for valid receipts
- MetaMask-compatible owner and agent signatures
- A guided interface for successful calls, blocked calls, timeout releases, and settlement preview

## Payment model

```text
Owner signs policy -> Agent requests a paid resource -> Endpoint returns an x402-style quote
-> Policy checks merchant + limits -> Completed work creates a receipt -> Valid receipts settle on GIWA
```

The front end demonstrates an **x402-style** payment and receipt flow on GIWA Sepolia.

## Live demo

Open the public MVP here: [agent-tabs-eta.vercel.app](https://agent-tabs-eta.vercel.app/)

Suggested walkthrough:

1. Connect the owner wallet on GIWA Sepolia.
2. Fund the tab with the project test settlement token.
3. Save and sign a policy for the approved on-chain data source.
4. Run a whale-flow snapshot or pool scan.
5. Review the receipt and settlement preview.

## Test settlement token

| Token | Address | Explorer |
| --- | --- | --- |
| AgentTabsTestToken (ATST) | `0x945a8d9ac7B375D0a27BaA761a9B995eA9d6fdEB` | [View](https://sepolia-explorer.giwa.io/address/0x945a8d9ac7B375D0a27BaA761a9B995eA9d6fdEB) |

**ATST** is a project-issued test token deployed for this demo. It temporarily represents a stablecoin settlement asset on GIWA Sepolia. It has no value and is not represented as a real stablecoin.

The Agent Tabs application contract is included in this repository as an MVP implementation and is not presented here as a deployed production contract.

## Repository structure

```text
app/                         Next.js entry point
public/demo.html             Interactive product demo
AgentTabsFinal.sol           Payment vault, policy, and receipt settlement
AgentTabsTestToken.sol       Test settlement token for GIWA Sepolia
README.md                    Project overview and testnet notes
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

## Next steps

- Connect the policy flow to compatible paid endpoints and real x402 payment adapters.
- Add a merchant-facing receipt verification and settlement view.
- Support multiple agent tabs and policy templates for different teams or tasks.
- Audit the contracts and add stronger account and key-management controls before any production use.
