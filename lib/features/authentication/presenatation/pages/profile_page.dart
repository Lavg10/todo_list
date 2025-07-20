// features/profile/presentation/pages/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/profile_cubit.dart';
import '../blocs/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  void _pickAndUpload() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      await context.read<ProfileCubit>().uploadAvatar(file);
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile(
        fullName: _nameController.text,
        address: _addressController.text,
        contact: _contactController.text,
        age: _ageController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
        _nameController.text = state.name;
        _addressController.text = state.address;
        _contactController.text = state.contact;
        _ageController.text = state.age;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("My Profile"),
            backgroundColor: const Color.fromARGB(255, 121, 206, 180),
            centerTitle: true,
            elevation: 2,
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundImage: state.imageUrl != null
                                  ? NetworkImage(state.imageUrl!)
                                  : null,
                              child: state.imageUrl == null
                                  ? const Icon(Icons.person, size: 70)
                                  : null,
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: _pickAndUpload,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 114, 141, 187),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          _nameController,
                          'Full Name',
                          Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Name required' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _addressController,
                          'Address',
                          Icons.home_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _contactController,
                          'Contact Number',
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _ageController,
                          'Age',
                          Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              (v == null || int.tryParse(v) == null)
                              ? 'Valid age required'
                              : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                138,
                                206,
                                200,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
