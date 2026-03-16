import 'package:flutter/material.dart';
import 'package:warehouse_admin/core/theme.dart';
import 'package:warehouse_admin/widgets/sidebar.dart';
import 'package:warehouse_admin/widgets/top_navbar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      // Mobile drawer for navigation
      drawer: isMobile
          ? const Drawer(
              child: Sidebar(),
            )
          : null,

      // Mobile app bar with gradient
      appBar: isMobile
          ? AppBar(
              title: const Text(
                'PC Parts Pro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryDark,
                      AppTheme.primaryColor,
                      AppTheme.sidebarBackground,
                    ],
                  ),
                ),
              ),
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,

      body: isMobile ? _buildMobileLayout(child) : _buildDesktopLayout(child),
    );
  }

  Widget _buildDesktopLayout(Widget child) {
    return Row(
      children: [
        // Sidebar - always visible on desktop
        const Sidebar(),

        // Main Content
        Expanded(
          child: Column(
            children: [
              const TopNavbar(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.backgroundColor,
                        AppTheme.primaryColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Widget child) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundColor,
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
