pragma solidity ^0.5.0;

import "../Libs/SafeMath.sol";
import "../Libs/ECDSALib.sol";

import "../ERC20_Token/IERC20.sol";
import "../ERC725_IdentityProxy/ERC725.sol";
import "./IERC1077Refund.sol";

contract ERC1077Refund is IERC1077Refund, ERC725
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
		uint256        _gas,
		uint256        _gasPrice,
		address        _gasToken,
		bytes calldata _signature
	)
	external returns (uint256)
	{
		uint256 gasBefore = gasleft();

		// Check nonce
		require(_nonce == m_signatureNonce, "Invalid nonce");

		// Hash message
		bytes32 messageHash = keccak256(abi.encode(
			address(this),
			_to,
			_value,
			_data,
			_nonce,
			_gas,
			_gasPrice,
			_gasToken
		));

		m_signatureNonce++;
		// m_lastTimestamp = now;

		uint256 executionId = _execute(
			addrToKey(messageHash.toEthSignedMessageHash().recover(_signature)),
			_to,
			_value,
			_data
		);

		refund(gasBefore.sub(gasleft()).min(_gas), _gasPrice, _gasToken);
		return executionId;
	}

	function approveSigned(
		uint256        _id,
		bool           _value,
		uint256        _nonce,
		uint256        _gas,
		uint256        _gasPrice,
		address        _gasToken,
		bytes calldata _signature
	)
	external returns (bool)
	{
		uint256 gasBefore = gasleft();

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

		bool success = _approve(
			addrToKey(messageHash.toEthSignedMessageHash().recover(_signature)),
			_id,
			_value
		);

		refund(gasBefore.sub(gasleft()).min(_gas), _gasPrice, _gasToken);

		return success;
	}

	function refund(uint256 gasUsed, uint256 gasPrice, address gasToken)
	private
	{
		if (gasToken != address(0))
		{
			IERC20 token = IERC20(gasToken);
			token.transfer(msg.sender, gasUsed.mul(gasPrice));
		}
		else
		{
			msg.sender.transfer(gasUsed.mul(gasPrice));
		}
	}
}
