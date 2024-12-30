const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StakingContract", function () {
  let stakingContract;
  let token;
  let owner, addr1, addr2;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy ERC20 Token
    const Token = await ethers.getContractFactory("MyToken");
    token = await Token.deploy(
      "Test Token",
      "TT",
      ethers.utils.parseEther("10000")
    );
    await token.deployed();

    // Deploy Staking Contract
    const StakingContract = await ethers.getContractFactory("StakingContract");
    stakingContract = await StakingContract.deploy();
    await stakingContract.deployed();

    // Transfer tokens to addr1 for testing
    await token.transfer(addr1.address, ethers.utils.parseEther("1000"));
  });

  it("Should allow staking of tokens", async function () {
    const amount = ethers.utils.parseEther("100");
    await token.connect(addr1).approve(stakingContract.address, amount);

    // Stake tokens
    const tx = await stakingContract
      .connect(addr1)
      .stake(amount, token.address);
    const receipt = await tx.wait();
    const event = receipt.events.find((e) => e.event === "Staked");

    // Get the timestamp from the blockchain
    const blockTimestamp = (await ethers.provider.getBlock(receipt.blockNumber))
      .timestamp;

    const emittedTimestamp = event.args[2];
    expect(Math.abs(emittedTimestamp - blockTimestamp)).to.be.lessThanOrEqual(
      1
    );

    // Check staking info
    const stakeInfo = await stakingContract.userstakeInfo(addr1.address);
    expect(stakeInfo.amountStaked).to.equal(amount);
  });

  it("Should calculate rewards correctly", async function () {
    // Fast-forward 7 days
    await ethers.provider.send("evm_increaseTime", [7 * 24 * 60 * 60]);
    await ethers.provider.send("evm_mine");

    const reward = await stakingContract.calculateReward(addr1.address);
    expect(reward).to.be.above(0);
  });

  it("Should allow withdrawal of rewards", async function () {
    // Arrange: Stake tokens first
    const stakeAmount = ethers.utils.parseEther("100");
    await token.connect(addr1).approve(stakingContract.address, stakeAmount);
    await stakingContract.connect(addr1).stake(stakeAmount, token.address);

    // Act: Wait for 7 days to accumulate rewards (simulate time passage)
    await network.provider.send("evm_increaseTime", [7 * 24 * 60 * 60]); // 7 days in seconds
    await network.provider.send("evm_mine");

    const reward = await stakingContract.calculateReward(addr1.address);
    const initialBalance = await token.balanceOf(addr1.address);

    // Withdraw rewards
    await expect(
      stakingContract
        .connect(addr1)
        .withdrawReward(addr1.address, token.address)
    )
      .to.emit(stakingContract, "WithdrawRewardToken")
      .withArgs(addr1.address, token.address, reward);

    // Assert: Verify reward withdrawal
    const finalBalance = await token.balanceOf(addr1.address);
    expect(finalBalance.sub(initialBalance)).to.equal(reward); // Ensure the reward is added to the user's balance
  });

  it("Should allow withdrawal of staked tokens", async function () {
    const stakeAmount = ethers.utils.parseEther("20");

    // Withdraw staked tokens
    await expect(
      stakingContract
        .connect(addr1)
        .withdrawStakedToken(stakeAmount, token.address)
    )
      .to.emit(stakingContract, "WithdrawStakedToken")
      .withArgs(addr1.address, token.address, stakeAmount);

    // Verify stake info
    const stakeInfo = await stakingContract.userstakeInfo(addr1.address);
    expect(stakeInfo.amountStaked).to.equal(80000000000000000000n);
  });
});
