import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return ListView.builder(
  //     itemBuilder: (_, index) {
  //       if (index > 10) return null;
  //       return Text('Index $index');
  //     },
  //   );
  // }

  @override
  State<StatefulWidget> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List jokes = [];

  void parseJokes() {
    SharedPreferences.getInstance().then((pref) {
      String? curJokes = pref.getString('jokes');
      curJokes ??= '';
      jokes = curJokes.split('\n:::');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    parseJokes();
    return ListView.builder(
      itemBuilder: (_, index) {
        index += 1;
        if (index >= jokes.length) return null;
        return Container(
          height: 100,
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 67, 206, 97),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            jokes[index],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        );
      },
    );
  }
}
