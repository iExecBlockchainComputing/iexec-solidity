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

pragma solidity >=0.4.24;

import "./IENS.sol";

interface IReverseRegistrar
{
	function ADDR_REVERSE_NODE() external view returns (bytes32);
	function ens() external view returns (IENS);
	function defaultResolver() external view returns (address);
	function claim(address) external returns (bytes32);
	function claimWithResolver(address, address) external returns (bytes32);
	function setName(string calldata) external returns (bytes32);
	function node(address) external pure returns (bytes32);
}
