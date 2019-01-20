pragma solidity ^0.5.0;

contract IERC1077Refund
{
	enum OperationType { CALL, DELEGATECALL, CREATE }

	// Events
	event ExecutedSigned(bytes32 indexed messageHash, uint256 indexed nonce, bool indexed success);

	// Functions
	function lastNonce()
	external view returns (uint256);

	function lastTimestamp()
	external view returns (uint256);

	// function canExecute(
	// 	address       to,
	// 	uint256       value,
	// 	bytes memory  data,
	// 	uint256       nonce,
	// 	uint256       gasPrice,
	// 	address       gasToken,
	// 	uint256       gasLimit,
	// 	OperationType operationType,
	// 	bytes memory  signatures)
	// public view returns (bool);

	function executeSigned(
		address        to,
		uint256        value,
		bytes calldata data,
		uint256        nonce,
		uint256        gasPrice,
		address        gasToken,
		uint256        gasLimit,
		OperationType  operationType,
		bytes calldata signatures)
	external returns (bytes32);
}
