pragma solidity ^0.5.0;

contract Voluntary_project {
    
    address public owner;
    mapping (address => bool) public valid_validators;
    mapping (address => Attributes) public valid_clients;
    mapping (address => bool) public valid_organizations; // note that here organizations can be other voluntry organizations or banks.
    
    struct Age{
       
        uint val;
        uint ver_result;// not dealt with: 0, approved: 1, rejected: -1
        mapping (uint => address) preferred_verifiers;
        mapping (uint => Verification_res) verification_res;
        uint total_num_of_preferred_verifiers;
        uint total_number_of_verifications;// it keeps track of the number of verifiers who has checked (i.e. approved/rejected) this attribute. 
    }
    
    struct Degree{
       
        string type_;// e.g. MSc, BSc, etc.
        string description;
        uint ver_result;// not dealt with: 0, approved: 1, rejected: -1
        mapping (uint => address) preferred_verifiers;
        uint total_num_of_preferred_verifiers;
        mapping (uint => Verification_res) verification_res;
        uint total_number_of_verifications;
    }
    
    struct License{
       
        string type_;
        string description;
        string Expiry_date;
        uint ver_result;// not dealt with: 0, approved: 1, rejected: -1
        mapping (uint => address) preferred_verifiers;
        uint total_num_of_preferred_verifiers;
        mapping (uint => Verification_res) verification_res;
        uint total_number_of_verifications;
    }
    
    struct Attributes{
        
        mapping (address => Age) age;
        mapping (uint => Degree) degree; // a volunteer can have multiple Degrees
        mapping (uint => License) license; // a volunteer can have multiple Licences
        uint total_number_of_degrees;
        uint total_number_of_licenses;
        bool valid; //this is used to allow a function to check if the attributes belong to a valid volunteer.
        bytes32 proof_of_attributes_ownership;// it simply holds a random value sent by the owner of this Attributes. 
        //It is used when someone wants to ensure that a public key holder is the owner of this attributes. 
        //It simply sends a random value to the oublic key holder who is suposed to store it on this field.  
    }
    
    struct Verification_res{
        
        address verifier_addr;
        bool res;
    }
    
    modifier only_valid_client(){
        
        require(valid_clients[msg.sender].valid == true);
        _;
    }
    
    modifier only_owner(){
        
        require(msg.sender == owner);
        _;
    }
        
    modifier only_valid_admin(){
        
        require(valid_organizations[msg.sender] == true);
        _;
    }
    
    function register_validator(address validator) external only_valid_admin{ // registers valid validators in the smart contract.
        
        valid_validators[validator] = true;
    }
    
    function register_client(address client) external only_valid_admin{ // registers valid volunteers in the smart contract.
        
        Attributes memory atr;
        atr.valid = true;
        valid_clients[client] = atr;
        valid_clients[client].age[client].val = 0;
    }
    
    
    function add_admin(address new_admin) external only_owner{
        
        valid_organizations[new_admin] = true;
    }
    
//------ Insert Attributes-----------------------------

    function is_valid_validator(address validator) internal returns (bool res){
        
        res = false;
        if(valid_validators[validator] == true){
            res = true;
        }
        else res; 
    }
    
    function insert_age(uint val_, address[] calldata verifiers) external only_valid_client{
        
        for(uint i=0; i < verifiers.length; i++){ //check if the verifiers it proposes are valid
            if(is_valid_validator(verifiers[i]) == true){
                uint j = valid_clients[msg.sender].age[msg.sender].total_num_of_preferred_verifiers++;
                valid_clients[msg.sender].age[msg.sender].preferred_verifiers[j] = verifiers[i];
            }
        }
        
        require(valid_clients[msg.sender].age[msg.sender].val == 0); // make sure it cannot overwrite its age
        valid_clients[msg.sender].age[msg.sender].val = val_; // set age's field.
        
    }
    
    function insert_degree(string calldata degree_, string calldata description_, address[] calldata verifiers) external only_valid_client{
        
        uint j = valid_clients[msg.sender].total_number_of_degrees++;
        for(uint i = 0; i < verifiers.length; i++){ //check if the verifiers it proposes are valid.
            if(is_valid_validator(verifiers[i]) == true){
                //insert the verifier
                uint k = valid_clients[msg.sender].degree[j].total_num_of_preferred_verifiers++;
                valid_clients[msg.sender].degree[j].preferred_verifiers[k] = verifiers[i];
            }
        }
        // store degree's fields.
        valid_clients[msg.sender].degree[j].type_ = degree_;
        valid_clients[msg.sender].degree[j].description = description_;
    }
    
    function insert_license(string calldata license_, string calldata description, string calldata expiry_date, address[] calldata verifiers) external only_valid_client{
        
        uint j = valid_clients[msg.sender].total_number_of_licenses++;
        for(uint i = 0; i < verifiers.length; i++){ //check if the verifiers it proposes are valid.
            if(is_valid_validator(verifiers[i]) == true){
                //insert the verifier
                uint k = valid_clients[msg.sender].license[j].total_num_of_preferred_verifiers++;
                valid_clients[msg.sender].license[j].preferred_verifiers[k] = verifiers[i];
            }
        }
        // store all its attributes.
        valid_clients[msg.sender].license[j].type_ = license_;
        valid_clients[msg.sender].license[j].description = description;
        valid_clients[msg.sender].license[j].Expiry_date = expiry_date;
    }
    
   function validate_age(address client, bool res) external{
       // check if the client is valid.
       require(valid_clients[client].valid == true);
       // check if the verifier is valid.
       bool is_valid_verifier = false;
       uint j = valid_clients[client].age[client].total_num_of_preferred_verifiers;
       for(uint i = 0; i < j; i++){
            if(valid_clients[client].age[client].preferred_verifiers[i] == msg.sender){
                is_valid_verifier = true; 
            }
       }
       require(is_valid_verifier);
       //set verification result in age sttribute
       uint k = valid_clients[client].age[client].total_number_of_verifications++;
       valid_clients[client].age[client].verification_res[k].verifier_addr == msg.sender;
       valid_clients[client].age[client].verification_res[k].res == res;
   } 
    
   function validate_degree(address client, bool res, uint index) external{
       // check if the client is valid.
       require(valid_clients[client].valid == true);
       // check if the verifier is valid.
       bool is_valid_verifier = false;
       uint j = valid_clients[client].degree[index].total_num_of_preferred_verifiers;
       for(uint i = 0; i < j; i++){
            if(valid_clients[client].degree[index].preferred_verifiers[i] == msg.sender){
                is_valid_verifier = true; 
            }
       }
       require(is_valid_verifier);
       //set verification result in degree attribute
       uint k = valid_clients[client].degree[index].total_number_of_verifications++;
       valid_clients[client].degree[index].verification_res[k].verifier_addr == msg.sender;
       valid_clients[client].degree[index].verification_res[k].res == res;
   }
   
   function validate_license(address client, bool res, uint index) external{
       // check if the client is valid.
       require(valid_clients[client].valid == true);
       // check if the verifier is valid.
       bool is_valid_verifier = false;
       uint j = valid_clients[client].license[index].total_num_of_preferred_verifiers;
       for(uint i = 0; i < j; i++){
            if(valid_clients[client].license[index].preferred_verifiers[i] == msg.sender){
                is_valid_verifier = true; 
            }
       }
       require(is_valid_verifier);
       //set verification result in degree attribute
       uint k = valid_clients[client].license[index].total_number_of_verifications++;
       valid_clients[client].license[index].verification_res[k].verifier_addr == msg.sender;
       valid_clients[client].license[index].verification_res[k].res == res;
   }
    
    // allows a client to prove to any party that certain Attributes belong to it, and it works as follows:
    // the verifier sends a random value to the prover (off-chain). Then prover stores the value in the fielkd called 
    //"proof_of_attributes_ownership" in its attributes. note that behind the sicence it's checked the signature of msg.sender to make sure 
    // the message is comming from msg.sender. The verification can be done on the user interface, it reads valid_clients[client].proof_of_attributes_ownership 
    //and checks if it equals the number value it sent in the previous step. 
    function prove_attributes_ownership(bytes32 val) external{
        valid_clients[msg.sender].proof_of_attributes_ownership = val;
    }
}