//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ICryptoDevsNFT.sol";
import "./IFakeNFTMarketPlace.sol";

contract CryptoDevsDAO is Ownable
{
    struct Porposal
    {
        uint256 nftTokenId;
        uint256 deadline;
        uint256 yayVotes;
        uint256 nayVotes;
        bool executed;
        mapping(uint256 => bool) voters;
    }

    mapping(uint256 => Porposal) proposals;
    uint256 public numProposals;

    IFakeNFTMarketplace nftMarketPlace;
    ICryptoDevsNFT cryptoDevsNFT;

    constructor(address _nftMarketPlace, address _cryptoDevsNFT) payable
    {
        nftMarketPlace = IFakeNFTMarketplace(_nftMarketPlace);
        cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }

    modifier nftHolderOnly()
    {
        require(cryptoDevsNFT.balanceOf(msg.sender)>0,"Not a DAO member");
        _;
    }

    function createProposal(uint256 _nftTokenId) external nftHolderOnly returns(uint256)
    {
        require(nftMarketPlace.available(_nftTokenId), "NFT not for sale");

        Porposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + 1 minutes;

        numProposals++;

        return  numProposals -1;
    }

    modifier activeProposalOnly(uint256 proposalIndex)
    {
        require(proposals[proposalIndex].deadline > block.timestamp, "Deadline exceeded");
        _;
    }

    enum Vote
    {
        YAY,
        NAY
    }

    function  voteOnProposal(uint256 proposalIndex, Vote vote) external nftHolderOnly activeProposalOnly(proposalIndex)
    {
        Porposal storage proposal = proposals[proposalIndex];
        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;

        for(uint256 i= 0; i < voterNFTBalance; i++)
        {
            uint256 tokeId = cryptoDevsNFT.tokenOwnerByIndex(msg.sender, i);

            if(proposal.voters[tokeId] == false)
            {
                numVotes++;
                proposal.voters[tokeId] = true;
            }
        }

        require(numVotes > 0, "Already voted");

        if(vote == Vote.YAY)
        {
            proposal.yayVotes += numVotes;
        }
        else
        {
            proposal.nayVotes += numVotes;
        }
    }


    modifier inactiveProposalOnly(uint256 proposalIndex)
    {
        require(proposals[proposalIndex].deadline <= block.timestamp, "Deadline not exceeded");

        require(proposals[proposalIndex].executed == false, "Proposal already executed");
        _;
    }


    function executeProposal(uint256 proposalIndex) external nftHolderOnly inactiveProposalOnly(proposalIndex)
    {
        Porposal storage proposal = proposals[proposalIndex];

        if(proposal.yayVotes > proposal.nayVotes)
        {
            uint256 nftprice = nftMarketPlace.getPrice();

            require(address(this).balance >= nftprice, "Not enough funds");

            nftMarketPlace.purchase{value:nftprice}(proposal.nftTokenId);
        }

        proposal.executed = true;
    }


    function withdrawEther() external onlyOwner
    {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable{}
    fallback() external payable{}
}