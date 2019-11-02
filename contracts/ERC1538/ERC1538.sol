pragma solidity ^0.5.10;

import "./ERC1538Store.sol";

contract ERC1538 is ERC1538Store
{
	bytes4 constant internal FALLBACK = bytes4(keccak256("fallback"));

	event CommitMessage(string message);
	event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

	constructor()
	public
	{
		renounceOwnership();
	}

	function _setFunc(bytes memory funcSignature, address funcDelegate)
	internal
	{
		bytes4 funcId = bytes4(keccak256(funcSignature));
		if (funcId == FALLBACK)
		{
			funcId = bytes4(0);
		}

		address oldDelegate = m_funcDelegates.value(funcId);
		if (funcDelegate == address(0))
		{
			m_funcDelegates.remove(funcId);
			delete m_funcSignatures[funcId];
		}
		else
		{
			m_funcDelegates.set(funcId, funcDelegate);
			m_funcSignatures[funcId] = funcSignature;
		}

		emit FunctionUpdate(funcId, oldDelegate, funcDelegate, string(funcSignature));
	}
}
