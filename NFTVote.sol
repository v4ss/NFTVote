// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NFTVote__VoteIsClosed();
error NFTVote__VoterHasAlreadyVoted();
error NFTVote__NotEnoughNFT(uint256 balanceOfNFT);
error NFTVote__InvalidId(uint256 idOfCandidate);

contract NFTVote is ERC721, Ownable {

    struct Candidate {
        string name;
        uint256 vote;
    }

    Candidate[] private s_candidates;

    uint256 private s_nextTokenId;
    mapping(address voter => bool hasVoted) private s_voterAlreadyVoted;
    bool private s_voteState;

    constructor(address initialOwner)
        ERC721("MyToken", "MTK")
        Ownable(initialOwner)
    {
        s_voteState = false;
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = s_nextTokenId++;
        _safeMint(to, tokenId);
    }

    function addCandidate(string memory name) public onlyOwner {
        s_candidates.push(Candidate(name, 0));
    }

    function voteFor(uint256 idOfCandidate) public {
        if(!s_voteState) revert NFTVote__VoteIsClosed();
        if(s_voterAlreadyVoted[msg.sender]) revert NFTVote__VoterHasAlreadyVoted();
        if(balanceOf(msg.sender) == 0) revert NFTVote__NotEnoughNFT(0);
        if(idOfCandidate >= s_candidates.length) revert NFTVote__InvalidId(idOfCandidate);

        uint256 voteWeight = balanceOf(msg.sender);
        
        s_candidates[idOfCandidate].vote += voteWeight;
        s_voterAlreadyVoted[msg.sender] = true;
    }

    function getWinner() public view onlyOwner returns(Candidate memory) {
        Candidate[] memory candidates = s_candidates;
        uint256 winnerIndex = 0;

        for (uint256 i = 1 ; i < candidates.length ; i++) {
            if(candidates[winnerIndex].vote <= candidates[i].vote ) {
                winnerIndex = i;
            }
        }

        return candidates[winnerIndex];
    }

    function setVoteState(bool voteState) public onlyOwner {
        s_voteState = voteState;
    }

    function getVoteState() public view returns(bool) {
        return s_voteState;
    }

    function getCandidatesList() public view returns (Candidate[] memory) {
        return s_candidates;
    }

}
