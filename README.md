# TAL13 Website

Static GitHub Pages website for the TAL13 BEP-20 community token on BNB Chain.
The site includes a wallet profile, live DEX price lookup, aluminum market reference data, and a prepared staking interface with APY tiers.

## Files

- `index.html` - website
- `profile.html` - dedicated wallet profile page
- `data/aluminum.json` - generated aluminum reference price/history
- `scripts/update-aluminum.mjs` - updater for aluminum data
- `.github/workflows/update-aluminum.yml` - scheduled GitHub Action for data refresh
- `Tal13.sol` - TAL13 BEP-20 token contract
- `tal13-logo.png` - token logo
- `TokenLocker.sol` - TAL13 token lock smart contract
- `TAL13Staking.sol` - TAL13 staking smart contract with real reward payouts
- `README.md` - project notes

## Official TAL13 Contract

`0xb88238565e5b168bc0257b80ce41067b5bf9fee3`

## Deployed TokenLocker Contract

`0xD68143B467DC511Cf9A443AF92331cf2148014aD`

The old TokenLocker is kept on the website as Legacy Locks so existing locks can still be withdrawn after unlock time.

## Live Site

`https://egorftop.github.io/TAL13/`

## Publish On GitHub Pages

1. Open repository settings on GitHub.
2. Go to Pages.
3. Source: Deploy from a branch.
4. Branch: `main`.
5. Folder: `/root`.
6. Save and wait for the Pages deployment.

## Activate TAL13 Staking

The website is ready for staking, but staking transactions stay disabled until a TAL13Staking contract is deployed.

1. Open Remix.
2. Create `TAL13Staking.sol`.
3. Paste the code from this repository.
4. Compile with Solidity `0.8.20` or newer.
5. Deploy to BNB Smart Chain Mainnet.
6. Constructor `tokenAddress`:
   `0xb88238565e5b168bc0257b80ce41067b5bf9fee3`
7. Copy the deployed TAL13Staking address and deployment block.
8. Mint an initial reward pool to the staking contract. Recommended start: `10 TAL13`.
9. In `index.html`, find:

```js
const STAKING_ADDRESS = "PASTE_STAKING_CONTRACT_ADDRESS_HERE";
const STAKING_DEPLOY_BLOCK = 0;
```

10. Replace those values with the deployed staking address and deployment block.
11. Commit and push `index.html`.

After that, the staking section will work on the website.

`TAL13Staking.sol` supports:

- staking TAL13 from 30 to 3650 days;
- APY tiers: 30-89 days = 3%, 90-179 days = 5%, 180-364 days = 6.5%, 365+ days = 8%;
- reserving rewards at stake time from the contract reward pool;
- withdrawing principal plus reward only after unlock time;
- viewing all stakes per wallet;
- tracking total active principal and reserved rewards;
- withdrawing only unreserved reward pool TAL13 by the owner;
- recovering unsupported tokens sent by mistake, but not the TAL13 staking token.

## Aluminum Data

The aluminum reference chart uses COMEX Aluminum Futures (`ALI=F`) data from Yahoo Finance.
The updater stores prices in USD per metric ton and USD per kilogram:

```bash
node scripts/update-aluminum.mjs
```

GitHub Actions also runs the updater on a daily schedule and commits `data/aluminum.json` when the data changes.
