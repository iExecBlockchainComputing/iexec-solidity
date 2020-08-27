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

library ECDSALib
{
	struct signature
	{
		uint8   v;
		bytes32 r;
		bytes32 s;
	}

	function recover(bytes32 hash, signature memory sign)
	public pure returns (address)
	{
		require(sign.v == 27 || sign.v == 28);
		return ecrecover(hash, sign.v, sign.r, sign.s);
	}

	function recover(bytes32 hash, bytes memory sign)
	public pure returns (address)
	{
		bytes32 r;
		bytes32 s;
		uint8   v;

		if (sign.length == 65) // 65bytes: (r,s,v) form
		{
			assembly
			{
				r :=         mload(add(sign, 0x20))
				s :=         mload(add(sign, 0x40))
				v := byte(0, mload(add(sign, 0x60)))
			}
		}
		else if (sign.length == 64) // 64bytes: (r,vs) form → see EIP2098
		{
			assembly
			{
				r :=                mload(add(sign, 0x20))
				s := and(           mload(add(sign, 0x40)), 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
				v := shr(7, byte(0, mload(add(sign, 0x40))))
			}
		}
		else
		{
			revert("invalid-signature-format");
		}

		if (v < 27) v += 27;
		require(v == 27 || v == 28);
		return ecrecover(hash, v, r, s);
	}

	function toEthSignedMessageHash(bytes32 hash)
	public pure returns (bytes32)
	{
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
	}

	function toEthTypedStructHash(bytes32 struct_hash, bytes32 domain_separator)
	public pure returns (bytes32)
	{
		return keccak256(abi.encodePacked("\x19\x01", domain_separator, struct_hash));
	}
}
