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
