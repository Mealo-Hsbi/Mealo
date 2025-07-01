import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  int servings = 1;
  int readyInMinutes = 10;
  String summary = '';
  String imageUrl = '';
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> steps = [];

  // Für dynamische Felder
  final TextEditingController _ingredientNameController = TextEditingController();
  final TextEditingController _ingredientAmountController = TextEditingController();
  final TextEditingController _ingredientUnitController = TextEditingController();
  final TextEditingController _stepDescriptionController = TextEditingController();
  final TextEditingController _stepDurationController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  File? _selectedImage;
  String? _uploadedImagePath;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || ingredients.isEmpty || steps.isEmpty) return;
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final api = ApiClient();
      await api.post(
        '/recipes',
        data: {
          'title': title,
          'servings': servings,
          'readyInMinutes': readyInMinutes,
          'summary': summary,
          'imageUrl': imageUrl,
          'ingredients': ingredients,
          'steps': steps,
        },
        options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() { errorMessage = 'Fehler beim Anlegen: $e'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() { _selectedImage = File(picked.path); });
    final mimeType = lookupMimeType(picked.path) ?? 'image/png';
    final filename = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final api = ApiClient();
    final res = await api.post(
      '/recipes/image-upload-url',
      data: {'filename': filename, 'contentType': mimeType},
      options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
    );
    final uploadUrl = res.data['uploadUrl'];
    final objectKey = res.data['objectKey'];
    // Upload zum Storage
    final uploadRes = await Dio().put(
      uploadUrl,
      data: await picked.readAsBytes(),
      options: Options(headers: {'Content-Type': mimeType}),
    );
    if (uploadRes.statusCode == 200) {
      setState(() {
        imageUrl = objectKey;
        _uploadedImagePath = objectKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezept erstellen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titel'),
                onChanged: (v) => title = v,
                validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Portionen'),
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      onChanged: (v) => servings = int.tryParse(v) ?? 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Zeit (Minuten)'),
                      keyboardType: TextInputType.number,
                      initialValue: '10',
                      onChanged: (v) => readyInMinutes = int.tryParse(v) ?? 10,
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Kurzbeschreibung'),
                onChanged: (v) => summary = v,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Bild auswählen & hochladen'),
                    onPressed: isLoading ? null : _pickAndUploadImage,
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Image.file(_selectedImage!, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                  if (_uploadedImagePath != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check_circle, color: Colors.green),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Zutaten', style: Theme.of(context).textTheme.titleMedium),
              ...ingredients.map((ing) => ListTile(
                    title: Text('${ing['amount']} ${ing['unit']} ${ing['name']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() { ingredients.remove(ing); });
                      },
                    ),
                  )),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _ingredientNameController,
                      decoration: const InputDecoration(hintText: 'Name'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ingredientAmountController,
                      decoration: const InputDecoration(hintText: 'Menge'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ingredientUnitController,
                      decoration: const InputDecoration(hintText: 'Einheit'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      if (_ingredientNameController.text.isEmpty || _ingredientAmountController.text.isEmpty) return;
                      setState(() {
                        ingredients.add({
                          'name': _ingredientNameController.text,
                          'amount': double.tryParse(_ingredientAmountController.text) ?? 1,
                          'unit': _ingredientUnitController.text,
                        });
                        _ingredientNameController.clear();
                        _ingredientAmountController.clear();
                        _ingredientUnitController.clear();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Schritte', style: Theme.of(context).textTheme.titleMedium),
              ...steps.asMap().entries.map((entry) => ListTile(
                    title: Text(entry.value['description'] ?? ''),
                    subtitle: entry.value['durationMinutes'] != null && entry.value['durationMinutes'] > 0
                        ? Text('Dauer: ${entry.value['durationMinutes']} Min.')
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() { steps.removeAt(entry.key); });
                      },
                    ),
                  )),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _stepDescriptionController,
                      decoration: const InputDecoration(hintText: 'Beschreibung'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _stepDurationController,
                      decoration: const InputDecoration(hintText: 'Min.'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      if (_stepDescriptionController.text.isEmpty) return;
                      setState(() {
                        steps.add({
                          'description': _stepDescriptionController.text,
                          'durationMinutes': int.tryParse(_stepDurationController.text) ?? null,
                        });
                        _stepDescriptionController.clear();
                        _stepDurationController.clear();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Rezept anlegen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 