// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.0/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC20/utils/SafeERC20.sol";

contract TokenLocker is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    uint256 public constant MIN_LOCK_DAYS = 1;
    uint256 public constant MAX_LOCK_DAYS = 3650;

    uint256 public totalLocked;
    mapping(address => uint256) public totalLockedOf;

    struct LockInfo {
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    mapping(address => LockInfo[]) private userLocks;

    event Locked(
        address indexed user,
        uint256 indexed lockId,
        uint256 amount,
        uint256 unlockTime,
        uint256 daysCount
    );
    event Withdrawn(address indexed user, uint256 indexed lockId, uint256 amount);
    event UnsupportedTokenRecovered(address indexed tokenAddress, address indexed to, uint256 amount);

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address is zero");
        token = IERC20(tokenAddress);
    }

    function lock(uint256 amount, uint256 daysCount) external nonReentrant {
        require(amount > 0, "Amount is zero");
        require(daysCount >= MIN_LOCK_DAYS, "Minimum lock is 1 day");
        require(daysCount <= MAX_LOCK_DAYS, "Lock period too long");

        uint256 unlockTime = block.timestamp + (daysCount * 1 days);

        token.safeTransferFrom(msg.sender, address(this), amount);

        userLocks[msg.sender].push(LockInfo({
            amount: amount,
            unlockTime: unlockTime,
            withdrawn: false
        }));

        totalLocked += amount;
        totalLockedOf[msg.sender] += amount;

        emit Locked(msg.sender, userLocks[msg.sender].length - 1, amount, unlockTime, daysCount);
    }

    function withdraw(uint256 lockId) external nonReentrant {
        require(lockId < userLocks[msg.sender].length, "Invalid lock id");

        LockInfo storage lockInfo = userLocks[msg.sender][lockId];

        require(!lockInfo.withdrawn, "Already withdrawn");
        require(block.timestamp >= lockInfo.unlockTime, "Still locked");

        uint256 amount = lockInfo.amount;

        lockInfo.withdrawn = true;
        totalLocked -= amount;
        totalLockedOf[msg.sender] -= amount;

        token.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, lockId, amount);
    }

    function getLock(address user, uint256 lockId) external view returns (LockInfo memory) {
        require(lockId < userLocks[user].length, "Invalid lock id");
        return userLocks[user][lockId];
    }

    function getLocks(address user) external view returns (LockInfo[] memory) {
        return userLocks[user];
    }

    function getLocksCount(address user) external view returns (uint256) {
        return userLocks[user].length;
    }

    function canWithdraw(address user, uint256 lockId) external view returns (bool) {
        if (lockId >= userLocks[user].length) {
            return false;
        }

        LockInfo memory lockInfo = userLocks[user][lockId];
        return !lockInfo.withdrawn && block.timestamp >= lockInfo.unlockTime;
    }

    function recoverUnsupportedToken(address tokenAddress, address to, uint256 amount) external onlyOwner {
        require(tokenAddress != address(token), "Cannot recover locked token");
        require(to != address(0), "Recipient is zero");
        IERC20(tokenAddress).safeTransfer(to, amount);

        emit UnsupportedTokenRecovered(tokenAddress, to, amount);
    }
}
