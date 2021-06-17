class QuickPref {
  String _name;
  String _users;
  int _amount;
  String _emoji;
  String _id;

  QuickPref(String name, String users, int amount, String emoji, String id) {
    this._name = name;
    this._users = users;
    this._amount = amount;
    this._emoji = emoji;
    this._id = id;
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

  String getId() {
    return (_id);
  }
}