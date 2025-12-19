import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/themes/color_palette.dart';

class RegisterPageScreen extends StatefulWidget {
  const RegisterPageScreen({super.key});

  @override
  State<RegisterPageScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<RegisterPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.darkBackground,
      appBar: AppBar(
        backgroundColor: ColorPallete.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Register',
          style: TextStyle(
            color: ColorPallete.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Form(
          // key: _formKey,
          child: Column(
            children: [
              // Dugme za sliku
              GestureDetector(
                // onTap: _pickImage,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: ColorPallete.accent,
                  // backgroundImage: profileImage,
                  // child: profileImage == null
                  //     ? const Icon(
                  //         Icons.camera_alt,
                  //         size: 36,
                  //         color: ColorPallete.darkBackground,
                  //       )
                  //     : null,
                ),
              ),
              const SizedBox(height: 22),
              // --- POLJA ---
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: ColorPallete.accent,
                  ),
                  labelText: 'First name',
                  labelStyle: TextStyle(color: ColorPallete.accent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorPallete.accent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPallete.accent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter first name' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: ColorPallete.accent,
                  ),
                  labelText: 'Last name',
                  labelStyle: TextStyle(color: ColorPallete.accent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorPallete.accent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPallete.accent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter last name' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.face, color: ColorPallete.accent),
                  labelText: 'Nickname',
                  labelStyle: TextStyle(color: ColorPallete.accent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorPallete.accent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPallete.accent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter nickname' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: ColorPallete.accent,
                  ),
                  labelText: 'Hotmail',
                  labelStyle: TextStyle(color: ColorPallete.accent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorPallete.accent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPallete.accent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty || !v.contains('@')
                    ? 'Enter valid email (Hotmail)'
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: ColorPallete.accent,
                  ),
                  labelText: 'Šifra',
                  labelStyle: TextStyle(color: ColorPallete.accent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorPallete.accent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPallete.accent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 5 ? 'Min 5 karaktera' : null,
              ),

              const SizedBox(height: 28),

              // --- DUGME REGISTER ---
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
                  onPressed: () {},
                  child: const Text(
                    'Register',
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
    );
  }
}
