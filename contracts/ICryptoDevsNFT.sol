//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

interface ICryptoDevsNFT
{
    function balanceOf(address owner) external view returns (uint256);
    function tokenOwnerByIndex(address owner, uint256 index) external view returns(uint256);
}