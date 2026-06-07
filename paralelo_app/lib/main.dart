import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paralelo_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:paralelo_app/features/auth/views/login_view.dart';
import 'package:paralelo_app/features/usuarios/viewmodels/usuarios_viewmodel.dart';
import 'package:paralelo_app/features/usuarios/views/usuarios_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UsuariosViewModel()),
      ],
      child: const ParaleloApp(),
    ),
  );
}

class ParaleloApp extends StatelessWidget {
  const ParaleloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paralelo API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C6FCD), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const _SplashRouter(),
    );
  }
}

// Decide si mostrar Login o la pantalla principal según si hay token guardado
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final logged = await context.read<AuthViewModel>().isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => logged ? const UsuariosView() : const LoginView()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF7C6FCD))),
    );
  }
}
