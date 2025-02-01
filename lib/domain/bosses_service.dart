import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/boss_mapper.dart';
import '../data/boss_model.dart';
import 'boss.dart';

class BossesService {
  static const bossesPath = 'assets/interlude_bosses_json.json';
  Duration _bossRespawnDuration = const Duration(hours: 2);
  Duration _bossRespawnTime = const Duration(hours: 1);

  set setRespawnDuration(Duration duration) {
    _bossRespawnDuration = duration;
  }

  set setRespawnTime(Duration duration) {
    _bossRespawnTime = duration;
  }

  SharedPreferences? _prefs;

  SharedPreferences get _storage {
    if (_prefs == null) {
      throw Exception('Storage not initialized');
    }

    return _prefs!;
  }

  List<Boss> _bosses = [];

  List<Boss> get bosses => _bosses;

  Future<void> fetchBosses({bool resetFromApi = false}) async {
    _prefs = await SharedPreferences.getInstance();

    if (!resetFromApi) {
      final List<Boss> localBosses = _getLocal();

      if (localBosses.isNotEmpty) {
        log('Bosses from local: ${localBosses.length}');

        _bosses = localBosses;
        return;
      }
    }

    final bossesContent = await rootBundle.loadString(bossesPath);
    final bossesRaw = jsonDecode(bossesContent) as Map<String, dynamic>;

    List<BossModel> bossesData =
        (bossesRaw['bosses'] as List<dynamic>).map((boss) => BossModel.fromJson(boss)).toList();

    List<Boss> bosses = [];

    for (final BossModel model in bossesData) {
      final Boss? boss = BossMapper.fromModel(model);

      if (boss != null) {
        bosses.add(boss);
      }
    }

    log('Bosses from api: ${bosses.length}');

    _bosses
      ..clear()
      ..addAll(bosses);

    _saveLocal();
  }

  List<Boss> filter({
    int minLevel = 0,
    int maxLevel = 100,
  }) {
    return bosses
        .where(
          (boss) => boss.level >= minLevel && boss.level <= maxLevel,
        )
        .toList();
  }

  Boss getBoss(int id) => bosses.firstWhere((boss) => boss.id == id);

  void onKill(Boss killedBoss) {
    _bosses = _bosses.map((boss) {
      if (killedBoss.id == boss.id) {
        return boss.copyWith(
          respawn: Respawn(
            deadAt: DateTime.now(),
            startTime: DateTime.now().add(_bossRespawnDuration),
            endTime: DateTime.now().add(_bossRespawnDuration + _bossRespawnTime),
          ),
        );
      }

      return boss;
    }).toList();

    _saveLocal();
  }

  void onReset(Boss killedBoss) {
    _bosses = _bosses.map((boss) {
      if (killedBoss.id == boss.id) {
        return boss.copyWith(
          respawn: Respawn(
            deadAt: DateTime.now(),
            startTime: DateTime.now(),
            endTime: DateTime.now(),
          ),
        );
      }

      return boss;
    }).toList();

    _saveLocal();
  }

  void _saveLocal() {
    List<Map<String, dynamic>> bossesData = bosses.map((boss) => boss.toJson()).toList();

    _storage.setStringList('bosses', bossesData.map((boss) => jsonEncode(boss)).toList());
  }

  List<Boss> _getLocal() {
    List<String>? bossesData = _storage.getStringList('bosses');

    if (bossesData == null) {
      return [];
    }

    return bossesData.map((boss) => Boss.fromJson(jsonDecode(boss))).toList();
  }
}
