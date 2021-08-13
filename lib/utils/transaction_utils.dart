import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/classes/user.dart';

Future<bool> checkUsersInGroupT(Transaction tr, List<IOUser> list, String group) async {
  if (!await groupExistT(tr, group))
    return false;
  for (IOUser usr in list) {
    if (!await userIsInGroupT(tr, group, usr.getId()))
      return false;
  }
  return true;
}

Future<bool> groupExistT(Transaction tr, String id) async {
  final DocumentReference ref = FirebaseFirestore.instance.collection("groups").doc(id);
  var doc = await tr.get(ref);
  return doc.exists;
}
Future<bool> userIsInGroupT(Transaction tr, String group, String usrId) async {
  final DocumentReference ref = FirebaseFirestore.instance
      .collection('groups')
      .doc(group)
      .collection("users")
      .doc(usrId);
  var doc = await tr.get(ref);
  return doc.exists;
}

Future<void> changeBalanceT(Transaction tr, String id, int amount, String group) async {
  DocumentReference ref = FirebaseFirestore.instance
      .collection('groups')
      .doc(group)
      .collection("users")
      .doc(id);
  tr.update(ref, {"balance": FieldValue.increment(amount)});
}