import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registrasi gagal: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  if (!value.contains('@')) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password tidak boleh kosong";
                  }
                  if (value.length < 6) {
                    return "Password minimal 6 karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: register, child: const Text("Register")),
            ],
          ),
        ),
      ),
    );
  }
}
