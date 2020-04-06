pragma solidity ^0.6.0;

import "./ERC1538Store.sol";

contract ERC1538Module is ERC1538Store
{
	constructor()
	public
	{
		renounceOwnership();
	}
}
