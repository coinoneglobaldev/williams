import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:williams/models/delivery_save_model.dart';
import 'package:williams/services/api_services.dart';
import '../../constants.dart';
import '../../custom_widgets/custom_scaffold_driver.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/daily_drop_list_model.dart';

class DeliveryUploadScreen extends StatefulWidget {
  final DailyDropListModel deliveryItem;

  const DeliveryUploadScreen({
    super.key,
    required this.deliveryItem,
  });

  @override
  State<DeliveryUploadScreen> createState() => _DeliveryUploadScreenState();
}

class _DeliveryUploadScreenState extends State<DeliveryUploadScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  ApiServices apiServices = ApiServices();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fnCheckLocationEmptyOrNot();
    });
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _image = File(photo.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error taking photo: $e");
      }
      if (!mounted) return;
      Util.customErrorSnackBar(context, "Failed to take photo");
    }
  }

  void _fnCheckLocationEmptyOrNot() {
    if (!mounted) return;
    if (widget.deliveryItem.latitude.isEmpty ||
        widget.deliveryItem.longitude.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location not found'),
          content: const Text('Please update the customer location.'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await updateCustomerLocation();
                } catch (e) {
                  if (!context.mounted) return;
                  Util.customErrorSnackBar(
                    context,
                    "Failed to update location.\n(${e.toString()})",
                  );
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  Future<CommonResponseModel> uploadDeliveryPhoto() async {
    if (_image == null) {
      Util.customErrorSnackBar(context, "Please take a photo first!");
      throw Exception("No photo selected");
    }

    setState(() {
      isUploading = true;
    });

    try {
      final result = await apiServices.fnSaveDeliveryDetails(
        prmAutoId: widget.deliveryItem.autoId,
        prmId: widget.deliveryItem.id,
        prmDeliveryImage: '', //todo: upload image
        prmDeliveryRemarks: 'remarks',
        prmCmpId: widget.deliveryItem.companyId,
        prmBrId: widget.deliveryItem.branchId,
        prmFaId: widget.deliveryItem.faId,
        prmUId: widget.deliveryItem.userId,
      );
      if (!mounted) return result;
      if (result.message == "Success") {
        Util.customSuccessSnackBar(context, "Photo uploaded successfully!");
        Navigator.pop(context);
        return result;
      } else {
        throw Exception("Upload failed: ${result.message}");
      }
    } catch (e) {
      if (!mounted) rethrow;
      Util.customErrorSnackBar(
        context,
        "Failed to upload photo.\n(${e.toString()})",
      );
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<CommonResponseModel> updateCustomerLocation() async {
    try {
      final result = await apiServices.fnUpdateCustomerLocation(
        prmAccId: widget.deliveryItem.crId, //todo: check if this is the correct field
        prmLatitude: '',
        prmLongitude: '',
      );
      if (!mounted) return result;
      if (result.message == "Success") {
        Util.customSuccessSnackBar(context, "Location updated successfully!");
        Navigator.pop(context);
        return result;
      } else {
        throw Exception("update location failed: ${result.message}");
      }
    } catch (e) {
      Util.customErrorSnackBar(
        context,
        "Failed to updated location.\n(${e.toString()})",
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldDriver(
      title: 'Delivery Upload',
      bodyWidget: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade200,
                        Colors.blue.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _takePhoto,
                      child: Center(
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 80,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Tap to Capture',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    uploadDeliveryPhoto();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.cloud_upload),
                      SizedBox(width: 10),
                      Text(
                        'Upload Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_image == null)
                  Text(
                    'Complete your delivery and capture proof of delivery',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
