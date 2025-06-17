import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darkops/blocs/auth/auth_bloc.dart';
import 'package:darkops/blocs/dashboard/dashboard_bloc.dart';
import 'package:darkops/blocs/scan/scan_bloc.dart';
import 'package:darkops/screens/login_options.dart';
import 'package:darkops/services/api_seevice.dart';
import 'package:darkops/services/scan_service.dart';
import 'package:darkops/services/google_auth_service.dart';
import 'package:darkops/repositories/auth_repository.dart';
import 'package:darkops/repositories/dashboard_repository.dart';
import 'package:darkops/dashboard/theme_provider.dart';
import 'package:darkops/dashboard/homepage.dart';

void main() {
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(create: (context) => ApiService()),
        RepositoryProvider<ScanService>(create: (context) => ScanService()),
        RepositoryProvider<GoogleAuthService>(
          create: (context) => GoogleAuthService(),
        ),
        RepositoryProvider<AuthRepository>(
          create:
              (context) =>
                  AuthRepository(apiService: context.read<ApiService>()),
        ),
        RepositoryProvider<DashboardRepository>(
          create:
              (context) =>
                  DashboardRepository(apiService: context.read<ApiService>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create:
                (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AuthCheckRequested()),
          ),
          BlocProvider<DashboardBloc>(
            create:
                (context) => DashboardBloc(
                  dashboardRepository: context.read<DashboardRepository>(),
                ),
          ),
          BlocProvider<ScanBloc>(
            create:
                (context) => ScanBloc(
                  scanService: context.read<ScanService>(),
                  googleAuthService: context.read<GoogleAuthService>(),
                ),
          ),
        ],
        child: ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
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
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Show loading screen while checking auth status
          if (state.status == AuthStatus.loading) {
            return const Scaffold(
              backgroundColor: Color(0xFF101828),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 139, 92, 246),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          // Navigate based on auth status
          if (state.isAuthenticated) {
            return const HomePage();
          } else {
            return const LoginOptions();
          }
        },
      ),
    );
  }
}
