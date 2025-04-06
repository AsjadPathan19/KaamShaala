import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work/models/job.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new job in Firestore
  Future<void> createJob(Job job) async {
    try {
      final docRef = await _firestore.collection('jobs').add(job.toMap());

      // Get the job document with the new ID
      final doc = await docRef.get();
      final createdJob = Job.fromFirestore(doc);

      // Send notification to all workers
      await _sendJobNotification(createdJob);
    } catch (e) {
      print('Error creating job: $e');
      rethrow;
    }
  }

  /// Sends a notification for a new job
  Future<void> _sendJobNotification(Job job) async {
    try {
      // Get all worker tokens from the users collection
      final workersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .get();

      final tokens = workersSnapshot.docs
          .map((doc) => doc.data()['fcmToken'] as String?)
          .where((token) => token != null)
          .toList();

      if (tokens.isEmpty) return;

      // Send notification to each worker
      for (final token in tokens) {
        await _firestore.collection('notifications').add({
          'type': 'new_job',
          'jobId': job.id,
          'jobTitle': job.title,
          'job': job.toMap(),
          'token': token,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error sending job notification: $e');
    }
  }

  /// Updates an existing job in Firestore
  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update(data);
    } catch (e) {
      print('Error updating job: $e');
      rethrow;
    }
  }

  /// Deletes a job from Firestore
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      print('Error deleting job: $e');
      rethrow;
    }
  }

  /// Gets all jobs from Firestore
  Stream<List<Job>> getJobs() {
    return _firestore
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    });
  }

  /// Gets jobs posted by a specific user
  Stream<List<Job>> getUserJobs(String userId) {
    return _firestore
        .collection('jobs')
        .where('clientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    });
  }

  /// Gets jobs assigned to a specific worker
  Stream<List<Job>> getWorkerJobs(String workerId) {
    return _firestore
        .collection('jobs')
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    });
  }

  /// Gets a single job by ID
  Future<Job?> getJob(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return Job.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting job: $e');
      rethrow;
    }
  }

  // Toggle job active status
  Future<void> toggleJobStatus(String jobId, bool isActive) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': isActive ? 'open' : 'closed',
      });
    } catch (e) {
      print('Error toggling job status: $e');
      throw Exception('Failed to toggle job status: $e');
    }
  }

  /// Applies for a job
  Future<void> applyForJob(String jobId, String workerId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'workerId': workerId,
        'status': 'assigned',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error applying for job: $e');
      rethrow;
    }
  }
}
