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

import "../../Upgradeability/Proxy.sol";
import "../ERC1538Core.sol";


contract ERC1538ProxyV2 is ERC1538Core, Proxy
{
	constructor(address _erc1538Delegate)
	public
	{
		_setFunc("updateContract(address,string[],string)", _erc1538Delegate);
		emit CommitMessage("Added ERC1538 updateContract function at contract creation");
	}

	function _implementation() internal override view returns (address)
	{
		address delegateFunc = m_funcs.value1(msg.sig);

		if (delegateFunc != address(0))
		{
			return delegateFunc;
		}
		else
		{
			return m_funcs.value1(0xFFFFFFFF);
		}
	}
}
