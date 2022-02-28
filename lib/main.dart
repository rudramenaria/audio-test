import 'dart:developer';

import 'package:audio_test/load_audio_data.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Audio Testing',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Duration maxDuration = const Duration(milliseconds: 1000);
  late Duration elapsedDuration;
  late AudioCache audioPlayer;
  late List<double> samples;
  late int totalSamples;

  late List<String> audioData;

  List<List<String>> audioDataList = [
    [
      'assets/dm.json',
      'dance_monkey.mp3',
    ],
    [
      'assets/soy.json',
      'shape_of_you.mp3',
    ],
    [
      'assets/sp.json',
      'surface_pressure.mp3',
    ],
  ];

  Future<void> parseData() async {
    final json = await rootBundle.loadString(audioData[0]);
    Map<String, dynamic> audioDataMap = {
      "json": json,
      "totalSamples": totalSamples,
    };
    final samplesData = await compute(loadparseJson, audioDataMap);
    await audioPlayer.load(audioData[1]);
    await audioPlayer.play(audioData[1]);

    await Future.delayed(const Duration(milliseconds: 200));
    int maxDurationInmilliseconds =
        await audioPlayer.fixedPlayer!.getDuration();

    maxDuration = Duration(milliseconds: maxDurationInmilliseconds);

    setState(() {
      samples = samplesData["samples"];
    });
  }

  final ScrollController _scrollController = ScrollController();
  bool playing = true;
  @override
  void initState() {
    super.initState();
    totalSamples = 250;
    audioData = audioDataList[0];
    audioPlayer = AudioCache(
      fixedPlayer: AudioPlayer(),
    );

    samples = [];
    elapsedDuration = const Duration();

    parseData();
    audioPlayer.fixedPlayer!.onPlayerCompletion.listen((_) {
      setState(() {
        elapsedDuration = maxDuration;
        playing = !playing;
      });
    });
    audioPlayer.fixedPlayer!.onAudioPositionChanged
        .listen((Duration timeElapsed) {
      elapsedDuration = timeElapsed;
      if (elapsedDuration.inSeconds >= 22) {
        _scrollController.animateTo(
          double.parse(((elapsedDuration.inSeconds - 22) * 08).toString()),
          duration: const Duration(milliseconds: 400),
          curve: Curves.linear,
        );
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 30,
      width: 30,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 100,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    flex: 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: 14.0),
                      child: Text(
                        'Random music here',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 00.0,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 0,
                            child: InkWell(
                              onTap: () {
                                if (playing) {
                                  playing = !playing;
                                  audioPlayer.fixedPlayer!.pause();
                                } else {
                                  if (elapsedDuration == maxDuration) {
                                    _scrollController.jumpTo(_scrollController
                                        .positions.first.minScrollExtent);
                                    audioPlayer.fixedPlayer!
                                        .seek(const Duration(seconds: 0));
                                  }
                                  playing = !playing;
                                  audioPlayer.fixedPlayer!.resume();
                                }
                                setState(() {});
                              },
                              child: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                IgnorePointer(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: RectangleWaveform(
                                      maxDuration: maxDuration,
                                      inactiveColor: Colors.white,
                                      activeColor: Colors.white,
                                      activeBorderColor:
                                          Colors.deepPurpleAccent,
                                      elapsedDuration: elapsedDuration,
                                      samples: samples,
                                      height: 40,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                ),
                                IgnorePointer(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: RectangleWaveform(
                                      maxDuration: maxDuration,
                                      inactiveColor: Colors.white,
                                      activeColor: Colors.white,
                                      activeBorderColor:
                                          Colors.deepPurpleAccent,
                                      elapsedDuration: elapsedDuration,
                                      samples: samples,
                                      height: 40,
                                      invert: true,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            elapsedDuration.inMinutes
                                    .toString()
                                    .padLeft(2, '0') +
                                ':' +
                                elapsedDuration.inSeconds
                                    .toString()
                                    .padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _scrollController.jumpTo(
                        _scrollController.positions.first.minScrollExtent);
                    audioPlayer.fixedPlayer!.seek(
                      const Duration(milliseconds: 0),
                    );
                    audioPlayer.fixedPlayer!.resume();
                    if (!playing) {
                      playing = !playing;
                    }
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.black,
                  ),
                ),
                child: const Icon(Icons.replay_outlined),
              ),
            ],
          )
        ],
      ),
    );
  }
}
