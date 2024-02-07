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
            mapping(address => bool ) voted_addresses;

            // CONSTRUCTOR
             constructor() {
                 owner = msg.sender;
                 //voted_addresses.push(msg.sender); should be able to vote in my own proposal
            }
            // MODIFIER DEFINITIONS
            modifier onlyOwner() {
                 require(msg.sender == owner);
                  _;
            }

            modifier active() {
                require(proposal_history[counter].is_active == true, "The proposal is not active");
                _;
            }

            modifier newVoter(address _address) {
                require(!voted_addresses[_address], "Address has already voted");
                _;
            }

            // FUNCTION DEFINITIONS
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
                    pass = pass%2==0?pass:pass+1; // if pass votes are odd, add one to it
                    pass=pass/2;
                    // if approve+(pass/2) votes are more than reject votes, then proposal is approved 
                    // or if approve greater than reject then it doesn't matter how many pass votes are there
                    if (approve>reject || approve+pass>reject) {
                        return true;
                    } else {
                        return false;
                    }
            }

            function vote(uint8 choice) external active newVoter(msg.sender) {
                // Function logic
                // First part
                Proposal storage proposal = proposal_history[counter];
                uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
                voted_addresses[msg.sender]=true;
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
                // updating actual proposal state
                proposal_history[counter].current_state = proposal.current_state;
                // Third part
                if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
                    proposal.is_active = false;
                 //   voted_addresses = [owner]; // reset the addresses that have voted because proposal is inactive and over now
                }
            }

            function teminateProposal() external onlyOwner active {
                proposal_history[counter].is_active = false;
            }

            // function isVoted(address _address) public view returns (bool) {
            //     for (uint i = 0; i < voted_addresses.length; i++) {
            //         if (voted_addresses[i] == _address) {
            //             return true;
            //         }
            //     }
            //     return false;
            // }

            function getCurrentProposal() external view returns(Proposal memory) {
                return proposal_history[counter];
            }

            function getProposal(uint256 number) external view returns(Proposal memory) {
                return proposal_history[number];
            }
    
}

