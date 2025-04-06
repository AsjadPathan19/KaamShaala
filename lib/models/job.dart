import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final double budget;
  final String category;
  final String status;
  final String clientId;
  final DateTime createdAt;
  final String? workerId;
  final DateTime? completedAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.category,
    required this.status,
    required this.clientId,
    required this.createdAt,
    this.workerId,
    this.completedAt,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      status: map['status'] ?? 'open',
      clientId: map['clientId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      workerId: map['workerId'],
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'budget': budget,
      'category': category,
      'status': status,
      'clientId': clientId,
      'createdAt': Timestamp.fromDate(createdAt),
      'workerId': workerId,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  @override
  String toString() {
    return 'Job{id: $id, title: $title, category: $category, createdAt: $createdAt}';
  }
}
