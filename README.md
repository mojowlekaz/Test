# Sample Hardhat Project

# Blockchain Developer Technical Test - Staking Contract

This project is a solution for the Solidity task in the Blockchain Developer Technical Test. The goal is to create a secure and efficient staking smart contract on Ethereum that meets the provided requirements.

## Objective

The staking contract allows users to:

1. Stake ERC20 tokens.
2. Earn rewards proportional to the staking duration.
3. Withdraw staked tokens and rewards after a minimum lock-in period of 7 days.

## Features

- **Staking Tokens**: Users can stake a specified amount of ERC20 tokens.
- **Reward Calculation**: Rewards are accrued based on the staking duration.
- **Token Withdrawal**: Users can withdraw both staked tokens and rewards after 7 days.
- **Secure Design**:
  - Uses OpenZeppelin's ERC20 standard for token handling.
  - Implements non-reentrancy protection.
  - Includes clear error messages with `require`.

## Functions

### `stake(uint256 amount)`

- Allows users to stake a specified amount of ERC20 tokens.
- Transfers tokens from the user's wallet to the contract.
- Emits a `Staked` event.

### `withdraw()`

- Lets users withdraw staked tokens and rewards after the lock-in period.
- Requires that the user has staked tokens and the 7-day period has elapsed.
- Emits `WithdrawRewardToken` and `WithdrawStakedToken` events.

### `getReward(address user)`

- Returns the reward amount for a specific user.
- Calculates rewards based on the staking duration.

## Contract Highlights

- **Modifiers**:
  - `onlyafter7days`: Ensures rewards can only be claimed after 7 days.
- **Events**:
  - `Staked(address indexed user, uint256 amount, address indexed tokenAddress)`
  - `WithdrawRewardToken(address indexed user, address indexed tokenAddress, uint256 reward)`
  - `WithdrawStakedToken(address indexed user, uint256 amount)`

## Testing

Test cases are written using JavaScript with Hardhat. They validate the following functionalities:

1. **Staking Tokens**:

   - Verify that users can stake tokens.
   - Check that the staked amount updates correctly.

2. **Reward Calculation**:

   - Validate that rewards are calculated accurately based on staking duration.

3. **Token and Reward Withdrawal**:

   - Ensure users can withdraw tokens and rewards after the lock-in period.
   - Test for failure scenarios (e.g., attempting to withdraw before 7 days).

4. **Security**:
   - Confirm protection against reentrancy attacks.
   - Validate error handling for insufficient staking amounts and other invalid operations.

### Running Tests

1. Install dependencies:

```shell
npm install
npx hardhat compile
npx hardhat test

```
