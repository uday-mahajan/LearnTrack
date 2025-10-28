import 'package:firebase_database/firebase_database.dart';
import '../models/class_session.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Create new class session under "classes" node
  Future<void> createClassSession(ClassSession session) async {
    try {
      await _db.child('classes').push().set(session.toMap());
      print("✅ Class session saved successfully in Realtime Database");
    } catch (e) {
      print("❌ Error saving class session: $e");
      rethrow;
    }
  }
}
