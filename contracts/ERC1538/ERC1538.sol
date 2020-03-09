pragma solidity ^0.6.0;

import "./ERC1538Store.sol";

contract ERC1538 is ERC1538Store
{
	bytes4 constant internal RECEIVE  = bytes4(keccak256("receive"));
	bytes4 constant internal FALLBACK = bytes4(keccak256("fallback"));

	event CommitMessage(string message);
	event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

	constructor()
	public
	{
		renounceOwnership();
	}

	function _setFunc(string memory funcSignature, address funcDelegate)
	internal
	{
		bytes4 funcId = bytes4(keccak256(bytes(funcSignature)));
		if (funcId == RECEIVE ) { funcId = bytes4(0x00000000); }
		if (funcId == FALLBACK) { funcId = bytes4(0xFFFFFFFF); }

		address oldDelegate = m_funcs.value1(funcId);

		if (funcDelegate == oldDelegate) // No change → skip
		{
			return;
		}
		else if (funcDelegate == address(0)) // Delete
		{
			m_funcs.del(funcId);
		}
		else // Set / Update
		{
			m_funcs.set(funcId, funcDelegate, bytes(funcSignature));
		}

		emit FunctionUpdate(funcId, oldDelegate, funcDelegate, funcSignature);
	}
}
