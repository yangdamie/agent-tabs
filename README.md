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

- Owner-funded ATST vault on GIWA Sepolia
- Per-call and daily spending limits
- Approved-merchant allowlist
- Policy creation through the owner wallet
- Real `approve -> deposit -> spend` payment flow
- Merchant payout in ATST when an approved data call succeeds
- Visible receipts and rejected-call history in the interface
- A guided interface for successful calls, blocked calls, timeout releases, and paid receipt review

## Payment model

```text
Owner approves ATST -> Owner deposits ATST into the tab -> Owner creates a policy
-> Agent requests a paid resource -> Policy checks merchant + limits
-> spend() transfers ATST to the merchant on GIWA -> The interface records the paid receipt
```

The front end demonstrates an **x402-style** request/quote flow, then executes the payment through the Phase 1 Agent Tabs contract on GIWA Sepolia. A successful call transfers ATST to the approved merchant and records the receipt in the interface.

## Live demo

Open the public MVP here: [agent-tabs-eta.vercel.app](https://agent-tabs-eta.vercel.app/)

Suggested walkthrough:

1. Connect the owner wallet on GIWA Sepolia.
2. Fund the tab with the project test settlement token.
3. Save and sign a policy for the approved on-chain data source.
4. Run a whale-flow snapshot or pool scan.
5. Open the receipt queue and verify the merchant payout transaction.

## Test settlement token

| Token | Address | Explorer |
| --- | --- | --- |
| AgentTabsFaucetToken (ATST) | `0x29FacB7eCbd885F443A96fAfD6090eD690D5dF1E` | [View](https://sepolia-explorer.giwa.io/address/0x29FacB7eCbd885F443A96fAfD6090eD690D5dF1E) |
| AgentTabsPhase1 | `0xd9145CCE52D386f254917e481eB44e9943F39138` | [View](https://sepolia-explorer.giwa.io/address/0xd9145CCE52D386f254917e481eB44e9943F39138) |

**ATST** is a project-issued test token deployed for this demo. It temporarily represents a stablecoin settlement asset on GIWA Sepolia. It has no value and is not represented as a real stablecoin.

The Phase 1 contract source is [contracts/AgentTabsPhase1.sol](contracts/AgentTabsPhase1.sol). It implements the live MVP path: `approve -> deposit -> createPolicy -> spend`, with ATST transferred to the approved merchant.

## Repository structure

```text
app/                         Next.js entry point
public/demo.html             Interactive product demo
contracts/AgentTabsPhase1.sol Live deposit, policy, spend, and merchant payout contract
contracts/AgentTabsFaucetToken.sol Test settlement token for GIWA Sepolia
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
