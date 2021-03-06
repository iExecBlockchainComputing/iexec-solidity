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

/**
 * @title SafeMathExtended
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMathExtended
{
	/**
	* @dev Adds two unsigned integers, reverts on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a + b;
		require(c >= a);
		return c;
	}

	/**
	* @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{
		require(b <= a);
		uint256 c = a - b;
		return c;
	}

	/**
	* @dev Multiplies two unsigned integers, reverts on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256)
	{
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0)
		{
			return 0;
		}
		uint256 c = a * b;
		require(c / a == b);
		return c;
	}

	/**
	* @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256)
	{
			// Solidity only automatically asserts when dividing by 0
			require(b > 0);
			uint256 c = a / b;
			// assert(a == b * c + a % b); // There is no case in which this doesn't hold
			return c;
	}

	/**
	* @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
	* reverts when dividing by zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256)
	{
		require(b != 0);
		return a % b;
	}

	/**
	* @dev Returns the largest of two numbers.
	*/
	function max(uint256 a, uint256 b) internal pure returns (uint256)
	{
		return a >= b ? a : b;
	}

	/**
	* @dev Returns the smallest of two numbers.
	*/
	function min(uint256 a, uint256 b) internal pure returns (uint256)
	{
		return a < b ? a : b;
	}

	/**
	* @dev Multiplies the a by the fraction b/c
	*/
	function mulByFraction(uint256 a, uint256 b, uint256 c) internal pure returns (uint256)
	{
		return div(mul(a, b), c);
	}

	/**
	* @dev Return b percents of a (equivalent to a percents of b)
	*/
	function percentage(uint256 a, uint256 b) internal pure returns (uint256)
	{
		return mulByFraction(a, b, 100);
	}

	/**
	* @dev Returns the base 2 log of x
	* @notice Source : https://ethereum.stackexchange.com/questions/8086/logarithm-math-operation-in-solidity
	*/
	function log(uint x) internal pure returns (uint y)
	{
		assembly
		{
			let arg := x
			x := sub(x,1)
			x := or(x, div(x, 0x02))
			x := or(x, div(x, 0x04))
			x := or(x, div(x, 0x10))
			x := or(x, div(x, 0x100))
			x := or(x, div(x, 0x10000))
			x := or(x, div(x, 0x100000000))
			x := or(x, div(x, 0x10000000000000000))
			x := or(x, div(x, 0x100000000000000000000000000000000))
			x := add(x, 1)
			let m := mload(0x40)
			mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
			mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
			mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
			mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
			mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
			mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
			mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
			mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
			mstore(0x40, add(m, 0x100))
			let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
			let shift := 0x100000000000000000000000000000000000000000000000000000000000000
			let a := div(mul(x, magic), shift)
			y := div(mload(add(m,sub(255,a))), shift)
			y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
		}
	}
}
