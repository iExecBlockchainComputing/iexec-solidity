pragma solidity ^0.5.0;

import "../Libs/SafeMath.sol";
import "../Libs/ECDSALib.sol";

import "../ERC20_Token/IERC20.sol";
import "../ERC725_IdentityProxy/ERC725.sol";
import "./IERC1077.sol";

contract ERC1077 is IERC1077, ERC725
{
	using SafeMath for uint256;
	using ECDSALib for bytes32;

	uint256 private m_signatureNonce = 0;

	function lastNonce()
	external view returns (uint256)
	{
		return m_signatureNonce;
	}

	function executeSigned(
		address        _to,
		uint256        _value,
		bytes calldata _data,
		uint256        _nonce,
		bytes calldata _signature
	)
	external returns (uint256)
	{
		// Check nonce
		require(_nonce == m_signatureNonce, "Invalid nonce");

		// Hash message
		bytes32 messageHash = keccak256(abi.encode(
			address(this),
			_to,
			_value,
			_data,
			_nonce
		));

		m_signatureNonce++;
		// m_lastTimestamp = now;

		return _execute(
			addrToKey(messageHash.toEthSignedMessageHash().recover(_signature)),
			_to,
			_value,
			_data
		);
	}

	function approveSigned(
		uint256        _id,
		bool           _value,
		uint256        _nonce,
		bytes calldata _signature
	)
	external returns (bool)
	{
		// Check nonce
		require(_nonce == m_signatureNonce, "Invalid nonce");

		// Hash message
		bytes32 messageHash = keccak256(abi.encode(
			address(this),
			_id,
			_value,
			_nonce
		));

		m_signatureNonce++;
		// m_lastTimestamp = now;

		return _approve(
			addrToKey(messageHash.toEthSignedMessageHash().recover(_signature)),
			_id,
			_value
		);
	}

}
