pragma solidity >=0.4.22 <0.9.0;

contract FighterCreate {
    // ---------------
    // -- VARIABLES --  
    // ---------------

    uint public count = 0;
    uint randNonce = 0;

    event NewFighter(uint fighterId, string name);

    struct Fighter {
        string name;
        uint16 level;
        uint16 victory;
        uint16 losses; 
    }

    Fighter[] public fighters;

    mapping (uint => address) fighterToOwner;
    mapping (address => uint) ownerFighterCount;

    // ---------------
    // --- UTILITY --- 
    // ---------------
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
/*
    function compareStringsbyBytes(string memory s1, string memory s2) internal pure returns(bool){
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }*/

    function randMod(uint _modulus) internal returns(uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
    }

    // -------------- 
    // -- CREATION --
    // --------------


    function _createFighter(string memory _name) internal{
        fighters.push(Fighter(_name, 1, 0, 0));
        fighterToOwner[count] = msg.sender;
        ownerFighterCount[msg.sender]++;
        count++;
    }

    function mintFighter(string memory _name) public {
        //require(ownerFighterCount[msg.sender] == 0);
        _createFighter(_name);
    }


    // ------------
    // -- HELPER --
    // ------------
    
    function getEnemies(uint _id) external view returns (uint[] memory){
        uint sameLevelCount = 0; // To create the enemySameLevel array
        uint indexCounter = 0; // Be able to keep count of where to push next in sameLevelArray

        // First iteration to get the array length of sameLevel 
        for (uint i = 0; i < fighters.length; i++){
            if (fighterToOwner[i] != msg.sender && fighters[i].level == fighters[_id].level && i != _id){
                sameLevelCount++;
            }
        }

        uint[] memory allIds = new uint[](sameLevelCount);

        for (uint i = 0; i < fighters.length; i++){
            if (fighterToOwner[i] != msg.sender && fighters[i].level == fighters[_id].level && i != _id){
                allIds[indexCounter] = i;
                indexCounter++;
            }
        }

        return allIds;

    }

    function getFighterByOwner(address _owner) external view returns(string memory) {
        string memory result = "";
        for (uint i = 0; i < fighters.length; i++) {
            if (fighterToOwner[i] == _owner) {
                result = string(abi.encodePacked(result, uint2str(i), ";", fighters[i].name, ";", uint2str(fighters[i].level), ";", uint2str(fighters[i].victory), ";", uint2str(fighters[i].losses), ","));
            }
        }
        return result;
    }

    function getFighterInformation(uint _id) public view returns(string memory){
        Fighter memory chosenFighter = fighters[_id];
        return string(abi.encodePacked(chosenFighter.name, ";", uint2str(chosenFighter.level), ";", uint2str(chosenFighter.victory), ";", uint2str(chosenFighter.losses)));
    }

    function isOwner(uint _id) public view returns(bool){
        return msg.sender == fighterToOwner[_id];
    }

    function fight(uint _myId, uint _enemyId) external returns(uint) {
        require(isOwner(_myId));
        Fighter storage myFighter = fighters[_myId];
        Fighter storage enemyFighter = fighters[_enemyId];
        uint rand = randMod(100);
        uint attackVictoryProbability = 50;

        if (rand <= attackVictoryProbability) {
            myFighter.victory++;
            enemyFighter.losses++;
            if ((myFighter.victory/(myFighter.level+1)) == 1){
                myFighter.level++;    
            }
            return 0;
        } else {
            myFighter.losses++;
            enemyFighter.victory++;
            return 1;
        }    
    }
}
