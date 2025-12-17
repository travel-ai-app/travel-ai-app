import 'package:flutter/material.dart'; // UI //

import 'presentation/theme/app_theme.dart'; // theme //
import 'core/navigation/app_router.dart'; // router //

Future<void> main() async { // main //
  WidgetsFlutterBinding.ensureInitialized(); // init //
  runApp(const MyApp()); // run //
} // end //

class MyApp extends StatelessWidget { // app //
  const MyApp({super.key}); // ctor //

  @override
  Widget build(BuildContext context) { // build //
    return MaterialApp( // app //
      debugShowCheckedModeBanner: false, // hide //
      title: 'Travel AI App', // title //
      theme: AppTheme.light, // light //
      darkTheme: AppTheme.dark, // dark //
      themeMode: ThemeMode.light, // mode //
      onGenerateRoute: AppRouter.onGenerateRoute, // routes //
      initialRoute: '/', // start //
    ); // end //
  } // end //
} // end class //
