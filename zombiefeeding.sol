pragma solidity >=0.5.0 <0.6.0;

import "./zombiefactory.sol";

/// @title Interface for CryptoKitties Contract
/// @dev This interface allows interaction with the CryptoKitties contract
contract KittyInterface {
    /// @notice Get details about a specific CryptoKitty
    /// @param _id The ID of the CryptoKitty
    /// @return Various attributes of the CryptoKitty
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

/// @title ZombieFeeding Contract
/// @dev This contract allows zombies to feed on CryptoKitties and other zombies to multiply
contract ZombieFeeding is ZombieFactory {
    KittyInterface kittyContract;

    /// @dev Modifier to check if the caller is the owner of the zombie
    /// @param _zombieId The ID of the zombie
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    /// @notice Set the address of the CryptoKitties contract
    /// @param _address The address of the CryptoKitties contract
    /// @dev Only the owner of the contract can set the address
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    /// @dev Internal function to trigger the cooldown period for a zombie
    /// @param _zombie The zombie to trigger the cooldown for
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    /// @dev Internal view function to check if a zombie is ready for action
    /// @param _zombie The zombie to check
    /// @return True if the zombie is ready, false otherwise
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }

    /// @notice Feed and multiply a zombie with a target DNA and species
    /// @param _zombieId The ID of the zombie
    /// @param _targetDna The DNA of the target
    /// @param _species The species of the target
    /// @dev Only the owner of the zombie can call this function
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // if the species is a kitty, the last two digits of the new dna will be 99
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    /// @notice Feed a zombie on a CryptoKitty
    /// @param _zombieId The ID of the zombie
    /// @param _kittyId The ID of the CryptoKitty
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        // to receive a specific value from a set of values, you can use the following syntax
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
