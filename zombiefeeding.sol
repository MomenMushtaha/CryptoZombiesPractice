pragma solidity >=0.5.0 <0.6.0;

import "./zombiefactory.sol";

// declare the interface for the CryptoKitties contract
contract KittyInterface {
    // view functions do not cost gas when called externally
    // this function will allow us to fetch the kitty's data from the CryptoKitties contract
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

// ZombieFeeding inherits from ZombieFactory
contract ZombieFeeding is ZombieFactory {
    // declare the KittyInterface contract to interact with the CryptoKitties contract
    KittyInterface kittyContract;

    // modify the cooldown time to 1 day
    // notice the syntax for the modifier declaration
    modifier onlyOwnerOf(uint _zombieId) {
        // require that the caller of the function is the owner of the zombie
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    // function to set the address of the CryptoKitties contract
    // when a variable is declared as `address`, it is assumed to be an Ethereum address
    // when a variable is declared with a '_' prefix, it is assumed to be a function argument
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // function to trigger the cooldown for a zombie
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    // function to check if a zombie is ready
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }

    // function to feed and multiply a zombie with a target dna and species
    // only the owner of the zombie can call this function as specified by the onlyOwnerOf modifier
    // the memory keyword is used to store the data in memory
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
        // the storage is used by default when declaring a state variable. it is very computationally expensive because
        //it writes to the Ethereum blockchain every time it is used which means it will pass through thousands of nodes
        //in the network and will be stored in the blockchain forever
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // if the species is a kitty, the last two digits of the new dna will be 99
        // this is to differentiate between zombies and kitties, this is a simple way to add a new feature to the game
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        // to receive a specific value from a set of values, you can use the following syntax
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
