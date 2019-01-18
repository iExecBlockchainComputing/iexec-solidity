pragma solidity ^0.5.0;

import "../libs/KeyStoreLib.sol";

import "./IERC725Key.sol";

/// @title KeyManager
/// @author Mircea Pasoi
/// @notice Implement add/remove functions from ERC725 spec
/// @dev Key data is stored using KeyStore library. Inheriting ERC725 for the events

contract ERC725Key is IERC725Key
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
		require(msg.sender == address(this) || m_keys.find(addrToKey(msg.sender), MANAGEMENT_KEY));
		_;
	}

	/// @dev Number of keys managed by the contract
	/// @return Unsigned integer number of keys
	function numKeys()
	external
	view
	returns (uint)
	{
		return m_keys.count;
	}

	/// @dev Find the key data, if held by the identity
	/// @param _key Key bytes to find
	/// @return `(purposes, keyType, key)` tuple if the key exists
	function getKey(bytes32 _key)
	external
	view
	returns(uint256[] memory purposes, uint256 keyType, bytes32 key)
	{
		KeyStoreLib.Key storage k = m_keys.keys[_key];
		purposes = k.purposes;
		keyType  = k.keyType;
		key      = k.key;
	}

	/// @dev Find if a key has is present and has the given purpose
	/// @param _key Key bytes to find
	/// @param purpose Purpose to find
	/// @return Boolean indicating whether the key exists or not
	function keyHasPurpose(bytes32 _key, uint256 purpose)
	external
	view
	returns(bool exists)
	{
		return m_keys.find(_key, purpose);
	}

	/// @dev Find all the keys held by this identity for a given purpose
	/// @param _purpose Purpose to find
	/// @return Array with key bytes for that purpose (empty if none)
	function getKeysByPurpose(uint256 _purpose)
	external
	view
	returns(bytes32[] memory keys)
	{
		return m_keys.keysByPurpose[_purpose];
	}

	/// @dev Add key data to the identity if key + purpose tuple doesn't already exist
	/// @param _key Key bytes to add
	/// @param _purpose Purpose to add
	/// @param _keyType Key type to add
	/// @return `true` if key was added, `false` if it already exists
	function addKey(
		bytes32 _key,
		uint256 _purpose,
		uint256 _keyType
	)
	public
	onlyManagement
	returns (bool success)
	{
		if (m_keys.find(_key, _purpose))
		{
			return false;
		}
		m_keys.add(_key, _purpose, _keyType);
		emit KeyAdded(_key, _purpose, _keyType);
		return true;
	}

	/// @dev Remove key data from the identity
	/// @param _key Key bytes to remove
	/// @param _purpose Purpose to remove
	/// @return `true` if key was found and removed, `false` if it wasn't found
	function removeKey(
		bytes32 _key,
		uint256 _purpose
	)
	public
	onlyManagement
	returns (bool success)
	{
		if (!m_keys.find(_key, _purpose))
		{
			return false;
		}
		uint256 keyType = m_keys.remove(_key, _purpose);
		emit KeyRemoved(_key, _purpose, keyType);
		return true;
	}

	/// @dev Add key data to the identity without checking if it already exists
	/// @param _key Key bytes to add
	/// @param _purpose Purpose to add
	/// @param _keyType Key type to add
	function _addKey(
		bytes32 _key,
		uint256 _purpose,
		uint256 _keyType
	)
	internal
	{
		m_keys.add(_key, _purpose, _keyType);
		emit KeyAdded(_key, _purpose, _keyType);
	}
}
