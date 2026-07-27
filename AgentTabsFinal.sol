// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IATST {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract AgentTabsFinal {
    struct Policy { address owner; address agent; address merchant; uint128 perCallLimit; uint128 dailyLimit; uint64 validUntil; bool active; }
    struct Receipt { bytes32 policyId; bytes32 requestId; uint128 amount; uint64 completedAt; bytes32 resultHash; }

    IATST public immutable paymentToken;
    address public immutable admin;
    uint256 private unlocked = 1;
    mapping(address => uint256) public vaultBalance;
    mapping(address => bool) public approvedMerchant;
    mapping(bytes32 => Policy) public policies;
    mapping(bytes32 => bool) public settledRequest;
    mapping(bytes32 => mapping(uint256 => uint256)) public dailySpend;

    event Deposited(address indexed owner, uint256 amount);
    event MerchantStatus(address indexed merchant, bool approved);
    event PolicyCreated(bytes32 indexed policyId, address indexed owner, address indexed agent);
    event ReceiptSettled(bytes32 indexed policyId, bytes32 indexed requestId, uint256 amount);

    modifier onlyAdmin() { require(msg.sender == admin, "ADMIN_ONLY"); _; }
    modifier nonReentrant() { require(unlocked == 1, "REENTRANCY"); unlocked = 2; _; unlocked = 1; }

    constructor(address token) { require(token != address(0), "ZERO_TOKEN"); paymentToken = IATST(token); admin = msg.sender; }

    function setMerchant(address merchant, bool approved) external onlyAdmin {
        approvedMerchant[merchant] = approved;
        emit MerchantStatus(merchant, approved);
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
    }

    function createPolicy(address agent, address merchant, uint128 perCallLimit, uint128 dailyLimit, uint64 validUntil, bytes32 salt) external returns (bytes32 policyId) {
        require(agent != address(0), "ZERO_AGENT");
        require(approvedMerchant[merchant], "MERCHANT_NOT_APPROVED");
        require(perCallLimit > 0 && dailyLimit >= perCallLimit, "INVALID_LIMITS");
        require(validUntil > block.timestamp, "INVALID_EXPIRY");
        policyId = keccak256(abi.encode(msg.sender, agent, merchant, salt));
        require(policies[policyId].owner == address(0), "POLICY_EXISTS");
        policies[policyId] = Policy(msg.sender, agent, merchant, perCallLimit, dailyLimit, validUntil, true);
        emit PolicyCreated(policyId, msg.sender, agent);
    }

    function setPolicyActive(bytes32 policyId, bool active) external { require(msg.sender == policies[policyId].owner, "OWNER_ONLY"); policies[policyId].active = active; }

    function receiptDigest(Receipt calldata receipt) public view returns (bytes32) {
        return keccak256(abi.encodePacked("AGENT_TABS_RECEIPT_V1", block.chainid, address(this), receipt.policyId, receipt.requestId, receipt.amount, receipt.completedAt, receipt.resultHash));
    }

    function settleBatch(Receipt[] calldata receipts, bytes[] calldata signatures) external nonReentrant {
        require(receipts.length > 0 && receipts.length == signatures.length, "LENGTH");
        for (uint256 i; i < receipts.length; i++) {
            Receipt calldata receipt = receipts[i]; Policy storage policy = policies[receipt.policyId];
            require(policy.active && block.timestamp <= policy.validUntil, "INACTIVE");
            require(!settledRequest[receipt.requestId], "SETTLED");
            require(receipt.amount <= policy.perCallLimit && receipt.resultHash != bytes32(0), "BAD_RECEIPT");
            uint256 day = uint256(receipt.completedAt) / 1 days;
            uint256 spent = dailySpend[receipt.policyId][day] + receipt.amount;
            require(spent <= policy.dailyLimit && vaultBalance[policy.owner] >= receipt.amount, "LIMIT");
            require(_recover(_ethHash(receiptDigest(receipt)), signatures[i]) == policy.agent, "BAD_AGENT");
            settledRequest[receipt.requestId] = true; dailySpend[receipt.policyId][day] = spent; vaultBalance[policy.owner] -= receipt.amount;
            require(paymentToken.transfer(policy.merchant, receipt.amount), "PAYMENT_FAILED");
            emit ReceiptSettled(receipt.policyId, receipt.requestId, receipt.amount);
        }
    }

    function _ethHash(bytes32 digest) private pure returns (bytes32) { return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", digest)); }
    function _recover(bytes32 digest, bytes calldata signature) private pure returns (address) {
        require(signature.length == 65, "BAD_SIGNATURE"); bytes32 r; bytes32 s; uint8 v;
        assembly { r := calldataload(signature.offset) s := calldataload(add(signature.offset, 32)) v := byte(0, calldataload(add(signature.offset, 64))) }
        if (v < 27) v += 27; return ecrecover(digest, v, r, s);
    }
}
