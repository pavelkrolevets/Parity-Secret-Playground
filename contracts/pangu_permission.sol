pragma solidity 0.5.7;

interface SSPermissions {

    function checkPermissions(
        address user,
        bytes32 documentKeyId
    )
    external view
    returns (bool permissionGranted);
}