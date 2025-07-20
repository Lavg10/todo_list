import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/authentication/presenatation/pages/login_page.dart';
import 'features/authentication/presenatation/blocs/auth_cubit.dart';
import 'features/authentication/data/services/todo_service.dart';
import 'features/authentication/presenatation/pages/todo_page.dart';
import 'features/authentication/presenatation/blocs/todo_cupit.dart';
// import 'features/authentication/presenatation/blocs/login_cubit.dart';
import 'features/authentication/data/repositories/auth_repository.dart';
import 'features/authentication/presenatation/blocs/profile_cubit.dart';
import 'features/authentication/presenatation/pages/profile_page.dart';
import 'features/authentication/data/services/profile_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository(
    Supabase.instance.client,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider<LoginCubit>(
        //   create: (_) => LoginCubit(authRepository),
        // ),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepository)),
        BlocProvider(
          create: (_) => ProfileCubit(ProfileService()),
          child: ProfilePage(),
        ),
        BlocProvider(
          create: (_) => TodoCubit(TodoService()),
          child: TodoPage(),
        ),
        BlocProvider(
          create: (_) => TodoCubit(TodoService()),
          child: const TodoPage(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginPage(),
      ),
    );
  }
}
