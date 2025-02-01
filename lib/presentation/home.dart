import 'dart:async';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../domain/boss.dart';
import '../domain/bosses_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const Duration _updateInterval = Duration(seconds: 1);

  double width = 1812;
  double height = 2620;

  int minLevel = 1;
  int maxLevel = 100;

  BossesService bossesService = BossesService();
  List<Boss> bosses = [];
  Boss selectedBoss = Boss.empty();

  double scale = 1.0;
  double positionX = 0.0;
  double positionY = 0.0;

  double get _fixX => (positionX) + (width / 2) - 252;
  double get _fixY => (positionY) + (height / 2) - 10;
  double get _indicatorSize => 20 * scale;

  OverlayPortalController portalController = OverlayPortalController();

  void init() async {
    await bossesService.fetchBosses();

    // Updater
    Timer.periodic(
      _updateInterval,
      (timer) {
        getBosses();
      },
    );
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx == 0 && details.delta.dy == 0) return;

    double newX = positionX + details.delta.dx;
    double newY = positionY + details.delta.dy;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (newX < -(width - screenWidth)) newX = -(width - screenWidth);
    if (newX > 0) newX = 0;

    if (newY < -(height - screenHeight)) newY = -(height - screenHeight);
    if (newY > 0) newY = 0;

    setState(() {
      positionX = newX;
      positionY = newY;
    });
  }

  void onScaleUpdate(PointerScrollEvent details) {
    return;

    if (details.scrollDelta.dy > 0) {
      setState(() {
        scale -= 0.2;
      });
    } else {
      setState(() {
        scale += 0.2;
      });
    }
  }

  void onBossTap(Boss boss) {
    portalController.show();

    setState(() {
      selectedBoss = bossesService.getBoss(boss.id);
    });
  }

  void setMinLevel(int level) {
    minLevel = level;

    getBosses();
  }

  void setMaxLevel(int level) {
    maxLevel = level;

    getBosses();
  }

  void getBosses() {
    setState(() {
      bosses = bossesService.filter(
        minLevel: minLevel,
        maxLevel: maxLevel,
      );
    });
  }

  void onKillPressed() {
    bossesService.onKill(selectedBoss);

    selectedBoss = bossesService.getBoss(selectedBoss.id);
    getBosses();
  }

  void onResetPressed() {
    bossesService.onReset(selectedBoss);

    selectedBoss = bossesService.getBoss(selectedBoss.id);
    getBosses();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.black54,
            onPressed: null,
            child: TextField(
              textAlign: TextAlign.center,
              cursorColor: Colors.white70,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                if (value.isEmpty) return;

                setMinLevel(int.tryParse(value) ?? 1);
              },
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.black54,
            onPressed: null,
            child: TextField(
              textAlign: TextAlign.center,
              cursorColor: Colors.white70,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                if (value.isEmpty) return;

                setMaxLevel(int.tryParse(value) ?? 100);
              },
            ),
          ),
        ],
      ),
      body: OverlayPortal.targetsRootOverlay(
        controller: portalController,
        overlayChildBuilder: (BuildContext context) {
          return Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black38,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: selectedBoss.name.toString()),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.black38,
                          content: Text('Copied ${selectedBoss.name} to clipboard'),
                        ),
                      );
                    },
                    child: Text(
                      selectedBoss.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    'Level: ${selectedBoss.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (selectedBoss.isDead || selectedBoss.isRespawning) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Killed: ${DateFormat('HH:mm').format(selectedBoss.respawn.deadAt)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Resp: ${DateFormat('HH:mm').format(selectedBoss.respawn.startTime)} - ${DateFormat('HH:mm').format(selectedBoss.respawn.endTime)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: selectedBoss.isDead ? null : onKillPressed,
                        child: const SizedBox(
                          width: 40,
                          child: Text(
                            'Kill',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // child: const Text('Kill'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue),
                        ),
                        onPressed: selectedBoss.isDead ? onResetPressed : null,
                        child: const SizedBox(
                          width: 40,
                          child: Text(
                            'Reset',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) onScaleUpdate(pointerSignal);
          },
          child: GestureDetector(
            onPanUpdate: (details) => onPanUpdate(details),
            child: Stack(
              children: [
                Positioned(
                  left: positionX,
                  top: positionY,
                  child: SizedBox(
                    width: width * scale,
                    height: height * scale,
                    child: Image.asset('assets/aden.jpg'),
                  ),
                ),
                ...bosses.take(bosses.length).map<Widget>(
                  (boss) {
                    final bool isSelected = selectedBoss.id == boss.id;

                    // print(bossSpawn.pos.first.toString());

                    return Positioned(
                      left: boss.pos.x + _fixX - _indicatorSize / 2,
                      top: boss.pos.y + _fixY - _indicatorSize / 2,
                      child: GestureDetector(
                        onTap: () {
                          onBossTap(boss);
                        },
                        child: Container(
                          width: _indicatorSize,
                          height: _indicatorSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.white70 : Colors.white70,
                              width: isSelected ? 3 : 1,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                            shape: BoxShape.circle,
                            color: boss.isDead
                                ? Colors.red
                                : boss.isRespawning
                                    ? Colors.indigoAccent
                                    : Colors.green,
                          ),
                          child: Text(
                            boss.level.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10 * scale,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
