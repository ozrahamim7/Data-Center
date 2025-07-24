import 'package:flutter/material.dart';
import 'package:srv_hub/models/server_model.dart';
import 'package:srv_hub/services/server_service.dart';
import '../models/vendor_model.dart';
import '../services/vendor_service.dart';

class AddServerPage extends StatefulWidget {
  const AddServerPage({super.key});

  @override
  State<AddServerPage> createState() => _AddServerPageState();
}

class _AddServerPageState extends State<AddServerPage> {
  final ServerService _serverService = ServerService();
  final VendorService _vendorService = VendorService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _ipAddressController;
  late TextEditingController _portController;
  late TextEditingController _descriptionController;
  late TextEditingController _cabinetController;
  late TextEditingController _cabinetLocationController;
  late TextEditingController _switchNameController;
  late TextEditingController _panelController;
  ServerState _serverState = ServerState.offline;

  bool _isLoading = false;

  String? _selectedVendorName;
  String? _selectedVendorId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _ipAddressController = TextEditingController();
    _portController = TextEditingController(text: '22');
    _descriptionController = TextEditingController();
    _cabinetController = TextEditingController();
    _cabinetLocationController = TextEditingController();
    _switchNameController = TextEditingController();
    _panelController = TextEditingController();
    _serverState = ServerState.offline;
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
    _switchNameController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Server'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Server Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Server Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.dns),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a server name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Vendor dropdown
                    StreamBuilder<List<VendorModel>>(
                      stream: _vendorService.getVendors(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final vendors = snapshot.data ?? [];

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
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _switchNameController,
                      decoration: const InputDecoration(
                        labelText: 'Switch',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.settings_input_hdmi),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _panelController,
                      decoration: const InputDecoration(
                        labelText: 'Panel',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.dashboard),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
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
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _cabinetController,
                      decoration: const InputDecoration(
                        labelText: 'Cabinet',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cabin),
                      ),
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
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a cabinet location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _addServer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Add Server',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addServer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new server model with the vendor
        final newServer = ServerModel(
          name: _nameController.text,
          location: _locationController.text,
          ipAddress: _ipAddressController.text,
          port: int.parse(_portController.text),
          description: _descriptionController.text,
          cabinet: _cabinetController.text,
          cabinetLocation: _cabinetLocationController.text,
          state: _serverState,
          vendor: _selectedVendorName ?? '',
          switchName: _switchNameController.text.trim(),
          panel: _panelController.text.trim(),
        );

        await _serverService.addServer(newServer);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server added successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding server: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
