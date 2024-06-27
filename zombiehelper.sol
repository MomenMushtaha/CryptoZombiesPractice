pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

/// @title ZombieHelper Contract
/// @dev Provides additional functionalities for zombies such as leveling up, changing names and DNA, and getting zombies by owner
contract ZombieHelper is ZombieFeeding {
    // Define levelUpFee and set it to 0.001 ether
    uint levelUpFee = 0.001 ether;

    /// @dev Modifier to require a zombie to be above a certain level
    /// @param _level The level required
    /// @param _zombieId The ID of the zombie
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    /// @notice Withdraws the balance of the contract to the owner
    /// @dev Only the owner of the contract can call this function
    function withdraw() external onlyOwner {
        address _owner = owner();
        // Transfer the balance of the contract to the owner
        _owner.transfer(address(this).balance);
    }

    /// @notice Set the fee required to level up a zombie
    /// @param _fee The new level up fee
    /// @dev Only the owner of the contract can call this function
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    /// @notice Level up a zombie by paying the level up fee
    /// @param _zombieId The ID of the zombie to level up
    /// @dev The payable modifier indicates that this function can receive ether
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level = zombies[_zombieId].level.add(1);
    }

    /// @notice Change the name of a zombie
    /// @param _zombieId The ID of the zombie
    /// @param _newName The new name for the zombie
    /// @dev Only the owner of the zombie can call this function and the zombie must be above level 2
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    /// @notice Change the DNA of a zombie
    /// @param _zombieId The ID of the zombie
    /// @param _newDna The new DNA for the zombie
    /// @dev Only the owner of the zombie can call this function and the zombie must be above level 20
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    /// @notice Get all zombies owned by a specific address
    /// @param _owner The address to query
    /// @return An array of IDs of zombies owned by the address
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
