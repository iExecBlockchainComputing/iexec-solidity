pragma solidity ^0.6.0;

contract TestContract
{
	string  public constant id = "TestContract";
	address public caller;
	bytes   public value;

	fallback() external payable
	{
		revert("fallback should revert");
	}

	function set(bytes calldata _value) external
	{
		caller = msg.sender;
		value  = _value;
	}

}
