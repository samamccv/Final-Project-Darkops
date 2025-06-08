import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darkops/blocs/auth/auth_bloc.dart';
import 'package:darkops/screens/login_options.dart';
import 'package:darkops/services/api_seevice.dart';
import 'package:darkops/dashboard/theme_provider.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(apiService: ApiService())),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DarkOps',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(254, 240, 239, 239),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(254, 240, 239, 239),
          foregroundColor: Colors.black,
        ),
        cardColor: const Color.fromARGB(241, 255, 255, 255),
        brightness: Brightness.light,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF101828),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101828),
          foregroundColor: Colors.white,
        ),
        
        cardColor: const Color(0xFF1D2939),
        brightness: Brightness.dark,
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: const LoginOptions(),
    );
  }
}