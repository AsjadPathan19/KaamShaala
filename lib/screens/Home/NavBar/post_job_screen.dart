import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/job_service.dart';
import '../../../services/user_service.dart';
import '../../../models/job.dart';
import '../../../screens/Home/NavBar/edit_job_screen.dart';

/// A screen that allows users to post new job opportunities
/// Contains a form with job details like title, description, location, and budget
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final AuthService _authService = AuthService();
  final JobService _jobService = JobService();
  final UserService _userService = UserService();

  late TabController _tabController;
  bool _isLoading = false;
  bool _showForm = false;
  String _selectedJobType = 'Plumber';
  Job? _editingJob;

  final List<String> _jobTypes = [
    'Plumber',
    'Mason',
    'Electrician',
    'Carpenter',
    'Painter',
    'Cleaner',
    'Driver',
    'Security Guard',
    'Other',
  ];

  // Cache for validation results
  final Map<String, String?> _validationCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Optimized validation method
  String? _validateField(String field, String? value) {
    if (value == null) {
      return 'This field is required';
    }

    if (_validationCache.containsKey(field)) {
      return _validationCache[field];
    }

    String? error;
    switch (field) {
      case 'description':
        error = value.isEmpty ? 'Please enter job description' : null;
        break;
      case 'location':
        error = value.isEmpty ? 'Please enter job location' : null;
        break;
      case 'budget':
        if (value.isEmpty) {
          error = 'Please enter budget';
        } else if (double.tryParse(value) == null) {
          error = 'Please enter a valid number';
        } else if (double.parse(value) <= 0) {
          error = 'Budget must be greater than 0';
        }
        break;
    }

    _validationCache[field] = error;
    return error;
  }

  void _clearForm() {
    setState(() {
      _formKey.currentState?.reset();
      _descriptionController.clear();
      _locationController.clear();
      _budgetController.clear();
      _selectedJobType = 'Plumber';
      _validationCache.clear();
      _showForm = false;
      _editingJob = null;
    });
  }

  void _editJob(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditJobScreen(job: job)),
    ).then((updated) {
      if (updated == true) {
        setState(() {}); // Refresh the list if job was updated
      }
    });
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userDoc = await _userService.getCurrentUserDocument();
      final contactNumber = userDoc?.get('contact') ?? '';

      if (_editingJob != null) {
        // Update existing job
        await _jobService.updateJob(_editingJob!.id, {
          'title': _selectedJobType,
          'description': _descriptionController.text,
          'budget': double.parse(_budgetController.text),
          'category': _selectedJobType,
        });

        _showSnackBar('Job updated successfully!', Colors.green);
      } else {
        // Create new job
        final newJob = Job(
          id: '', // ID will be assigned by Firestore
          title: _selectedJobType,
          description: _descriptionController.text,
          budget: double.parse(_budgetController.text),
          category: _selectedJobType,
          status: 'open',
          clientId: _authService.currentUser!.uid,
          createdAt: DateTime.now(),
        );
        await _jobService.createJob(newJob);

        _showSnackBar('Job posted successfully!', Colors.green);
      }

      _clearForm();
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showDeleteConfirmation(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _jobService.deleteJob(job.id);
              _showSnackBar('Job deleted successfully', Colors.green);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    final isActive = job.status == 'open';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 20,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isActive,
                    activeColor: Colors.green,
                    onChanged: (value) =>
                        _jobService.toggleJobStatus(job.id, value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.description,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.category,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      Text(
                        job.budget.toString(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _editJob(job),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _showDeleteConfirmation(job),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return StreamBuilder<List<Job>>(
      stream: _jobService.getUserJobs(_authService.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red[300]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data ?? [];
        final activeJobs = jobs.where((job) => job.status == 'open').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        activeJobs >= 3
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: activeJobs >= 3 ? Colors.orange : Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Active Jobs: $activeJobs/3',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: activeJobs / 3,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        activeJobs >= 3 ? Colors.orange : Colors.green,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (activeJobs < 3 && !_showForm)
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _showForm = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Post New Job'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (jobs.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No jobs posted yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first job posting',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Active Jobs'),
                      Tab(text: 'Inactive Jobs'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: jobs
                                .where((job) => job.status == 'open')
                                .map(_buildJobCard)
                                .toList(),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: jobs
                                .where((job) => job.status != 'open')
                                .map(_buildJobCard)
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildJobForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editingJob != null ? 'Edit Job' : 'Post New Job',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFormField(
              label: 'Job Type',
              icon: Icons.work_outline,
              child: DropdownButtonFormField<String>(
                value: _selectedJobType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                items: _jobTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedJobType = newValue);
                  }
                },
              ),
            ),
            _buildFormField(
              label: 'Job Description',
              icon: Icons.description_outlined,
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: 'Enter detailed job description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) => _validateField('description', value),
              ),
            ),
            _buildFormField(
              label: 'Location',
              icon: Icons.location_on_outlined,
              child: TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: 'Enter job location...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) => _validateField('location', value),
              ),
            ),
            _buildFormField(
              label: 'Budget (₹)',
              icon: Icons.currency_rupee,
              child: TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: 'Enter budget amount...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) => _validateField('budget', value),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveJob,
                icon: Icon(
                  _editingJob != null ? Icons.save : Icons.post_add,
                  size: 20,
                ),
                label: Text(
                  _editingJob != null ? 'Save Changes' : 'Post Job',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Jobs'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDashboard(),
              if (_showForm) ...[const SizedBox(height: 24), _buildJobForm()],
            ],
          ),
        ),
      ),
    );
  }
}
