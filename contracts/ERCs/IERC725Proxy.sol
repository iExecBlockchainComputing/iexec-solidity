pragma solidity ^0.5.0;

contract IERC725Proxy
{
	// Events
	event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
	event Executed          (uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
	event ExecutionFailed   (uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
	event Approved          (uint256 indexed executionId, bool approved);

	// Functions
	function execute(address _to, uint256 _value, bytes calldata _data) external returns (uint256 executionId);
	function approve(uint256 _id, bool _approve) external returns (bool success);
}
