import 'package:flutter/material.dart';
import '../../../models/job.dart';
import '../../../services/job_service.dart';

class EditJobScreen extends StatefulWidget {
  final Job job;

  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final JobService _jobService = JobService();

  bool _isLoading = false;
  String _selectedJobType = 'Plumber';
  bool _hasChanges = false;

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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with job data
    _selectedJobType = widget.job.title;
    _descriptionController.text = widget.job.description;
    _budgetController.text = widget.job.budget.toString();

    // Listen for changes to track if form is modified
    _descriptionController.addListener(_onFormChanged);
    _locationController.addListener(_onFormChanged);
    _budgetController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  String? _validateField(String field, String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (field == 'budget') {
      if (double.tryParse(value) == null) {
        return 'Please enter a valid number';
      }
      if (double.parse(value) <= 0) {
        return 'Budget must be greater than 0';
      }
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _jobService.updateJob(widget.job.id, {
        'title': _selectedJobType,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'salary': double.parse(_budgetController.text),
        'category': _selectedJobType,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate successful update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Edit Job'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          actions: [
            if (_hasChanges)
              TextButton.icon(
                onPressed: _isLoading ? null : _saveChanges,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Job Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.job.status == 'open'
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.job.status == 'open'
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: widget.job.status == 'open'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Job Status: ${widget.job.status == 'open' ? 'Active' : 'Inactive'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.job.status == 'open'
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: widget.job.status == 'open',
                        activeColor: Colors.green,
                        onChanged: (value) {
                          _jobService.toggleJobStatus(widget.job.id, value);
                          setState(() => _hasChanges = true);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Edit Form
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
                  child: Form(
                    key: _formKey,
                    onChanged: () => setState(() => _hasChanges = true),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                            items: _jobTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedJobType = value;
                                  _hasChanges = true;
                                });
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
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                _validateField('description', value),
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
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                _validateField('location', value),
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
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                _validateField('budget', value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
