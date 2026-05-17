// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TokenLocker {
    IERC20 public immutable token;
    uint256 public constant MIN_LOCK_DAYS = 1;

    struct LockInfo {
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    mapping(address => LockInfo[]) private userLocks;

    event Locked(address indexed user, uint256 indexed lockId, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 indexed lockId, uint256 amount);

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address is zero");
        token = IERC20(tokenAddress);
    }

    function lock(uint256 amount, uint256 daysCount) external {
        require(amount > 0, "Amount is zero");
        require(daysCount >= MIN_LOCK_DAYS, "Minimum lock is 1 day");

        uint256 unlockTime = block.timestamp + (daysCount * 1 days);

        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        userLocks[msg.sender].push(LockInfo({
            amount: amount,
            unlockTime: unlockTime,
            withdrawn: false
        }));

        emit Locked(msg.sender, userLocks[msg.sender].length - 1, amount, unlockTime);
    }

    function withdraw(uint256 lockId) external {
        require(lockId < userLocks[msg.sender].length, "Invalid lock id");

        LockInfo storage lockInfo = userLocks[msg.sender][lockId];

        require(!lockInfo.withdrawn, "Already withdrawn");
        require(block.timestamp >= lockInfo.unlockTime, "Still locked");

        lockInfo.withdrawn = true;

        require(token.transfer(msg.sender, lockInfo.amount), "Transfer failed");

        emit Withdrawn(msg.sender, lockId, lockInfo.amount);
    }

    function getLocks(address user) external view returns (LockInfo[] memory) {
        return userLocks[user];
    }

    function getLocksCount(address user) external view returns (uint256) {
        return userLocks[user].length;
    }
}
