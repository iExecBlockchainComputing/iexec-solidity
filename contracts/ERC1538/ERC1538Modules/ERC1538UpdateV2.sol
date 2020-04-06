pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../ERC1538Core.sol";
import "../ERC1538Module.sol";


interface ERC1538UpdateV2
{
	function updateContract(address _delegate, string[] calldata _functionSignatures, string calldata commitMessage) external;
}

contract ERC1538UpdateV2Delegate is ERC1538UpdateV2, ERC1538Core, ERC1538Module
{
	function updateContract(
		address           _delegate,
		string[] calldata _functionSignatures,
		string   calldata _commitMessage
	)
	external override onlyOwner
	{
		if (_delegate != address(0))
		{
			uint256 size;
			assembly { size := extcodesize(_delegate) }
			require(size > 0, "[ERC1538] _delegate address is not a contract and is not address(0)");
		}
		for (uint256 i = 0; i < _functionSignatures.length; ++i)
		{
			_setFunc(_functionSignatures[i], _delegate);
		}
		emit CommitMessage(_commitMessage);
	}
}
