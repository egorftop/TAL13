# TAL13 Website

Static GitHub Pages website for the TAL13 BEP-20 community token on BNB Chain.

## Files

- `index.html` - website
- `tal13-logo.png` - token logo
- `TokenLocker.sol` - optional token lock smart contract
- `README.md` - project notes

## Official TAL13 Contract

`0xb88238565e5b168bc0257b80ce41067b5bf9fee3`

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
const LOCKER_ADDRESS = "PASTE_LOCKER_CONTRACT_ADDRESS_HERE";
```

9. Replace it with the deployed locker address.
10. Commit and push `index.html`.

After that, the lock section will work on the website.
