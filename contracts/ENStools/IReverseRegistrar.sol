pragma solidity >=0.4.24;

import "./IENS.sol";

interface IReverseRegistrar
{
	function ADDR_REVERSE_NODE() external view returns (bytes32);
	function ens() external view returns (IENS);
	function defaultResolver() external view returns (address);
	function claim(address) external returns (bytes32);
	function claimWithResolver(address, address) external returns (bytes32);
	function setName(string calldata) external returns (bytes32);
	function node(address) external pure returns (bytes32);
}
