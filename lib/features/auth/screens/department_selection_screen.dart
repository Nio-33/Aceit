import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Screen for selecting department and subjects
class DepartmentSelectionScreen extends StatefulWidget {
  // If coming directly from registration, we'll use these parameters
  // Otherwise we'll get the data from auth provider
  final String? email;
  final String? password;
  final String? name;

  const DepartmentSelectionScreen({
    super.key,
    this.email,
    this.password,
    this.name,
  });

  @override
  State<DepartmentSelectionScreen> createState() =>
      _DepartmentSelectionScreenState();
}

class _DepartmentSelectionScreenState extends State<DepartmentSelectionScreen> {
  String _selectedDepartment =
      AppConstants.departments[0]; // Default to first department
  List<String> _selectedSubjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateSelectedSubjects();
  }

  void _updateSelectedSubjects() {
    // Initialize with core subjects that are always selected
    _selectedSubjects = List<String>.from(AppConstants.coreSubjects);

    // Add first non-core subject from the department if available
    final departmentSubjects =
        AppConstants.subjectsByDepartment[_selectedDepartment] ?? [];
    for (final subject in departmentSubjects) {
      if (!AppConstants.coreSubjects.contains(subject)) {
        _selectedSubjects.add(subject);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Department'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header - more compact
                  const Text(
                    'Choose Your Study Path',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select your department to personalize your learning',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Department selection cards - more compact
                  ...AppConstants.departments
                      .map((department) => _buildDepartmentCard(department)),

                  const SizedBox(height: 16),

                  // Subject selection - more compact
                  const Text(
                    'Subject Selection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Core subjects are automatically selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subject checkboxes - in a limited height container
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        children: _buildSubjectCheckboxes(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Continue button
                  ElevatedButton(
                    onPressed: _handleUpdateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDepartmentCard(String department) {
    final isSelected = department == _selectedDepartment;
    final subjects = AppConstants.subjectsByDepartment[department] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDepartment = department;
            _updateSelectedSubjects();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Radio button
              Radio<String>(
                value: department,
                groupValue: _selectedDepartment,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDepartment = value;
                      _updateSelectedSubjects();
                    });
                  }
                },
                activeColor: AppTheme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),

              // Department info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${subjects.length} subjects',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Icon
              Icon(
                _getDepartmentIcon(department),
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSubjectCheckboxes() {
    final departmentSubjects =
        AppConstants.subjectsByDepartment[_selectedDepartment] ?? [];

    return departmentSubjects.map((subject) {
      final isCoreSubject = AppConstants.coreSubjects.contains(subject);
      final isSelected = _selectedSubjects.contains(subject);

      return CheckboxListTile(
        title: Text(subject),
        subtitle: isCoreSubject
            ? const Text('Core subject (required)',
                style: TextStyle(fontSize: 12))
            : null,
        value: isSelected,
        onChanged: isCoreSubject
            ? null // Core subjects can't be deselected
            : (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedSubjects.add(subject);
                  } else {
                    _selectedSubjects.remove(subject);
                  }
                });
              },
        activeColor: AppTheme.primaryColor,
        checkColor: Colors.white,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }).toList();
  }

  IconData _getDepartmentIcon(String department) {
    switch (department) {
      case 'Science':
        return Icons.science;
      case 'Arts':
        return Icons.palette;
      case 'Commercial':
        return Icons.business;
      default:
        return Icons.school;
    }
  }

  Future<void> _handleUpdateProfile() async {
    // Validate subject selection
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one subject')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // If we have registration data (coming from registration flow), register the user
      if (widget.email != null &&
          widget.password != null &&
          widget.name != null) {
        await authProvider.register(
          email: widget.email!,
          password: widget.password!,
          name: widget.name!,
          department: _selectedDepartment,
          selectedSubjects: _selectedSubjects,
        );

        if (mounted) {
          // Navigate to email verification screen
          Navigator.pushReplacementNamed(
              context, AppConstants.emailVerificationRoute);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Account created successfully! Please verify your email.')),
          );
        }
      }
      // Otherwise update the existing user's department and subjects (coming after email verification)
      else {
        print(
            'DepartmentSelectionScreen: Updating user profile with department: $_selectedDepartment');
        print(
            'DepartmentSelectionScreen: Selected subjects: $_selectedSubjects');

        try {
          // Update the user's department and subjects
          await authProvider.updateUserProfile(
            department: _selectedDepartment,
            selectedSubjects: _selectedSubjects,
          );

          print('DepartmentSelectionScreen: Profile updated successfully');

          if (mounted) {
            // Navigate to dashboard
            print('DepartmentSelectionScreen: Navigating to dashboard...');
            Navigator.pushReplacementNamed(
                context, AppConstants.dashboardRoute);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
          }
        } catch (updateError) {
          print(
              'DepartmentSelectionScreen: Error updating profile: $updateError');

          // If Firebase update fails, we'll still update the local UI and proceed to dashboard
          if (mounted) {
            print(
                'DepartmentSelectionScreen: Firebase update failed, proceeding with local update only');

            // Update local AuthProvider state
            if (authProvider.user != null) {
              final updatedUser = authProvider.user!.copyWith(
                department: _selectedDepartment,
                selectedSubjects: _selectedSubjects,
              );
              authProvider.updateLocalUserData(updatedUser);
            }

            // Navigate to dashboard even after error
            print(
                'DepartmentSelectionScreen: Forcing navigation to dashboard after Firebase failure');
            Navigator.pushReplacementNamed(
                context, AppConstants.dashboardRoute);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Profile saved locally. Some features may be limited.'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('DepartmentSelectionScreen: Operation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operation failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
