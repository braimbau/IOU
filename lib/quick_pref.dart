class QuickPref {
  String _name;
  String _users;
  int _amount;
  String _emoji;

  QuickPref(String name, String users, int amount, String emoji) {
    this._name = name;
    this._users = users;
    this._amount = amount;
    this._emoji = emoji;
  }

  String getName() {
    return (_name);
  }

  String getUsers() {
    return (_users);
  }

  int getAmount() {
    return (_amount);
  }

  String getEmoji() {
    return (_emoji);
  }
}