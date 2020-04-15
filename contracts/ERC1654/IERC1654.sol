pragma solidity ^0.6.0;

interface IERC1654
{
	function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bytes4 magicValue);
}
