// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAgentTabsToken {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract AgentTabsPhase {
    struct Policy {
        address agent;
        address merchant;
        uint128 perCallLimit;
        uint128 dailyLimit;
        uint64 validUntil;
        bool active;
    }

    IAgentTabsToken public immutable paymentToken;
    address public immutable admin;
    bool public enforcePlatformList;
    uint256 private unlocked = 1;

    mapping(address => uint256) public vaultBalance;
    mapping(address => Policy) public policies;
    mapping(address => mapping(uint256 => uint256)) public dailySpend;
    mapping(bytes32 => bool) public spentRequest;
    mapping(address => bool) public platformMerchant;

    event Deposited(address indexed owner, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    event PlatformListMode(bool enabled);
    event PlatformMerchant(address indexed merchant, bool approved);
    event PolicyCreated(address indexed owner, address indexed agent, address indexed merchant, uint256 perCallLimit, uint256 dailyLimit);
    event PaymentSpent(address indexed owner, address indexed agent, address indexed merchant, bytes32 requestId, uint256 amount, bytes32 resultHash);

    modifier onlyAdmin() {
        require(msg.sender == admin, "ADMIN_ONLY");
        _;
    }

    modifier nonReentrant() {
        require(unlocked == 1, "REENTRANCY");
        unlocked = 2;
        _;
        unlocked = 1;
    }

    constructor(address token) {
        require(token != address(0), "ZERO_TOKEN");
        paymentToken = IAgentTabsToken(token);
        admin = msg.sender;
    }

    function setPlatformListMode(bool enabled) external onlyAdmin {
        enforcePlatformList = enabled;
        emit PlatformListMode(enabled);
    }

    function setPlatformMerchant(address merchant, bool approved) external onlyAdmin {
        require(merchant != address(0), "ZERO_MERCHANT");
        platformMerchant[merchant] = approved;
        emit PlatformMerchant(merchant, approved);
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "ZERO_AMOUNT");
        require(paymentToken.transferFrom(msg.sender, address(this), amount), "TRANSFER_FAILED");
        vaultBalance[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(vaultBalance[msg.sender] >= amount, "INSUFFICIENT_BALANCE");
        vaultBalance[msg.sender] -= amount;
        require(paymentToken.transfer(msg.sender, amount), "TRANSFER_FAILED");
        emit Withdrawn(msg.sender, amount);
    }

    function createPolicy(address agent, address merchant, uint128 perCallLimit, uint128 dailyLimit, uint64 validUntil) external {
        require(agent != address(0), "ZERO_AGENT");
        require(merchant != address(0), "ZERO_MERCHANT");
        if (enforcePlatformList) {
            require(platformMerchant[merchant], "MERCHANT_NOT_APPROVED");
        }
        require(perCallLimit > 0 && dailyLimit >= perCallLimit, "INVALID_LIMITS");
        require(validUntil > block.timestamp, "INVALID_EXPIRY");

        policies[msg.sender] = Policy(agent, merchant, perCallLimit, dailyLimit, validUntil, true);
        emit PolicyCreated(msg.sender, agent, merchant, perCallLimit, dailyLimit);
    }

    function setPolicyActive(bool active) external {
        require(policies[msg.sender].agent != address(0), "NO_POLICY");
        policies[msg.sender].active = active;
    }

    function spend(address owner, uint256 amount, bytes32 requestId, bytes32 resultHash) external nonReentrant {
        Policy memory policy = policies[owner];

        require(policy.active && block.timestamp <= policy.validUntil, "INACTIVE");
        require(msg.sender == owner || msg.sender == policy.agent, "AGENT_ONLY");
        if (enforcePlatformList) {
            require(platformMerchant[policy.merchant], "MERCHANT_NOT_APPROVED");
        }
        require(!spentRequest[requestId], "REQUEST_SPENT");
        require(amount > 0 && amount <= policy.perCallLimit, "PER_CALL_LIMIT");
        require(resultHash != bytes32(0), "EMPTY_RESULT");

        uint256 day = block.timestamp / 1 days;
        uint256 newDailySpend = dailySpend[owner][day] + amount;
        require(newDailySpend <= policy.dailyLimit, "DAILY_LIMIT");
        require(vaultBalance[owner] >= amount, "INSUFFICIENT_VAULT");

        spentRequest[requestId] = true;
        dailySpend[owner][day] = newDailySpend;
        vaultBalance[owner] -= amount;

        require(paymentToken.transfer(policy.merchant, amount), "PAYMENT_FAILED");
        emit PaymentSpent(owner, msg.sender, policy.merchant, requestId, amount, resultHash);
    }
}
