# TAL13 Website

Static GitHub Pages website for the TAL13 BEP-20 community token on BNB Chain.
The site includes a wallet profile, live DEX price lookup, aluminum market reference data, and a prepared token-lock interface.

## Files

- `index.html` - website
- `profile.html` - dedicated wallet profile page
- `data/aluminum.json` - generated aluminum reference price/history
- `scripts/update-aluminum.mjs` - updater for aluminum data
- `.github/workflows/update-aluminum.yml` - scheduled GitHub Action for data refresh
- `Tal13.sol` - TAL13 BEP-20 token contract
- `tal13-logo.png` - token logo
- `TokenLocker.sol` - TAL13 token lock smart contract
- `README.md` - project notes

## Official TAL13 Contract

`0xb88238565e5b168bc0257b80ce41067b5bf9fee3`

## Deployed TokenLocker Contract

`0xD68143B467DC511Cf9A443AF92331cf2148014aD`

## Live Site

`https://egorftop.github.io/TAL13/`

## Publish On GitHub Pages

1. Open repository settings on GitHub.
2. Go to Pages.
3. Source: Deploy from a branch.
4. Branch: `main`.
5. Folder: `/root`.
6. Save and wait for the Pages deployment.

## Activate Token Locking

The website is ready for token locking, but lock transactions stay disabled until a TokenLocker contract is deployed.

1. Open Remix.
2. Create `TokenLocker.sol`.
3. Paste the code from this repository.
4. Compile with Solidity `0.8.20` or newer.
5. Deploy to BNB Smart Chain Mainnet.
6. Constructor `tokenAddress`:
   `0xb88238565e5b168bc0257b80ce41067b5bf9fee3`
7. Copy the deployed TokenLocker address.
8. In `index.html`, find:

```js
const LOCKER_ADDRESS = "0xD68143B467DC511Cf9A443AF92331cf2148014aD";
```

9. Replace it with the deployed locker address.
10. Commit and push `index.html`.

After that, the lock section will work on the website.

`TokenLocker.sol` supports:

- locking TAL13 from 1 to 3650 days;
- withdrawing only after unlock time;
- viewing all locks per wallet;
- tracking total active locked TAL13;
- recovering unsupported tokens sent by mistake, but not the locked TAL13 token.

## Aluminum Data

The aluminum reference chart uses COMEX Aluminum Futures (`ALI=F`) data from Yahoo Finance.
The updater stores prices in USD per metric ton and USD per kilogram:

```bash
node scripts/update-aluminum.mjs
```

GitHub Actions also runs the updater on a daily schedule and commits `data/aluminum.json` when the data changes.
