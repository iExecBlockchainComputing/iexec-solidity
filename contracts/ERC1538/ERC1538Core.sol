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

import "./IERC1538.sol";
import "./ERC1538Store.sol";

contract ERC1538Core is IERC1538, ERC1538Store
{
	bytes4 constant internal RECEIVE  = 0xd217fcc6; // bytes4(keccak256("receive"));
	bytes4 constant internal FALLBACK = 0xb32cdf4d; // bytes4(keccak256("fallback"));

	event CommitMessage(string message);
	event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

	function _setFunc(string memory funcSignature, address funcDelegate)
	internal
	{
		bytes4 funcId = bytes4(keccak256(bytes(funcSignature)));
		if (funcId == RECEIVE ) { funcId = bytes4(0x00000000); }
		if (funcId == FALLBACK) { funcId = bytes4(0xFFFFFFFF); }

		address oldDelegate = m_funcs.value1(funcId);

		if (funcDelegate == oldDelegate) // No change → skip
		{
			return;
		}
		else if (funcDelegate == address(0)) // Delete
		{
			m_funcs.del(funcId);
		}
		else // Set / Update
		{
			m_funcs.set(funcId, funcDelegate, bytes(funcSignature));
		}

		emit FunctionUpdate(funcId, oldDelegate, funcDelegate, funcSignature);
	}
}
