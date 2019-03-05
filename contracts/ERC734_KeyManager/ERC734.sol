pragma solidity ^0.5.0;

import "./ERC734KeyGetters.sol";
import "./ERC734KeyManagement.sol";
import "./ERC734Execute.sol";

contract ERC734 is ERC734KeyGetters, ERC734KeyManagement, ERC734Execute
{
}
