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

	mapping(bytes32 => uint256) m_keynonces;

	function keyNonce(bytes32 _key)
	external view returns (uint256)
	{
		return m_keynonces[_key];
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

		bytes32 key = addrToKey(
			keccak256(abi.encode(
				address(this),
				_to,
				_value,
				_data,
				_nonce,
				_gas,
				_gasPrice,
				_gasToken
			))
			.toEthSignedMessageHash()
			.recover(_signature)
		);

		// Check nonce
		require(_nonce == m_keynonces[key], "Invalid nonce");
		m_keynonces[key]++;

		uint256 executionId = _execute(key _to, _value, _data);

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

		bytes32 key = addrToKey(
			keccak256(abi.encode(
				address(this),
				_id,
				_value,
				_nonce
				_gas,
				_gasPrice,
				_gasToken
			))
			.toEthSignedMessageHash()
			.recover(_signature)
		);

		// Check nonce
		require(_nonce == m_keynonces[key], "Invalid nonce");
		m_keynonces[key]++;

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
