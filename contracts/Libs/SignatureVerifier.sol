pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "../ERC734/IERC734.sol";
import "../ERC1271/IERC1271.sol";
import "./ECDSA.sol";

contract SignatureVerifier is ECDSA
{
	function _isContract(address _addr)
	internal view returns (bool)
	{
		uint32 size;
		assembly { size := extcodesize(_addr) }
		return size > 0;
	}

	function _addrToKey(address _addr)
	internal pure returns (bytes32)
	{
		return bytes32(uint256(_addr));
	}

	function _checkIdentity(address _identity, address _candidate, uint256 _purpose)
	internal view returns (bool valid)
	{
		return _identity == _candidate || IERC734(_identity).keyHasPurpose(_addrToKey(_candidate), _purpose); // Simple address || ERC 734 identity contract
	}

	function _checkSignature(address _identity, bytes32 _hash, bytes memory _signature)
	internal view returns (bool)
	{
		if (_isContract(_identity))
		{
			return IERC1271(_identity).isValidSignature(_hash, _signature);
		}
		else
		{
			return recover(_hash, _signature) == _identity;
		}
	}

}
