pragma solidity >=0.5.0 <0.6.0;

import "./zombiehelper.sol";

contract ZombieAttack is ZombieHelper {
    uint randNonce = 0;
    uint attackVictoryProbability = 70;

    /////////// SECURITY ISSUE ///////////
    // The following line is vulnerable to a front-running attack.
    // The attacker can call the function multiple times in a short period of time and get the same random number.
    // The attacker can then use this information to manipulate the outcome of the attack.
    /////////////////////////////////////
    // how to fix this issue:
    // - use the "commit-reveal" pattern
    // - use the "blockhash" function
    function randMod(uint _modulus) internal returns(uint) {
        randNonce = randNonce.add(1);
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
    }
    /////////// SECURITY ISSUE ///////////
    // The following function is vulnerable to a reentrancy attack.
    // The attacker can call the function multiple times in a short period of time and drain the contract of all its ether.
    /////////////////////////////////////
    // how to fix this issue:
    // - use the "Checks-Effects-Interactions" pattern
    // - use the "withdrawal pattern"
    // - use the "pull over push" pattern
    // - use the "Reentrancy Guard" pattern
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        uint rand = randMod(100);
        if (rand <= attackVictoryProbability) {
            myZombie.winCount = myZombie.winCount.add(1);
            myZombie.level = myZombie.level.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount = myZombie.lossCount.add(1);
            enemyZombie.winCount = enemyZombie.winCount.add(1);
            _triggerCooldown(myZombie);
        }
    }
}
