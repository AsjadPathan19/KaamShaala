import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/job_service.dart';
import '../../../models/job.dart';
import '../../../widgets/JobCard.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/job_notification_dialog.dart';

/// The home screen of the application that displays job posts and user information
/// Contains a list of job posts with details like location, title, and uploader
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Plumber',
    'Mason',
    'Electrician',
    'Carpenter',
    'Painter',
    'Cleaner',
    'Driver',
    'Security Guard',
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    _notificationService.onNewJobReceived = _showJobNotification;
  }

  void _showJobNotification(Job job) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JobNotificationDialog(job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', null),
                      _buildCategoryChip('Plumbing', 'plumbing'),
                      _buildCategoryChip('Electrical', 'electrical'),
                      _buildCategoryChip('Carpentry', 'carpentry'),
                      _buildCategoryChip('Painting', 'painting'),
                      _buildCategoryChip('Cleaning', 'cleaning'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Job>>(
              stream: _jobService.getJobs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final jobs = snapshot.data ?? [];
                final filteredJobs = jobs.where((job) {
                  final matchesSearch =
                      job.title.toLowerCase().contains(_searchQuery) ||
                          job.description.toLowerCase().contains(_searchQuery);
                  final matchesCategory = _selectedCategory == null ||
                      job.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredJobs.isEmpty) {
                  return const Center(
                    child: Text('No jobs found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    return JobCard(job: filteredJobs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/post-job');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? value : null);
        },
      ),
    );
  }
}
