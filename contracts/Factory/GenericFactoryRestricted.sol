pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/roles/WhitelistedRole.sol";
import "./GenericFactory.sol";


contract GenericFactoryRestricted is GenericFactory, WhitelistedRole
{
	constructor(address _minter)
	public
	{
		if (_minter != address(0))
		{
			renounceWhitelistAdmin();
			_addWhitelistAdmin(_minter);
		}
	}

	function createContract(bytes memory _code, bytes32 _salt)
	public onlyWhitelisted() returns(address)
	{
		return super.createContract(_code, _salt);
	}

	function createContractAndCallback(bytes memory _code, bytes32 _salt, bytes memory _callback)
	public onlyWhitelisted() returns(address)
	{
		return super.createContractAndCallback(_code, _salt, _callback);
	}
}
