// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.0/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC20/utils/SafeERC20.sol";

contract TAL13Staking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    uint256 public constant MIN_STAKE_DAYS = 30;
    uint256 public constant MAX_STAKE_DAYS = 3650;
    uint256 public constant BPS_DENOMINATOR = 10000;
    uint256 public constant YEAR_DAYS = 365;

    uint256 public totalPrincipalLocked;
    uint256 public totalRewardsReserved;
    mapping(address => uint256) public totalPrincipalOf;

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 unlockTime;
        uint16 apyBps;
        uint256 reward;
        bool withdrawn;
    }

    mapping(address => StakeInfo[]) private userStakes;

    event Staked(
        address indexed user,
        uint256 indexed stakeId,
        uint256 amount,
        uint256 unlockTime,
        uint256 daysCount,
        uint16 apyBps,
        uint256 reward
    );
    event Withdrawn(address indexed user, uint256 indexed stakeId, uint256 amount, uint256 reward);
    event UnreservedRewardsWithdrawn(address indexed to, uint256 amount);
    event UnsupportedTokenRecovered(address indexed tokenAddress, address indexed to, uint256 amount);

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address is zero");
        token = IERC20(tokenAddress);
    }

    function stake(uint256 amount, uint256 daysCount) external nonReentrant {
        require(amount > 0, "Amount is zero");
        require(daysCount >= MIN_STAKE_DAYS, "Minimum stake is 30 days");
        require(daysCount <= MAX_STAKE_DAYS, "Stake period too long");

        uint16 apyBps = apyForDays(daysCount);
        uint256 reward = calculateReward(amount, daysCount);
        require(rewardPoolAvailable() >= reward, "Reward pool too low");

        uint256 unlockTime = block.timestamp + (daysCount * 1 days);

        token.safeTransferFrom(msg.sender, address(this), amount);

        userStakes[msg.sender].push(StakeInfo({
            amount: amount,
            startTime: block.timestamp,
            unlockTime: unlockTime,
            apyBps: apyBps,
            reward: reward,
            withdrawn: false
        }));

        totalPrincipalLocked += amount;
        totalRewardsReserved += reward;
        totalPrincipalOf[msg.sender] += amount;

        emit Staked(
            msg.sender,
            userStakes[msg.sender].length - 1,
            amount,
            unlockTime,
            daysCount,
            apyBps,
            reward
        );
    }

    function withdraw(uint256 stakeId) external nonReentrant {
        require(stakeId < userStakes[msg.sender].length, "Invalid stake id");

        StakeInfo storage stakeInfo = userStakes[msg.sender][stakeId];

        require(!stakeInfo.withdrawn, "Already withdrawn");
        require(block.timestamp >= stakeInfo.unlockTime, "Still locked");

        uint256 amount = stakeInfo.amount;
        uint256 reward = stakeInfo.reward;

        stakeInfo.withdrawn = true;
        totalPrincipalLocked -= amount;
        totalRewardsReserved -= reward;
        totalPrincipalOf[msg.sender] -= amount;

        token.safeTransfer(msg.sender, amount + reward);

        emit Withdrawn(msg.sender, stakeId, amount, reward);
    }

    function apyForDays(uint256 daysCount) public pure returns (uint16) {
        require(daysCount >= MIN_STAKE_DAYS, "Minimum stake is 30 days");

        if (daysCount < 90) {
            return 300;
        }

        if (daysCount < 180) {
            return 500;
        }

        if (daysCount < 365) {
            return 650;
        }

        return 800;
    }

    function calculateReward(uint256 amount, uint256 daysCount) public pure returns (uint256) {
        uint16 apyBps = apyForDays(daysCount);
        return (amount * apyBps * daysCount) / (YEAR_DAYS * BPS_DENOMINATOR);
    }

    function rewardPoolAvailable() public view returns (uint256) {
        uint256 balance = token.balanceOf(address(this));
        uint256 reserved = totalPrincipalLocked + totalRewardsReserved;

        if (balance <= reserved) {
            return 0;
        }

        return balance - reserved;
    }

    function pendingReward(address user, uint256 stakeId) external view returns (uint256) {
        require(stakeId < userStakes[user].length, "Invalid stake id");

        StakeInfo memory stakeInfo = userStakes[user][stakeId];
        if (stakeInfo.withdrawn) {
            return 0;
        }

        return stakeInfo.reward;
    }

    function canWithdraw(address user, uint256 stakeId) external view returns (bool) {
        if (stakeId >= userStakes[user].length) {
            return false;
        }

        StakeInfo memory stakeInfo = userStakes[user][stakeId];
        return !stakeInfo.withdrawn && block.timestamp >= stakeInfo.unlockTime;
    }

    function getStake(address user, uint256 stakeId) external view returns (StakeInfo memory) {
        require(stakeId < userStakes[user].length, "Invalid stake id");
        return userStakes[user][stakeId];
    }

    function getStakes(address user) external view returns (StakeInfo[] memory) {
        return userStakes[user];
    }

    function getStakesCount(address user) external view returns (uint256) {
        return userStakes[user].length;
    }

    function withdrawUnreservedRewards(address to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "Recipient is zero");
        require(amount <= rewardPoolAvailable(), "Amount exceeds available rewards");

        token.safeTransfer(to, amount);

        emit UnreservedRewardsWithdrawn(to, amount);
    }

    function recoverUnsupportedToken(address tokenAddress, address to, uint256 amount) external onlyOwner nonReentrant {
        require(tokenAddress != address(token), "Cannot recover staking token");
        require(to != address(0), "Recipient is zero");

        IERC20(tokenAddress).safeTransfer(to, amount);

        emit UnsupportedTokenRecovered(tokenAddress, to, amount);
    }
}
