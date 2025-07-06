import 'package:flutter/material.dart';

class NavigatorBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  NavigatorBar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Color(0xFF3B82F6),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Reservations'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'My Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profile'),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
