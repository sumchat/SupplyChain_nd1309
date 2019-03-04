pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'FarmerRole' to manage this role - add, remove, check
contract SupplierRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event SupplierAdded(address indexed account);
  event SupplierRemoved(address indexed account);

  // Define a struct 'farmers' by inheriting from 'Roles' library, struct Role
  Roles.Role private suppliers;

  // In the constructor make the address that deploys this contract the 1st farmer
  constructor() public {
    _addSupplier(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlySupplier() {
    require(isSupplier(msg.sender));
    _;
  }

  // Define a function 'isFarmer' to check this role
  function isSupplier(address account) public view returns (bool) {
    return suppliers.has(account);
  }

  // Define a function 'addFarmer' that adds this role
  function addSupplier(address account) public onlySupplier {
    _addSupplier(account);
  }

  // Define a function 'renounceFarmer' to renounce this role
  function renounceSupplier() public {
    _removeSupplier(msg.sender);
  }

  // Define an internal function '_addFarmer' to add this role, called by 'addFarmer'
  function _addSupplier(address account) internal {
    suppliers.add(account);
    emit SupplierAdded(account);
  }

  // Define an internal function '_removeFarmer' to remove this role, called by 'removeFarmer'
  function _removeSupplier(address account) internal {
    suppliers.remove(account);
    emit SupplierRemoved(account);
  }
}