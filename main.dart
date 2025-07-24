import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:srv_hub/screens/login_page.dart';
import 'package:srv_hub/screens/home_page.dart';
import 'package:srv_hub/screens/register_page.dart';
import 'package:srv_hub/screens/server_detail_page.dart';
import 'package:srv_hub/screens/add_server_page.dart';
import 'package:srv_hub/screens/download_page.dart';
import 'package:srv_hub/screens/equipment_page.dart';
import 'package:srv_hub/screens/vendors_page.dart';
import 'package:srv_hub/services/users_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
// void main() {
//   runApp(const MaterialApp(home: TestAPI()));
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'SrvHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF607D8B),
            primary: const Color(0xFF607D8B),
            secondary: const Color(0xFF90A4AE),
            background: Colors.white,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF607D8B),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF607D8B),
              foregroundColor: Colors.white,
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/server-detail': (context) => const ServerDetailPage(),
          '/add-server': (context) => const AddServerPage(),
          '/download': (context) => const DownloadPage(),
          '/equipment': (context) => const EquipmentPage(),
          '/vendors': (context) => const VendorsPage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return user != null ? const HomePage() : const LoginPage();
  }
}
