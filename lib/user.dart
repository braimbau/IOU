class User {
  String  _id;
  String  _name;
  String  _url;

  User(String id, String name, String url) {
    this._name = name;
    this._url = url;
    this._id = id;
  }

  String getId() {
    return (_id);
  }

  String getName() {
    return (_name);
  }

  String getUrl() {
    return (_url);
  }

  void setId(String id) {
    _id = id;
  }

  void setName(String name) {
    _name = name;
  }
  void setUrl(String url) {
    _url = url;
  }

  @override
  bool operator==(other) => other._id == _id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return '$_name';
  }
}