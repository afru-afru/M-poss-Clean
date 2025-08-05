import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/pages/loading_screen2.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp(
      title: 'Ministry of Revenues POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Ag', 
        scaffoldBackgroundColor: Colors.white,
      ),
      // The first screen to be displayed is the LoadingScreen
      home: const LoadingScreen(),
      debugShowCheckedModeBanner: false, // This removes the debug banner
      ),
    );
  }
}