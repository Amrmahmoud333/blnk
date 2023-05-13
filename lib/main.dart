import 'package:blnk/logic/cubit/google_service_cubit.dart';
import 'package:blnk/theme/styling.dart';
import 'package:blnk/views/collect_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(BlocProvider(
    create: (context) => GoogleServiceCubit(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blnk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightAppTheme,
      home: const CollectDataScreen(),
    );
  }
}
