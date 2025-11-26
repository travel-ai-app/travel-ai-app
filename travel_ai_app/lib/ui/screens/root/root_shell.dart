import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // HomeScreen βρίσκεται στο ίδιο level με τον φάκελο root
import '../ai/ai_screen.dart'; // ai/ai_screen.dart
import '../expenses/expenses_screen.dart'; // expenses/expenses_screen.dart
import '../trip/itinerary_screen.dart'; // itinerary/itinerary_screen.dart

class RootShell extends StatefulWidget { // shell με bottom navigation
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0; // ποιο tab είναι ενεργό

  // λίστα με τις οθόνες που θα δείχνει κάθε tab
  final List<Widget> _screens = const [
    HomeScreen(),
    AiScreen(),
    ExpensesScreen(),
    ItineraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // δείχνει την οθόνη του active tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // αλλάζουμε tab
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Trip',
          ),
        ],
      ),
    );
  }
}