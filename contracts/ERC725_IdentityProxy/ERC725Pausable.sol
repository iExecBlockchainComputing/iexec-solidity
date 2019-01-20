pragma solidity ^0.5.0;

import "./ERC725KeyBase.sol";

/// @title Pausable
/// @author Mircea Pasoi
/// @notice Base contract which allows children to implement an emergency stop mechanism
/// @dev Inspired by https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol

contract ERC725Pausable is ERC725KeyBase
{
	event LogPause();
	event LogUnpause();

	bool public paused = false;

	/// @dev Modifier to make a function callable only when the contract is not paused
	modifier whenNotPaused()
	{
		require(!paused);
		_;
	}

	/// @dev Modifier to make a function callable only when the contract is paused
	modifier whenPaused()
	{
		require(paused);
		_;
	}

	/// @dev called by a MANAGEMENT_KEY or the identity itself to pause, triggers stopped state
	function pause()
	public
	onlyManagement
	whenNotPaused
	{
		paused = true;
		emit LogPause();
	}

	/// @dev called by a MANAGEMENT_KEY or the identity itself to unpause, returns to normal state
	function unpause()
	public
	onlyManagement
	whenPaused
	{
		paused = false;
		emit LogUnpause();
	}
}
