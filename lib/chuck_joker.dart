import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'chuck_joker.g.dart';

@JsonSerializable()
class Joke {
  final String id, value;

  Joke({required this.id, required this.value});

  factory Joke.fromJSON(Map<String, dynamic> json) => _$JokeFromJson(json);
}

class ChuckJoker {
  static const String apiDomain = "api.chucknorris.io";
  static const String apiPath = "jokes/random";
  static const queryParams = {
    "category": "dev",
  };

  static Future<Joke> randJoke() async {
    String jokeJson =
        await http.read(Uri.https(apiDomain, apiPath, queryParams));
    return Joke.fromJSON(jsonDecode(jokeJson));
  }
}

class JokeManager {
  String currentJoke = "(null)";
  String nextJoke = "(null)";
  bool _initialized = false;

  static const preloadBuffer = 5;
  final List<String> _preloadJokes = [];

  static const List<Color> availableColors = [
    Colors.greenAccent,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
  ];

  static const List<String> availableImages = [
    "images/0.png",
    "images/1.png",
    "images/2.png",
    "images/3.png",
    "images/4.png",
    "images/5.png",
    "images/6.png",
  ];

  final Random _random;

  Color currentCol = Colors.black;
  Color nextCol = Colors.black;

  String currentImage = availableImages[0];
  String nextImage = availableImages[1];

  JokeManager() : _random = Random();

  Future<String> _nextJoke() async {
    if (_preloadJokes.isEmpty) {
      for (int i = 0; i < preloadBuffer; ++i) {
        _preloadJokes.add((await ChuckJoker.randJoke()).value);
      }
    }

    return _preloadJokes.removeAt(0);
  }

  Future<void> init() async {
    if (_initialized) {
      throw Exception("JokeManager already initialized");
    }

    currentJoke = await _nextJoke();
    nextJoke = await _nextJoke();

    currentCol = availableColors[_random.nextInt(availableColors.length)];
    nextCol = availableColors[_random.nextInt(availableColors.length)];

    currentImage = availableImages[_random.nextInt(availableImages.length)];
    nextImage = availableImages[_random.nextInt(availableImages.length)];

    _initialized = true;
  }

  Future<void> loadNextJoke() async {
    currentJoke = nextJoke;
    nextJoke = await _nextJoke();

    currentCol = nextCol;
    nextCol = availableColors[_random.nextInt(availableColors.length)];

    currentImage = nextImage;
    nextImage = availableImages[_random.nextInt(availableImages.length)];
  }

  // add this separate call for optimization
  void moveNextToTop() {
    currentJoke = nextJoke;
    currentCol = nextCol;
    currentImage = nextImage;
  }
}
