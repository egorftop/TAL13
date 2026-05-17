# TAL13 website

This is a static TAL13 website for GitHub Pages.

## Files

- `index.html` — website
- `tal13-logo.png` — token logo
- `TokenLocker.sol` — optional token lock smart contract

## Official TAL13 contract

`0xb88238565e5b168bc0257b80ce41067b5bf9fee3`

## How to publish on GitHub Pages

1. Go to https://github.com
2. Create a new public repository named `tal13`
3. Upload all files from this folder:
   - index.html
   - tal13-logo.png
   - TokenLocker.sol
   - README.md
4. Open repository Settings
5. Go to Pages
6. Source: Deploy from a branch
7. Branch: main
8. Folder: /root
9. Save
10. Wait 1–5 minutes

Your website will be:

`https://YOUR-GITHUB-USERNAME.github.io/tal13/`

## How to activate token locking

1. Open Remix.
2. Create `TokenLocker.sol`.
3. Paste the code from `TokenLocker.sol`.
4. Compile with Solidity `0.8.20` or newer.
5. Deploy to BNB Smart Chain Mainnet.
6. Constructor tokenAddress:
   `0xb88238565e5b168bc0257b80ce41067b5bf9fee3`
7. Copy deployed TokenLocker address.
8. In `index.html`, find:

```js
const LOCKER_ADDRESS = "PASTE_LOCKER_CONTRACT_ADDRESS_HERE";
```

9. Replace it with your deployed locker address.
10. Commit/update `index.html` on GitHub.

After that, the lock section will work on the website.

## Important

TAL13 is not backed by physical aluminum and is not redeemable for metal.
