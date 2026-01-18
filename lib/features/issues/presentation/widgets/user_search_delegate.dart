import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:field_link/features/issues/data/datasources/issue_remote_datasource.dart';
import 'package:field_link/features/issues/data/models/user_search_model.dart';

/// A SearchDelegate for searching and selecting users for issue assignment.
class UserSearchDelegate extends SearchDelegate<UserSearchModel?> {
  final IssueRemoteDataSource _dataSource;
  Timer? _debounce;

  UserSearchDelegate({IssueRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? GetIt.I<IssueRemoteDataSource>();

  @override
  String get searchFieldLabel => 'Search users by name or email';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Type at least 2 characters to search',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return FutureBuilder<List<UserSearchModel>>(
      future: _searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error searching users',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No users found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserListTile(
              user: user,
              onTap: () => close(context, user),
            );
          },
        );
      },
    );
  }

  Future<List<UserSearchModel>> _searchUsers(String searchQuery) async {
    try {
      final response = await _dataSource.searchUsers(
        query: searchQuery,
        size: 20,
        sortBy: 'fullName',
        sortDirection: 'asc',
      );

      final pageResponse = UserSearchPageResponse.fromJson(response);
      return pageResponse.content;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// A ListTile for displaying a user in search results.
class _UserListTile extends StatelessWidget {
  final UserSearchModel user;
  final VoidCallback onTap;

  const _UserListTile({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Text(
          user.avatarInitials,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(user.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.email,
            style: theme.textTheme.bodySmall,
          ),
          if (user.displayRole.isNotEmpty && user.displayRole != 'No Role')
            Text(
              user.displayRole,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      trailing: _buildStatusBadge(context, user.status),
      isThreeLine: user.displayRole.isNotEmpty && user.displayRole != 'No Role',
      onTap: onTap,
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    IconData icon;
    
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'INACTIVE':
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
        break;
      case 'SUSPENDED':
        color = Colors.red;
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    
    return Icon(icon, color: color, size: 20);
  }
}

/// A form field widget for selecting a user assignee.
class UserAssigneeField extends StatelessWidget {
  final UserSearchModel? selectedUser;
  final ValueChanged<UserSearchModel?> onUserSelected;
  final String label;
  final bool enabled;

  const UserAssigneeField({
    super.key,
    this.selectedUser,
    required this.onUserSelected,
    this.label = 'Assignee',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled ? () => _openUserSearch(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: selectedUser != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: enabled ? () => onUserSelected(null) : null,
                )
              : const Icon(Icons.person_search),
        ),
        child: selectedUser != null
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      selectedUser!.avatarInitials,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedUser!.fullName,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          selectedUser!.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                'Tap to search and select a user',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
      ),
    );
  }

  Future<void> _openUserSearch(BuildContext context) async {
    final result = await showSearch<UserSearchModel?>(
      context: context,
      delegate: UserSearchDelegate(),
    );
    
    if (result != null) {
      onUserSelected(result);
    }
  }
}
