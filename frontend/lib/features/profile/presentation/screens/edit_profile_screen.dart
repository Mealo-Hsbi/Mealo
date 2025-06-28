import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickImageAndUpload() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final vm = Provider.of<ProfileViewModel>(context, listen: false);
      final file = File(image.path);
      await vm.uploadAvatar(file);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profilbild aktualisiert')),
        );
        Navigator.of(context).pop(); // oder: Navigator.of(context).maybePop();
      }
    }
  }

  void _changeName() {
    // TODO: Navigator push zu ChangeNameScreen oder Dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name ändern – noch nicht implementiert')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Change Profile Picture'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickImageAndUpload,
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Change Name'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeName,
          ),
        ],
      ),
    );
  }
}
