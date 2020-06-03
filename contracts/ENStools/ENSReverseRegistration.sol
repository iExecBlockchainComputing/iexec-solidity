pragma solidity ^0.6.0;

// import "@ensdomains/ens/contracts/ENS.sol"; // ENS packages are dependency heavy
import "./IENS.sol";
import "./IReverseRegistrar.sol";

contract ENSReverseRegistration
{
	bytes32 internal constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

	function _setName(IENS ens, string memory name)
	internal
	{
		IReverseRegistrar(ens.owner(ADDR_REVERSE_NODE)).setName(name);
	}
}
