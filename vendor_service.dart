import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:srv_hub/models/vendor_model.dart';

class VendorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vendors';

  // Get all vendors
  Stream<List<VendorModel>> getVendors() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all vendors as a future (not stream)
  Future<List<VendorModel>> getAllVendors() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => VendorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Add a new vendor
  Future<String> addVendor(VendorModel vendor) async {
    // Check if vendor with the same name already exists
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('name', isEqualTo: vendor.name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Return existing vendor ID if it already exists
      return querySnapshot.docs.first.id;
    }

    // Add new vendor if it doesn't exist
    final docRef = await _firestore.collection(_collection).add(vendor.toMap());
    return docRef.id;
  }

  // Update an existing vendor
  Future<void> updateVendor(VendorModel vendor) async {
    await _firestore.collection(_collection).doc(vendor.uuid).update(vendor.toMap());
  }

  // Delete a vendor
  Future<void> deleteVendor(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
