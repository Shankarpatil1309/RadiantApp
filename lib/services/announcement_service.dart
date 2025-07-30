import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/announcement_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class AnnouncementService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "announcements";

  Future<void> addAnnouncement(Announcement announcement) async {
    await _firestoreService.createDocument(
        _collection, announcement.id, announcement.toMap());
  }

  Future<Announcement?> getAnnouncement(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Announcement.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _firestoreService.updateDocument(
        _collection, announcement.id, announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Announcement>> listenAnnouncements() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Announcement.fromDoc(doc)).toList());
  }
}
