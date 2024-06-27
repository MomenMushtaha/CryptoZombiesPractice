pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {
    // Define levelUpFee here and set it to 0.001 ether
    uint levelUpFee = 0.001 ether;

    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    // Create a function named withdraw that only allows the contract owner to call it
    // why is it called from outside the contract? because it is called from the web3.js
    function withdraw() external onlyOwner {
        address _owner = owner();
        // Transfer the balance of the contract to the owner
        _owner.transfer(address(this).balance);
    }

    // why is it called from outside the contract? because it is called from the web3.js
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    // payable modifier means that this function can receive ether
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level = zombies[_zombieId].level.add(1);
    }

    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    // why is it called from outside the contract? because it is called from the web3.js
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
        // why memory? because it is a temporary variable
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        // since we are trying to keep the contract simple, we are not using a mapping to keep track of the zombies owned by an address
        // instead, we are iterating over all the zombies in the contract and checking their owner
        // why not use a mapping? because it is more expensive to maintain a mapping!
        // for loops are cheaper than storage too!!
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

}
