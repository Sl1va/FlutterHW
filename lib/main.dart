// ignore_for_file: no_logic_in_create_state

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chinder/screen/chinder.dart';
import 'package:chinder/screen/favourites.dart';

void main() => runApp(ChinderApp());

class ChinderApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChinderAppState();
}

class _ChinderAppState extends State<ChinderApp> {
  List<Widget> pages = [
    ChuckNorrisApp(),
    FavouritesScreen(),
  ];

  int index = 0;

  void choose(int selectedIndex) {
    setState(() {
      index = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: ChuckBar(),
          body: pages.elementAt(index),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_max_outlined), label: 'home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'favourites',
              ),
            ],
            currentIndex: index,
            selectedItemColor: Colors.blue,
            onTap: choose,
          ),
        ),
      ),
    );
  }
}
