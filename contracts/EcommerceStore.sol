pragma solidity ^0.4.13;
import "contracts/Escrow.sol";
contract EcommerceStore {
  //enum converts words to integers e.g. 0 = open
 enum ProductStatus { Open, Sold, Unsold }
 enum ProductCondition { New, Used }

 uint public productIndex;
 // mapping tracks the merchant account address
 mapping (address => mapping(uint => Product)) stores;
 mapping (uint => address) productIdInStore;
 //maps to escrowInfo
 mapping (uint => address) productEscrow;
// The information the user enters about music product
 struct Product {
  uint id;
  string name;
  string category;
  string imageLink;
  string descLink;
  uint auctionStartTime;
  uint auctionEndTime;
  uint startPrice;
  address highestBidder;
  uint highestBid;
  uint secondHighestBid;
  uint totalBids;
  ProductStatus status;
  ProductCondition condition;
  //tracks which users bid and what they bid
  mapping (address => mapping (bytes32 => Bid)) bids;
 }

 struct Bid {
   address bidder;
   uint productId;
   uint value;
   bool revealed;
 }

//escrow
 function finalizeAuction(uint _productId) public {
  Product memory product = stores[productIdInStore[_productId]][_productId];
  // 48 hours to reveal the bid
  require(now > product.auctionEndTime);
  require(product.status == ProductStatus.Open);
  require(product.highestBidder != msg.sender);
  require(productIdInStore[_productId] != msg.sender);

  if (product.totalBids == 0) {
   product.status = ProductStatus.Unsold;
  } else {
   // Whoever finalizes the auction is the arbiter
   Escrow escrow = (new Escrow).value(product.secondHighestBid)(_productId, product.highestBidder, productIdInStore[_productId], msg.sender);
   productEscrow[_productId] = address(escrow);
   product.status = ProductStatus.Sold;
   // The bidder only pays the amount equivalent to second highest bidder
   // Refund the difference
   uint refund = product.highestBid - product.secondHighestBid;
   product.highestBidder.transfer(refund);

  }
  }

  function releaseAmountToSeller(uint _productId) public {
    Escrow(productEscrow[_productId]).releaseAmountToSeller(msg.sender);
  }

  function refundAmountToBuyer(uint _productId) public {
    Escrow(productEscrow[_productId]).refundAmountToBuyer(msg.sender);
  }

  function escrowAddressForProduct(uint _productId) view public returns (address) {
  return productEscrow[_productId];
  }

  function escrowInfo(uint _productId) view public returns (address, address, address, bool, uint, uint) {
  return Escrow(productEscrow[_productId]).escrowInfo();
 }
 /////
 function EcommerceStore() public {
  productIndex = 0; //increments by 1
 }
 event NewProduct(uint _productId, string _name, string _category, string _imageLink, string _descLink, uint _auctionStartTime, uint _auctionEndTime, uint _startPrice, uint _productCondition);
 function addProductToStore(string _name, string _category, string _imageLink, string _descLink, uint _auctionStartTime,
  uint _auctionEndTime, uint _startPrice, uint _productCondition) public {

    //validates auction start time less than end time
  require (_auctionStartTime < _auctionEndTime);
  productIndex += 1; // the increment as shown above ^
  //product struct initaliser
  Product memory product = Product(productIndex, _name, _category, _imageLink, _descLink, _auctionStartTime, _auctionEndTime,
                   _startPrice, 0, 0, 0, 0, ProductStatus.Open, ProductCondition(_productCondition));
//stores the initaliser
  stores[msg.sender][productIndex] = product;
  //tracks who added the product
  productIdInStore[productIndex] = msg.sender;

  NewProduct(productIndex, _name, _category, _imageLink, _descLink, _auctionStartTime, _auctionEndTime, _startPrice, _productCondition);
}
// returns product details using product id
function getProduct(uint _productId) view public returns (uint, string, string, string, string, uint, uint, uint, ProductStatus, ProductCondition) {
  Product memory product = stores[productIdInStore[_productId]][_productId]; // memory tells EVM object variable is temporary, cleared after function executed
  return (product.id, product.name, product.category, product.imageLink, product.descLink, product.auctionStartTime,
      product.auctionEndTime, product.startPrice, product.status, product.condition);
    }
//retrieve product from stores map & build the big struct and add it to mapping from initaliser
function bid(uint _productId, bytes32 _bid) payable public returns (bool) {
  Product storage product = stores[productIdInStore[_productId]][_productId];
  require (now >= product.auctionStartTime); //now is the current blocks timestamp
  require (now <= product.auctionEndTime);
  require (msg.value > product.startPrice);
  require (product.bids[msg.sender][_bid].bidder == 0);
  product.bids[msg.sender][_bid] = Bid(msg.sender, _productId, msg.value, false);
  product.totalBids += 1;
  return true;
    }
function revealBid(uint _productId, string _amount, string _secret) public {
  Product storage product = stores[productIdInStore[_productId]][_productId];
  bytes32 sealedBid = sha3(_amount, _secret); //hidden bid (private to bidder)

  Bid memory bidInfo = product.bids[msg.sender][sealedBid];
  require (bidInfo.bidder > 0); //bidder must bid something before reavealing
  require (bidInfo.revealed == false);

  uint refund;

  uint amount = stringToUint(_amount);

 if(bidInfo.value < amount) {
// They didn't send enough amount, they lost
  refund = bidInfo.value;
  } else {
// If first to reveal set as highest bidder
 if (address(product.highestBidder) == 0) {
 product.highestBidder = msg.sender;
 product.highestBid = amount;
 product.secondHighestBid = product.startPrice;
 refund = bidInfo.value - amount;
} else {
 if (amount > product.highestBid) {
  product.secondHighestBid = product.highestBid;
  product.highestBidder.transfer(product.highestBid);
  product.highestBidder = msg.sender;
  product.highestBid = amount;
  refund = bidInfo.value - amount;
 } else if (amount > product.secondHighestBid) {
  product.secondHighestBid = amount;
  refund = amount;
 } else {
  refund = amount;
 }
}
}
product.bids[msg.sender][sealedBid].revealed = true;

if (refund > 0) {
  msg.sender.transfer(refund);
}
}
//gets highest bidder (getter) - to display on webpage and for testing
function highestBidderInfo(uint _productId) view public returns (address, uint, uint) {
  Product memory product = stores[productIdInStore[_productId]][_productId];
  return (product.highestBidder, product.highestBid, product.secondHighestBid);
}

function totalBids(uint _productId) view public returns (uint) {
  Product memory product = stores[productIdInStore[_productId]][_productId];
  return product.totalBids;
}

function stringToUint(string s) pure private returns (uint) {
  bytes memory b = bytes(s);
  uint result = 0;
  for (uint i = 0; i < b.length; i++) {
    if (b[i] >= 48 && b[i] <= 57) {
      result = result * 10 + (uint(b[i]) - 48);
    }
  }
  return result;
}
  }
