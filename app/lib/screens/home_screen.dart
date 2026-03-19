import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'coming_soon_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	  backgroundColor: Colors.black, // ADD THIS
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
				  SvgPicture.asset('assets/icons/queen.svg', height: 28),
				  SvgPicture.asset('assets/icons/king.svg', height: 28),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                "CHESS",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Play. Learn. Improve.",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 40),

              // Game Modes
              _modeTile(
                context,
                title: "Offline vs Bot",
                subtitle: "Play against engine",
				iconPath: "assests/icons/knight.svg",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(mode: 'offline'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _modeTile(
                context,
                title: "Engine Analysis",
                subtitle: "Analyze positions",
				iconPath: "assests/icons/pawn.svg",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(mode: 'engine'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _modeTile(
                context,
                title: "Online Multiplayer",
                subtitle: "Coming soon",
				iconPath: "assests/icons/king.svg",
                disabled: true,
                onTap: () {},
              ),

              const Spacer(),

              // Bottom button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: const Text("SETTINGS"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _modeTile(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String iconPath,
  required VoidCallback onTap,
  bool disabled = false,
}) {
  return GestureDetector(
    onTap: disabled ? null : onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: disabled ? Colors.white24 : Colors.white,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            height: 26,
            colorFilter: ColorFilter.mode(
              disabled ? Colors.white24 : Colors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: disabled ? Colors.white24 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    ),
  );
}}
