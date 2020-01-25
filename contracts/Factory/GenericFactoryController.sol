pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./GenericFactory.sol";


contract GenericFactoryController is Ownable
{
	GenericFactory              public factory;
	mapping(address => uint256) public dailyLimit;
	mapping(address => uint256) public lastUse;
	mapping(address => uint256) public lastUseCount;

	/**
	 * Modifiers
	 */
	modifier limited()
	{
		if (lastUse[msg.sender] != _today())
		{
			lastUse     [msg.sender] = _today();
			lastUseCount[msg.sender] = 0;
		}
		require(lastUseCount[msg.sender] < dailyLimit[msg.sender], "daily-limit-exceeded");
		lastUseCount[msg.sender] += 1;
		_;
	}

	/**
	 * Constructor
	 */
	constructor(address _factory)
	public
	{
		factory = GenericFactory(_factory);
	}

	/**
	 * Methods
	 */
	function setDailyLimit(address _user, uint256 _limit)
	public onlyOwner()
	{
		dailyLimit[_user] = _limit;
	}

	function createContract(bytes memory _code, bytes32 _salt)
	public limited() returns (address)
	{
		return factory.createContract(_code, _salt);
	}

	function createContractAndCall(bytes memory _code, bytes32 _salt, bytes memory _call)
	public limited() returns (address)
	{
		return factory.createContractAndCall(_code, _salt, _call);
	}

	/**
	 * Internal tools
	 */
	function _today()
	internal view returns (uint256)
	{
		return now / 1 days;
	}
}
