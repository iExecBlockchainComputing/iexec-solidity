pragma solidity ^0.5.10;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "solstruct/contracts/libs/LibMap.bytes4.address.sol";

contract ERC1538Store is Ownable
{
	using LibMap_bytes4_address for LibMap_bytes4_address.map;

	LibMap_bytes4_address.map internal m_funcDelegates;
	mapping(bytes4 => bytes)  internal m_funcSignatures;
}
