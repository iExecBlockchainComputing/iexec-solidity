pragma solidity >=0.4.24;

interface IENS
{
	event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
	event Transfer(bytes32 indexed node, address owner);
	event NewResolver(bytes32 indexed node, address resolver);
	event NewTTL(bytes32 indexed node, uint64 ttl);
	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

	function setRecord(bytes32, address, address, uint64) external;
	function setSubnodeRecord(bytes32, bytes32, address, address, uint64) external;
	function setSubnodeOwner(bytes32, bytes32, address) external returns(bytes32);
	function setResolver(bytes32, address) external;
	function setOwner(bytes32, address) external;
	function setTTL(bytes32, uint64) external;
	function setApprovalForAll(address, bool) external;
	function owner(bytes32) external view returns (address);
	function resolver(bytes32) external view returns (address);
	function ttl(bytes32) external view returns (uint64);
	function recordExists(bytes32) external view returns (bool);
	function isApprovedForAll(address, address) external view returns (bool);
}
