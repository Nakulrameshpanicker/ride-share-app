import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/routes/routes.dart';
import 'package:flutter_projects/ui/authentication/login/authentication_page.dart';
import 'package:flutter_projects/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CoreBloc.dart';
import 'default_fire_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CoreBloc().initSharedData();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: AppConstants.APP_NAME,
      themeMode: ThemeMode.light,
      initialRoute: Routes.SCRAP_LIST,
      navigatorKey: AppConstants.navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.splash_screen:
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          case Routes.REGISTRATION:
            return MaterialPageRoute(
                builder: (context) => const AuthenticationPage());
          // Add the route for '/auth' here
          case Routes.DASH_BOARD:
            return MaterialPageRoute(builder: (context) => const _HomePage());
          // Other routes...
          default:
            return null;
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLoader = true;

  _getAppData() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
  }

  @override
  void initState() {
    _getAppData();
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      navigateScreens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [Color(0xFF0084c5), Color(0xFF00bde0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateScreens() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var isFirst = preferences.getBool(AppConstants.WELCOME_SCREEN);
    var userData = AppConstants.loggedUser;
    print("logged user ---> ${userData}");
    print("isFirst---> ${isFirst}");
    if (userData != null) {
      AppConstants.navigatorKey.currentState!
          .pushReplacementNamed(Routes.DASH_BOARD);
    } else {
      AppConstants.navigatorKey.currentState!
          .pushReplacementNamed(Routes.REGISTRATION);
    }
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(); // Replace with your HomePage content
  }
}
