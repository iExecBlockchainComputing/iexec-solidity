pragma solidity ^0.5.0;

// import "../tools/Ownable.sol";
contract ERC1538UpgradeableStorage// is OwnableMutable
{
	// m_owner from OwnableMutable
	address m_owner;
	modifier onlyOwner()
	{
		require(msg.sender == m_owner);
		_;
	}

	// maps functions to the delegate contracts that execute the functions
	// funcId => delegate contract
	mapping(bytes4 => address) internal m_delegates;

	// array of function signatures supported by the contract
	bytes[] internal m_funcSignatures;

	// maps each function signature to its position in the funcSignatures array.
	// signature => index+1
	mapping(bytes => uint256) internal m_funcSignatureToIndex;

}