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

contract TestContract
{
	string  public constant id = "TestContract";
	address public caller;
	bytes   public value;

	event Receive(uint256 value, bytes data);
	event Fallback(uint256 value, bytes data);

	receive()
	external payable
	{
		emit Receive(msg.value, msg.data);
	}

	fallback()
	external payable
	{
		emit Fallback(msg.value, msg.data);
	}

	function set(bytes calldata _value)
	external
	{
		caller = msg.sender;
		value  = _value;
	}
}
