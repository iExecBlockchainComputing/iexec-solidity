pragma solidity ^0.5.0;

import "./ERC725Pausable.sol";

/// @title MultiSig
/// @author Mircea Pasoi
/// @notice Implement execute and multi-sig functions from ERC725 spec
/// @dev Key data is stored using KeyStore library. Inheriting ERC725 for the getters

contract ERC725MultiSig is ERC725Pausable
{
	// To prevent replay attacks
	uint256 private nonce = 1;

	struct Execution
	{
		address to;
		uint256 value;
		bytes   data;
	}

	mapping (uint256 => Execution) public executions;
	mapping (uint256 => bytes32[]) public approved;

	/// @dev Generate a unique ID for an execution request
	/// @param _to address being called (msg.sender)
	/// @param _value ether being sent (msg.value)
	/// @param _data ABI encoded call data (msg.data)
	function execute(
		address        _to,
		uint256        _value,
		bytes calldata _data
	)
	external
	whenNotPaused
	returns (uint256 executionId)
	{
		require(_to != address(0));

		require(m_keys.find(
			addrToKey(msg.sender),
			_to == address(this) ? MANAGEMENT_KEY : ACTION_KEY
		));

		// Generate id and increment nonce
		executionId = getExecutionId(address(this), _to, _value, _data, nonce);
		emit ExecutionRequested(executionId, _to, _value, _data);
		nonce++;

		if (msg.sender != address(this))
		{
			executions[executionId].to    = _to;
			executions[executionId].value = _value;
			executions[executionId].data  = _data;
			approved[executionId].push(addrToKey(msg.sender));
		}

		uint256 threshold = (_to == address(this)) ? managementThreshold : actionThreshold;
		if (approved[executionId].length >= threshold)
		{
			_execute(executionId, _to, _value, _data);
		}

		return executionId;
	}

	/// @dev Approves an execution. If the execution is being approved multiple times,
	///  it will throw an error. Disapproving multiple times will work i.e. not do anything.
	///  The approval could potentially trigger an execution (if the threshold is met).
	/// @param _id Execution ID
	/// @param _approve `true` if it's an approval, `false` if it's a disapproval
	/// @return `false` if it's a disapproval and there's no previous approval from the sender OR
	///  if it's an approval that triggered a failed execution. `true` if it's a disapproval that
	///  undos a previous approval from the sender OR if it's an approval that succeded OR
	///  if it's an approval that triggered a succesful execution
	function approve(uint256 _id, bool _approve)
	external
	whenNotPaused
	returns (bool success)
	{
		Execution storage execution = executions[_id];
		bytes32 senderkey = addrToKey(msg.sender);

		// Must exist
		require(execution.to != address(0));

		// Must be approved with the right key
		require(m_keys.find(
			senderkey,
			execution.to == address(this) ? MANAGEMENT_KEY : ACTION_KEY
		));

		emit Approved(_id, _approve);

		bytes32[] storage approvals = approved[_id];
		if (_approve)
		{
			// Only approve once
			bool newApproval = true;
			for (uint256 i = 0; i < approvals.length; ++i)
			{
				if (approvals[i] == senderkey)
				{
					newApproval = false;
					break;
				}
			}
			if (newApproval)
			{
				// Approve
				approvals.push(senderkey);
			}

			uint256 threshold = (execution.to == address(this)) ? managementThreshold : actionThreshold;
			if (approvals.length >= threshold)
			{
				_execute(_id, execution.to, execution.value, execution.data);
				delete executions[_id];
				delete approved[_id];
			}
			return true;
		}
		else
		{
			// Find in approvals
			for (uint256 i = 0; i < approvals.length; ++i)
			{
				if (approvals[i] == senderkey)
				{
					// Undo approval
					approvals[i] = approvals[approvals.length - 1];
					delete approvals[approvals.length - 1];
					approvals.length--;
					return true;
				}
			}
			return false;
		}
	}

	/// @dev Change multi-sig threshold for MANAGEMENT_KEY
	/// @param _threshold New threshold to change it to (will throw if 0 or larger than available keys)
	function changeManagementThreshold(uint256 _threshold)
	external
	whenNotPaused
	onlyManagement
	{
		// Don't lock yourself out
		require(_threshold > 0 && _threshold <= m_keys.keysByPurpose[MANAGEMENT_KEY].length);
		managementThreshold = _threshold;
	}

	/// @dev Change multi-sig threshold for ACTION_KEY
	/// @param _threshold New threshold to change it to (will throw if 0 or larger than available keys)
	function changeActionThreshold(uint256 _threshold)
	external
	whenNotPaused
	onlyManagement
	{
		// Don't lock yourself out
		require(_threshold > 0 && _threshold <= m_keys.keysByPurpose[ACTION_KEY].length);
		actionThreshold = _threshold;
	}

	/// @dev Generate a unique ID for an execution request
	/// @param self address of identity contract
	/// @param _to address being called (msg.sender)
	/// @param _value ether being sent (msg.value)
	/// @param _data ABI encoded call data (msg.data)
	/// @param _nonce nonce to prevent replay attacks
	/// @return Integer ID of execution request
	function getExecutionId(
		address      self,
		address      _to,
		uint256      _value,
		bytes memory _data,
		uint256      _nonce
	)
	private
	pure
	returns (uint256)
	{
		return uint256(keccak256(abi.encodePacked(self, _to, _value, _data, _nonce)));
	}

	/// @dev Executes an action on other contracts, or itself, or a transfer of ether
	/// @param _id Execution ID
	/// @param _to Execution target
	/// @param _value Execution value
	/// @param _data Execution data
	/// @return `true` if the execution succeeded, `false` otherwise
	function _execute(
		uint256      _id,
		address      _to,
		uint256      _value,
		bytes memory _data
	)
	private
	returns (bool)
	{
		// Call
		// TODO: Should we also support DelegateCall and Create (new contract)?
		// solhint-disable-next-line avoid-call-value
		bool success;
 		(success, /*returndata*/) = _to.call.value(_value)(_data);
		if (success)
		{
			emit Executed(_id, _to, _value, _data);
		}
		else
		{
			emit ExecutionFailed(_id, _to, _value, _data);
		}
		return success;
	}
}
