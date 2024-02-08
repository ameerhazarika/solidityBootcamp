// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
contract ProposalContract { 
    
    address owner; // address of the owner
    uint256 private counter; // keep track of the ids
    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
    mapping(address => bool ) voted_addresses; // Addresses that have voted



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
                require(!proposal_history[counter].is_active, "Existing proposal still active."); // only one proposal at a time
                counter += 1;
                proposal_history[counter] = Proposal(_title,_description, 0, 0, 0, _total_vote_to_end, false, true);
            }

            function calculateCurrentState() private view returns(bool) {
                    Proposal storage proposal = proposal_history[counter];
                    uint256 approve = proposal.approve;
                    uint256 reject = proposal.reject;
                    uint256 pass = proposal.pass;
                    pass = pass%2==0?pass/2:(pass+1)/2; // if pass votes are odd, add one to it
                    // if approve+(pass/2) votes are more than reject votes, then proposal is approved 
                    // or if approve votes are greater than reject votes then it doesn't matter how many pass votes are there
                    if (approve>reject || approve+pass>reject) {
                        return true;
                    } else {
                        return false;
                    }
            }

            function vote(uint8 choice) external active newVoter(msg.sender) {
                // choice should be only either of 3 values check
                require(choice==0||choice==1||choice==2,"Choice should be either 0, 1 0r 2");
                Proposal storage proposal = proposal_history[counter];
                uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
                voted_addresses[msg.sender]=true;
                // removed calculating current state at every if condition
                if (choice == 1) {
                    proposal.approve += 1;
                } else if (choice == 2) {
                    proposal.reject += 1;
                } else if (choice == 0) {
                    proposal.pass += 1;
                }
                // updating actual proposal state , this wasn't done previously and gave wrong proposal state when calling getCurrentProposal 
                proposal_history[counter].current_state = calculateCurrentState();

                // if total votes exceed votes to end then we close the proposal voting
                if (proposal.total_vote_to_end - total_vote == 1) {
                    proposal.is_active = false; 
                }
            }

            function teminateProposal() external onlyOwner active {
                proposal_history[counter].is_active = false;
            }

            function getCurrentProposal() external view returns(Proposal memory) {
                return proposal_history[counter];
            }

            function getProposal(uint256 number) external view returns(Proposal memory) {
                require(number>=1 && number<=counter,"Please enter a valid proposal id");
                return proposal_history[number];
            }
    
}

