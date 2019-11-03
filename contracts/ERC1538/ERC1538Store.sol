pragma solidity ^0.5.10;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "solstruct/contracts/libs/LibMap2.bytes4.address.bytes.sol";

contract ERC1538Store is Ownable
{
	using LibMap2_bytes4_address_bytes for LibMap2_bytes4_address_bytes.map;

	LibMap2_bytes4_address_bytes.map internal m_funcs;
}
