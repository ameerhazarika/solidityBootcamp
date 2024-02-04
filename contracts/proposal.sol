// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
contract ProposalContract { 
    // Our contract code
    address owner; // address of the owner
    uint256 private counter; // keep track of the ids


            struct Proposal {
                string title; // title of the proposal
                string description; // Description of the proposal
                uint256 approve; // Number of approve votes
                uint256 reject; // Number of reject votes
                uint256 pass; // Number of pass votes
                uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
                bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
                bool is_active; // This shows if others can vote to our contract
            }
            mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
            address[]  private voted_addresses;
            modifier onlyOwner() {
                 require(msg.sender == owner);
                  _;
            }
            modifier active() {
                require(proposal_history[counter].is_active == true, "The proposal is not active");
                _;
            }
            modifier newVoter(address _address) {
                require(!isVoted(_address), "Address has already voted");
                _;
            }
            constructor() {
                 owner = msg.sender;
                 voted_addresses.push(msg.sender);
            }
            function setOwner(address new_owner) external onlyOwner {
                owner = new_owner;
            }
            function create(string calldata _title,string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
                counter += 1;
                proposal_history[counter] = Proposal(_title,_description, 0, 0, 0, _total_vote_to_end, false, true);
            }
            function calculateCurrentState() private view returns(bool) {
                    Proposal storage proposal = proposal_history[counter];
                    uint256 approve = proposal.approve;
                    uint256 reject = proposal.reject;
                    uint256 pass = proposal.pass;
                    uint256 total_vote = approve + reject + pass;
                  

                    if (proposal.total_vote_to_end - total_vote == 1) {
                        return false;
                    } else {
                        return true;
                    }
            }
            function vote(uint8 choice) external active newVoter(msg.sender) {
                // Function logic
                // First part
                Proposal storage proposal = proposal_history[counter];
                uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
                voted_addresses.push(msg.sender);
                // Second part
                if (choice == 1) {
                    proposal.approve += 1;
                    proposal.current_state = calculateCurrentState();
                } else if (choice == 2) {
                    proposal.reject += 1;
                    proposal.current_state = calculateCurrentState();
                } else if (choice == 0) {
                    proposal.pass += 1;
                    proposal.current_state = calculateCurrentState();
                }

                // Third part
                if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
                    proposal.is_active = false;
                    voted_addresses = [owner]; // reset the addresses that have voted because proposal is inactive and over now
                }
            }
    
}

