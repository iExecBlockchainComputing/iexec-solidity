pragma solidity >=0.5.0 <0.7.0;


interface IERC2362
{
  function valueFor(bytes32 _id) external view returns(int256,uint256,uint256);
}
