import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_notification_platform/flutter_web_notification_platform.dart';

class AdminService extends ChangeNotifier {
  // final FlutterLocalNotificationsPlugin notificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  // Fetch all users along with their stray dog reports
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('userss').get();

      List<Map<String, dynamic>> usersList = [];

      for (var doc in usersSnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

          QuerySnapshot reportsSnapshot =
              await doc.reference.collection('stray_dog_reports').get();

          List<Map<String, dynamic>> reportsList = [];
          for (var reportDoc in reportsSnapshot.docs) {
            reportsList.add({
              ...reportDoc.data() as Map<String, dynamic>,
              'reportId': reportDoc.id, // Include report ID
            });
          }

          userData['stray_dog_reports'] = reportsList;
          userData['uid'] = doc.id; // Include user ID
          usersList.add(userData);
        }
      }

      return usersList;
    } catch (e) {
      print("Error fetching users and reports: $e");
      return [];
    }
  }

  // Update the status of a report
  Future<void> updateReportStatus(
      String userId, String reportId, String newStatus) async {
    try {
      DocumentReference reportRef = FirebaseFirestore.instance
          .collection('userss')
          .doc(userId)
          .collection('stray_dog_reports')
          .doc(reportId);

      await reportRef.update({'status': newStatus});
      print("Report status updated to: $newStatus");
    } catch (e) {
      print("Error updating report status: $e");
    }
  }
}
