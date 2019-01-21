pragma solidity ^0.5.0;

import "./ERC725Pausable.sol";

/// @title MultiSig
/// @author Mircea Pasoi
/// @notice Implement execute and multi-sig functions from ERC725 spec
/// @dev Key data is stored using KeyStore library. Inheriting ERC725 for the getters

contract ERC725MultiSig is ERC725Pausable
{
	struct Execution
	{
		address to;
		uint256 value;
		bytes   data;
	}

	// To prevent replay attacks
	uint256 private m_nonce = 0;

	// Execution store
	mapping (uint256 => Execution) public executions;
	mapping (uint256 => bytes32[]) public approved;

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

	/// @dev call a contract method, or transfer ether
	/// @param _id Execution ID
	/// @param _to Execution target
	/// @param _value Execution value
	/// @param _data Execution data
	/// @return `true` if the execution succeeded, `false` otherwise
	function _call(
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
		// bytes memory returndata;
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

	/// @dev Generate a unique ID for an execution request
	/// @param _key identity asking for the execution
	/// @param _to address being called (msg.sender)
	/// @param _value ether being sent (msg.value)
	/// @param _data ABI encoded call data (msg.data)
	function _execute(
		bytes32       _key,
		address       _to,
		uint256       _value,
		bytes memory _data
	)
	internal
	whenNotPaused
	returns (uint256 executionId)
	{
		// Must be required by the right key
		require(m_keys.find(
			_key,
			_to == address(this) ? MANAGEMENT_KEY : ACTION_KEY
		));

		// Generate id and increment nonce
		executionId = uint256(keccak256(abi.encodePacked(
			address(this),
			_to,
			_value,
			_data,
			m_nonce++
		)));

		executions[executionId].to    = _to;
		executions[executionId].value = _value;
		executions[executionId].data  = _data;
		approved[executionId].push(_key);

		emit ExecutionRequested(executionId, _to, _value, _data);

		uint256 threshold = (_to == address(this)) ? managementThreshold : actionThreshold;
		if (approved[executionId].length >= threshold)
		{
			_call(executionId, _to, _value, _data);
			// delete executions[_id];
			// delete approved[_id];
		}

		return executionId;
	}

	/// @dev External api to the execute function that considers the key of msg.sender
	/// @param _to address being called (msg.sender)
	/// @param _value ether being sent (msg.value)
	/// @param _data ABI encoded call data (msg.data)
	function execute(
		address        _to,
		uint256        _value,
		bytes calldata _data
	)
	external
	returns (uint256 executionId)
	{
		return _execute(addrToKey(msg.sender), _to, _value, _data);
	}

	/// @dev Approves an execution. If the execution is being approved multiple times,
	///  it will not provide additional approvals. Disapproving multiple times will
	///  work i.e. not do anything. The approval could potentially trigger an execution
	///  (if the threshold is met).
	/// @param _key identity approving or Disapproving
	/// @param _id Execution ID
	/// @param _value `true` if it's an approval, `false` if it's a disapproval
	/// @return `false` if it's a disapproval and there's no previous approval from the sender OR
	///  if it's an approval that triggered a failed execution. `true` if it's a disapproval that
	///  undos a previous approval from the sender OR if it's an approval that succeded OR
	///  if it's an approval that triggered a succesful execution
	function _approve(
		bytes32 _key,
		uint256 _id,
		bool    _value
	)
	internal
	whenNotPaused
	returns (bool success)
	{
		Execution storage execution = executions[_id];
		bytes32[] storage approvals = approved[_id];

		// Must exist (have at least one approval)
		require(approvals.length > 0);

		// Must be approved by the right key
		require(m_keys.find(
			_key,
			execution.to == address(this) ? MANAGEMENT_KEY : ACTION_KEY
		));

		emit Approved(_id, _value);

		if (_value)
		{
			// Only approve once
			bool newApproval = true;
			for (uint256 i = 0; i < approvals.length; ++i)
			{
				if (approvals[i] == _key)
				{
					newApproval = false;
					break;
				}
			}
			if (newApproval)
			{
				// Approve
				approvals.push(_key);
			}

			uint256 threshold = (execution.to == address(this)) ? managementThreshold : actionThreshold;
			if (approvals.length >= threshold)
			{
				return _call(_id, execution.to, execution.value, execution.data);
				// delete executions[_id];
				// delete approved[_id];
			}
			else
			{
				return true;
			}
		}
		else // !approve
		{
			// Find in approvals
			for (uint256 i = 0; i < approvals.length; ++i)
			{
				if (approvals[i] == _key)
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

	/// @dev External api to the approve function that considers the key of msg.sender
	/// @param _id Execution ID
	/// @param _value `true` if it's an approval, `false` if it's a disapproval
	/// @return `false` if it's a disapproval and there's no previous approval from the sender OR
	///  if it's an approval that triggered a failed execution. `true` if it's a disapproval that
	///  undos a previous approval from the sender OR if it's an approval that succeded OR
	///  if it's an approval that triggered a succesful execution
	function approve(uint256 _id, bool _value)
	external
	returns (bool success)
	{
		return _approve(addrToKey(msg.sender), _id, _value);
	}
}