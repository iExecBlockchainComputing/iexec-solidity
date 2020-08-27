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

interface IENS
{
	event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
	event Transfer(bytes32 indexed node, address owner);
	event NewResolver(bytes32 indexed node, address resolver);
	event NewTTL(bytes32 indexed node, uint64 ttl);
	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

	function setRecord(bytes32, address, address, uint64) external;
	function setSubnodeRecord(bytes32, bytes32, address, address, uint64) external;
	function setSubnodeOwner(bytes32, bytes32, address) external returns(bytes32);
	function setResolver(bytes32, address) external;
	function setOwner(bytes32, address) external;
	function setTTL(bytes32, uint64) external;
	function setApprovalForAll(address, bool) external;
	function owner(bytes32) external view returns (address);
	function resolver(bytes32) external view returns (address);
	function ttl(bytes32) external view returns (uint64);
	function recordExists(bytes32) external view returns (bool);
	function isApprovedForAll(address, address) external view returns (bool);
}
