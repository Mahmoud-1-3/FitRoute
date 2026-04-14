import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ─── Storage Service ───────────────────────────────────────────────────────
/// Handles uploading and deleting files directly from Firebase Storage.

class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  /// Uploads a file to a specific path in Firebase Storage.
  /// Returns the public download URL strings.
  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    // We upload to the "profile_images/{uid}" path.
    final ref = _storage.ref().child('profile_images').child(uid);

    // Set metadata so Firebase recognizes it as an image
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    // Attempt the upload.
    final uploadTask = ref.putFile(file, metadata);
    
    // Wait explicitly for the task to complete
    final snapshot = await uploadTask.whenComplete(() => null);

    // Retrieve and return the publicly accessible URL.
    return await snapshot.ref.getDownloadURL();
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});
