pragma solidity ^0.4.24;

import "../wateraccesscontrol/ConsumerRole.sol";
import "../wateraccesscontrol/DistributorRole.sol";
import "../wateraccesscontrol/SupplierRole.sol";
import "../wateraccesscontrol/RetailerRole.sol";
import "../watercore/Ownable.sol";
// Define a contract 'Supplychain'
contract SupplyChain is ConsumerRole, DistributorRole, SupplierRole, RetailerRole, Ownable {

  // Define 'owner'
  //address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Disinfected,  // 0
    Collected,  // 1
    Filtered,    // 2
    Enhanced,     //3
    Packed,     //4
    ForSale,    // 5
    Sold,       // 6
    Shipped,    // 7
    Received,   // 8
    Purchased   // 9
    }

   State constant defaultState = State.Disinfected;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Supplier, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address  originSupplierID; // Metamask-Ethereum address of the Supplier
    string  originSupplierName; // Supplier Name
    string  originSupplierInformation;  // Supplier Information
    string  originSourceWaterLatitude; // Source Latitude
    string  originSourceWaterLongitude;  // Source Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address distributorID;  // Metamask-Ethereum address of the Distributor
    address retailerID; // Metamask-Ethereum address of the Retailer
    address  consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 10 events with the same 8 state values and accept 'upc' as input argument
   event Disinfected(uint upc);
   event Collected(uint upc);
   event Filtered(uint upc);
   event Enhanced(uint upc);
   event Packed(uint upc);
   event ForSale(uint upc);
   event Sold(uint upc);
   event Shipped(uint upc);
   event Received(uint upc);
   event Purchased(uint upc);


  // Define a modifer that checks to see if msg.sender == owner of the contract
 /*  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  } */

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].consumerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Harvested
  modifier disinfected(uint _upc) {
    require(items[_upc].itemState == State.Disinfected);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Collected
  modifier collected(uint _upc) {
    require(items[_upc].itemState == State.Collected);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Filtered
  modifier filtered(uint _upc) {
    require(items[_upc].itemState == State.Filtered);
    _;
  }
  // Define a modifier that checks if an item.state of a upc is Enhanced
  modifier enhanced(uint _upc) {
    require(items[_upc].itemState == State.Enhanced);
    _;
  }
  

  // Define a modifier that checks if an item.state of a upc is Packed
  modifier packed(uint _upc) {
  require(items[_upc].itemState == State.Packed);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
  require(items[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
  require(items[_upc].itemState == State.Sold);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
   require(items[_upc].itemState == State.Shipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
  require(items[_upc].itemState == State.Received);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Purchased
  modifier purchased(uint _upc) {
    require(items[_upc].itemState == State.Purchased);
    _;
  }

 

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    //owner = msg.sender;
    transferOwnership(msg.sender);
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
   function kill() public 
    onlyOwner()
   {
     
    //if (msg.sender == owner()) {
      selfdestruct(owner());
    //}
  } 

  // Define a function 'harvestItem' that allows a farmer to mark an item 'Harvested'
  function disinfectItem(uint _upc, address _originSupplierID, string memory _originSupplierName, string memory _originSupplierInformation, string memory _originSourceWaterLatitude, string memory _originSourceWaterLongitude, string memory _productNotes) public 
  {
    // Add the new item as part of Disinfect
     Item memory _item = Item({sku:sku,upc:_upc,ownerID:_originSupplierID,originSupplierID:_originSupplierID,originSupplierName:_originSupplierName,originSupplierInformation:_originSupplierInformation,originSourceWaterLatitude:_originSourceWaterLatitude,originSourceWaterLongitude:_originSourceWaterLongitude,
    productID: sku + upc,productNotes:_productNotes,productPrice:0,itemState:State.Disinfected,distributorID:address(0),retailerID:address(0),consumerID:address(0)});
     items[_upc] = _item;
    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit Disinfected(upc);
    
  }

  // Define a function 'collecttItem' that allows a supplier to mark an item 'Collected'
  function collectItem(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
    disinfected(_upc)
    
  // Call modifier to verify caller of this function
    onlySupplier()
    //verifyCaller(items[_upc].ownerID)
  {
    // Update the appropriate fields    
    items[_upc].itemState = State.Collected;
    // Emit the appropriate event
    emit Collected(upc); 
    
    
  }

// Define a function 'filterItem' that allows a supplier to mark an item 'Filtered'
  function filterItem(uint _upc) public
  // Call modifier to check if upc has passed previous supply chain stage
     collected(_upc)
     
  // Call modifier to verify caller of this function
    onlySupplier()
   // verifyCaller(items[_upc].ownerID)
  {     
    // Update the appropriate fields
    items[_upc].itemState = State.Filtered;
    // Emit the appropriate event
    emit Filtered(upc);
  }

  // Define a function 'enhanceItem' that allows a supplier to mark an item 'Enhanced'
  function enhanceItem(uint _upc) public
  // Call modifier to check if upc has passed previous supply chain stage
     filtered(_upc)
     
  // Call modifier to verify caller of this function
    onlySupplier()
    //verifyCaller(items[_upc].ownerID)
  {    
    // Update the appropriate fields
    items[_upc].itemState = State.Enhanced;
    // Emit the appropriate event
    emit Enhanced(upc);
  }



  // Define a function 'packItem' that allows a farmer to mark an item 'Packed'
  function packItem(uint _upc) public
  // Call modifier to check if upc has passed previous supply chain stage
    enhanced(_upc)
    
  // Call modifier to verify caller of this function
    //onlySupplier()
    verifyCaller(items[_upc].ownerID)
  {    
    // Update the appropriate fields    
    items[_upc].itemState = State.Packed;
    // Emit the appropriate event
    emit Packed(upc);
  }

  // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) public
  // Call modifier to check if upc has passed previous supply chain stage
    packed(_upc)
    
  // Call modifier to verify caller of this function
    onlySupplier()
    //verifyCaller(items[_upc].ownerID)
  {  
    // Update the appropriate fields
    items[_upc].productPrice = _price;
    items[_upc].itemState = State.ForSale;
    // Emit the appropriate event
    emit ForSale(_upc);
  }

  // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough,
  // and any excess ether sent is refunded back to the buyer
  function buyItem(uint _upc) public payable
    // Call modifier to check if upc has passed previous supply chain stage
      forSale(_upc)
    // Call modifer to check if buyer has paid enough
      paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    {    
      
    // Update the appropriate fields - ownerID, distributorID, itemState
      
      items[_upc].ownerID = msg.sender;
      items[_upc].distributorID = msg.sender;
      items[_upc].itemState = State.Sold;
    // Transfer money to company
       items[_upc].originSupplierID.transfer(items[_upc].productPrice);
    // emit the appropriate event
      emit Sold(upc);
  }

  // Define a function 'shipItem' that allows the distributor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  function shipItem(uint _upc) public
    // Call modifier to check if upc has passed previous supply chain stage
      sold(_upc)
    // Call modifier to verify caller of this function
      onlyDistributor()
      //verifyCaller(items[_upc].ownerID)
    {  
    
      // Update the appropriate fields
      items[_upc].itemState = State.Shipped;
      // Emit the appropriate event
      emit Shipped(_upc);


  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) public
    // Call modifier to check if upc has passed previous supply chain stage
    shipped(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyRetailer()
    {    
     
    // Update the appropriate fields - ownerID, retailerID, itemState
    items[_upc].itemState = State.Received;
    items[_upc].ownerID = msg.sender;
    items[_upc].retailerID = msg.sender;
    // Emit the appropriate event
    emit Received(_upc);
  }

  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function purchaseItem(uint _upc) public
    // Call modifier to check if upc has passed previous supply chain stage
     received(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyConsumer()
    {    
    // Update the appropriate fields - ownerID, consumerID, itemState
    
    items[_upc].itemState = State.Purchased;
    items[_upc].ownerID = msg.sender;
    items[_upc].consumerID = msg.sender;
    // Emit the appropriate event
    emit Purchased(_upc);
  }

 

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originSupplierID,
  string  originSupplierName,
  string  originSupplierInformation,
  string  originSourceWaterLatitude,
  string  originSourceWaterLongitude
  ) 
  {
  // Assign values to the 8 parameters
  itemSKU = items[_upc].sku;
  itemUPC = items[_upc].upc;
  ownerID = items[_upc].ownerID;
  originSupplierID = items[_upc].originSupplierID;
  originSupplierName = items[_upc].originSupplierName;
  originSupplierInformation = items[_upc].originSupplierInformation;
  originSourceWaterLatitude = items[_upc].originSourceWaterLatitude;
  originSourceWaterLongitude = items[_upc].originSourceWaterLongitude;  
  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  originSupplierID,
  originSupplierName,
  originSupplierInformation,
  originSourceWaterLatitude,
  originSourceWaterLongitude
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  uint    itemState,
  address distributorID,
  address retailerID,
  address consumerID
  ) 
  {
    // Assign values to the 9 parameters
  State _itemState;
  itemSKU = items[_upc].sku;
  itemUPC = items[_upc].upc;
  productID = items[_upc].productID;
  productNotes = items[_upc].productNotes;
  productPrice = items[_upc].productPrice;
  _itemState = State(items[_upc].itemState);
  itemState = uint(_itemState);
  distributorID = items[_upc].distributorID;
  retailerID = items[_upc].retailerID;  
 consumerID = items[_upc].consumerID;
    
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  distributorID,
  retailerID,
  consumerID
  );
  }
}