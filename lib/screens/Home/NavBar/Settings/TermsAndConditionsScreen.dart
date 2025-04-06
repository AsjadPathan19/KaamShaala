import 'package:flutter/material.dart';

/// A screen that displays the Terms and Conditions of the application
/// Provides a scrollable view of the terms with proper formatting and sections
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  /// Creates a styled title for each section
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Creates a styled body text for each section
  Widget sectionBody(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar at top of screen
      appBar: AppBar(
        title: Text(
          "Terms & Conditions",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),

      // Main body content
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                "Terms and Conditions",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Section 1: User Eligibility
              sectionTitle("1. User Eligibility"),
              sectionBody(
                "Users must be at least 18 years of age to register and use our platform. "
                "Users must provide accurate, complete, and up-to-date information during registration. "
                "KaamShaala reserves the right to suspend or terminate accounts if false information is provided.",
              ),

              // Section 2: User Responsibilities
              sectionTitle("2. User Responsibilities"),
              sectionBody(
                "Users are responsible for maintaining the confidentiality of their account credentials. "
                "Users should use the platform ethically and legally, without engaging in fraudulent, abusive, or harmful activity. "
                "All communication and transactions between workers and users must adhere to respectful and professional standards.",
              ),

              // Section 3: Job Listings & Applications
              sectionTitle("3. Job Listings & Applications"),
              sectionBody(
                "KaamShaala provides a platform for users to post job listings and for workers to apply. "
                "We do not guarantee employment or job placement. "
                "Users are responsible for verifying the authenticity of job listings and worker profiles.",
              ),

              // Section 4: Payment & Fees
              sectionTitle("4. Payment & Fees"),
              sectionBody(
                "All payments must be made through the platform's secure payment system. "
                "KaamShaala may charge fees for premium services or features. "
                "Users agree to pay all applicable fees and taxes.",
              ),

              // Section 5: Privacy & Data Protection
              sectionTitle("5. Privacy & Data Protection"),
              sectionBody(
                "We collect and process personal data in accordance with our Privacy Policy. "
                "Users consent to the collection and use of their data as described in our Privacy Policy. "
                "We implement security measures to protect user data.",
              ),

              // Section 6: Termination
              sectionTitle("6. Termination"),
              sectionBody(
                "KaamShaala reserves the right to terminate or suspend user accounts for violations of these terms. "
                "Users may terminate their accounts at any time by following the account deletion process.",
              ),

              // Section 7: Changes to Terms
              sectionTitle("7. Changes to Terms"),
              sectionBody(
                "We may modify these terms at any time. "
                "Users will be notified of significant changes. "
                "Continued use of the platform after changes constitutes acceptance of the new terms.",
              ),

              // Section 8: Contact Information
              sectionTitle("8. Contact Information"),
              sectionBody(
                "For questions about these terms, please contact us at support@kaamshaala.com. "
                "We aim to respond to all inquiries within 48 hours.",
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
