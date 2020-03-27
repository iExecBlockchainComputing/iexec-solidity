pragma solidity ^0.6.0;

contract TestContract
{
	string  public constant id = "TestContract";
	address public caller;
	bytes   public value;

	event Receive(uint256 value, bytes data);
	event Fallback(uint256 value, bytes data);

	receive()
	external payable
	{
		emit Receive(msg.value, msg.data);
	}

	fallback()
	external payable
	{
		emit Fallback(msg.value, msg.data);
	}

	function set(bytes calldata _value)
	external
	{
		caller = msg.sender;
		value  = _value;
	}
}
