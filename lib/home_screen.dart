// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'select_products_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3B82F6);

    return Container(
      color: const Color(0xFFF4F6F8), // Light grey background
      child: Column(
        children: [
          // Search Bar Section
          Container(
            color: Color(0xFFEFF4FF),
           
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // "Add Invoice" Section
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add_outlined, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'If you want to add a new invoice',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
   onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const SelectProductsScreen()),
  );
},
                  icon: const Icon(Icons.add, color: primaryBlue),
                  label: const Text(
                    'Add Invoices',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}