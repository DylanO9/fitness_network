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

  bool isEditingDisplayName = false;
  bool isEditingEmail = false;
  bool isEditingCoachingStatus = false;
  bool isEditingAge = false;
  bool isEditingGender = false;
  bool isEditingWeight = false;
  bool isEditingHeight = false;

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

  Future<void> _updateUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        await Supabase.instance.client
            .from('Fitness_Details')
            .update({
              'coaching_status': coachingStatus == 'Active',
              'age': age,
              'gender': gender,
              'weight': weight,
              'height': height,
            })
            .eq('user_id', user.id);

        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            email: email,
            data: {'display_name': displayName},
          ),
        );
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                  _buildEditableProfileItem('Display Name', displayName, isEditingDisplayName, (value) {
                    setState(() {
                      displayName = value;
                    });
                  }, () {
                    setState(() {
                      isEditingDisplayName = !isEditingDisplayName;
                    });
                  }),
                  _buildEditableProfileItem('Email', email, isEditingEmail, (value) {
                    setState(() {
                      email = value;
                    });
                  }, () {
                    setState(() {
                      isEditingEmail = !isEditingEmail;
                    });
                  }),
                  _buildEditableProfileItem('Coaching Status', coachingStatus, isEditingCoachingStatus, (value) {
                    setState(() {
                      coachingStatus = value;
                    });
                  }, () {
                    setState(() {
                      isEditingCoachingStatus = !isEditingCoachingStatus;
                    });
                  }),
                  _buildEditableProfileItem('Age', age.toString(), isEditingAge, (value) {
                    setState(() {
                      age = int.tryParse(value) ?? 0;
                    });
                  }, () {
                    setState(() {
                      isEditingAge = !isEditingAge;
                    });
                  }),
                  _buildEditableProfileItem('Gender', gender, isEditingGender, (value) {
                    setState(() {
                      gender = value;
                    });
                  }, () {
                    setState(() {
                      isEditingGender = !isEditingGender;
                    });
                  }),
                  _buildEditableProfileItem('Weight', weight.toStringAsFixed(1), isEditingWeight, (value) {
                    setState(() {
                      weight = double.tryParse(value) ?? 0.0;
                    });
                  }, () {
                    setState(() {
                      isEditingWeight = !isEditingWeight;
                    });
                  }),
                  _buildEditableProfileItem('Height', height.toStringAsFixed(1), isEditingHeight, (value) {
                    setState(() {
                      height = double.tryParse(value) ?? 0.0;
                    });
                  }, () {
                    setState(() {
                      isEditingHeight = !isEditingHeight;
                    });
                  }),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateUserProfile,
                      child: Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableProfileItem(String title, String value, bool isEditing, ValueChanged<String> onChanged, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 16),
          Flexible(
            child: isEditing
                ? TextFormField(
                    initialValue: value,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: onEdit,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: onEdit,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
