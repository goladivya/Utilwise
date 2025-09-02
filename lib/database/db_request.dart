import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Models/community.dart';
import '../Models/objects.dart';
import '../Models/requests.dart';
import './db_user.dart';
import 'db_objects.dart';

class RequestDataBaseService {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> createCommunity(CommunityModel community) async {
    try {
      final sp1 = await _db
          .collection('communities')
          .where("Name", isEqualTo: community.name)
          .where("Phone Number", isEqualTo: community.phoneNo)
          .get();

      if (sp1.docs.isNotEmpty) {
        return false;
      }

      await _db.collection('communities').add(community.toJson());

      addUserInCommunity(community, community.phoneNo, true);
      // create misc object
      String? communityID = await getCommunityID(community);
      ObjectsModel object = ObjectsModel(
          name: "Misc",
          communityID: communityID,
          creatorPhoneNo: community.phoneNo,
          type: "",
          description: "");
      ObjectDataBaseService.createObjects(object);
      return true;
    } catch (e) {
      return false;
    }

  }

  static Future<String?> getCommunityID(CommunityModel community) async {
    try {
      final sp = await _db
          .collection('communities')
          .where("Name", isEqualTo: community.name)
          .where("Phone Number", isEqualTo: community.phoneNo)
          .get();

      if (sp.docs.isNotEmpty) {
        return sp.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> addUserInCommunity(
      CommunityModel community, String memberPhoneNo, bool admin) async {
    try {
      String? communityID = await getCommunityID(community);
      String? userID = await UserDataBaseService.getUserID(memberPhoneNo);

      if (communityID == null) {
        return false;
      }

      if (userID == null) {
        return false;
      }

      final sp = await _db
          .collection('communityMembers')
          .where("CommunityID", isEqualTo: communityID)
          .where("UserID", isEqualTo: userID)
          .get();

      if (sp.docs.isNotEmpty) {
        return false;
      }

      await _db.collection('communityMembers').add(
          {'CommunityID': communityID, 'UserID': userID, 'Is Admin': admin});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeUserFromCommunity(
      CommunityModel community, String memberPhoneNo) async {
    try {
      String? communityID = await getCommunityID(community);
      String? userID = await UserDataBaseService.getUserID(memberPhoneNo);

      if (communityID == null) {
        return false;
      }

      if (userID == null) {
        return false;
      }

      final sp = await _db
          .collection('communityMembers')
          .where("CommunityID", isEqualTo: communityID)
          .where("UserID", isEqualTo: userID)
          .get();

      if (sp.docs.isEmpty) {
        return false;
      }

      await _db.collection('communityMembers').doc(sp.docs.first.id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleCreatorPower(
      CommunityModel communityName, String memberPhoneNo) async {
    try {
      String? communityID = await getCommunityID(communityName);
      String? userID = await UserDataBaseService.getUserID(memberPhoneNo);

      if (communityID == null) {
        return false;
      }

      if (userID == null) {
        return false;
      }

      final sp = await _db
          .collection('communityMembers')
          .where("CommunityID", isEqualTo: communityID)
          .where("UserID", isEqualTo: userID)
          .get();

      if (sp.docs.isEmpty) {
        return false;
      }

      await _db
          .collection('communityMembers')
          .doc(sp.docs.first.id)
          .update({'Is Admin': !sp.docs.first.data()['Is Admin']});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getCommunityName(String? communityID) async {
    try {
      final sp = await _db.collection('communities').doc(communityID).get();
      if (sp.data() == null) {
        return "";
      }
      return sp.data()!['Name'];
    } catch (e) {
      return "";
    }
  }

  static Future<bool> communityAddRemoveNotification(
      CommunityModel community, String phoneNo, bool isAdd) async {
    String token = await UserDataBaseService.getUserToken(phoneNo);

    if (token == "") {
      return false;
    }

    String msgTitle = isAdd ? "New Community Added" : "Community Removed";
    String msgBody = isAdd
        ? "You have been added to ${community.name}"
        : "You have been removed from ${community.name}";

    var data = {
      'to': token.toString(),
      'priority': 'high',
      'notification': {
        'title': msgTitle,
        'body': msgBody,
      }
    };

    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
          'key=AAAAsXT8mZo:APA91bEjQMOMbx42wNSYYqsQsFQcQX3QEWrjeSVE0kKtvkxtoJrhhvJvqb2yCjPRHFlQQ05YZRkjgYkHJvNtO0O4n5b8w35-XMNQHda0Y_D7XPoF5oZWRN7U6HhmsymK7hEzK2qrms74'
        });

    return true;
  }

  static Future<bool> addCommunityLogNotification(
      CommunityModel community, String message) async {
    try {
      String date = DateFormat("dd, MMMM, yyyy").format(DateTime.now());
      String? communityId = await getCommunityID(community);
      final sp = await _db
          .collection('logsNotification')
          .where("CommunityID", isEqualTo: communityId)
          .get();

      if (sp.docs.isNotEmpty) {
        await _db.collection('logsNotification').doc(sp.docs.first.id).update({
          'Notification': FieldValue.arrayUnion([message + " ^" + date])
        });
      } else {
        await _db.collection('logsNotification').add({
          'CommunityID': communityId,
          'Notification': [message + " ^" + date]
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> getCommunityNotification(
      CommunityModel community) async {
    List<String> notifications = [];
    try {
      String? communityID = await getCommunityID(community);
      final sp = await _db
          .collection('logsNotification')
          .where("CommunityID", isEqualTo: communityID)
          .get();

      for (var community in sp.docs) {
        for (var notification in community.data()['Notification']) {
          notifications.add(notification);
        }
      }
      return notifications;
    } catch (e) {
      return notifications;
    }
  }

  static Future<bool> deleteCommunity(CommunityModel community) async {
    try {
      String? communityID = await getCommunityID(community);
      await _db.collection('communities').doc(communityID).delete();

      await _db
          .collection("communityMembers")
          .where("CommunityID", isEqualTo: communityID)
          .get()
          .then((value) {
        for (DocumentSnapshot ds in value.docs) {
          ds.reference.delete();
        }
      });

      List<String> objectsid = [];

      await _db
          .collection("objects")
          .where("CommunityID", isEqualTo: communityID)
          .get()
          .then((value) {
        for (DocumentSnapshot ds in value.docs) {
          objectsid.add(ds.id);
          ds.reference.delete();
        }
      });

      for (var id in objectsid) {
        await _db
            .collection("expenses")
            .where("ObjectID", isEqualTo: id)
            .get()
            .then((value) {
          for (DocumentSnapshot ds in value.docs) {
            ds.reference.delete();
          }
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCommunity(String communityName,
      String creatorPhoneNumber, String newCommunityName) async {
    if (communityName == newCommunityName) {
      return false;
    }

    final communitySnapshot = await _db
        .collection('communities')
        .where("Name", isEqualTo: communityName)
        .where("Phone Number", isEqualTo: creatorPhoneNumber)
        .get();

    if (communitySnapshot.docs.isNotEmpty) {
      final communityDoc = communitySnapshot.docs.first;
      await communityDoc.reference.update({'Name': newCommunityName});
      return true;
    }
    return false;
  }
}
