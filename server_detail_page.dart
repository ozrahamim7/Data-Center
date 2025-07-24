import 'package:flutter/material.dart';
import 'package:srv_hub/models/server_model.dart';
import 'package:srv_hub/services/server_service.dart';
import 'package:srv_hub/models/vendor_model.dart';
import 'package:srv_hub/services/vendor_service.dart';
import 'package:srv_hub/services/users_service.dart';
import 'package:srv_hub/models/user_model.dart';

class ServerDetailPage extends StatefulWidget {
  const ServerDetailPage({super.key});

  @override
  State<ServerDetailPage> createState() => _ServerDetailPageState();
}

class _ServerDetailPageState extends State<ServerDetailPage> {
  final ServerService _serverService = ServerService();
  final VendorService _vendorService = VendorService();
  final AuthService _authService = AuthService();
  bool _isEditing = false;
  bool _isViewer = false;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _ipAddressController;
  late TextEditingController _portController;
  late TextEditingController _descriptionController;
  late TextEditingController _cabinetController;
  late TextEditingController _cabinetLocationController;
  late TextEditingController _vendorController;
  late TextEditingController _switchNameController;
  late TextEditingController _panelController;
  late ServerState _serverState;
  String? _selectedVendorName;
  String? _selectedVendorId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _ipAddressController = TextEditingController();
    _portController = TextEditingController();
    _descriptionController = TextEditingController();
    _cabinetController = TextEditingController();
    _cabinetLocationController = TextEditingController();
    _vendorController = TextEditingController();
    _switchNameController = TextEditingController();
    _panelController = TextEditingController();
    _serverState = ServerState.offline;
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final role = await _authService.getUserRole();
    setState(() {
      _isViewer = role == UserRole.viewer;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _ipAddressController.dispose();
    _portController.dispose();
    _descriptionController.dispose();
    _cabinetController.dispose();
    _cabinetLocationController.dispose();
    _vendorController.dispose();
    _switchNameController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  void _initializeControllers(ServerModel server) {
    _nameController.text = server.name;
    _locationController.text = server.location;
    _ipAddressController.text = server.ipAddress;
    _portController.text = server.port.toString();
    _descriptionController.text = server.description;
    _cabinetController.text = server.cabinet;
    _cabinetLocationController.text = server.cabinetLocation;
    _vendorController.text = server.vendor;
    _switchNameController.text = server.switchName;
    _panelController.text = server.panel;
    _serverState = server.state;
    _selectedVendorName = server.vendor;
  }

  @override
  Widget build(BuildContext context) {
    final server = ModalRoute.of(context)!.settings.arguments as ServerModel;

    if (_nameController.text != server.name) {
      _initializeControllers(server);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Server' : 'Server Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing && !_isViewer)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (!_isEditing && !_isViewer)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context, server),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditing) _buildStatusIndicator(server),

              const SizedBox(height: 24),

              _buildServerForm(),

              const SizedBox(height: 32),

              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _initializeControllers(server);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveServer(server),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ServerModel server) {
    final stateColor = ServerModel.getStateColor(server.state);
    final stateText = ServerModel.getStateString(server.state);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stateColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: stateColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            stateText,
            style: TextStyle(
              color: stateColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            'ID: ${server.uuid.substring(0, 8)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Server Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.dns),
          ),
          readOnly: !_isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a server name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        _isEditing
          ? StreamBuilder<List<VendorModel>>(
              stream: _vendorService.getVendors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final vendors = snapshot.data ?? [];

                if (_selectedVendorId == null && _selectedVendorName != null) {
                  final matchingVendor = vendors.where(
                    (v) => v.name.toLowerCase() == _selectedVendorName!.toLowerCase()
                  ).toList();

                  if (matchingVendor.isNotEmpty) {
                    _selectedVendorId = matchingVendor.first.uuid;
                  }
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Vendor',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  hint: const Text('Select a vendor'),
                  value: _selectedVendorId,
                  items: vendors.map((vendor) {
                    return DropdownMenuItem<String>(
                      value: vendor.uuid,
                      child: Text(vendor.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vendor';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedVendorId = value;
                        _selectedVendorName = vendors
                            .firstWhere((vendor) => vendor.uuid == value)
                            .name;
                      });
                    }
                  },
                );
              },
            )
          : TextFormField(
              controller: _vendorController,
              decoration: const InputDecoration(
                labelText: 'Vendor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              readOnly: true,
            ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _switchNameController,
          decoration: const InputDecoration(
            labelText: 'Switch',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.settings_input_hdmi),
          ),
          readOnly: !_isEditing,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _panelController,
          decoration: const InputDecoration(
            labelText: 'Panel',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.dashboard),
          ),
          readOnly: !_isEditing,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          readOnly: !_isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _ipAddressController,
          decoration: const InputDecoration(
            labelText: 'IP Address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
          ),
          readOnly: !_isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an IP address';
            }
            final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
            if (!ipRegex.hasMatch(value)) {
              return 'Please enter a valid IP address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _portController,
          decoration: const InputDecoration(
            labelText: 'Port',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.settings_ethernet),
          ),
          readOnly: !_isEditing,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a port number';
            }
            final port = int.tryParse(value);
            if (port == null || port < 1 || port > 65535) {
              return 'Port must be between 1 and 65535';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          readOnly: !_isEditing,
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _cabinetController,
          decoration: const InputDecoration(
            labelText: 'Cabinet',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.grid_view),
          ),
          readOnly: !_isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a cabinet identifier';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _cabinetLocationController,
          decoration: const InputDecoration(
            labelText: 'Cabinet Location',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.place),
          ),
          readOnly: !_isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a cabinet location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        if (_isEditing)
          DropdownButtonFormField<ServerState>(
            decoration: const InputDecoration(
              labelText: 'Server State',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.power_settings_new),
            ),
            value: _serverState,
            items: ServerState.values.map((state) {
              final stateText = ServerModel.getStateString(state);
              final stateColor = ServerModel.getStateColor(state);

              return DropdownMenuItem<ServerState>(
                value: state,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: stateColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(stateText),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _serverState = newValue;
                });
              }
            },
          ),
      ],
    );
  }

  void _saveServer(ServerModel originalServer) async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedServer = ServerModel(
          uuid: originalServer.uuid,
          name: _nameController.text,
          location: _locationController.text,
          ipAddress: _ipAddressController.text,
          port: int.parse(_portController.text),
          description: _descriptionController.text,
          cabinet: _cabinetController.text,
          cabinetLocation: _cabinetLocationController.text,
          state: _serverState,
          vendor: _selectedVendorName ?? originalServer.vendor,
          switchName: _switchNameController.text.trim(),
          panel: _panelController.text.trim(),
        );

        await _serverService.updateServer(updatedServer);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server updated successfully')),
        );

        setState(() {
          _isEditing = false;
        });

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating server: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, ServerModel server) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Server'),
        content: Text(
          'Are you sure you want to delete "${server.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await _serverService.deleteServer(server.uuid);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Server deleted successfully')),
                );

                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                });
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting server: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
