pragma solidity ^0.6.0;

interface IERC1538
{
	event CommitMessage(string message);
	event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);
}
