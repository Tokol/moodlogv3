import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/insert_help_line.dart';

class HelplineScreen extends StatefulWidget {
  const HelplineScreen({Key? key}) : super(key: key);

  @override
  State<HelplineScreen> createState() => _HelplineScreenState();
}

class _HelplineScreenState extends State<HelplineScreen> {
  late Future<List<HelplineCategory>> _helplinesFuture;

  @override
  void initState() {
    super.initState();

    _helplinesFuture = _fetchHelplines();
  }

  Future<List<HelplineCategory>> _fetchHelplines() async {


    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('helplines')
          .orderBy('type')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HelplineCategory(
          type: data['type'],
          organizations: List<Organization>.from(
            data['organizations'].map((org) => Organization.fromMap(org)),
          ),
        );
      }).toList();
    } catch (e) {
      print('Error fetching helplines: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<HelplineCategory>>(
        future: _helplinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Unable to load helplines',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final helplines = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: helplines.length,
            itemBuilder: (context, index) {
              final category = helplines[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      category.type,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: category.organizations.length,
                      itemBuilder: (context, orgIndex) {
                        final org = category.organizations[orgIndex];
                        return _buildOrganizationCard(org);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrganizationCard(Organization org) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              org.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                org.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _makePhoneCall(org.phone),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }
}

class HelplineCategory {
  final String type;
  final List<Organization> organizations;

  HelplineCategory({
    required this.type,
    required this.organizations,
  });
}

class Organization {
  final String name;
  final String description;
  final String phone;

  Organization({
    required this.name,
    required this.description,
    required this.phone,
  });

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      name: map['name'],
      description: map['description'],
      phone: map['phone'],
    );
  }
}