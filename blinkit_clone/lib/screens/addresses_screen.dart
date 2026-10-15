// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';

// class AddressesScreen extends StatelessWidget {
//   const AddressesScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
//     final user = userProvider.user;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Addresses'),
//         backgroundColor: const Color(0xFFE23744),
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Add New Address Button
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement add new address functionality
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Add address feature coming soon!'),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE23744),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.all(16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   Icon(Icons.add),
//                   SizedBox(width: 8),
//                   Text('Add New Address'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Saved Addresses List
//             Text(
//               'Saved Addresses',
//               style: Theme.of(
//                 context,
//               ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: user?.addresses.isEmpty ?? true
//                   ? Center(
//                       child: Text(
//                         'No addresses saved yet',
//                         style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: user!.addresses.length,
//                       itemBuilder: (context, index) {
//                         final address = user.addresses[index];
//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 16),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.location_on,
//                                       color: Color(0xFFE23744),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         address.house,
//                                         style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.edit),
//                                       onPressed: () {
//                                         // TODO: Implement edit address
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           const SnackBar(
//                                             content: Text(
//                                               'Edit address feature coming soon!',
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete),
//                                       onPressed: () {
//                                         // TODO: Implement delete address
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           const SnackBar(
//                                             content: Text(
//                                               'Delete address feature coming soon!',
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   address.area,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'map_picker_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFE23744),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'My Addresses',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your saved delivery addresses',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;

          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE23744)),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add New Address Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show bottom sheet with options
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.map,
                                  color: Color(0xFFE23744),
                                ),
                                title: const Text('Pick on Map'),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  // Open map picker
                                  final result =
                                      await Navigator.push<AddressModel?>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MapPickerScreen(),
                                        ),
                                      );

                                  if (result is AddressModel) {
                                    // Save immediately via provider
                                    final userProvider =
                                        Provider.of<UserProvider>(
                                          context,
                                          listen: false,
                                        );

                                    try {
                                      await userProvider.addAddress(result);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Address saved from map!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error saving address: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.edit_location_alt,
                                  color: Color(0xFFE23744),
                                ),
                                title: const Text('Enter Manually'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _showAddEditAddressDialog(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE23744),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text(
                      'Add New Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Addresses Section Header
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      color: Color(0xFFE23744),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saved Addresses',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user?.addresses.isNotEmpty ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE23744),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${user!.addresses.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Addresses List
                Expanded(
                  child: user?.addresses.isEmpty ?? true
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: user!.addresses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final address = user.addresses[index];
                            return _buildAddressCard(context, address, index);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'No addresses saved yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first address to get started',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel address,
    int index,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAddressDetailsDialog(context, address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE23744).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Color(0xFFE23744),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.house,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address.area,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'activate':
                          // Activate this address
                          final userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false,
                          );
                          userProvider.setActiveAddress(index);
                          break;
                        case 'edit':
                          _showAddEditAddressDialog(
                            context,
                            address: address,
                            index: index,
                          );
                          break;
                        case 'delete':
                          _showDeleteConfirmDialog(context, index);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!address.isActive)
                        const PopupMenuItem(
                          value: 'activate',
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked,
                                size: 18,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text('Set as Active'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (address.isActive)
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

  void _showAddressDetailsDialog(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFFE23744)),
            const SizedBox(width: 8),
            const Text('Address Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('House/Building:', address.house),
            const SizedBox(height: 12),
            _buildDetailRow('Area/Locality:', address.area),
            const SizedBox(height: 12),
            _buildDetailRow('City:', address.city),
            const SizedBox(height: 12),
            _buildDetailRow('State:', address.state),
            const SizedBox(height: 12),
            _buildDetailRow('Pincode:', address.pincode),
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

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showAddEditAddressDialog(
    BuildContext context, {
    AddressModel? address,
    int? index,
  }) {
    final isEditing = address != null;
    final houseController = TextEditingController(text: address?.house ?? '');
    final areaController = TextEditingController(text: address?.area ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final stateController = TextEditingController(text: address?.state ?? '');
    final pincodeController = TextEditingController(
      text: address?.pincode ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              isEditing ? Icons.edit_location : Icons.add_location_alt,
              color: const Color(0xFFE23744),
            ),
            const SizedBox(width: 8),
            Text(isEditing ? 'Edit Address' : 'Add New Address'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: houseController,
                  decoration: InputDecoration(
                    labelText: 'House/Building/Apartment',
                    hintText: 'e.g., 123 Main Street, Apt 4B',
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter house/building details';
                    }
                    if (value.trim().length < 3) {
                      return 'Please enter at least 3 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: 'Area/Locality',
                    hintText: 'e.g., Downtown, City Center',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter area/locality';
                    }
                    if (value.trim().length < 3) {
                      return 'Please enter at least 3 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'e.g., Mumbai',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    if (value.trim().length < 2) {
                      return 'Please enter at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                    hintText: 'e.g., Maharashtra',
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter state';
                    }
                    if (value.trim().length < 2) {
                      return 'Please enter at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pincodeController,
                  decoration: InputDecoration(
                    labelText: 'Pincode',
                    hintText: 'e.g., 400001',
                    prefixIcon: const Icon(Icons.local_post_office),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE23744)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter pincode';
                    }
                    final cleaned = value.trim();
                    final pinReg = RegExp(r'^\d{4,6}$');
                    if (!pinReg.hasMatch(cleaned)) {
                      return 'Please enter a valid pincode (4-6 digits)';
                    }
                    return null;
                  },
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
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );

                try {
                  final newAddress = AddressModel(
                    house: houseController.text.trim(),
                    area: areaController.text.trim(),
                    city: cityController.text.trim(),
                    pincode: pincodeController.text.trim(),
                    state: stateController.text.trim(),
                  );

                  if (isEditing) {
                    await userProvider.updateAddress(index!, newAddress);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    await userProvider.addAddress(newAddress);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE23744),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete Address'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this address? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );

              try {
                await userProvider.deleteAddress(index);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting address: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}





