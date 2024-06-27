pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";

/// @title ZombieFactory Contract
/// @dev This contract creates zombies and manages their ownership and attributes
contract ZombieFactory is Ownable {

    // Since SafeMath protects against overflow attacks, we can use it to do math operations
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    /// @dev Event emitted when a new zombie is created
    /// @param zombieId The ID of the newly created zombie
    /// @param name The name of the newly created zombie
    /// @param dna The DNA of the newly created zombie
    event NewZombie(uint zombieId, string name, uint dna);

    // Zombie DNA is 16 digits long
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    /// @dev Struct representing a zombie
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // Array of zombies
    Zombie[] public zombies;

    /// @dev Mapping from zombie ID to owner address
    mapping (uint => address) public zombieToOwner;

    /// @dev Mapping from owner address to number of owned zombies
    mapping (address => uint) ownerZombieCount;

    /// @dev Internal function to create a new zombie
    /// @param _name The name of the new zombie
    /// @param _dna The DNA of the new zombie
    function _createZombie(string memory _name, uint _dna) internal {
        // Push a new zombie to the zombies array
        // The new zombie has the name, dna, level 1, readyTime 1 day from now, winCount 0, lossCount 0
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        // msg.sender is the address of the person who called the function
        // It is commonly used to implement access control mechanisms.
        zombieToOwner[id] = msg.sender;
        // Increment the ownerZombieCount for the msg.sender
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        // Emit the NewZombie event so that the frontend is notified
        emit NewZombie(id, _name, _dna);
    }

    /// @dev Internal function to generate a random DNA sequence
    /// @param _str A string used to generate the random DNA
    /// @return A uint representing the generated DNA
    // View functions can be called internally or externally and do not modify the state
    function _generateRandomDna(string memory _str) private view returns (uint) {
        // keccak256 is a cryptographic hash function that takes an input and returns a unique fixed-size string of 256 bits
        // abi.encodePacked concatenates the arguments and converts them into a tightly packed byte array
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        // The dnaModulus is used to truncate the dna to 16 digits
        return rand % dnaModulus;
    }

    /// @notice Create a new random zombie
    /// @param _name The name of the new zombie
    /// @dev This function requires that the sender does not already own a zombie
    function createRandomZombie(string memory _name) public {
        // Require statements are used to validate inputs
        require(ownerZombieCount[msg.sender] == 0, "Each player can only have one zombie");
        uint randDna = _generateRandomDna(_name);
        // Ensure the last two digits are zero
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
