import 'package:erpnext_logistics_mobile/home.dart';
import 'package:erpnext_logistics_mobile/modules/profile.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int index = 0;
  // _BottomNavigationState();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          backgroundColor: Colors.white,
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          backgroundColor: Colors.white,
          label: "Profile",
        )
      ],
      onTap: (currentIndex) {
        setState(() {
          index = currentIndex;
          print(currentIndex);
        });
        if (currentIndex == 0) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const EFF()));
        } else if (currentIndex == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Profile()));
        }
      },
    );
  }
}
