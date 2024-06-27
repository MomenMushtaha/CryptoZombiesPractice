pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";

// ERC721 are used to build NFTs (non-fungible tokens) and are used to build games like cryptokitties
// ERC721 is a standard interface for NFTs, and has a few functions that are required to be implemented
// to inherit from multiple contracts, separate them with a comma
contract ZombieOwnership is ZombieAttack, ERC721 {
    // Use SafeMath for uint256
    using SafeMath for uint256;
    // mapping from zombie id to owner address
    mapping (uint => address) zombieApprovals;

    function balanceOf(address _owner) external view returns (uint256) {
        return ownerZombieCount[_owner];
    }
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return zombieToOwner[_tokenId];
    }

    // internal function to transfer a zombie from one owner to another
    // this function is called by transferFrom and takes in the _from, _to, and _tokenId
    // it increments the ownerZombieCount of the _to address and decrements the ownerZombieCount of the _from address
    // it sets the zombieToOwner mapping of the _tokenId to the _to address
    // it emits a Transfer event
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        // require that the sender is either the owner of the zombie or the approved address for the zombie
        require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

}
