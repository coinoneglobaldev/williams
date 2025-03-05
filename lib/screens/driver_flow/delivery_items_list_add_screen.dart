import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import '../../custom_widgets/custom_logout_button.dart';

class DeliveryItemsListAddScreen extends StatefulWidget {
  const DeliveryItemsListAddScreen({super.key});

  @override
  State<DeliveryItemsListAddScreen> createState() =>
      _DeliveryItemsListAddScreenState();
}

class _DeliveryItemsListAddScreenState
    extends State<DeliveryItemsListAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final Uri url =
      Uri.parse('https://flowares.com/index.php/home/accountdeletion');
  bool isAddressValid = true;
  TextEditingController itemController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController itemAmountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                        ),
                      ),
                      Text(
                        'Delivery Items Add',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const CustomLogoutConfirmation(),
                          );
                        },
                        child: Text('Logout'),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          if (!await launchUrl(url)) {
                            if (kDebugMode) {
                              print('Could not launch $url');
                            }
                          }
                        },
                        child: Text('Account Deletion'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: itemController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter delivery items';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Customer Name',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: itemQuantityController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item count';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Item Count',
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      const Spacer(),
                      Text('Address'),
                      Radio(
                          value: true,
                          groupValue: isAddressValid,
                          onChanged: (bool? value) {
                            setState(() {
                              isAddressValid = value!;
                            });
                          }),
                      const Spacer(),
                      Text('Location'),
                      Radio(
                          value: false,
                          groupValue: isAddressValid,
                          onChanged: (bool? value) {
                            setState(() {
                              isAddressValid = value!;
                            });
                          }),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (isAddressValid)
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                      controller: addressController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Address',
                      ),
                    ),
                  if (!isAddressValid)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter latitude';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            controller: latitudeController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Latitude',
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter longitude';
                              }
                              return null;
                            },
                            controller: longitudeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Longitude',
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: itemAmountController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Amount',
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (kDebugMode) {
                            print('isAddressValid: $isAddressValid');
                          }
                        }
                      },
                      child: Text('Submit'))
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
