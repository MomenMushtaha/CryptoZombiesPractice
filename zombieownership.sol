pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";

/// @title ZombieOwnership Contract
/// @dev Implements ERC721 standard for Zombie NFTs and manages zombie ownership
contract ZombieOwnership is ZombieAttack, ERC721 {
    using SafeMath for uint256;

    // Mapping from zombie ID to owner address
    mapping (uint => address) zombieApprovals;

    /// @notice Get the number of zombies owned by a specific address
    /// @param _owner The address to query
    /// @return The number of zombies owned by the address
    function balanceOf(address _owner) external view returns (uint256) {
        return ownerZombieCount[_owner];
    }

    /// @notice Find the owner of a specific zombie
    /// @param _tokenId The ID of the zombie to query
    /// @return The address of the owner of the zombie
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return zombieToOwner[_tokenId];
    }

    /// @dev Internal function to transfer a zombie from one owner to another
    /// @param _from The current owner of the zombie
    /// @param _to The new owner of the zombie
    /// @param _tokenId The ID of the zombie to transfer
    /// @notice This function increments the ownerZombieCount of the `_to` address and decrements the ownerZombieCount of the `_from` address. It also sets the zombieToOwner mapping of the `_tokenId` to the `_to` address and emits a Transfer event.
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    /// @notice Transfer a zombie from one owner to another
    /// @param _from The current owner of the zombie
    /// @param _to The new owner of the zombie
    /// @param _tokenId The ID of the zombie to transfer
    /// @dev The sender must be either the owner of the zombie or the approved address for the zombie
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Approve another address to transfer the given zombie ID
    /// @param _approved The address to be approved
    /// @param _tokenId The ID of the zombie to approve
    /// @dev The sender must be the owner of the zombie. This function emits an Approval event.
    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

}

