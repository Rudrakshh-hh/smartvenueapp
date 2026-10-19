import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _aiPredictiveRouting = true;
  bool _congestionAlerts = true;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.badge_rounded, color: AppTheme.cyan(isDark), size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STUDENT DIGITAL ID',
                    style: TextStyle(
                      color: AppTheme.cyan(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Campus Profile & IPS',
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // HOLOGRAM DIGITAL CAMPUS PASS CARD
          GlassContainer(
            borderRadius: 24,
            borderColor: AppTheme.cyan(isDark),
            gradientColors: [
              AppTheme.cyan(isDark).withValues(alpha: isDark ? 0.15 : 0.12),
              AppTheme.purple(isDark).withValues(alpha: isDark ? 0.12 : 0.1),
              (isDark ? AppTheme.darkCard : AppTheme.lightSurface).withValues(
                alpha: 0.85,
              ),
            ],
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          color: AppTheme.cyan(isDark),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appState.userDepartment.toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.cyan(isDark),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.nfc_rounded,
                      color: AppTheme.purple(isDark),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.cyan(isDark)
                          .withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppTheme.cyan(isDark),
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.userName,
                          style: TextStyle(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${appState.studentId}',
                          style: TextStyle(
                            color: AppTheme.cyan(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Status: Active Scholar',
                          style: TextStyle(
                            color: AppTheme.textMuted(isDark),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: (isDark ? Colors.white12 : Colors.black12),
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Simulated QR Barcode
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCESS CLEARANCE',
                          style: TextStyle(
                            color: AppTheme.textMuted(isDark),
                            fontSize: 9.5,
                          ),
                        ),
                        Text(
                          'LEVEL 1 - 3 ALL BLOCKS',
                          style: TextStyle(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : AppTheme.darkBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: isDark ? Colors.black : Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // HYBRID IPS SENSOR HARDWARE DIAGNOSTICS
          Text(
            'HYBRID IPS HARDWARE DIAGNOSTICS',
            style: TextStyle(
              color: AppTheme.cyan(isDark),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSensorRow(
                  icon: Icons.bluetooth_searching_rounded,
                  color: AppTheme.cyan(isDark),
                  title: 'BLE 5.0 Beacon Anchor',
                  subtitle: appState.activeBleAnchor,
                  statusText: 'CONNECTED',
                  isDark: isDark,
                ),
                Divider(
                  color: (isDark ? Colors.white10 : Colors.black12),
                  height: 20,
                ),
                _buildSensorRow(
                  icon: Icons.directions_walk_rounded,
                  color: AppTheme.purple(isDark),
                  title: 'Kinematic PDR (Accel + Gyro)',
                  subtitle:
                      '${appState.pdrStepCounter} steps detected (Kalman Filtered)',
                  statusText: 'CALIBRATED',
                  isDark: isDark,
                ),
                Divider(
                  color: (isDark ? Colors.white10 : Colors.black12),
                  height: 20,
                ),
                _buildSensorRow(
                  icon: Icons.camera_front_rounded,
                  color: AppTheme.blue(isDark),
                  title: 'OpenCV ArUco Vision Engine',
                  subtitle: 'Last scan 8m ago (Square Fiducial Pose Locked)',
                  statusText: 'READY',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      appState.triggerArUcoRecalibration();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'ArUco Camera Vision Scan Triggered! Position Rectified.',
                          ),
                          backgroundColor: AppTheme.cyanPrimary,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppTheme.cyan(isDark),
                      size: 18,
                    ),
                    label: Text(
                      'RECALIBRATE POSITION WITH ARUCO SCAN',
                      style: TextStyle(
                        color: AppTheme.cyan(isDark),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.cyan(isDark)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // PREFERENCES & TOGGLES
          Text(
            'SYSTEM PREFERENCES',
            style: TextStyle(
              color: AppTheme.cyan(isDark),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Theme Toggle Switch
                SwitchListTile(
                  value: !isDark,
                  activeThumbColor: AppTheme.cyan(isDark),
                  onChanged: (val) => appState.toggleTheme(),
                  title: Text(
                    'White theme',
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isDark
                        ? 'Currently on Dark Cyber Theme'
                        : 'Currently on White Theme',
                    style: TextStyle(
                      color: AppTheme.textMuted(isDark),
                      fontSize: 11,
                    ),
                  ),
                  secondary: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    color: isDark
                        ? AppTheme.purple(isDark)
                        : AppTheme.amber(isDark),
                  ),
                ),
                Divider(
                  color: (isDark ? Colors.white10 : Colors.black12),
                  height: 1,
                ),
                SwitchListTile(
                  value: _aiPredictiveRouting,
                  activeThumbColor: AppTheme.cyan(isDark),
                  onChanged: (val) =>
                      setState(() => _aiPredictiveRouting = val),
                  title: Text(
                    'AI Predictive Routing',
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Auto-calculates shortest path using D* Lite',
                    style: TextStyle(
                      color: AppTheme.textMuted(isDark),
                      fontSize: 11,
                    ),
                  ),
                ),
                Divider(
                  color: (isDark ? Colors.white10 : Colors.black12),
                  height: 1,
                ),
                SwitchListTile(
                  value: _congestionAlerts,
                  activeThumbColor: AppTheme.cyan(isDark),
                  onChanged: (val) => setState(() => _congestionAlerts = val),
                  title: Text(
                    'Hallway Congestion Alerts',
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Reroute around busy corridors',
                    style: TextStyle(
                      color: AppTheme.textMuted(isDark),
                      fontSize: 11,
                    ),
                  ),
                ),
                Divider(
                  color: (isDark ? Colors.white10 : Colors.black12),
                  height: 1,
                ),
                SwitchListTile(
                  value: _biometricEnabled,
                  activeThumbColor: AppTheme.cyan(isDark),
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                  title: Text(
                    'Biometric Fast Auth',
                    style: TextStyle(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Use FaceID/Fingerprint for sign in',
                    style: TextStyle(
                      color: AppTheme.textMuted(isDark),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // LOG OUT BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => appState.logout(),
              icon: const Icon(
                Icons.logout_rounded,
                color: AppTheme.roseAlert,
                size: 18,
              ),
              label: const Text(
                'LOG OUT',
                style: TextStyle(
                  color: AppTheme.roseAlert,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.roseAlert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSensorRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String statusText,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textMuted(isDark),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
