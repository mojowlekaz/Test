//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract StakingContract is ReentrancyGuard {

    modifier onlyafter7days(address user)  {
        uint256 userstakedperiod = userstakeInfo[user].time;
        uint256 userTokenstaked = userstakeInfo[user].amountStaked;
        uint256 stakedPeriod = (block.timestamp - userstakedperiod);
        require(stakedPeriod  >= 7 days, "Minimum staking period is 7 days"); 
        
        _;
    }
 

    //mapping
    mapping(address => UserStakeInfo) public userstakeInfo;
    mapping(address => mapping(address => uint256)) public UniquelyStaked;


    uint256 public totalStake;
    uint256 public rewardRate = 10;
    uint256 public time = 365;
    //struct
    struct UserStakeInfo {
        address user;
        uint256 amountStaked;
        uint256 time;
    }

    //custom error
    error paramsError(string);
    error funcError();

    //events
    event Staked(address indexed user, uint256 indexed amount, uint256 time);
    event WithdrawStakedToken(address indexed user, address indexed token, uint256 amount);
    event WithdrawRewardToken(address indexed user, address indexed token, uint256 amount);

    function stake(uint256 amount, address tokenAddress) external nonReentrant returns(bool) {
        if(amount < 0) revert paramsError("invalid amount ");
        if(tokenAddress == address(0)) revert paramsError("incorrect token address");
        bool transferStatus = ERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        require(transferStatus, "Token transferFrom failed");
        userstakeInfo[msg.sender] = UserStakeInfo({user: msg.sender, amountStaked: amount, time: block.timestamp});
        totalStake += amount;
        UniquelyStaked[tokenAddress][msg.sender] = amount;
        emit Staked(msg.sender, amount, block.timestamp);
        return true;
    }
    

    function withdrawStakedToken(uint256 amount, address tokenAddress) external nonReentrant {
     if(amount < 0) revert paramsError("invalid amount ");
     if(tokenAddress == address(0)) revert paramsError("incorrect token address");
     require(amount <= userstakeInfo[msg.sender].amountStaked, "Insufficient Amount staked");
     require(UniquelyStaked[tokenAddress][msg.sender] >= amount, "You did not stake this token");
     userstakeInfo[msg.sender].amountStaked -= amount;
     UniquelyStaked[tokenAddress][msg.sender] -= amount;
     bool transferStatus = ERC20(tokenAddress).transfer(msg.sender, amount);
     require(transferStatus, "Token Transfer failed");
     emit WithdrawStakedToken(msg.sender, tokenAddress, amount);
    }

    function withdrawReward(address user, address tokenAddress) public  nonReentrant onlyafter7days(user){
        uint256 reward = calculateReward(user);
        require(userstakeInfo[user].amountStaked > 0, "You did not stake token");
        require(UniquelyStaked[tokenAddress][msg.sender] >= reward, "You did not stake this token");
        require(ERC20(tokenAddress).balanceOf(address(this)) > reward, "Insufficient token in contract");
        bool transferStatus =  ERC20(tokenAddress).transfer(msg.sender, reward);
        require(transferStatus, "Token Transfer failed");
        emit WithdrawRewardToken(msg.sender, tokenAddress, reward);
    }

    function calculateReward(address user) public view returns(uint256 reward){
        uint256 userstakedperiod = userstakeInfo[user].time;
        uint256 userTokenstaked = userstakeInfo[user].amountStaked;
        uint256 stakedPeriod = (block.timestamp - userstakedperiod) / 1 days ;
        // require(stakedPeriod  >= 7, "MInimum staking period is 7 days");
        reward = (userTokenstaked * rewardRate * stakedPeriod) / 100;

    }

    function getReward(address user, address tokenAddress) public view returns(uint256) {
        uint256 reward = calculateReward(user);
        require(userstakeInfo[user].amountStaked > 0, "You did not stake token");
        require(UniquelyStaked[tokenAddress][msg.sender] >= reward, "You did not stake this token");
        return reward;
    }
}