import 'package:flutter/material.dart';
import 'package:srv_hub/models/server_model.dart';
import 'package:srv_hub/services/users_service.dart';
import 'package:srv_hub/services/server_service.dart';
import 'package:srv_hub/services/excel_service.dart';
import 'package:srv_hub/models/user_model.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final ServerService _serverService = ServerService();
  final ExcelService _excelService = ExcelService();
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isAdmin = false;
  bool _isViewer = false;

  String _filterText = '';
  String _filterField = 'All';
  List<String> _filterFields = ['All', 'Name', 'Location', 'IP Address', 'ID'];
  bool _isFilterActive = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final role = await _authService.getUserRole();
    setState(() {
      _isAdmin = role == UserRole.admin;
      _isViewer = role == UserRole.viewer;
    });
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _exportToExcel(BuildContext context) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final servers = await _serverService.getAllServers();
      final filePath = await _excelService.exportServersToExcel(servers);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to Excel: $filePath'),
          action: SnackBarAction(label: 'OPEN', onPressed: () {}),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting to Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _importFromExcel(BuildContext context) async {
    setState(() {
      _isImporting = true;
    });

    try {
      final importedServers = await _excelService.pickAndImportExcelFile();

      if (importedServers.isEmpty) {
        setState(() {
          _isImporting = false;
        });
        return;
      }

      final importCount = await _serverService.importServers(importedServers);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported $importCount servers'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing from Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SrvHub Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.inventory, size: 18),
                label: const Text('Equipment'),
                onPressed: () => Navigator.pushNamed(context, '/equipment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.business, size: 18),
                label: const Text('Vendors'),
                onPressed: () => Navigator.pushNamed(context, '/vendors'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Downloads'),
              onPressed: () => Navigator.pushNamed(context, '/download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
              left: 0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to SrvHub!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Logged in as: ${user?.email ?? 'User'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Servers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _isExporting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export'),
                            onPressed: () => _exportToExcel(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                    const SizedBox(width: 8),
                    // Only show Import button if user is admin
                    if (_isAdmin)
                      _isImporting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.file_upload),
                              label: const Text('Import'),
                              onPressed: () => _importFromExcel(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: _isFilterActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      tooltip: 'Filter servers',
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<ServerModel>>(
              stream: _serverService.getServers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final servers = snapshot.data ?? [];

                List<ServerModel> filteredServers = servers;
                if (_isFilterActive && _filterText.isNotEmpty) {
                  final searchText = _filterText.toLowerCase();

                  filteredServers = servers.where((server) {
                    switch (_filterField) {
                      case 'Name':
                        return server.name.toLowerCase().contains(searchText);
                      case 'Location':
                        return server.location.toLowerCase().contains(
                          searchText,
                        );
                      case 'IP Address':
                        return server.ipAddress.toLowerCase().contains(
                          searchText,
                        );
                      case 'ID':
                        return server.uuid.toLowerCase().contains(searchText);
                      case 'All':
                      default:
                        return server.name.toLowerCase().contains(searchText) ||
                            server.location.toLowerCase().contains(
                              searchText,
                            ) ||
                            server.ipAddress.toLowerCase().contains(
                              searchText,
                            ) ||
                            server.uuid.toLowerCase().contains(searchText);
                    }
                  }).toList();
                }

                if (servers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No servers yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first server using the + button',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 120,
                        ),
                    itemCount: filteredServers.length,
                    itemBuilder: (context, index) {
                      final server = filteredServers[index];
                      return _buildServerCard(server);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isViewer
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddServerDialog(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildServerCard(ServerModel server) {
    final stateColor = ServerModel.getStateColor(server.state);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: stateColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => _navigateToServerDetail(server),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: stateColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      server.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        server.location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.computer_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${server.ipAddress}:${server.port}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToServerDetail(ServerModel server) async {
    final result = await Navigator.pushNamed(
      context,
      '/server-detail',
      arguments: server,
    );

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server deleted successfully')),
      );
    }
  }

  void _showAddServerDialog(BuildContext context) {
    Navigator.pushNamed(context, '/add-server');
  }

  void _showFilterDialog(BuildContext context) {
    final textController = TextEditingController(text: _filterText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Servers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Search term',
                hintText: 'Enter text to filter',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                textController.text = value;
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length),
                );
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filter by field',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              value: _filterField,
              items: _filterFields.map((field) {
                return DropdownMenuItem<String>(
                  value: field,
                  child: Text(field),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filterField = value;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterText = '';
                _filterField = 'All';
                _isFilterActive = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Apply button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filterText = textController.text;
                _isFilterActive = _filterText.isNotEmpty;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAccountOptions(BuildContext context) {
    // TODO: Implement account options menu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account options not implemented yet')),
    );
  }
}

