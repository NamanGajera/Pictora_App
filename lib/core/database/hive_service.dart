import 'package:hive_flutter/hive_flutter.dart';

import '../../data/hiveModel/post_hive_model.dart';
import '../../data/hiveModel/user_hive_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PostHiveModelAdapter());
    Hive.registerAdapter(MediaHiveModelAdapter());
    Hive.registerAdapter(UserHiveModelAdapter());
    Hive.registerAdapter(ProfileHiveModelAdapter());
  }

  static Future<Box<T>> openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return await Hive.openBox<T>(name);
  }

  static Future<void> clearBox<T>(String name) async {
    final box = await openBox<T>(name);
    await box.clear();
  }

  static Future<void> closeBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<T>(name).close();
    }
  }
}
