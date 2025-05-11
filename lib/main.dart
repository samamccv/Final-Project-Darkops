import 'package:darkops/screens/login_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darkops/blocs/auth/auth_bloc.dart';
import 'package:darkops/services/api_seevice.dart';

void main() {
  runApp(const MyApp());
}

// The main app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(apiService: ApiService())),
      ],
      child: MaterialApp(
        title: 'DarkOps',
        theme: ThemeData.dark(),
        home: const LoginOptions(),
      ),
    );
  }
}

// Splash Screen with delayed navigation
