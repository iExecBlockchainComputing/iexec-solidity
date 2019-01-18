pragma solidity ^0.5.0;

import "./IERC725.sol";
import "../libs/KeyStoreLib.sol";

/// @title KeyManager
/// @author Mircea Pasoi
/// @notice Implement add/remove functions from ERC725 spec
/// @dev Key data is stored using KeyStore library. Inheriting ERC725 for the events

contract ERC725KeyBase is IERC725Key
{
	// Key storage
	using KeyStoreLib for KeyStoreLib.Keys;
	KeyStoreLib.Keys internal m_keys;

	/// @dev Convert an Ethereum address (20 bytes) to an ERC725 key (32 bytes)
	function addrToKey(address addr)
	public
	pure
	returns (bytes32)
	{
		return keccak256(abi.encodePacked(addr));
	}

	/// @dev Modifier that only allows keys of purpose 1, or the identity itself
	modifier onlyManagement
	{
		require(m_keys.find(addrToKey(msg.sender), MANAGEMENT_KEY));
		_;
	}
}
