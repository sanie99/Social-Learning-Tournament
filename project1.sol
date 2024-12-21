// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialLearningTournament {
    struct Participant {
        address participantAddress;
        string name;
        uint score;
        bool hasParticipated;
    }

    address public owner;
    uint public tournamentEndTime;
    uint public registrationFee;
    bool public isTournamentActive;
    mapping(address => Participant) public participants;
    address[] public participantList;

    event ParticipantRegistered(address participant, string name);
    event TournamentEnded(address winner, uint prize);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier isTournamentOngoing() {
        require(isTournamentActive, "The tournament is not active");
        require(block.timestamp < tournamentEndTime, "The tournament has ended");
        _;
    }

    constructor(uint _duration, uint _registrationFee) {
        owner = msg.sender;
        tournamentEndTime = block.timestamp + _duration;
        registrationFee = _registrationFee;
        isTournamentActive = true;
    }

    function register(string memory _name) public payable isTournamentOngoing {
        require(msg.value == registrationFee, "Incorrect registration fee");
        require(!participants[msg.sender].hasParticipated, "Already registered");

        participants[msg.sender] = Participant({
            participantAddress: msg.sender,
            name: _name,
            score: 0,
            hasParticipated: true
        });

        participantList.push(msg.sender);
        emit ParticipantRegistered(msg.sender, _name);
    }

    function updateScore(address _participant, uint _score) public onlyOwner isTournamentOngoing {
        require(participants[_participant].hasParticipated, "Participant not found");
        participants[_participant].score += _score;
    }

    function endTournament() public onlyOwner {
        require(isTournamentActive, "Tournament is already ended");

        isTournamentActive = false;

        address winner;
        uint highestScore = 0;

        for (uint i = 0; i < participantList.length; i++) {
            address participantAddr = participantList[i];
            if (participants[participantAddr].score > highestScore) {
                highestScore = participants[participantAddr].score;
                winner = participantAddr;
            }
        }

        uint prize = address(this).balance;
        if (winner != address(0)) {
            payable(winner).transfer(prize);
            emit TournamentEnded(winner, prize);
        }
    }

    function getParticipants() public view returns (Participant[] memory) {
        Participant[] memory participantData = new Participant[](participantList.length);
        for (uint i = 0; i < participantList.length; i++) {
            participantData[i] = participants[participantList[i]];
        }
        return participantData;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
