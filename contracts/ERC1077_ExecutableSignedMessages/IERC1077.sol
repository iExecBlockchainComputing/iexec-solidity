pragma solidity ^0.5.0;

contract IERC1077
{
	// Events
	event ExecutedSigned(bytes32 indexed messageHash, uint256 indexed nonce, bool indexed success);

	// Functions
	function lastNonce    () external view returns (uint256);
	function lastTimestamp() external view returns (uint256);

	function executeSigned(
		address        to,
		uint256        value,
		bytes calldata data,
		uint256        nonce,
		bytes calldata signature
	)
	external returns (bytes32);
}
