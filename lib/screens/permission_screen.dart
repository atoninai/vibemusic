import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionScreen({super.key, required this.onComplete});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final PermissionService _permService = PermissionService();
  bool _storageGranted = false;
  bool _overlayGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final perms = await _permService.checkAllPermissions();
    setState(() {
      _storageGranted = perms['storage'] ?? false;
      _overlayGranted = perms['overlay'] ?? false;
    });
  }

  Future<void> _requestStorage() async {
    final granted = await _permService.requestStoragePermission();
    setState(() {
      _storageGranted = granted;
    });
  }

  Future<void> _requestOverlay() async {
    await _permService.requestOverlayPermission();
    // Re-check after returning from settings
    await Future.delayed(const Duration(milliseconds: 500));
    final isGranted = await _permService.hasOverlayPermission();
    setState(() {
      _overlayGranted = isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // App Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(77),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.music_note, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Vibeland',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We need a few permissions to access your music and provide the best experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withAlpha(153),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Storage Permission Card
              _PermissionCard(
                icon: Icons.folder_outlined,
                title: 'Storage Access',
                description: 'Access your local music files to play them',
                isGranted: _storageGranted,
                onRequest: _requestStorage,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Overlay Permission Card
              _PermissionCard(
                icon: Icons.layers_outlined,
                title: 'Screen Overlay',
                description: 'Show Dynamic Island over other apps',
                isGranted: _overlayGranted,
                onRequest: _requestOverlay,
                isRequired: false,
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _storageGranted ? widget.onComplete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.primary.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _storageGranted ? 'Continue' : 'Grant Storage to Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _storageGranted ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!_storageGranted)
                Text(
                  'Storage access is required to use Vibeland',
                  style: TextStyle(
                    color: Colors.white.withAlpha(102),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;
  final bool isRequired;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? Colors.green.withAlpha(77)
              : const Color(0x14FFFFFF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isGranted
                  ? Colors.green.withAlpha(40)
                  : AppTheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGranted ? Icons.check_circle : icon,
              color: isGranted ? Colors.green : AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: onRequest,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
