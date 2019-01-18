pragma solidity ^0.5.0;

import "./ERCs/ERC725KeyGetters.sol";
import "./ERCs/ERC725KeyManager.sol";
import "./ERCs/ERC1077.sol";

contract Identity is ERC725KeyGetters, ERC725KeyManager, ERC1077
{
	constructor()
	public
	{
		_addKey(addrToKey(msg.sender), MANAGEMENT_KEY, ECDSA_TYPE);
	}
}
