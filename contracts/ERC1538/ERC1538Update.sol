pragma solidity ^0.5.10;

import "./ERC1538.sol";


interface ERC1538Update
{
	function updateContract(address _delegate, string calldata _functionSignatures, string calldata commitMessage) external;
}

contract ERC1538UpdateDelegate is ERC1538Update, ERC1538
{
	function updateContract(
		address         _delegate,
		string calldata _functionSignatures,
		string calldata _commitMessage
	)
	external onlyOwner
	{
		bytes memory signatures = bytes(_functionSignatures);
		uint256 start;
		uint256 pos;
		uint256 end;
		uint256 size;

		if (_delegate != address(0))
		{
			assembly { size := extcodesize(_delegate) }
			require(size > 0, "[ERC1538] _delegate address is not a contract and is not address(0)");
		}
		assembly
		{
			start := add(signatures, 32)
			end   := add(start, mload(signatures))
		}
		for (pos = start; pos < end; ++pos)
		{
			uint256 char;
			assembly { char := byte(0, mload(pos)) }
			if (char == 0x3B) // 0x3B = ';'
			{
				size = (pos - start);
				assembly { mstore(signatures, size) }

				_setFunc(signatures, _delegate);

				assembly { signatures := add(signatures, add(size, 1)) }
				start = ++pos;
			}
		}
		emit CommitMessage(_commitMessage);
	}
}
