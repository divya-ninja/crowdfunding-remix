// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // project owner
    address public owner;
    // The funding goal in wei
    uint public fundingGoal;
    // funding deadline (Unix timestamp)
    uint public deadline;
    // to keep track of contributions
    mapping(address => uint) public contributions;
    // Current amount raised
    uint public currentAmount;

    constructor(uint _goalInEth, uint _durationInDays) {
        owner = msg.sender; // deployer will be project owner
        fundingGoal = _goalInEth * 1 ether;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized since you are not project owner");
        _;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Crowdfunding has ended.");
        require(msg.value > 0, "Contribution must be greater than 0.");
        contributions[msg.sender] += msg.value;
        currentAmount += msg.value;
    }

    function hasReachedGoal() public view returns (bool) {
        return currentAmount >= fundingGoal;
    }

    function withdrawFunds() public onlyOwner {
        require(hasReachedGoal(), "Funding goal has not met");
        payable(owner).transfer(currentAmount);
        currentAmount = 0;
    }

    // to withdraw the funding amount by contributors if deadline has expired and funding goal not met
    function refund() public {
        require(block.timestamp >= deadline, "The campaign is still active.");
        require(!hasReachedGoal(), "The funding goal has been reached.");
        require(contributions[msg.sender] > 0, "You have not contributed.");
        uint refundAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
