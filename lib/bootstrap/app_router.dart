import 'package:flutter/material.dart';
import '../presentation/auth/login/login_page.dart';
import '../presentation/home/main_scaffold.dart';
import '../presentation/auth/signup/signup_flow.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupFlow());
      case home:
        return MaterialPageRoute(builder: (_) => const MainScaffold());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
