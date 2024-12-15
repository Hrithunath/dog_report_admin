import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'details_page.dart';
import 'report_details.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final PageController pageController = PageController();
  final SideMenuController sideMenuController = SideMenuController();
  String? title;
  String? message;
  @override
  void dispose() {
    sideMenuController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the layout adapts well to larger screens
    return Scaffold(
      body: Row(
        children: [
          // Sidebar with fixed width
          Container(
            width: 250, // Fixed width for sidebar

            child: SideMenu(
              controller: sideMenuController,
              style: SideMenuStyle(
                displayMode: SideMenuDisplayMode.open,
                hoverColor: Colors.blue[100],
                selectedColor: Colors.blue,
                selectedTitleTextStyle: const TextStyle(color: Colors.white),
                selectedIconColor: Colors.white,
                unselectedTitleTextStyle: const TextStyle(color: Colors.black),
                unselectedIconColor: Colors.black,
              ),
              title: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              items: [
                SideMenuItem(
                  title: 'Report User Details',
                  icon: const Icon(Icons.report),
                  onTap: (index, _) {
                    sideMenuController.changePage(0);
                    pageController.jumpToPage(0);
                  },
                ),
                SideMenuItem(
                  title: 'Notifications Page',
                  icon: const Icon(Icons.notifications),
                  onTap: (index, _) {
                    sideMenuController.changePage(1);
                    pageController.jumpToPage(1);
                  },
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                sideMenuController.changePage(index);
              },
              children: [
                ReportUserDetails(),
                NotificationBanner(
                    title: title ?? 'No Notifications',
                    message: message ?? 'You have no new notifications.')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
