import 'package:flutter/material.dart';

/// A screen that displays the list of completed jobs by the worker
/// Shows job details, completion date, and rating received
class CompletedJobsScreen extends StatefulWidget {
  const CompletedJobsScreen({super.key});

  @override
  _CompletedJobsScreenState createState() => _CompletedJobsScreenState();
}

class _CompletedJobsScreenState extends State<CompletedJobsScreen> {
  // Dummy data for completed jobs
  final List<Map<String, dynamic>> _completedJobs = [
    {
      'title': 'House Painting',
      'location': 'Connaught Place, Aurangabad',
      'clientName': 'John Doe',
      'completionDate': '2024-03-15',
      'rating': 4.5,
      'review': 'Excellent work! Very professional.',
      'image': 'https://via.placeholder.com/400x200',
      'amount': '₹5,000',
    },
    {
      'title': 'Wall Repair',
      'location': 'TV Center, Aurangabad',
      'clientName': 'Jane Smith',
      'completionDate': '2024-03-10',
      'rating': 5.0,
      'review': 'Great service, highly recommended!',
      'image': 'https://via.placeholder.com/400x200',
      'amount': '₹3,500',
    },
    {
      'title': 'Tile Installation',
      'location': 'Jalna Road, Aurangabad',
      'clientName': 'Mike Johnson',
      'completionDate': '2024-03-05',
      'rating': 4.0,
      'review': 'Good work, completed on time.',
      'image': 'https://via.placeholder.com/400x200',
      'amount': '₹7,500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Completed Jobs',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _completedJobs.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: constraints.maxWidth * 0.15,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Text(
                      'No completed jobs yet',
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.045,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                itemCount: _completedJobs.length,
                itemBuilder: (context, index) {
                  final job = _completedJobs[index];
                  return Card(
                    margin: EdgeInsets.only(
                      bottom: constraints.maxWidth * 0.04,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Image
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              job['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: constraints.maxWidth * 0.12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Job Title and Amount
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      job['title'],
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.02),
                                  Text(
                                    job['amount'],
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.01),
                              // Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: constraints.maxWidth * 0.04,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.01),
                                  Expanded(
                                    child: Text(
                                      job['location'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: constraints.maxWidth * 0.035,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.01),
                              // Client Name and Completion Date
                              Wrap(
                                spacing: constraints.maxWidth * 0.04,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: constraints.maxWidth * 0.04,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth * 0.01,
                                      ),
                                      Text(
                                        'Client: ${job['clientName']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize:
                                              constraints.maxWidth * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: constraints.maxWidth * 0.04,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth * 0.01,
                                      ),
                                      Text(
                                        'Completed: ${job['completionDate']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize:
                                              constraints.maxWidth * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.015),
                              // Rating
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: constraints.maxWidth * 0.05,
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.01),
                                  Text(
                                    job['rating'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: constraints.maxWidth * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.01),
                              // Review
                              Text(
                                job['review'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                  fontSize: constraints.maxWidth * 0.035,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
        },
      ),
    );
  }
}
