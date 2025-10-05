import 'package:calorie_wise/features/results/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late List<CameraDescription> _cameras;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    return _controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
      setState(() {
        _initializeControllerFuture = _controller.initialize();
      });
    }
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      if (!mounted) return;
      _navigateToResults(image.path);
    } catch (e) {
      print(e);
    }
  }

  void _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _navigateToResults(pickedFile.path);
    }
  }

  void _navigateToResults(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                _buildControls(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(30.0),
        color: Colors.black.withOpacity(0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: _pickImageFromGallery,
              icon: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 3),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                final newCameraIndex =
                    (_cameras.indexOf(_controller.description) + 1) %
                        _cameras.length;
                _controller = CameraController(
                  _cameras[newCameraIndex],
                  ResolutionPreset.high,
                  enableAudio: false,
                );
                setState(() {
                  _initializeControllerFuture = _controller.initialize();
                });
              },
              icon: const Icon(
                Icons.flip_camera_ios_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
