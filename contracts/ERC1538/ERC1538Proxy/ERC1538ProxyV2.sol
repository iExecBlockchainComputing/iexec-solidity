pragma solidity ^0.6.0;

import "../../Upgradeability/Proxy.sol";
import "../ERC1538Core.sol";


contract ERC1538ProxyV2 is ERC1538Core, Proxy
{
	constructor(address _erc1538Delegate)
	public
	{
		_transferOwnership(msg.sender);
		_setFunc("updateContract(address,string[],string)", _erc1538Delegate);
		emit CommitMessage("Added ERC1538 updateContract function at contract creation");
	}

	function _implementation() internal override view returns (address)
	{
		address delegateFunc = m_funcs.value1(msg.sig);

		if (delegateFunc != address(0))
		{
			return delegateFunc;
		}
		else
		{
			return m_funcs.value1(0xFFFFFFFF);
		}
	}
}
