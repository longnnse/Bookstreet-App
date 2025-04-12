import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapmobile/models/kios_model.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/routers/route.dart';
import 'package:mapmobile/services/preferences_manager.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesManager.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => MapModel()),
      ChangeNotifierProvider(create: (context) => KiosModel())
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1080, 1920),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(
                scaffoldBackgroundColor:
                    const Color.fromARGB(255, 243, 243, 243),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color.fromARGB(255, 243, 243, 243),
                ),
                fontFamily: 'Roboto'),
          );
        });
  }
}
