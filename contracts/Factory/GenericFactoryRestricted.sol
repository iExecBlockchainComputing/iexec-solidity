pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "./GenericFactory.sol";


contract GenericFactoryRestricted is GenericFactory, MinterRole
{

	constructor(address _minter)
	public
	{
		if (_minter != address(0))
		{
			renounceMinter();
			_addMinter(_minter);
		}
	}

	function createContract(bytes memory _code, bytes32 _salt)
	public onlyMinter() returns(address)
	{
		return super.createContract(_code, _salt);
	}

	function createContractAndCallback(bytes memory _code, bytes32 _salt, bytes memory _callback)
	public onlyMinter() returns(address)
	{
		return super.createContractAndCallback(_code, _salt, _callback);
	}
}
