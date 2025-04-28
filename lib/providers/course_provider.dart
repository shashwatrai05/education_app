import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import '../service/firestore_service.dart';

final courseProvider = FutureProvider<List<Course>>((ref) async {
  return FirestoreService().getCourses();
});
