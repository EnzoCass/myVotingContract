//SPDX-License-Identifier: MIT

pragma solidity =0.8.16;


interface VotingContract {

    // only admin address should be able to add candidates
    // admin is msg.sender of the contract
    function addCandidate(uint _candidateId) external returns(bool);

    // admin can't vote
    // msg.sender can only vote once
    function voteCandidate(uint candidateId) external returns(bool);

    // getWinner returns the winner's voteCount
    function getWinner() external view returns(uint);

}


contract MyVotingContract is VotingContract {
    
    struct Candidate {
        uint candidateId;
        uint voteCount;
    }

    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }
    
    address inec;   
    uint timing;

    constructor(uint _timing) {
        inec = msg.sender;
        timing = block.timestamp + _timing;
        voters[inec].weight = 1;
    }


    Candidate[] private candidates;
    mapping(address => Voter) private voters;

    function addCandidate(uint _candidateId) external returns(bool) {

        if(block.timestamp > timing) {
            revert("time elapsed");   
        }
        
        require(msg.sender == inec,"Not Authorized");
        
        candidates.push(Candidate({
            candidateId: _candidateId,
            voteCount: 0
        }));
        
        return true;
    
    }

    function voteCandidate(uint candidateId) external returns(bool) {
    
        if(block.timestamp < timing) {
            revert("not yet time");
        }

        if(block.timestamp > timing + 15) {    
            revert("time elapsed");    
        }

        require(!voters[msg.sender].voted, "Already voted");
        require(voters[msg.sender].weight == 0, "weight not zero");

        voters[msg.sender].weight = 1;
        voters[msg.sender].voted = true;
        candidates[candidateId].voteCount += voters[msg.sender].weight;

        return true;

    }

    function getWinner() external view returns(uint) {
        
        if(block.timestamp < timing + 15) {
            revert("not yet time");
        }

        uint winningVoteCount = 0;
        
        for(uint i = 0; i < candidates.length; i++) {
           
            if(candidates[i].voteCount > winningVoteCount) {

                winningVoteCount = candidates[i].voteCount;
                
            }

        }

        return winningVoteCount;
    }
}