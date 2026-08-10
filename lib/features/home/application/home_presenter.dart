import 'package:mindly/core/app_info.dart';

abstract final class HomePresenter {
  static const String brand = AppInfo.name;
  static const String greeting = 'Good to see you.';
  static const String prompt = 'What would you like me to remember?';
}
