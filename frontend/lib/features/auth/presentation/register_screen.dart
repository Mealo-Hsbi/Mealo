import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _repo = AuthRepository();
  final _firstNameCtrl   = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool   _loading = false;
  String? _error;

  Future<void> _register() async {
    final firstName = _firstNameCtrl.text.trim();
    final email     = _emailCtrl.text.trim();
    final pass      = _passCtrl.text;
    final confirm   = _confirmPassCtrl.text;

    if (firstName.isEmpty) {
      setState(() => _error = 'Bitte gib deinen Vornamen ein');
      return;
    }
    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Bitte alle Felder ausfüllen');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwörter stimmen nicht überein');
      return;
    }

    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      // 1) Registrierung via Firebase
      await _repo.signUp(email: email, password: pass);

      // 2) DisplayName auf Vornamen setzen
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(firstName);
        await user.reload();

        // 3) User-Record in eigener DB anlegen
        await _repo.createUserInDb(
          name: firstName,
          avatarUrl: user.photoURL,
        );
      }

      // 4) Zurück zum Login
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  height: 140,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Create your account",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: _firstNameCtrl,
                decoration: InputDecoration(
                  hintText: 'Vorname',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Passwort',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Passwort bestätigen',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const Spacer(flex: 3),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already a member? ',
                      style: const TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
