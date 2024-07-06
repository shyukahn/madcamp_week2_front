import 'package:flutter/material.dart';
import 'package:serverapp/pages/my_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.title});

  final String title;

  @override
  State createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  static const List<Widget> _mainPages = <Widget>[
    Text(
      'Page 1',
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
    ),
    Text(
      'Page 2',
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
    ),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _mainPages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
          ),BottomNavigationBarItem(
            icon: Icon(Icons.add_to_photos_rounded),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'My Page',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}