# Agent Tabs

<p align="center">
  <img src="public/agent-tabs-logo.png" width="88" alt="Agent Tabs logo" />
</p>

<p align="center">
  <strong>Give agents a tab. Keep the wallet in control.</strong><br />
  A GIWA Sepolia MVP for owner-controlled stablecoin-style spending by AI agents.
</p>

<p align="center">
  <a href="https://agent-tabs-eta.vercel.app/"><strong>Live demo</strong></a> |
  <a href="#contracts"><strong>Contracts</strong></a> |
  <a href="#local-development"><strong>Run locally</strong></a>
</p>

---

## Why Agent Tabs

AI agents are starting to act with wallets, call paid APIs, and make small autonomous payments. That creates a practical problem: users may want an agent to buy useful data or compute, but they do not want to hand the agent an unrestricted wallet.

Agent Tabs is a spending-control layer for that problem. The owner funds a limited tab, binds an agent and a merchant payTo address into a policy, sets per-payment and daily limits, then lets the agent pay only inside those rules.

This fits GIWA because the product is built around low-cost, stablecoin-style settlement on a fast L2. The current demo uses ATST, a project-issued test settlement token, to show the payment path on GIWA Sepolia.

## Demo scenario

The demo uses a DeFi researcher / on-chain analyst as the user. Their AI research agent buys on-chain signals such as whale-flow snapshots, liquidity-pool scans, and token-risk reports.

Each request is cheap, but an automated agent can still burn through a budget quickly. Agent Tabs gives the agent a narrow payment tab instead of full wallet access.

## x402-style flow

The front end demonstrates an x402-style request and payment flow:

```text
Paid endpoint returns a quote -> Owner policy checks price, asset and payTo
-> AgentTabs spend() transfers ATST to the merchant on GIWA
-> The interface records the paid result
```

Agent Tabs does not replace x402. It acts as an owner-controlled permission layer around x402-style agent payments.

## What this MVP demonstrates

- Owner-funded ATST vault on GIWA Sepolia
- Owner-filled agent wallet and merchant payTo address
- Per-payment and daily spending limits
- Policy creation through the owner wallet
- Real `approve -> deposit -> createPolicy -> spend` flow
- Merchant payout in ATST when a data call succeeds
- Failed calls do not create paid receipts
- Visible activity and paid receipt review in the interface

## Live demo

Open the public MVP here: [agent-tabs-eta.vercel.app](https://agent-tabs-eta.vercel.app/)

Suggested walkthrough:

1. Connect the owner wallet on GIWA Sepolia.
2. Claim ATST from the demo faucet.
3. Fund the tab with 1 ATST.
4. Enter the agent wallet and merchant payTo address.
5. Save and sign the policy.
6. Run `Whale-flow snapshot`.
7. Check that ATST moved from the tab contract to the merchant address.

## Demo Video

A short walkthrough of the Agent Tabs MVP is available here:

[Watch the demo video](https://github.com/yangdamie/agent-tabs/releases/tag/demo-v1)

## Contracts

| Contract | Address | Explorer |
| --- | --- | --- |
| AgentTabsFaucetToken (ATST) | `0x29FacB7eCbd885F443A96fAfD6090eD690D5dF1E` | [View](https://sepolia-explorer.giwa.io/address/0x29FacB7eCbd885F443A96fAfD6090eD690D5dF1E) |
| AgentTabs | `0xB1b3c63F1b2d4179dF83aA247a4BB6f301b4CA88` | [View](https://sepolia-explorer.giwa.io/address/0xB1b3c63F1b2d4179dF83aA247a4BB6f301b4CA88) |

ATST is a project-issued test token deployed for this demo. It temporarily represents a stablecoin settlement asset on GIWA Sepolia. It has no value and is not represented as a real stablecoin.

## On-Chain Proof (GIWA Sepolia)

Agent Tabs has executed the core lifecycle on GIWA Sepolia:

1. **Fund Agent Pool**: owner deposits ATST into the Agent Tabs vault, increasing `vaultBalance`.
   [Tx](https://sepolia-explorer.giwa.io/tx/0x3da319dc8ecb7ff4a4ce6187ee9c55412039b8a4b10bf990c0ac617fef78a82d)
2. **Create Policy**: owner binds an agent wallet, merchant payTo address, daily limit, and per-payment limit.
   [Tx](https://sepolia-explorer.giwa.io/tx/0x45a0bfbc354ae23a75ffdf56fd5b8a8b14aa5a2009e69fa575d885fe3f4a7dad)
3. **Successful Spend**: a policy-valid request transfers ATST from the vault to the merchant.
   [Tx](https://sepolia-explorer.giwa.io/tx/0x105e2cad0ba83f64b8353426e158eccdb7c5ffc0592b14364fdce16be8fcafe4)

Timeouts and limit breaches are intentionally not paid: failed requests do not create paid receipts, and over-limit requests are rejected before value moves.

## Contract model

`contracts/AgentTabs.sol` implements the live MVP path:

```text
approve -> deposit -> createPolicy -> spend
```

The owner can bind a merchant payTo address directly in `createPolicy`. The contract also keeps an optional platform merchant list switch for a later curated-provider mode, but that switch is not required for the current demo flow.

## Repository structure

```text
app/                          Next.js entry point
public/demo.html              Interactive product demo
contracts/AgentTabs.sol       Owner-bound policy and merchant payout contract
contracts/AgentTabsFaucetToken.sol ATST faucet token for GIWA Sepolia
README.md                     Project overview and testnet notes
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

This is an unaudited testnet MVP. It is built to demonstrate delegated spending controls and stablecoin-style settlement, not to hold real user funds. A production version would require audited contracts, real x402 endpoint integrations, stronger key management, and production-grade monitoring.

## Next steps

- Connect real x402 quotes and validate `price`, `asset`, `payTo`, `nonce`, and `requestId`.
- Add provider discovery with curated defaults, owner-defined merchants, risk labels, and verification status.
- Support multiple tabs for different agents, budgets, merchants, and tasks.
- Explore GIWA-native improvements such as batch settlement, Paymaster support, and Passkey/P256 authorization.
- Release a small TypeScript SDK for agent frameworks and API providers.

