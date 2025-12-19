import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/themes/color_palette.dart';

class LoginPageScreen extends StatefulWidget {
  const LoginPageScreen({super.key});

  @override
  State<LoginPageScreen> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPageScreen> {
  final _formKey = GlobalKey<FormState>();
  String? username, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.darkBackground,
      appBar: AppBar(
        backgroundColor: ColorPallete.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Login',
          style: TextStyle(
            color: ColorPallete.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // USERNAME
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: ColorPallete.accent,
                    ),
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: ColorPallete.accent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: ColorPallete.accent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: ColorPallete.accent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter username' : null,
                  onSaved: (value) => username = value,
                ),
                const SizedBox(height: 24),
                // PASSWORD
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: ColorPallete.accent,
                    ),
                    labelText: 'Šifra',
                    labelStyle: const TextStyle(color: ColorPallete.accent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: ColorPallete.accent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: ColorPallete.accent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Unesi šifru' : null,
                  onSaved: (value) => password = value,
                ),
                const SizedBox(height: 32),
                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // TODO: Ovdje pozovi login funkciju, API, provjeru...
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login...')),
                        );
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: ColorPallete.darkBackground,
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
      ),
    );
  }
}
