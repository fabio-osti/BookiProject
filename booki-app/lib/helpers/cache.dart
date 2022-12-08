import 'package:bookiapp/helpers/nulls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static late final SharedPreferences _cache;
  static SharedPreferences get get => _cache;

  static Future? _job;
  static Future get job => throwIfNull(_job, "Cache unitialized");

  static Future init() => _job ??= _init();
  static Future _init() async {
    _cache = await SharedPreferences.getInstance();
  }
}