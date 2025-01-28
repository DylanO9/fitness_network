import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  String displayName = 'No Name';
  String email = 'No Email';
  String coachingStatus = 'No Status';
  String gender = "No Gender";
  int age = 0;
  double weight = 0.0;
  double height = 0.0;

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        // Update basic user information
        setState(() {
          displayName = user.userMetadata?['display_name'] ?? 'No Name';
          email = user.email ?? 'No Email';
        });

        // Fetch additional fitness details
        final response = await Supabase.instance.client
            .from('Fitness_Details')
            .select()
            .eq('user_id', user.id)
            .single();

        if (response != null && response is Map) {
          setState(() {
            coachingStatus = response['coaching_status'] == true
              ? 'Active'
              : response['coaching_status'] == false
                ? 'Not Active'
                : 'No Status';
            age = response['age'] ?? 0;
            gender = response['gender'] ?? 'No Gender';
            weight = (response['weight'] ?? 0).toDouble();
            height = (response['height'] ?? 0).toDouble();
          });
        }
      }
    } catch (e) {
      // Handle errors (e.g., network issues, invalid response)
      print('Error fetching user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    displayName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                _buildProfileItem('Email', email),
                _buildProfileItem('Coaching Status', coachingStatus),
                _buildProfileItem('Age', age.toString()),
                _buildProfileItem('Gender', gender),
                _buildProfileItem('Weight', '${weight.toStringAsFixed(1)} lb'),
                _buildProfileItem('Height', '${height.toStringAsFixed(1)} in'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
