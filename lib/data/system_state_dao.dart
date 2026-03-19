import 'package:sqflite/sqflite.dart';

import 'database.dart';
import '../domain/tree_state.dart';
import '../services/app_data_runtime.dart';

class SystemStateDao {
  static const String _plantedAtKey = 'tree.planted_at';
  static const String _identityNameKey = 'tree.identity_name';
  static const String _growthSeedKey = 'tree.growth_seed';
  static const String _structuralMarkersKey = 'tree.structural_markers_json';
  static const String _lastWateredAtKey = 'tree.last_watered_at';

  static Future<String?> get(String key) async {
    final Database db = await AppDatabase.instance;

    final rows = await db.query(
      'system_state',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  static Future<void> set(String key, String value) async {
    _ensureWritable();
    final Database db = await AppDatabase.instance;

    await db.insert('system_state', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<DateTime?> getDateTime(String key) async {
    final value = await get(key);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
  }

  static Future<void> setDateTime(String key, DateTime dateTime) async {
    await set(key, dateTime.millisecondsSinceEpoch.toString());
  }

  static Future<TreeState> ensureTreeState() async {
    final existing = await getTreeState();
    if (existing != null) {
      return existing;
    }

    final seed = _newGrowthSeed();
    final initial = TreeState(
      plantedAt: null,
      identityName: null,
      growthSeed: seed,
      structuralMarkers: const [],
      lastWateredAt: null,
    );
    if (AppDataRuntime.isReadOnlySync()) {
      return initial;
    }
    await saveTreeState(initial);
    return initial;
  }

  static Future<TreeState?> getTreeState() async {
    final growthSeedRaw = await get(_growthSeedKey);
    if (growthSeedRaw == null) {
      return null;
    }

    final plantedAtRaw = await get(_plantedAtKey);
    final identityName = await get(_identityNameKey);
    final structuralMarkersRaw = await get(_structuralMarkersKey);
    final lastWateredAtRaw = await get(_lastWateredAtKey);

    return TreeState(
      plantedAt: _millisStringToDateTime(plantedAtRaw),
      identityName: identityName,
      growthSeed: int.parse(growthSeedRaw),
      structuralMarkers: TreeState.decodeMarkers(structuralMarkersRaw),
      lastWateredAt: _millisStringToDateTime(lastWateredAtRaw),
    );
  }

  static Future<void> saveTreeState(TreeState state) async {
    _ensureWritable();
    await set(_growthSeedKey, state.growthSeed.toString());

    if (state.plantedAt != null) {
      await setDateTime(_plantedAtKey, state.plantedAt!);
    }

    if (state.identityName != null) {
      await set(_identityNameKey, state.identityName!);
    }

    await set(
      _structuralMarkersKey,
      TreeState.encodeMarkers(state.structuralMarkers),
    );

    if (state.lastWateredAt != null) {
      await setDateTime(_lastWateredAtKey, state.lastWateredAt!);
    }
  }

  static Future<bool> hasIdentityName() async {
    final identityName = await get(_identityNameKey);
    return identityName != null && identityName.trim().isNotEmpty;
  }

  static DateTime? _millisStringToDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(raw));
  }

  static int _newGrowthSeed() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final salt = DateTime.now().microsecondsSinceEpoch;
    return ((now ^ (salt << 7)) & 0x7fffffff);
  }

  static void _ensureWritable() {
    if (AppDataRuntime.isReadOnlySync()) {
      throw StateError('Snapshot viewer is read-only.');
    }
  }
}
