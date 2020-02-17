pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract ECDSA
{
	struct signature
	{
		uint8   v;
		bytes32 r;
		bytes32 s;
	}

	function recover(bytes32 hash, signature memory sign)
	internal pure returns (address)
	{
		require(sign.v == 27 || sign.v == 28);
		return ecrecover(hash, sign.v, sign.r, sign.s);
	}

	function recover(bytes32 hash, bytes memory sign)
	internal pure returns (address)
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
	internal pure returns (bytes32)
	{
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
	}

	function toEthTypedStructHash(bytes32 struct_hash, bytes32 domain_separator)
	internal pure returns (bytes32)
	{
		return keccak256(abi.encodePacked("\x19\x01", domain_separator, struct_hash));
	}
}
