import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chinder/chuck_joker.dart';

class ChuckNorrisApp extends StatelessWidget {
  const ChuckNorrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    // disable horizontal orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return CardDeckWithButton();
  }
}

class ChuckBar extends AppBar {
  ChuckBar({super.key})
      : super(
          title: const Padding(
            padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "Chinder",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 100,
                ),
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.orange,
          toolbarHeight: 85,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(50, 20),
            ),
          ),
        );
}

class CardSurface extends StatefulWidget {
  final Color color;
  final String jokeText;
  final String imagePath;

  const CardSurface(
      {super.key,
      required this.color,
      required this.jokeText,
      required this.imagePath});

  static CardSurface empryCard() {
    return const CardSurface(
      color: Colors.black,
      jokeText: "No jokes for today, mr. Chuck",
      imagePath: "images/0.png",
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _CardSurfaceState();
  }
}

class _CardSurfaceState extends State<CardSurface> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double height = screenHeight * 0.55;
    double width = min(screenWidth * 0.8, height * 1.4);

    double verticalMargin = (screenWidth - width) / 2;
    double horizontalMargin = screenHeight * 0.07;

    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(40),
      ),
      height: height,
      width: width,
      margin: EdgeInsets.fromLTRB(
          verticalMargin, horizontalMargin, verticalMargin, horizontalMargin),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image(
            image: AssetImage(widget.imagePath),
            height: height / 2,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
          ),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontStyle: FontStyle.normal,
              ),
              child: Text(
                widget.jokeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardDeck extends StatefulWidget {
  final JokeManager jokeManager;
  final CardDeckState deckState;

  CardDeck({super.key})
      : jokeManager = JokeManager(),
        deckState = CardDeckState();

  @override
  State<StatefulWidget> createState() {
    // here `no_logic_in_create_state` is warning
    // but I ignored it to be able to access state from outer classes
    return deckState;
  }
}

class CardDeckState extends State<CardDeck> {
  CardSurface currentCard = CardSurface.empryCard(),
      nextCard = CardSurface.empryCard();

  @override
  void initState() {
    widget.jokeManager.init().then((_) {
      setState(() {
        _actualizeCards();
      });
    }).ignore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      childWhenDragging: nextCard,
      feedback: currentCard,
      child: currentCard,
    );
  }

  void _actualizeCards() {
    currentCard = CardSurface(
      color: widget.jokeManager.currentCol,
      jokeText: widget.jokeManager.currentJoke,
      imagePath: widget.jokeManager.currentImage,
    );
    nextCard = CardSurface(
      color: widget.jokeManager.nextCol,
      jokeText: widget.jokeManager.nextJoke,
      imagePath: widget.jokeManager.nextImage,
    );
  }

  void moveToNext() {
    widget.jokeManager.moveNextToTop();
    setState(() {
      _actualizeCards();
    });

    // use 2 setState calls to make swaps faster
    widget.jokeManager.loadNextJoke().then((_) {
      setState(() {
        _actualizeCards();
      });
    });
  }
}

class CardDeckWithButton extends StatelessWidget {
  final CardDeck deck;

  CardDeckWithButton({super.key}) : deck = CardDeck();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Row(
              children: [
                DragableTrigger(
                  trigger: deck.deckState.moveToNext,
                  rmarginRatio: 5 / 7,
                ),
                DragableTrigger(
                  trigger: deck.deckState.moveToNext,
                  rmarginRatio: 0,
                ),
              ],
            ),
            deck,
          ],
        ),
        SizedBox(
          height: 60,
          width: 150,
          child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 133, 121, 227),
              ),
              onPressed: () {
                deck.deckState.moveToNext();
              },
              child: const Text(
                "NEXT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              )),
        ),
      ],
    );
  }
}

class DragableTrigger extends StatelessWidget {
  final Function trigger;
  final double rmarginRatio;

  const DragableTrigger(
      {super.key, required this.trigger, required this.rmarginRatio});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        // color: Colors.red,
        width: screenWidth / 7,
        height: screenHeight / 1.5,
        margin: EdgeInsets.fromLTRB(0, 0, screenWidth * rmarginRatio, 0),
        child: Expanded(
          child: DragTarget(
            onWillAccept: (_) => false,
            onLeave: (_) => trigger(),
            builder: (BuildContext context, List<Object?> candidateData,
                List<dynamic> rejectedData) {
              return SizedBox(
                width: screenWidth / 7,
                height: screenHeight / 1.5,
              );
            },
          ),
        ));
  }
}
