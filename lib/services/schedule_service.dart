import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radiant_app/models/schedule_model.dart';
import 'package:radiant_app/services/firestore_service.dart';

class ScheduleService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = "schedules";

  Future<void> addSchedule(Schedule schedule) async {
    await _firestoreService.createDocument(
        _collection, schedule.id, schedule.toMap());
  }

  Future<Schedule?> getSchedule(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument(_collection, id);
    if (doc.exists) {
      return Schedule.fromDoc(doc);
    }
    return null;
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _firestoreService.updateDocument(
        _collection, schedule.id, schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    await _firestoreService.deleteDocument(_collection, id);
  }

  Stream<List<Schedule>> listenSchedules() {
    return _firestoreService.listenToCollection(_collection).map((snapshot) =>
        snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList());
  }
}
