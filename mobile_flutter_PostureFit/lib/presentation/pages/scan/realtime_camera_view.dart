import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../controllers/scan_controller.dart';

class RealtimeCameraView extends StatefulWidget {
  const RealtimeCameraView({super.key});

  @override
  State<RealtimeCameraView> createState() => _RealtimeCameraViewState();
}

class _RealtimeCameraViewState extends State<RealtimeCameraView> {
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  bool _isDetecting = false;
  bool _isBusy = false;
  List<Pose> _poses = [];
  Size? _imageSize;
  InputImageRotation? _rotation;

  @override
  void initState() {
    super.initState();
    _initializeCameraAndDetector();
  }

  Future<void> _initializeCameraAndDetector() async {
    // 1. Initialize Pose Detector
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );

    // 2. Initialize Camera
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Select camera by current direction
      final selectedCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == _lensDirection,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      print("Camera initialized successfully: ${_cameraController!.value.previewSize}");
      if (!mounted) return;

      // Start Image Stream
      _cameraController!.startImageStream((CameraImage image) {
        if (_isBusy) return;
        _isBusy = true;
        _processImage(image, selectedCamera);
      });

      setState(() {});
    } catch (e) {
      Get.snackbar(
        'Error Kamera',
        'Gagal menginisialisasi kamera: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameraController == null) return;

    // Stop stream and dispose current controller
    await _cameraController!.stopImageStream();
    await _cameraController!.dispose();
    _cameraController = null;

    // Toggle direction
    setState(() {
      _lensDirection = _lensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      _poses = [];
    });

    // Reinitialize
    await _initializeCameraAndDetector();
  }

  Future<void> _processImage(CameraImage image, CameraDescription camera) async {
    if (_poseDetector == null) {
      print("Pose detector is null!");
      _isBusy = false;
      return;
    }

    final inputImage = _getInputImage(image, camera);
    if (inputImage == null) {
      _isBusy = false;
      return;
    }

    try {
      final poses = await _poseDetector!.processImage(inputImage);
      print("=== ML Kit Pose: Terdeteksi ${poses.length} orang ===");
      if (mounted) {
        setState(() {
          _poses = poses;
          _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          _rotation = inputImage.metadata?.rotation;
        });
      }
    } catch (e) {
      print('Error detecting pose: $e');
    } finally {
      _isBusy = false;
    }
  }

  InputImage? _getInputImage(CameraImage image, CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (rotation == null) {
      print("ML Kit Rotation null untuk sensorOrientation: $sensorOrientation");
      return null;
    }

    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormatValue.fromRawValue(image.format.raw as int);
    if (format == null) {
      print("ML Kit Format null untuk raw format: ${image.format.raw}");
      return null;
    }
    if (image.planes.isEmpty) {
      print("CameraImage planes kosong!");
      return null;
    }

    final Uint8List bytes;
    if (Platform.isAndroid) {
      // Mengubah format YUV420 bawaan kamera Android ke NV21 agar dipahami ML Kit native
      bytes = _yuv420ToNv21(image);
    } else {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      bytes = allBytes.done().buffer.asUint8List();
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: Platform.isAndroid ? image.width : image.planes[0].bytesPerRow,
      ),
    );
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final numPixels = width * height;
    final nv21 = Uint8List(numPixels + (numPixels ~/ 2));

    // Copy Y (luminance) secara berurutan tanpa padding
    final int yRowStride = yPlane.bytesPerRow;
    int idY = 0;
    for (int r = 0; r < height; r++) {
      final int start = r * yRowStride;
      nv21.setRange(idY, idY + width, yBuffer.sublist(start, start + width));
      idY += width;
    }

    // Interleave V and U (chrominance)
    int idUV = numPixels;
    final int uRowStride = uPlane.bytesPerRow;
    final int vRowStride = vPlane.bytesPerRow;
    final int uPixelStride = uPlane.bytesPerPixel ?? 1;
    final int vPixelStride = vPlane.bytesPerPixel ?? 1;

    for (int r = 0; r < height ~/ 2; r++) {
      for (int c = 0; c < width ~/ 2; c++) {
        final int uIdx = r * uRowStride + c * uPixelStride;
        final int vIdx = r * vRowStride + c * vPixelStride;

        if (vIdx < vBuffer.length) {
          nv21[idUV++] = vBuffer[vIdx];
        }
        if (uIdx < uBuffer.length) {
          nv21[idUV++] = uBuffer[uIdx];
        }
      }
    }

    return nv21;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      // 1. Stop stream to take high res picture
      await _cameraController!.stopImageStream();

      // 2. Take Picture
      final XFile photo = await _cameraController!.takePicture();
      final bytes = await photo.readAsBytes();

      // 3. Save to controller
      final scanController = Get.find<ScanController>();
      scanController.capturedBytes.value = bytes;
      scanController.capturedPath.value = photo.path;
      scanController.hasCapture.value = true;

      // 4. Navigate to result view
      Get.offNamed('/result');
    } catch (e) {
      Get.snackbar('Gagal Mengambil Gambar', e.toString());
      // Resume stream if failed
      _initializeCameraAndDetector();
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    // Hitung scale factor agar preview kamera menutupi seluruh layar tanpa gepeng (fit cover)
    final double cameraAspect = _cameraController!.value.aspectRatio;
    final double screenAspect = size.width / size.height;
    final double scale = 1 / (cameraAspect * screenAspect);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera preview (Diberi scale agar full screen dan tidak gepeng)
          ClipRect(
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),

          // 2. Live skeleton drawing overlay
          if (_poses.isNotEmpty && _imageSize != null && _rotation != null)
            CustomPaint(
              painter: PosePainter(
                _poses,
                _imageSize!,
                _rotation!,
                _lensDirection == CameraLensDirection.front,
              ),
            ),

          // 3. User instructions and controls overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleCamera,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  'Arahkan Seluruh Badan ke Kamera',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          // 4. Capture Button Area
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Center(
              child: _isDetecting
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        height: 76,
                        width: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;

  PosePainter(this.poses, this.imageSize, this.rotation, this.isFrontCamera);

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final paintLine = Paint()
      ..color = const Color(0xFF00FF00) // Hijau neon untuk tulang
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final paintCircle = Paint()
      ..color = const Color(0xFFFF0000) // Merah neon untuk sendi
      ..style = PaintingStyle.fill;

    // Deteksi rotasi kamera
    final bool isRotated = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double srcWidth = isRotated ? imageSize.height : imageSize.width;
    final double srcHeight = isRotated ? imageSize.width : imageSize.height;

    // Sesuaikan skala dengan pembingkaian Kamera (fit cover)
    final double scaleX = size.width / srcWidth;
    final double scaleY = size.height / srcHeight;
    final double scale = scaleX > scaleY ? scaleX : scaleY;

    // Hitung offset agar koordinat presisi di tengah layar
    final double offsetX = (size.width - srcWidth * scale) / 2;
    final double offsetY = (size.height - srcHeight * scale) / 2;

    for (final pose in poses) {
      Offset? getCoordinate(PoseLandmarkType type) {
        final landmark = pose.landmarks[type];
        if (landmark == null) return null;

        double x = landmark.x;
        double y = landmark.y;

        // ML Kit sudah mengembalikan koordinat yang otomatis terotasi (sesuai portrait).
        // Jadi kita tidak perlu memutar x dan y secara manual lagi.

        double finalX = x * scale + offsetX;
        double finalY = y * scale + offsetY;

        // Jika menggunakan kamera depan, cerminkan koordinat X agar tidak terbalik
        if (isFrontCamera) {
          finalX = size.width - finalX;
        }

        return Offset(finalX, finalY);
      }

      void drawConnection(PoseLandmarkType type1, PoseLandmarkType type2) {
        final p1 = getCoordinate(type1);
        final p2 = getCoordinate(type2);
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, paintLine);
        }
      }

      // --- BAGIAN WAJAH ---
      // Hidung ke mata kiri
      drawConnection(PoseLandmarkType.nose, PoseLandmarkType.leftEyeInner);
      drawConnection(PoseLandmarkType.leftEyeInner, PoseLandmarkType.leftEye);
      drawConnection(PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeOuter);
      drawConnection(PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEar);
      // Hidung ke mata kanan
      drawConnection(PoseLandmarkType.nose, PoseLandmarkType.rightEyeInner);
      drawConnection(PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye);
      drawConnection(PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter);
      drawConnection(PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar);
      // Mulut
      drawConnection(PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth);

      // --- BAGIAN BADAN UTAMA (TORSO) ---
      // Hubungkan bahu ke bahu, pinggul ke pinggul
      drawConnection(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      drawConnection(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
      // Hubungkan bahu ke pinggul (Torso / Badan)
      drawConnection(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      drawConnection(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);

      // --- BAGIAN TANGAN (LENGAN & JARI) ---
      // Tangan Kiri
      drawConnection(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      drawConnection(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      drawConnection(PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb);
      drawConnection(PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky);
      drawConnection(PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex);
      drawConnection(PoseLandmarkType.leftPinky, PoseLandmarkType.leftIndex);
      
      // Tangan Kanan
      drawConnection(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      drawConnection(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
      drawConnection(PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb);
      drawConnection(PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky);
      drawConnection(PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex);
      drawConnection(PoseLandmarkType.rightPinky, PoseLandmarkType.rightIndex);
      
      // --- BAGIAN KAKI (TUNGKAI & TELAPAK) ---
      // Kaki Kiri
      drawConnection(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      drawConnection(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      drawConnection(PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel);
      drawConnection(PoseLandmarkType.leftAnkle, PoseLandmarkType.leftFootIndex);
      drawConnection(PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex);
      
      // Kaki Kanan
      drawConnection(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      drawConnection(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
      drawConnection(PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel);
      drawConnection(PoseLandmarkType.rightAnkle, PoseLandmarkType.rightFootIndex);
      drawConnection(PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex);

      // Gambar titik sendi
      pose.landmarks.forEach((type, landmark) {
        final p = getCoordinate(type);
        if (p != null) {
          canvas.drawCircle(p, 6.0, paintCircle);
        }
      });
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.rotation != rotation ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}
