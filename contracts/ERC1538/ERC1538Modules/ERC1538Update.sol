// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2020 IEXEC BLOCKCHAIN TECH                                       *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity ^0.6.0;

import "../ERC1538Core.sol";
import "../ERC1538Module.sol";


interface ERC1538Update
{
	function updateContract(address _delegate, string calldata _functionSignatures, string calldata commitMessage) external;
}

contract ERC1538UpdateDelegate is ERC1538Update, ERC1538Core, ERC1538Module
{
	function updateContract(
		address         _delegate,
		string calldata _functionSignatures,
		string calldata _commitMessage
	)
	external override onlyOwner
	{
		bytes memory signatures = bytes(_functionSignatures);
		uint256 start;
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
		for (uint256 pos = start; pos < end; ++pos)
		{
			uint256 char;
			assembly { char := byte(0, mload(pos)) }
			if (char == 0x3B) // 0x3B = ';'
			{
				uint256 length = (pos - start);
				assembly { mstore(signatures, length) }

				_setFunc(string(signatures), _delegate);

				assembly { signatures := add(signatures, add(length, 1)) }
				start = pos+1;
			}
		}
		emit CommitMessage(_commitMessage);
	}
}
