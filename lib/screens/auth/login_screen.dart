import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cyber_background.dart';
import '../../widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  final _idController = TextEditingController(text: 'SU-2026-8942');
  final _nameController = TextEditingController(text: 'Alex Mercer');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.login(_nameController.text, _idController.text);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      body: CyberBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Futuristic Graphic
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.neonGlowDecoration(
                    color: AppTheme.cyanPrimary,
                    borderRadius: 24,
                    isDark: isDark,
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: AppTheme.cyanPrimary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SMART VENUE',
                  style: TextStyle(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.cyanPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'AI INDOOR POSITIONING & TIMETABLE IPS',
                      style: TextStyle(
                        color: AppTheme.cyanPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Card Container with Glassmorphism
                GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Toggle Sign In vs Register
                      Container(
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.darkBg : AppTheme.lightCard).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isSignUp
                                        ? AppTheme.cyanPrimary.withValues(alpha: 0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: !_isSignUp
                                        ? Border.all(color: AppTheme.cyanPrimary.withValues(alpha: 0.5))
                                        : null,
                                  ),
                                  child: Text(
                                    'SIGN IN',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: !_isSignUp ? AppTheme.cyanPrimary : AppTheme.textMuted(isDark),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isSignUp
                                        ? AppTheme.purpleAccent.withValues(alpha: 0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: _isSignUp
                                        ? Border.all(color: AppTheme.purpleAccent.withValues(alpha: 0.5))
                                        : null,
                                  ),
                                  child: Text(
                                    'REGISTER',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _isSignUp ? AppTheme.purpleAccent : AppTheme.textMuted(isDark),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Fields
                      if (_isSignUp) ...[
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: AppTheme.textPrimary(isDark)),
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.cyanPrimary),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _idController,
                        style: TextStyle(color: AppTheme.textPrimary(isDark)),
                        decoration: const InputDecoration(
                          labelText: 'Student ID / Campus Email',
                          prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.cyanPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: AppTheme.textPrimary(isDark)),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.cyanPrimary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppTheme.textMuted(isDark),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSignUp ? AppTheme.purpleAccent : AppTheme.cyanPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: (_isSignUp ? AppTheme.purpleAccent : AppTheme.cyanPrimary).withValues(alpha: 0.4),
                          ),
                          child: Text(
                            _isSignUp ? 'CREATE CAMPUS PASS' : 'AUTHENTICATE',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Biometric Fast Auth Shortcut
                      OutlinedButton.icon(
                        onPressed: _handleAuth,
                        icon: const Icon(Icons.fingerprint_rounded, color: AppTheme.cyanPrimary),
                        label: const Text(
                          'Biometric Fast Key',
                          style: TextStyle(color: AppTheme.cyanPrimary, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.cyanPrimary.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Guest Mode Button
                TextButton(
                  onPressed: () {
                    final appState = Provider.of<AppState>(context, listen: false);
                    appState.login('Guest Student', 'GUEST-9900');
                  },
                  child: Text(
                    'Explore in Guest Campus Mode →',
                    style: TextStyle(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 13,
                      decoration: TextDecoration.underline,
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
