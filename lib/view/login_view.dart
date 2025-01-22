import 'package:efeone_mobile/controllers/login.dart';
import 'package:efeone_mobile/view/forgetpwd_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  bool isLoggingIn = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedEmail = prefs.getString('usr');
    String? savedPassword = prefs.getString('pwd');

    if (savedEmail != null) {
      emailController.text = savedEmail;
    }

    if (savedPassword != null) {
      passwordController.text = savedPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Provider.of<LoginController>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1, vertical: size.height * 0.1),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Image with Container
                    Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 30,
                          maxWidth: size.width * 0.5,
                        ),
                        child: Image.asset(
                          'assets/images/efeone Logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    // Email Field
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          // Email validation
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email,
                              color: Color.fromARGB(255, 6, 79, 138)),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        style: TextStyle(fontSize: size.height * 0.018),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Password Field
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          // Password validation
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        controller: passwordController,
                        obscureText: !loginController.isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock,
                              color: Color.fromARGB(255, 6, 79, 138)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              loginController.isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              loginController.isPasswordVisible =
                                  !loginController.isPasswordVisible;
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                        ),
                        style: TextStyle(fontSize: size.height * 0.018),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    // Login Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          loginController.setVerifying(true);
                          await loginController.connectioncheck(context);
                          await loginController.postLoginDetails(
                            emailController.text,
                            passwordController.text,
                            context,
                          );
                          loginController.setVerifying(false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 6, 79, 138),
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        loginController.buttonText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.height * 0.02,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    // Forgot Password Section
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: size.height * 0.02,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
