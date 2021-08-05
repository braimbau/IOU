import 'dart:ui';

class Group {
  String  _id;
  String  _name;

  Group(String id, String name) {
    this._name = name;
    this._id = id;
  }

  String getId() {
    return (_id);
  }

  String getName() {
    return (_name);
  }

  void setId(String id) {
    _id = id;
  }

  void setName(String name) {
    _name = name;
  }

  @override
  bool operator==(other) => other._id == _id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return '$_id';
  }
}