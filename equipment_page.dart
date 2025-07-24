import 'package:flutter/material.dart';
import 'package:srv_hub/models/equipment_model.dart';
import 'package:srv_hub/services/equipment_service.dart';
import 'package:srv_hub/services/vendor_service.dart';
import '../models/vendor_model.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final EquipmentService _equipmentService = EquipmentService();
  final VendorService _vendorService = VendorService();
  String _filterText = '';
  bool _isFilterActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _isFilterActive ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Filter equipment',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Equipment List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EquipmentModel>>(
              stream: _equipmentService.getEquipments(),
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

                final equipments = snapshot.data ?? [];

                List<EquipmentModel> filteredEquipments = equipments;
                if (_isFilterActive && _filterText.isNotEmpty) {
                  final searchText = _filterText.toLowerCase();
                  filteredEquipments = equipments.where((equipment) =>
                      equipment.type.toLowerCase().contains(searchText) ||
                      equipment.description.toLowerCase().contains(searchText) ||
                      equipment.vendor.toLowerCase().contains(searchText)
                  ).toList();
                }

                if (equipments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No equipment yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first equipment using the + button',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEquipments.length,
                  itemBuilder: (context, index) {
                    final equipment = filteredEquipments[index];
                    return _buildEquipmentCard(equipment);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEquipmentDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: const Icon(Icons.inventory_2),
        ),
        title: Text(
          equipment.type,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Vendor: ${equipment.vendor}'),
            Text(
              equipment.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'x${equipment.count}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditEquipmentDialog(context, equipment),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _showDeleteConfirmation(context, equipment),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => _showEquipmentDetails(context, equipment),
      ),
    );
  }

  void _showEquipmentDetails(BuildContext context, EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(equipment.type),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Type', equipment.type),
            const SizedBox(height: 8),
            _detailRow('Vendor', equipment.vendor),
            const SizedBox(height: 8),
            _detailRow('Count', equipment.count.toString()),
            const SizedBox(height: 8),
            _detailRow('Description', equipment.description),
            const SizedBox(height: 8),
            _detailRow('ID', equipment.uuid.substring(0, 8)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  void _showAddEquipmentDialog(BuildContext context) {
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final countController = TextEditingController(text: '1'); // Default count is 1
    final formKey = GlobalKey<FormState>();
    String? selectedVendorId;
    String? selectedVendorName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Equipment'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter equipment type';
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
                        value: selectedVendorId,
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
                              selectedVendorId = value;
                              selectedVendorName = vendors
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
                    controller: countController,
                    decoration: const InputDecoration(
                      labelText: 'Count',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a count';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count < 1) {
                        return 'Count must be at least 1';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Create and save the equipment
                    final newEquipment = EquipmentModel(
                      type: typeController.text.trim(),
                      description: descriptionController.text.trim(),
                      vendor: selectedVendorName ?? '',
                      count: int.parse(countController.text.trim()),
                    );

                    await _equipmentService.addEquipment(newEquipment);

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Equipment added successfully')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding equipment: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEquipmentDialog(BuildContext context, EquipmentModel equipment) {
    final typeController = TextEditingController(text: equipment.type);
    final descriptionController = TextEditingController(text: equipment.description);
    final countController = TextEditingController(text: equipment.count.toString());
    final formKey = GlobalKey<FormState>();
    String? selectedVendorId;
    String? selectedVendorName = equipment.vendor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Equipment'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter equipment type';
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

                      // Try to find the current vendor ID if it exists
                      if (selectedVendorId == null && equipment.vendor.isNotEmpty) {
                        final matchingVendor = vendors.where(
                          (v) => v.name.toLowerCase() == equipment.vendor.toLowerCase()
                        ).toList();

                        if (matchingVendor.isNotEmpty) {
                          selectedVendorId = matchingVendor.first.uuid;
                        }
                      }

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Vendor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        hint: const Text('Select a vendor'),
                        value: selectedVendorId,
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
                              selectedVendorId = value;
                              selectedVendorName = vendors
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
                    controller: countController,
                    decoration: const InputDecoration(
                      labelText: 'Count',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a count';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count < 1) {
                        return 'Count must be at least 1';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Create updated equipment model
                    final updatedEquipment = EquipmentModel(
                      uuid: equipment.uuid,
                      type: typeController.text.trim(),
                      description: descriptionController.text.trim(),
                      vendor: selectedVendorName ?? '',
                      count: int.parse(countController.text.trim()),
                    );

                    await _equipmentService.updateEquipment(updatedEquipment);

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Equipment updated successfully')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating equipment: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Text(
          'Are you sure you want to delete "${equipment.type}"? This action cannot be undone.',
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
                await _equipmentService.deleteEquipment(equipment.uuid);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Equipment deleted successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting equipment: $e')),
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

  void _showFilterDialog(BuildContext context) {
    final textController = TextEditingController(text: _filterText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Equipment'),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterText = '';
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
}
