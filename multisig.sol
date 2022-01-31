// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma abicoder v2;

contract wallet {
    address[] public owners;
    uint limit;

    struct Transfer {
        uint amount;
        address payable receiver;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }

    event TransferRequestCreated(uint _id, uint amount, address _initiator, address _receiver);
    event ApprovalReceived(uint _id, uint approvals, address _approver);
    event TransferApproved(uint _id);

    Transfer[] transferRequests;

    mapping(address => mapping(uint => bool)) approvals;

    modifier onlyOwners() {
        bool owner = false;
        for(uint i=0;i<owners.length;i++) {
            if(msg.sender == owners[i]) {
                owner = true;
            }
        }
        require(owner == true);
        _;
    }

    constructor(address[] memory _owners, uint _limit) {
        owners = _owners;
        limit = _limit;
    }

    function deposit() public payable {}

    function requestTransfer(uint _amount, address payable _receiver) public onlyOwners {
        emit TransferRequestCreated(transferRequests.length, _amount, msg.sender, _receiver);
        transferRequests.push( 
            Transfer(_amount, _receiver, 0, false, transferRequests.length) 
        );
    }

    function approve(uint _id) public onlyOwners {
        require(approvals[msg.sender][_id] == false);
        require(transferRequests[_id].hasBeenSent == false);

        approvals[msg.sender][_id] = true;
        transferRequests[_id].approvals++;

        emit ApprovalReceived(_id, transferRequests[_id].approvals, msg.sender);
        
        if(transferRequests[_id].approvals >= limit) {
            transferRequests[_id].receiver.transfer(transferRequests[_id].amount);
            transferRequests[_id].hasBeenSent = true;
            emit TransferApproved(_id);
        }
        
    }

    function getTransferRequests() public view returns(Transfer[] memory) {
        return transferRequests;
    }

}
