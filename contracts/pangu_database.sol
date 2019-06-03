pragma solidity 0.5.3;

contract MetaDataCrud {

  struct DataStruct {
    address publisher;
    string dataEncrypted;
    string dataDescription;
    bytes32 dataType;
    bytes32 checkSum;
    string dataSize;
    uint index;
  }

  mapping(bytes32 => DataStruct) private DataStructs;
  bytes32[] private dataIndex;

  event LogNewMetaData   (bytes32 indexed dataID, uint index, address publisher, string dataEncrypted, string dataDescription, bytes32 dataType, bytes32 checkSum, string dataSize);
  event LogUpdateMetaData(bytes32 indexed dataID, uint index, address publisher, string dataEncrypted, string dataDescription, bytes32 dataType, bytes32 checkSum, string dataSize);
  event LogDeleteMetaData(bytes32 indexed dataID, uint index);

  function isDataId(bytes32 dataID)
  public
  view
  returns(bool isIndeed)
  {
    if(dataIndex.length == 0) return false;
    return (dataIndex[DataStructs[dataID].index] == dataID);
  }

  function insertMeatData(
    bytes32 dataID,
    string memory dataEncrypted,
    string memory dataDescription,
    bytes32 dataType,
    bytes32 checkSum,
    string memory dataSize)
  public
  returns(uint index)
  {
    if(isDataId(dataID)) revert();
    DataStructs[dataID].publisher         = msg.sender;
    DataStructs[dataID].dataEncrypted     = dataEncrypted;
    DataStructs[dataID].dataDescription   = dataDescription;
    DataStructs[dataID].dataType          = dataType;
    DataStructs[dataID].dataSize          = dataSize;
    DataStructs[dataID].checkSum          = checkSum;
    DataStructs[dataID].index             = dataIndex.push(dataID)-1;
    emit LogNewMetaData(
      dataID,
      DataStructs[dataID].index,
      msg.sender,
      dataEncrypted,
      dataDescription,
      dataType,
      checkSum,
      dataSize);
    return dataIndex.length-1;
  }

  function deleteMetaData(bytes32 dataID)
  public
  returns(uint index)
  {
    if(!isDataId(dataID)) revert();
    require(DataStructs[dataID].publisher == msg.sender);
    uint rowToDelete = DataStructs[dataID].index;
    bytes32 keyToMove = dataIndex[dataIndex.length-1];
    dataIndex[rowToDelete] = keyToMove;
    DataStructs[keyToMove].index = rowToDelete;
    dataIndex.length--;
    emit LogDeleteMetaData(
      dataID,
      rowToDelete);
    emit LogUpdateMetaData(
      keyToMove,
      rowToDelete,
      DataStructs[keyToMove].publisher,
      DataStructs[keyToMove].dataEncrypted,
      DataStructs[keyToMove].dataDescription,
      DataStructs[keyToMove].dataType,
      DataStructs[keyToMove].checkSum,
      DataStructs[keyToMove].dataSize
    );
    return rowToDelete;
  }

  function getMetaData(bytes32 dataID)
  public
  view
  returns( address publisher, string memory dataEncrypted, string memory dataDescription, bytes32 dataType, bytes32 checkSum, string memory dataSize, uint index)
  {
    if(!isDataId(dataID)) revert();
    return(
    DataStructs[dataID].publisher,
    DataStructs[dataID].dataEncrypted,
    DataStructs[dataID].dataDescription,
    DataStructs[dataID].dataType,
    DataStructs[dataID].checkSum,
    DataStructs[dataID].dataSize,
    DataStructs[dataID].index);
  }

  function updateEncrData(bytes32 dataID, string memory dataEncrypted)
  public
  returns(bool success)
  {
    if(!isDataId(dataID)) revert();
    require(DataStructs[dataID].publisher == msg.sender);
    DataStructs[dataID].dataEncrypted = dataEncrypted;
    emit LogUpdateMetaData(
      dataID,
      DataStructs[dataID].index,
      DataStructs[dataID].publisher,
      dataEncrypted,
      DataStructs[dataID].dataDescription,
      DataStructs[dataID].dataType,
      DataStructs[dataID].checkSum,
      DataStructs[dataID].dataSize);
    return true;
  }

  function updateDataDiscr(bytes32 dataID, string memory dataDescription)
  public
  returns(bool success)
  {
    if(!isDataId(dataID)) revert();
    require(DataStructs[dataID].publisher == msg.sender);
    DataStructs[dataID].dataDescription = dataDescription;
    emit LogUpdateMetaData(
      dataID,
      DataStructs[dataID].index,
      DataStructs[dataID].publisher,
      DataStructs[dataID].dataEncrypted,
      dataDescription,
      DataStructs[dataID].dataType,
      DataStructs[dataID].checkSum,
      DataStructs[dataID].dataSize
    );
    return true;
  }

  function getMetaDataCount()
  public
  view
  returns(uint count)
  {
    return dataIndex.length;
  }

  function getMetaDataAtIndex(uint index)
  public
  view
  returns(bytes32 dataID)
  {
    return dataIndex[index];
  }
}
