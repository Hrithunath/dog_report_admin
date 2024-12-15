import 'package:admin_dog_rport/report_service.dart';
import 'package:flutter_web_notification_platform/flutter_web_notification_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportUserDetails extends StatefulWidget {
  @override
  _ReportUserDetailsState createState() => _ReportUserDetailsState();
}

class _ReportUserDetailsState extends State<ReportUserDetails> {
  final PlatformNotification platformNotification = PlatformNotificationWeb();

  int savedCount = 0;
  bool notificationShown = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCount();
    _listenForNewReports();
  }

  void _loadSavedCount() async {
    final prefs = await SharedPreferences.getInstance();
    savedCount = prefs.getInt('totalCount') ?? 0;
    notificationShown = prefs.getBool('notificationShown') ?? false;

    platformNotification.requestPermission();
    debugPrint("Notification permission request completed.");
  }

  // Save the current count to SharedPreferences
  void _saveCurrentCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('totalCount', value);
    prefs.setBool('notificationShown', notificationShown);
  }

  // Listen for new reports
  void _listenForNewReports() {
    FirebaseFirestore.instance
        .collection('userss')
        .snapshots()
        .listen((usersSnapshot) {
      int newCount = 0;

      for (var doc in usersSnapshot.docs) {
        doc.reference
            .collection('stray_dog_reports')
            .get()
            .then((reportsSnapshot) {
          newCount += reportsSnapshot.docs.length;
          print('=====newcount======$newCount');
          print('=====savecount======$savedCount');
          // Show notification only if the count increases and it hasn't been shown yet
          if (newCount > savedCount) {
            _showNotification(
                'Total reports have increased by ${newCount - savedCount}');
            print('Notification Showing');
            // notificationShown = true;
            _saveCurrentCount(
                newCount); // Save the updated count and notification status
          }
        });
      }
    });
  }

  // Show a notification (replace with your desired notification logic)
  void _showNotification(String message) {
    platformNotification.sendNotification(
        'New Report Added', 'Notification: $message');
  }

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();
    final userFuture = adminService.fetchAllUsers();

    final validStatuses = ["Not Captured", "Under Review", "Resolved"];

    return Scaffold(
      appBar: AppBar(title: const Text('User Reports')),
      body: Column(
        children: [
          // Your existing Card widget
          Card(
            elevation: 5,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.amber),
              child: const Center(
                child: Text(
                  'Users List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const Text('Error loading users.'),
                        ElevatedButton(
                          onPressed: () {
                            // ignore: invalid_use_of_protected_member
                            (context as Element).reassemble();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  var users = snapshot.data!;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      var reports = user['stray_dog_reports'] as List;

                      return ExpansionTile(
                        title: Text(user['name'] ?? 'No Name'),
                        subtitle: Text(user['email'] ?? 'No Email'),
                        children: reports.map<Widget>((report) {
                          String currentStatus =
                              validStatuses.contains(report['status'])
                                  ? report['status']
                                  : "Not Captured";
                          String selectedStatus = currentStatus;

                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report['description'] ??
                                            'No Description',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        report['incidentDate']
                                                ?.toDate()
                                                .toString() ??
                                            'Unknown Date',
                                      ),
                                      const SizedBox(height: 10),
                                      DropdownButtonFormField<String>(
                                        value: selectedStatus,
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              selectedStatus = value;
                                            });
                                          }
                                        },
                                        items: validStatuses.map((status) {
                                          return DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(status),
                                          );
                                        }).toList(),
                                        decoration: const InputDecoration(
                                          labelText: "Select Status",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            await adminService
                                                .updateReportStatus(
                                              user['uid'], // User ID
                                              report['reportId'], // Report ID
                                              selectedStatus,
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Status updated successfully!")),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Failed to update status.")),
                                            );
                                          }
                                        },
                                        child: const Text('Update Status'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No users found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
