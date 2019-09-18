pragma solidity ^0.5.1;

contract Voluntary_project {
    
    //+++++++++++ Contract's variables
    address public owner;
    uint public initial_verification_cost;
    uint public ratio;// determines what fraction of the initial_verification_cost is paid by the user of the verification result. Then 
    // the first user pays initial_verification_cost/ratio to the validator. The 2nd user pays  initial_verification_cost/ratio*ratio to the validator and 1st users and so on. 
    mapping (address => bool) public valid_validators;
    mapping (address => Attributes) public valid_clients;
    mapping (address => bool) public valid_organizations; // note that here organizations can be other voluntry organizations or banks.
    mapping (address => bool) public validator_with_inconsistent_res;// it allows the public to query and identify those validators who have provided an openinig of the commitment (i.e. the verification result)
    // that is not accepted by verify_commitment
    //+++++++++++
    constructor () public{
        owner = msg.sender;
        valid_organizations[msg.sender] = true;
        initial_verification_cost = 10 * 1000000000000000000;
        ratio = 2;
    }
    //********** structs
    struct Age{
       
        bytes val;
       // bytes32[] ver_result;// not dealt with: 0, approved: 1, rejected: -1 //xxxx I think we don't need this
        mapping (uint => address) preferred_verifiers;
        mapping (uint => Verification_res) verification_res;
        mapping (address => bool) verifier_exists;// is used to perevent verifier dublications.
        mapping (address => bool) verifiers_verified;// is used to perevent a verifier to verify an attribute multiple times.
        uint total_num_of_preferred_verifiers;
        uint total_number_of_verifications;// it keeps track of the number of verifiers who has checked (i.e. approved/rejected) this attribute. 
        bool inserted;
    }

    struct Degree{
       
        bytes type_;// e.g. MSc, BSc, etc.
        bytes description;
        //uint ver_result;// not dealt with: 0, approved: 1, rejected: -1
        mapping (uint => address) preferred_verifiers;
        mapping (address => bool) verifier_exists;// is used to perevent verifier dublications.
        mapping (address => bool) verifiers_verified;// is used to perevent a verifier to verify an attribute multiple times.
        uint total_num_of_preferred_verifiers;
        mapping (uint => Verification_res) verification_res;
        uint total_number_of_verifications;
    }
    
    struct License{
       
        bytes type_;
        bytes description;
        bytes Expiry_date;
        //uint ver_result;// not dealt with: 0, approved: 1, rejected: -1
        mapping (uint => address) preferred_verifiers;
        mapping (address => bool) verifier_exists;// is used to perevent verifier dublications.
        mapping (address => bool) verifiers_verified;// is used to perevent a verifier to verify an attribute multiple times.
        mapping (uint => Verification_res) verification_res;
        uint total_number_of_verifications;
        uint total_num_of_preferred_verifiers;
    }
    
    struct Attributes{
        
        mapping (address => Age) age;
        mapping (uint => Degree) degree; // a volunteer can have multiple Degrees
        mapping (uint => License) license; // a volunteer can have multiple Licences
        uint total_number_of_degrees;
        uint total_number_of_licenses;
        bool valid; //this is used to allow a function to check if the attributes belong to a valid volunteer.
        bytes proof_of_attributes_ownership;// it simply holds a random value sent by the owner of this Attributes. 
        //It is used when someone wants to ensure that a public key holder is the owner of this attributes. 
        //It simply sends a random value to the oublic key holder who is suposed to store it on this field.  
    }
    
    struct Verification_res{
        
        address payable verifier_addr;
        //bool res;
        bytes32 res;// the commitment to the verification result
        bool inconsistent_commitment_opening_provided;// this is set to true, if the validator has provided at least once an opening of the commitment: res, that is not accepted by verrify_commit()
        mapping (uint => address payable) who_gets_paid;
        uint counter;
    }
    //**********
    //----------getter functions for Age's fields
    function get_client_age_val(address client) external view returns (bytes memory ){
        
        return  valid_clients[client].age[client].val;
    }
    
    function get_client_age_num_of_preferred_verifiers(address client) external view returns (uint){
        
        return valid_clients[client].age[client].total_num_of_preferred_verifiers;
    }
    
    function get_client_age_total_number_of_verifications(address client) external view returns (uint){
        
        return valid_clients[client].age[client].total_number_of_verifications;
    }

    function get_client_age_preferred_verifier(address client, uint indx) external view returns (address){
        
        return valid_clients[client].age[client].preferred_verifiers[indx];
    }
    
    function get_client_age_verification_res(address client, uint indx) external view returns (bytes32){
        
        return valid_clients[client].age[client].verification_res[indx].res;
    }
    
    function get_client_age_verification_res_whoGetsPaid(address client, uint ver_res_indx, uint who_gets_paid_indx) external view returns (address){
        
        return valid_clients[client].age[client].verification_res[ver_res_indx].who_gets_paid[who_gets_paid_indx];
    }
    
    function get_client_age_verification_res_counter(address client, uint ver_res_indx) external view returns (uint){
        
        return valid_clients[client].age[client].verification_res[ver_res_indx].counter;
    }
    
    //valid_clients[client].age[client].verification_res[indx].counter
    
    //----------getter functions for Degree's fields
    
    function get_client_degree_type(address client, uint indx) external view returns (bytes memory){
        
        return valid_clients[client].degree[indx].type_;
    }
    
    function get_client_degree_description(address client, uint indx)  external view  returns (bytes memory){
        
        return valid_clients[client].degree[indx].description;
    }
    
    function get_client_degree_num_of_preferred_verifiers(address client, uint indx) external view returns (uint){
        
        return valid_clients[client].degree[indx].total_num_of_preferred_verifiers;
    }
    
    function get_client_degree_number_of_verifications(address client, uint indx) external view returns (uint){
        
        return valid_clients[client].degree[indx].total_number_of_verifications;
    }
    
    function get_client_degree_preferred_verifier(address client,  uint degree_indx, uint verifier_indx) external view returns (address){
        
        return valid_clients[client].degree[degree_indx].preferred_verifiers[verifier_indx];
    }
    
    function get_client_degree_verification_res(address client, uint degree_indx, uint verifier_indx) external view returns (bytes32){
        
        return valid_clients[client].degree[degree_indx].verification_res[verifier_indx].res;
    }
    
    function get_client_degree_verification_res_whoGetsPaid(address client, uint degree_indx, uint who_gets_paid_indx) external view returns (address){
        
        return valid_clients[client].degree[degree_indx].verification_res[0].who_gets_paid[who_gets_paid_indx];
    }
    
    //----------getter functions for License's fields
    function get_client_license_type(address client,uint indx) external view returns (bytes memory){
        
        return valid_clients[client].license[indx].type_;
    }
    
    function get_client_license_description(address client, uint indx) external view returns (bytes memory){
        
        return valid_clients[client].license[indx].description;
    }
    
    function get_client_license_expiryDate(address client, uint indx) external view returns (bytes memory){
        
        return valid_clients[client].license[indx].Expiry_date;
    }
    
    function get_client_license_num_of_preferred_verifiers(address client, uint indx) external view returns (uint){
        
        return valid_clients[client].license[indx].total_num_of_preferred_verifiers;
    }
    
    function get_client_license_number_of_verifications(address client, uint indx) external view returns (uint){
        
        return valid_clients[client].license[indx].total_number_of_verifications;
    }
    
    function get_client_license_preferred_verifier(address client,  uint degree_indx, uint verifier_indx) external view returns (address){
        
        return valid_clients[client].license[degree_indx].preferred_verifiers[verifier_indx];
    }
    
    function get_client_license_verification_res(address client, uint license_indx, uint verifier_indx) external view returns (bytes32){
        
        return valid_clients[client].license[license_indx].verification_res[verifier_indx].res;
    }
    
    function get_client_license_verification_res_whoGetsPaid(address client, uint degree_indx, uint who_gets_paid_indx) external view returns (address){
        
        return valid_clients[client].license[degree_indx].verification_res[0].who_gets_paid[who_gets_paid_indx];
    }
    //-------------
    //================ modifiers
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
    //================ 
    function find_degree_index(address client, bytes calldata val) external view returns (uint index){
        
        uint j = valid_clients[client].total_number_of_degrees;
        for(uint i = 0;i < j; i++){
            if(keccak256(valid_clients[client].degree[i].type_) == keccak256(val)){
                index = i;
                break;
            }
        }
    }
    
    function find_license_index(address client, bytes calldata val) external view returns (uint index){
        
        uint j = valid_clients[client].total_number_of_licenses;
        for(uint i = 0;i < j; i++){
            if(keccak256(valid_clients[client].license[i].type_) == keccak256(val)){
                index = i;
                break;
            }
        }
    }
    
    function register_validator(address validator) external only_valid_admin{ // registers valid validators in the smart contract.
        
        valid_validators[validator] = true;
    }
    
    function register_client(address client) external only_valid_admin{ // registers valid volunteers in the smart contract.
        
        Attributes memory atr;
        atr.valid = true;
        valid_clients[client] = atr;
        valid_clients[client].age[client].inserted = false;
    }
    
    function add_admin(address new_admin) external only_owner{
        
        valid_organizations[new_admin] = true;
    }
    
    function is_valid_validator(address validator) internal view returns (bool res){
        
        res = false;
        if(valid_validators[validator] == true){
            res = true;
        }
        else res; 
    }
    
    function insert_age(bytes calldata com_val_, address[] calldata verifiers) external only_valid_client{
        
        for(uint i = 0; i < verifiers.length; i++){ //checks if (1) each verifier the client proposes is valid, i.e. registered by the owner/admin and
         //(2) the verifier has not already been registered for this attribute (to prevent dublication).
            if(is_valid_validator(verifiers[i]) == true && valid_clients[msg.sender].age[msg.sender].verifier_exists[verifiers[i]] == false){
                uint j = valid_clients[msg.sender].age[msg.sender].total_num_of_preferred_verifiers++;
                valid_clients[msg.sender].age[msg.sender].preferred_verifiers[j] = verifiers[i];
                valid_clients[msg.sender].age[msg.sender].verifier_exists[verifiers[i]] = true;
            }
        }
        // makes sure it cannot overwrite its age
        if(valid_clients[msg.sender].age[msg.sender].inserted == false){
            valid_clients[msg.sender].age[msg.sender].val = com_val_;
        }
    }
    
    function insert_degree(bytes calldata degree_, bytes calldata description_, address[] calldata verifiers) external only_valid_client{

        uint counter = 0;
        uint j = valid_clients[msg.sender].total_number_of_degrees++;
        for(uint i = 0; i < verifiers.length; i++){ //checks if (1) the verifiers it proposes are valid (2) there's no duplication in verifiers list.
            if(is_valid_validator(verifiers[i]) == true && valid_clients[msg.sender].degree[j].verifier_exists[verifiers[i]] == false){
                //insert the verifier
                uint k = valid_clients[msg.sender].degree[j].total_num_of_preferred_verifiers++;
                valid_clients[msg.sender].degree[j].preferred_verifiers[k] = verifiers[i];
                valid_clients[msg.sender].degree[j].verifier_exists[verifiers[i]] = true;
                counter++;
            }
        }
        //require (counter == verifiers.length);// ensures that  verifiers array contains (1) valid verifiers and (2) no dublication.
        // store degree's fields.
        valid_clients[msg.sender].degree[j].type_ = degree_;
        valid_clients[msg.sender].degree[j].description = description_;
    }
  
    function insert_license(bytes calldata license_, bytes calldata description, bytes calldata expiry_date, address[] calldata verifiers) external only_valid_client{
        
        uint counter = 0;
        uint j = valid_clients[msg.sender].total_number_of_licenses++;
        for(uint i = 0; i < verifiers.length; i++){ //check if the verifiers it proposes are valid.
            if(is_valid_validator(verifiers[i]) == true  && valid_clients[msg.sender].license[j].verifier_exists[verifiers[i]] == false){
                //insert the verifier
                uint k = valid_clients[msg.sender].license[j].total_num_of_preferred_verifiers++;
                valid_clients[msg.sender].license[j].preferred_verifiers[k] = verifiers[i];
                valid_clients[msg.sender].license[j].verifier_exists[verifiers[i]] = true;
                counter++;
            }
        }
       // require (counter == verifiers.length);// ensures that verifiers array contains (1) valid verifiers and (2) no dublication.
        // store all its attributes.
        valid_clients[msg.sender].license[j].type_ = license_;
        valid_clients[msg.sender].license[j].description = description;
        valid_clients[msg.sender].license[j].Expiry_date = expiry_date;
    }
   
    function validate_age(address client, bytes32  res) external{
       // check if the client is valid.
       require(valid_clients[client].valid == true);
       // check if the verifier is valid.
       require(valid_clients[client].age[client].verifier_exists[msg.sender] == true);
       require(valid_clients[client].age[client].verifiers_verified[msg.sender] == false);
       valid_clients[client].age[client].verifiers_verified[msg.sender] = true; 
       //set verification result in age's attribute
       uint k = valid_clients[client].age[client].total_number_of_verifications++;
       require(k == 0);// ensures only one validator validates the attribute--Otherwise (when multi-validators engage), the payment 
       // system would be more complicated. 
      // valid_clients[client].age[client].verification_res[k].verifier_addr = msg.sender;
       uint t = valid_clients[client].age[client].verification_res[k].counter++;//recently added
       valid_clients[client].age[client].verification_res[k].who_gets_paid[t] = msg.sender;//recently added
       valid_clients[client].age[client].verification_res[k].res = res;
    } 
    //in future we need to add a feature to tis function, so the client can provide a signature on the opening of res to this function
    // so the function first checks it's the siganture of the validator, and then verifies the commitment.
    function verify_age_commitment(address client, address verifier, bytes calldata r, string calldata m) external{
        // check if the client is valid.
        require(valid_clients[client].valid == true);
        // check if the verifier is valid.
        require(valid_clients[client].age[client].verifier_exists[verifier] == true);
        require(valid_clients[client].age[client].verifiers_verified[verifier] == true);
        // find the result provided by the validator
        uint k = valid_clients[client].age[client].total_number_of_verifications;
        uint indx;
        for(uint i = 0; i < k; i++){
            if (valid_clients[client].age[client].verification_res[i].verifier_addr == verifier){
                indx = i;
                break;
            }
        }
        //checks the validator's siganture--- yet to be done
        //then checks the commitment's opening
        if(keccak256(abi.encodePacked(r,m)) != valid_clients[msg.sender].age[msg.sender].verification_res[indx].res){
            validator_with_inconsistent_res[verifier] = true;
            valid_clients[msg.sender].age[msg.sender].verification_res[indx].inconsistent_commitment_opening_provided = true;
        }
    }
    
    function determineAmount_toPay_to_ageValidator (address client) external view returns (uint to_pay) {
        
        uint k = valid_clients[client].age[client].verification_res[0].counter;
        to_pay = (determin_total_share(k));
    }
    
    function determineAmount_toPay_to_degreeValidator (address client, uint index) external view returns (uint to_pay) {
        
        uint k = valid_clients[client].degree[index].verification_res[0].counter;
        to_pay = (determin_total_share(k));
    }
    
    function determineAmount_toPay_to_licenseValidator (address client, uint index) external view returns (uint to_pay) {
        
        uint k = valid_clients[client].license[index].verification_res[0].counter;
        to_pay = (determin_total_share(k));
    }
    // for the current version there's only one verifier allowed to provide its input, so the index is set to 0.
    function pay_validator_of_age(address client) payable external{
        
        uint k = valid_clients[client].age[client].verification_res[0].counter++;
        uint total_amount_to_pay = (determin_total_share (k));
        require(msg.value >= total_amount_to_pay); // ensure the user pays enough coin
        require(k > 0);// ensures that atleast one validator has provided its input.
        uint each_share = (total_amount_to_pay) / k;
        for(uint i = 0; i < k; i++){
            valid_clients[client].age[client].verification_res[0].who_gets_paid[i].transfer(each_share);
        }
        valid_clients[client].age[client].verification_res[0].who_gets_paid[k] = msg.sender;
    }
    //determines the number of coins a user of a verification result should pay in total. In other words, it determines, how to share the initial cost.
    function determin_total_share(uint total_numOf_parties) internal view returns(uint){
        return (initial_verification_cost) / (ratio * total_numOf_parties);
    }
   
    function validate_degree(address client, bytes32 res, uint index) external{
      
       require(valid_clients[client].valid == true);  // check if the client is valid.
       require(valid_clients[client].degree[index].verifier_exists[msg.sender] == true); // check if the verifier is valid.
       require(valid_clients[client].degree[index].verifiers_verified[msg.sender] == false);// check if the verifier has been nominated by the client
       valid_clients[client].degree[index].verifiers_verified[msg.sender] = true;
       //set verification result in degree attribute
       uint k = valid_clients[client].degree[index].total_number_of_verifications++;
       require(k == 0); // ensures only one validator validates the attribute
       uint t = valid_clients[client].degree[index].verification_res[k].counter++;
       valid_clients[client].degree[index].verification_res[k].who_gets_paid[t] = msg.sender; // insert the validator address to who_gets_paid 
       valid_clients[client].degree[index].verification_res[k].res = res; // stor the verification result
    }
    
    function pay_validator_of_degree(address client, uint indx) payable external{
        
        //pay the validator
        uint k = valid_clients[client].degree[indx].total_number_of_verifications;// since at the moment there's only once client allowed to provide its input, total_number_of_verifications=0
        require(k > 0);// ensures that at least one validator has provided its input.
        uint t = valid_clients[client].degree[indx].verification_res[0].counter++;
        uint total_amount_to_pay = (determin_total_share (t));
        require(msg.value >= total_amount_to_pay); // ensure the user pays enough coin
        uint each_share = (total_amount_to_pay) / t;
        for(uint i = 0; i < t; i++){
            valid_clients[client].degree[indx].verification_res[0].who_gets_paid[i].transfer(each_share) ;
        }
        valid_clients[client].degree[indx].verification_res[0].who_gets_paid[t] = msg.sender;
    }
    
    function validate_license(address client, bytes32 res, uint index) external{
        // check if the client is valid.
        require(valid_clients[client].valid == true);
        // check if the verifier is valid.
        require(valid_clients[client].license[index].verifier_exists[msg.sender] == true);
        require(valid_clients[client].license[index].verifiers_verified[msg.sender] == false);
        valid_clients[client].license[index].verifiers_verified[msg.sender] = true;
        //set verification result in degree attribute
        uint k = valid_clients[client].license[index].total_number_of_verifications++;
        require(k == 0); // ensures only one validator validates the attribute
        uint t = valid_clients[client].license[index].verification_res[k].counter++;
        valid_clients[client].license[index].verification_res[k].who_gets_paid[t] = msg.sender;
        valid_clients[client].license[index].verification_res[k].res = res;
    }
    
    function pay_validator_of_license(address client, uint indx) payable external{
        
        //pay the validator
        uint k = valid_clients[client].license[indx].total_number_of_verifications;// since at the moment there's only once client allowed to provide its input, total_number_of_verifications=0
        require(k > 0);// ensures that at least one validator has provided its input.
        uint t = valid_clients[client].license[indx].verification_res[0].counter++;
        uint total_amount_to_pay = (determin_total_share(t));
        require(msg.value >= total_amount_to_pay); // ensure the user pays enough coin
        uint each_share = (total_amount_to_pay) / t;
        for (uint i = 0; i < t; i++){
            valid_clients[client].license[indx].verification_res[0].who_gets_paid[i].transfer(each_share) ;
        }
        valid_clients[client].license[indx].verification_res[0].who_gets_paid[t] = msg.sender;
    }
    
    
    
    // allows a client to prove to any party that certain Attributes belong to it, and it works as follows:
    // the verifier sends a random value to the prover (off-chain). Then prover stores the value in the fielkd called 
    //"proof_of_attributes_ownership" in its attributes. note that behind the sicence it's checked the signature of msg.sender to make sure 
    // the message is comming from msg.sender. The verification can be done on the user interface, it reads valid_clients[client].proof_of_attributes_ownership 
    //and checks if it equals the number value it sent in the previous step. 
    function prove_attributes_ownership(bytes calldata val) external{
        valid_clients[msg.sender].proof_of_attributes_ownership = val;
    }
    
}
