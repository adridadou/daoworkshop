contract Exchange {


        function Exchange() {
                owner = tx.origin;
        }
        mapping(uint => Company) public companies;
        mapping(uint => Trade) public trades;
        mapping(uint => User) public users;
        mapping(uint => mapping(uint => uint)) public data;
        mapping(uint => mapping(uint => uint)) public managed;
        uint public compCount = 0;
        uint public holdersCount = 0;
        uint public tradeCount = 0;
        address owner;

        struct Company {
                string name;
                string symbol;
                string mifidStatus;
                string isin;
                string ccy;
                uint shares;
        }
        struct Trade {
                uint from;
                uint to;
                uint compId;
                uint amount;
        }

        struct User {
                address add;
                string name;
                uint amount;
        }

        function addUser(address add, string _name, uint amount, uint _fund) {
                if (msg.sender == owner) {
                        users[++holdersCount] = User(add, _name, amount);
                        uint[] memory arr = new uint[](3);
                        arr[0] = holdersCount;
                        arr[1] = amount;
                        arr[2] = _fund;


                        genericEvent('userAdded', now, arr, _name, '', '', '', '');
                }
        }

        function deposit(uint from, uint to, uint amount) {
                if (users[from].amount > amount) {

                        if (managed[to][from] > 0) {
                                managed[to][from] += amount;
                        } else {
                                managed[to][from] = amount;
                                log0('added');
                        }

                        users[from].amount -= amount;
                        uint[] memory arr = new uint[](3);
                        arr[0] = from;
                        arr[1] = to;
                        arr[2] = amount;

                        genericEvent('depositAdded', now, arr, '', '', '', '', '');

                }


        }

        event genericEvent(string eventName, uint time, uint[] numbers, string p1, string p2, string p3, string p4, string p5);


        event companyAdded(uint compId, string name, string symbol, string mifid, string isin, uint shares, uint holder, string ccy);

        function registerCompany(string _name, string _symbol, string _mifid, string _isin, string _ccy, uint shares, uint holder) {
                if (msg.sender == owner) {
                        companies[++compCount] = Company(_name, _symbol, _mifid, _isin, _ccy, shares);
                        data[compCount][holder] = shares;
                        uint[] memory arr = new uint[](3);
                        arr[0] = compCount;
                        arr[1] = shares;
                        arr[2] = holder;

                        genericEvent('companyAdded', now, arr, _name, _symbol, _mifid, _isin, '');


                }
        }
        event tradeAdded(uint tradeId, uint time, uint compId, uint amount, uint price, uint from, uint to);

        event shareHolder(uint id, string name, address add, uint amount);

        function getShareBalance(uint shareId, uint holderId) constant returns(uint) {
                return data[shareId][holderId];
        }

        function getManagedBalance(uint managerId, uint userId) constant returns(uint) {
                return managed[managerId][userId];
        }

        function addTrade(uint _from, uint _to, uint _compId, uint _amount, uint _price) {
                if (msg.sender == owner) {

                        if (data[_compId][_from] - _amount >= 0 && (users[_to].amount > _amount * _price)) {
                                users[_to].amount -= _amount * _price;
                                users[_from].amount += _amount * _price;
                                uint time = now;


                                data[_compId][_from] = data[_compId][_from] - _amount;
                                data[_compId][_to] = data[_compId][_to] + _amount;

                                trades[++tradeCount] = Trade(_from, _to, _compId, _amount);

                                uint[] memory arr = new uint[](7);
                                arr[0] = tradeCount;
                                arr[1] = _compId;
                                arr[2] = _amount;
                                arr[3] = _price;
                                arr[4] = _from;
                                arr[5] = _to;

                                genericEvent('tradeAdded', time, arr, '', '', '', '', '');

                        }

                }

        }



}