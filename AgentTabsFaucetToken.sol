// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AgentTabsFaucetToken {
    string public constant name = "Agent Tabs Test Settlement Token";
    string public constant symbol = "ATST";
    uint8 public constant decimals = 18;

    uint256 public constant CLAIM_AMOUNT = 5 ether;
    uint256 public constant CLAIM_COOLDOWN = 1 days;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public lastClaimAt;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Claimed(address indexed account, uint256 amount, uint256 nextClaimAt);

    function claim() external {
        require(block.timestamp >= lastClaimAt[msg.sender] + CLAIM_COOLDOWN, "CLAIM_COOLDOWN");

        lastClaimAt[msg.sender] = block.timestamp;
        _mint(msg.sender, CLAIM_AMOUNT);

        emit Claimed(msg.sender, CLAIM_AMOUNT, block.timestamp + CLAIM_COOLDOWN);
    }

    function nextClaimAt(address account) external view returns (uint256) {
        uint256 claimedAt = lastClaimAt[account];
        return claimedAt == 0 ? 0 : claimedAt + CLAIM_COOLDOWN;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 approved = allowance[from][msg.sender];
        require(approved >= amount, "ALLOWANCE");

        if (approved != type(uint256).max) {
            allowance[from][msg.sender] = approved - amount;
        }

        _transfer(from, to, amount);
        return true;
    }

    function _mint(address to, uint256 amount) private {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "ZERO_RECIPIENT");
        require(balanceOf[from] >= amount, "BALANCE");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}
