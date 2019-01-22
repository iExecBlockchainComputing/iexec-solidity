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
		bytes calldata _signature
	)
	external returns (uint256)
	{
		// uint256 gasBefore = gasleft();

		bytes32 key = addrToKey(
			keccak256(abi.encode(
				address(this),
				_to,
				_value,
				_data,
				_nonce,
				uint256(0),
				uint256(0),
				address(0)
			))
			.toEthSignedMessageHash()
			.recover(_signature)
		);

		// Check nonce
		require(_nonce == m_keynonces[key], "Invalid nonce");
		m_keynonces[key]++;

		uint256 executionId = _execute(key, _to, _value, _data);

		// refund(gasBefore.sub(gasleft()).min(_gas), _gasPrice, _gasToken);
		return executionId;
	}

	function approveSigned(
		uint256        _id,
		bool           _value,
		uint256        _nonce,
		bytes calldata _signature
	)
	external returns (bool)
	{
		// uint256 gasBefore = gasleft();

		bytes32 key = addrToKey(
			keccak256(abi.encode(
				address(this),
				_id,
				_value,
				_nonce,
				uint256(0),
				uint256(0),
				address(0)
			))
			.toEthSignedMessageHash()
			.recover(_signature)
		);

		// Check nonce
		require(_nonce == m_keynonces[key], "Invalid nonce");
		m_keynonces[key]++;

		bool success = _approve(key, _id, _value);

		// refund(gasBefore.sub(gasleft()).min(_gas), _gasPrice, _gasToken);
		return success;
	}

}
