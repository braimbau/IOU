class IouTransaction {
  int  _id;
  int     _timestamp;
  int     _balanceEvo;
  int     _displayedAmount;
  int     _actualAmount;
  String  _selectedUsers;
  String  _payer;
  String  _label;

  IouTransaction(int id, int timestamp, int balanceEvo, int displayedAmount, String otherUsers, String payer, String label, int actualAmount) {
    this._id = id;
    this._timestamp = timestamp;
    this._balanceEvo = balanceEvo;
    this._displayedAmount = displayedAmount;
    this._actualAmount = actualAmount;
    this._selectedUsers = otherUsers;
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

  int getActualAmount() {
    return _actualAmount;
  }

  String getUsers() {
    return (_selectedUsers);
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