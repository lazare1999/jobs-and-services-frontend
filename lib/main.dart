import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jobs_and_services/app/preview/base_page.dart';
import 'app/craftsman/craftsman_main_page.dart';
import 'app/main_menu.dart';
import 'app/search_craftsman/search_craftsman_main_page.dart';
import 'my_route_observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(
      const RestartWidget(
          child: MyApp()
      )
  );
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({Key? key, this.child}) : super(key: key);

  final Widget? child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {

  _MyAppState();

  Locale _locale = const Locale.fromSubtags(languageCode: 'ka');

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.title,
      title: 'დასაქმება',
      navigatorObservers: <NavigatorObserver>[
        MyRouteObserver(), // this will listen all changes
      ],
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // ინგლისური
        Locale('ka', ''), // ქართული
        Locale('ru', ''), // რუსული
      ],
      locale: _locale,
      routes: {
        '/': (context) {
          return const BasePage();
        },
        '/main_menu': (context) {
          return const MainMenu();
        },
        '/craftsman': (context) {
          return const CraftsmanMainPage();
        },
        '/search_craftsman': (context) {
          return const SearchCraftsmanMainPage();
        }
      },
    );
  }
}
