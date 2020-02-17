pragma solidity ^0.6.0;

import "../Upgradeability/Proxy.sol";
import "./ERC1538.sol";


contract ERC1538Proxy is ERC1538, Proxy
{
	event CommitMessage(string message);
	event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

	constructor(address _erc1538Delegate)
	public
	{
		_transferOwnership(msg.sender);
		_setFunc("updateContract(address,string,string)", _erc1538Delegate);
		emit CommitMessage("Added ERC1538 updateContract function at contract creation");
	}

	function _implementation() internal override view returns (address)
	{
		return m_funcs.value1(msg.sig);
	}
}
