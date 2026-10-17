// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HostelIssueTracker {
    address public warden;
    uint256 public issueCount;

    struct Issue {
        uint256 id;
        string roomNumber;
        string description;
        address reportedBy;
        bool isResolved;
        uint256 timestamp;
    }

    mapping(uint256 => Issue) public issues;

    event IssueReported(uint256 indexed id, string roomNumber, string description, address indexed reportedBy);
    event IssueResolved(uint256 indexed id, address indexed resolvedBy);

    // Constructor sets the contract deployer as the Hostel Warden
    constructor() {
        warden = msg.sender;
        issueCount = 0;
    }

    // Modifier to restrict actions to the Warden only (for Unauthorised input testing)
    modifier onlyWarden() {
        require(msg.sender == warden, "Unauthorised: Only the Hostel Warden can perform this action");
        _;
    }

    // 1. Function for students to report a maintenance issue
    function reportIssue(string memory _roomNumber, string memory _description) public {
        // Input Validation (for Invalid input testing)
        require(bytes(_roomNumber).length > 0, "Invalid Input: Room number cannot be empty");
        require(bytes(_description).length > 0, "Invalid Input: Issue description cannot be empty");

        issueCount++;
        issues[issueCount] = Issue(
            issueCount,
            _roomNumber,
            _description,
            msg.sender,
            false,
            block.timestamp
        );

        emit IssueReported(issueCount, _roomNumber, _description, msg.sender);
    }

    // 2. Function for the warden to resolve an issue
    function resolveIssue(uint256 _id) public onlyWarden {
        require(_id > 0 && _id <= issueCount, "Invalid Input: Issue ID does not exist");
        require(!issues[_id].isResolved, "Invalid Input: Issue is already resolved");

        issues[_id].isResolved = true;
        emit IssueResolved(_id, msg.sender);
    }

    // 3. Function to fetch all issues for the frontend
    function getAllIssues() public view returns (Issue[] memory) {
        Issue[] memory allIssues = new Issue[](issueCount);
        for (uint256 i = 1; i <= issueCount; i++) {
            allIssues[i - 1] = issues[i];
        }
        return allIssues;
    }
}