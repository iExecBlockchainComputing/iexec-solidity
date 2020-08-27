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

import "./CounterfactualFactory.sol";


contract GenericFactory is CounterfactualFactory
{
	event NewContract(address indexed addr);

	function predictAddress(bytes memory _code, bytes32 _salt)
	public view returns(address)
	{
		return predictAddressWithCall(_code, _salt, bytes(""));
	}

	function createContract(bytes memory _code, bytes32 _salt)
	public returns(address)
	{
		return createContractAndCall(_code, _salt, bytes(""));
	}

	function predictAddressWithCall(bytes memory _code, bytes32 _salt, bytes memory _call)
	public view returns(address)
	{
		return _predictAddress(_code, keccak256(abi.encodePacked(_salt, _call)));
	}

	function createContractAndCall(bytes memory _code, bytes32 _salt, bytes memory _call)
	public returns(address)
	{
		address addr = _create2(_code, keccak256(abi.encodePacked(_salt, _call)));
		emit NewContract(addr);
		if (_call.length > 0)
		{
			// solium-disable-next-line security/no-low-level-calls
			(bool success, bytes memory reason) = addr.call(_call);
			require(success, string(reason));
		}
		return addr;
	}

}
