pragma solidity ^0.5.0;

import "./ERC725KeyGetters.sol";
import "./ERC725KeyManager.sol";
import "./ERC725MultiSig.sol";

contract ERC725 is ERC725KeyGetters, ERC725KeyManager, ERC725MultiSig
{
}
