import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';                 
import 'home_screen.dart';
import 'product_page.dart';
import 'report_page.dart';
import 'profile_page.dart';
import 'add_product_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    ),
    const ProductPage(),
    const ReportPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3B82F6);
    
    //  Get the user's data from the AuthBloc's state
    final authState = context.watch<AuthBloc>().state;
    String userName = 'User'; // Default name
    if (authState is AuthSuccess) {
      userName = authState.user.name;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primaryBlue),
          onPressed: () {},
        ),
        title: const Text('MRP', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                //  Display the dynamic user name from the BLoC
                Text(
                  userName,
                  style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  'assets/dropdownIcon.png',
                  width: 10,
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _pages.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddProductPage()),
                );
              },
              backgroundColor: primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
              shape: const CircleBorder(),
            )
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF4F6F8), width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(imagePath: 'assets/invoice-01.png', label: 'Invoice', index: 0),
          _buildNavItem(imagePath: 'assets/productIcon.png', label: 'Product', index: 1),
          _buildNavItem(imagePath: 'assets/analytics-02.png', label: 'Report', index: 2),
          _buildNavItem(imagePath: 'assets/user.png', label: 'Profile', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required String imagePath, required String label, required int index}) {
    bool isSelected = _selectedIndex == index;
    Color activeColor = const Color(0xFF3B82F6);
    Color inactiveColor = const Color(0xFFB1BBC8);

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 24,
              height: 24,
              color: isSelected ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}