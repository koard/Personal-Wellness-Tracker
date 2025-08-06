import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../main.dart' show cameras;
import 'recognition/recognition_screen.dart';
import '../../widgets/shared/capsule_notification.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      CapsuleNotificationHelper.showError(
        context,
        message: 'No cameras available on this device',
      );
      return;
    }

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        CapsuleNotificationHelper.showError(
          context,
          message: 'Camera initialization failed',
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Use application documents directory for permanent storage
      final directory = await getApplicationDocumentsDirectory();
      final mealsDir = path.join(directory.path, 'meals');
      
      // Create meals directory if it doesn't exist
      await Directory(mealsDir).create(recursive: true);
      
      final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(mealsDir, fileName);

      final image = await _controller!.takePicture();
      
      // Copy the image to our desired location
      await image.saveTo(filePath);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecognitionScreen(imagePath: filePath),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        CapsuleNotificationHelper.showError(
          context,
          message: 'Failed to take picture. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Take a Photo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),
                
                // Overlay with capture button
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isCapturing ? null : _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCapturing 
                              ? Colors.grey 
                              : Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: _isCapturing
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 32,
                              ),
                      ),
                    ),
                  ),
                ),
                
                // Instructions
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Position your meal in the center and tap the capture button',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
