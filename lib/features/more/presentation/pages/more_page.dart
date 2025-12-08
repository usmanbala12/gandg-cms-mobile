import 'package:flutter/material.dart';

import 'my_requests_page.dart';
import 'notifications_page.dart';
import 'request_create_page.dart';
import 'settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'More',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Requests Section
          _buildSectionHeader(context, 'Requests'),
          const SizedBox(height: 8),
          _buildCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.list_alt,
                title: 'My Requests',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyRequestsPage()),
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              _buildMenuItem(
                context,
                icon: Icons.add_circle_outline,
                title: 'Create Request',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RequestCreatePage()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          const SizedBox(height: 8),
          _buildCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Settings Section
          _buildSectionHeader(context, 'Settings'),
          const SizedBox(height: 8),
          _buildCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Field Link',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Field Link Inc.',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }
}
