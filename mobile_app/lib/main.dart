import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:capstone_app/providers/user_provider.dart';
import 'package:capstone_app/views/home_page.dart';
import 'package:capstone_app/views/build_profile_page.dart';
import 'package:capstone_app/views/edit_profile_page.dart';
import 'package:capstone_app/views/login_page.dart';
import 'package:capstone_app/views/matched_page.dart';
import 'package:capstone_app/views/messaging_page.dart';
import 'package:capstone_app/views/profile_page.dart';
import 'package:capstone_app/views/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase connection.
  await Supabase.initialize(
    url: 'https://enwbbyztboyashdtxocf.supabase.co',
    anonKey:
        //'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVud2JieXp0Ym95YXNoZHR4b2NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyMzQxMzAsImV4cCI6MjA1NDgxMDEzMH0.Bz0wUAZraKQeqFk8i-zCC18QKc_iNZqxGk9HAJyCU_E',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVud2JieXp0Ym95YXNoZHR4b2NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyMzQxMzAsImV4cCI6MjA1NDgxMDEzMH0.Bz0wUAZraKQeqFk8i-zCC18QKc_iNZqxGk9HAJyCU_E',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// Create Supabase client variable.
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner.
      title: 'URent App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Start at login page.
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => MainScreen(),
        '/build-profile': (context) => BuildProfilePage(),
        '/matched': (context) => MatchPopupPage(
              matchName: 'John',
              matchProfileImage: '.', // Placeholder.
            ),
        '/edit-profile': (context) => EditProfilePage(),
      },
    );
  }
}

// Main Navigation with Bottom Navigation Bar.
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // Bottom navigation bar pages.
  final List<Widget> _pages = [
    SwipePage(),
    MessengerApp(),
    ProfilePage(),
  ];
  // Adding functionality.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Code for bottom navigation.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
