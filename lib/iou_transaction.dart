class IouTransaction {
  int  _id;
  int     _timestamp;
  int     _balanceEvo;
  int     _displayedAmount;
  String  _users;
  String  _payer;
  String  _label;

  IouTransaction(int id, int timestamp, int balanceEvo, int displayedAmount, String otherUsers, String payer, String label) {
    this._id = id;
    this._timestamp = timestamp;
    this._balanceEvo = balanceEvo;
    this._displayedAmount = displayedAmount;
    this._users = otherUsers;
    this._payer = payer;
    this._label = label;
  }

  int getId() {
    return (_id);
  }

  int getTimestamp() {
    return (_timestamp);
  }

  int getBalanceEvo() {
    return (_balanceEvo);
  }

  int getDisplayedAmount() {
    return (_displayedAmount);
  }

  String getUsers() {
    return (_users);
  }

  String getPayer() {
    return (_payer);
  }

  String getLabel() {
    return (_label);
  }

  void setId(int id) {
    _id = id;
  }

  void setName(int timestamp) {
    _timestamp = timestamp;
  }
  void setBalanceEvo(int balanceEvo) {
    _balanceEvo = balanceEvo;
  }

  @override
  bool operator==(other) => other._id == _id;

  @override
  int get hashCode => _id.hashCode;

}