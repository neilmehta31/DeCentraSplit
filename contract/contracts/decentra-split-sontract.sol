// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DecentraSplit {
    address public owner;
    // payFrom => payTo => value;
    mapping (address => mapping (address => uint)) private graph;
    mapping (address => address []) private creditorsAddersses;
    address[] public debitorAddresses;
    struct Payments {
        address payFrom;
        address payTo;
        uint amount;
    }
    constructor() {
        owner = msg.sender;
    }
    function getAccountBalance() public view returns (uint) {
        return msg.sender.balance;
    }
    
    function memoisePayment(address _payTo, uint _amount) public {
        graph[msg.sender][_payTo] += _amount;
        debitorAddresses.push(msg.sender);
        creditorsAddersses[msg.sender].push(_payTo);
    }

    function getPaymentForAddress(address _payTo) public view returns (uint) {
        return graph[msg.sender][_payTo];
    }
    function getAllPaymentsForCurrentAddress() public view returns (Payments[] memory) {
        Payments[] memory payments = new Payments[](creditorsAddersses[msg.sender].length);
        for(uint i=0;i< creditorsAddersses[msg.sender].length;i++){
            payments[i] = Payments(msg.sender, creditorsAddersses[msg.sender][i], graph[msg.sender][creditorsAddersses[msg.sender][i]]);
        }
        return payments;
    }

    function makePendingPayments() public payable {
        for(uint i=0;i< creditorsAddersses[msg.sender].length;i++){
            uint amt = graph[msg.sender][creditorsAddersses[msg.sender][i]];
            assert(amt <= getAccountBalance());
            (bool success, ) = creditorsAddersses[msg.sender][i].call{value:amt}("");
            if(!success){
                revert("Failed to send ether");
            }
        }
    }
}