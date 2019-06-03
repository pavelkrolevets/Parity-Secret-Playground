pragma solidity 0.5.3;

import './pangu_permission.sol';

contract GrantAccess is SSPermissions{

  mapping(bytes32 => mapping(address => bool)) private documentPermissions;
  mapping(address => mapping(bytes32 => uint)) private documentOwnershipAndPrice;
  mapping(address => mapping(address => mapping(bytes32 => uint))) private depositForDoc;

  function publish (
    bytes32 _documentId,
    uint doc_price
  ) public {
    require(_documentId != 0);
    require(doc_price > 0);
    documentOwnershipAndPrice[msg.sender][_documentId] = doc_price;
  }

  function checkDeposit (address _publisher, address _consumer, bytes32 _documentId) view public returns(uint deposit) {
    return depositForDoc[_publisher][_consumer][_documentId];
  }

  function checkDocPrice (address _publisher, bytes32 _documentId)view public returns(uint price){
    return documentOwnershipAndPrice[_publisher][_documentId];
  }

  function deposit(address _docOwner, bytes32 _documentId) public payable {
    require(documentOwnershipAndPrice[_docOwner][_documentId] >= 0);
    require(msg.value >= documentOwnershipAndPrice[_docOwner][_documentId]);
    depositForDoc[_docOwner][msg.sender][_documentId] = msg.value;
    documentPermissions[_documentId][msg.sender] = true;
  }

  function releaseEscrow(address payable _publisher, bytes32 _documentId) public {
    require(depositForDoc[_publisher][msg.sender][_documentId]!=0);
    uint balance;
    balance = depositForDoc[_publisher][msg.sender][_documentId];
    _publisher.transfer(address(this).balance);
    depositForDoc[_publisher][msg.sender][_documentId] = 0;
  }

  function checkPermissions(
    address _grantee,
    bytes32 _documentId
  )
  external view
  returns(bool permissionGranted)
  {
    return documentPermissions[_documentId][_grantee];
  }
}


