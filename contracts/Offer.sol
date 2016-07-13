import "./dao_complete.sol";

contract SampleOfferWithoutReward {

    uint public totalCosts;
    uint public oneTimeCosts;
    uint public dailyWithdrawLimit;

    uint public dateOfSignature;
    DAO public client; // address of DAO
    DAO public originalClient; // address of DAO who signed the contract
    bool public isContractValid;

    modifier onlyClient {if (msg.sender != address(client)) throw; _ }

    // Prevents methods from perfoming any value transfer
    modifier noEther() {if (msg.value > 0) throw; _}

    function SampleOfferWithoutReward(
        address _client,
        uint _totalCosts,
        uint _oneTimeCosts,
        uint _dailyWithdrawLimit
    ) {
        originalClient = DAO(_client);
        client = DAO(_client);
        totalCosts = _totalCosts;
        oneTimeCosts = _oneTimeCosts;
        dailyWithdrawLimit = _dailyWithdrawLimit;
    }
    
    function sign() {
        if (msg.sender != address(originalClient) // no good samaritans give us money
            || msg.value != totalCosts    // no under/over payment
            || dateOfSignature != 0)      // don't sign twice
            throw;
            
        dateOfSignature = now;
        isContractValid = true;
    }

    function setDailyWithdrawLimit(uint _dailyWithdrawLimit) onlyClient noEther {
        dailyWithdrawLimit = _dailyWithdrawLimit;
    }

    // "fire the contractor"
    function returnRemainingEther() onlyClient {
        if (originalClient.DAOrewardAccount().call.value(this.balance)())
            isContractValid = false;
    }

    // Change the client DAO by giving the new DAO's address
    // warning: The new DAO must come either from a split of the original
    // DAO or an update via `newContract()` so that it can claim rewards
    function updateClientAddress(DAO _newClient) onlyClient noEther {
        client = _newClient;
    }

    function () {
        sign();
    }
}
