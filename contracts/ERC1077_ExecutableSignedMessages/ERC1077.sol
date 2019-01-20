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

	uint256 m_lastNonce;
	uint256 m_lastTimestamp;

	function lastNonce()
	external view returns (uint256)
	{
		return m_lastNonce;
	}

	function lastTimestamp()
	external view returns (uint256)
	{
		return m_lastNonce;
	}

	function executeSigned(
		address        to,
		uint256        value,
		bytes calldata data,
		uint256        nonce,
		bytes calldata signature
	)
	external
	returns (bytes32)
	{
		// Check nonce
		require(nonce == m_lastNonce, "Invalid nonce");

		// Hash message
		bytes32 messageHash = keccak256(abi.encodePacked(
			address(this),
			to,
			value,
			data,
			nonce
		));

		// Check signature
		require(m_keys.find(
			addrToKey(messageHash.toEthSignedMessageHash().recover(signature)),
			(to == address(this)) ? MANAGEMENT_KEY : ACTION_KEY
		));

		// Perform call
		bool success;
		// bytes memory resultdata;
		(success, /*resultdata*/) = to.call.value(value)(data);

		// Report
		emit ExecutedSigned(messageHash, nonce, success);
		m_lastNonce++;
		m_lastTimestamp = now;

		return messageHash;
	}

}
