import 'package:auth_frontend/core/helpers/navigation.dart';
import 'package:auth_frontend/features/auth/presentation/pages/home_page.dart';
import 'package:auth_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthMode { login, signup }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  AuthMode _mode = AuthMode.login;

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final hobbyController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    hobbyController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      if (_mode == AuthMode.login) {
        await ref
            .read(authProvider.notifier)
            .login(
              email: emailController.text,
              password: passwordController.text,
            );
      } else {
        await ref
            .read(authProvider.notifier)
            .signup(
              email: emailController.text,
              hobby: hobbyController.text,
              username: usernameController.text,
              password: passwordController.text,
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mode == AuthMode.login
                ? 'Login successfull'
                : 'Signup successfull',
          ),
        ),
      );

      AppNavigator.pushReplacement(context, const HomePage());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Icon(
                      Icons.lock_outline_rounded,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _mode == AuthMode.login
                          ? "Welcome Back"
                          : "Create Account",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _mode == AuthMode.login
                          ? "Login to continue"
                          : "Let's get you started",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 32),

                    CupertinoSlidingSegmentedControl<AuthMode>(
                      groupValue: _mode,
                      children: const {
                        AuthMode.login: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text("Login"),
                        ),
                        AuthMode.signup: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text("Sign Up"),
                        ),
                      },
                      onValueChanged: (value) {
                        if (value != null) {
                          setState(() => _mode = value);
                        }
                      },
                    ),

                    const SizedBox(height: 30),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          _Input(
                            controller: emailController,
                            hint: "Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Enter email";
                              }
                              return null;
                            },
                          ),

                          if (_mode == AuthMode.signup) ...[
                            const SizedBox(height: 16),

                            _Input(
                              controller: usernameController,
                              hint: "Username",
                              icon: Icons.person_outline,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Enter username";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            _Input(
                              controller: hobbyController,
                              hint: "Hobby",
                              icon: Icons.favorite_outline,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Enter hobby";
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscure,
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return "Minimum 6 characters";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => obscure = !obscure);
                                },
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: .75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: loading ? null : submit,
                          child: loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _mode == AuthMode.login
                                      ? "Login"
                                      : "Create Account",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          _mode = _mode == AuthMode.login
                              ? AuthMode.signup
                              : AuthMode.login;
                        });
                      },
                      child: Text(
                        _mode == AuthMode.login
                            ? "Don't have an account? Sign Up"
                            : "Already have an account? Login",
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

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _Input({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
    );
  }
}
