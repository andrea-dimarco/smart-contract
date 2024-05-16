// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;



contract Hotel {
    // Variables
    bool private pass;
    uint private createdAt;
    address private sender;
    address[3] private senders;
    
    constructor() {
        pass = true;
        createdAt = block.timestamp;
        sender = address(0x10000);
        senders = [address(0x10000),address(0x20000), address(0x30000)];
    }

    function setSender(address _sender) external {
        require(_sender == msg.sender);
        sender = msg.sender;
    }

    function setFail() external {
        uint delay = 50 days;
        require(block.timestamp >= createdAt + delay);
        pass = false;
    }

    function echidna_test_pass() public view returns (bool) {
        return pass;
    }

    function echidna_test_sender() public view returns (bool) {
        for (uint i; i < 3; i++) {
            if (sender == senders[i]) {
                return true;
            }
        }
        return false;
    }


}
