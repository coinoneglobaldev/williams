import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lasovrana/models/delivery_save_model.dart';

import '../../common/orientation_setup.dart';
import '../../constants.dart';
import '../../custom_screens/custom_network_error.dart';
import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_spinning_logo.dart';
import '../../custom_widgets/util_class.dart';
import '../../providers/connectivity_status_provider.dart';
import '../../services/api_services.dart';
import 'login.dart';

class ScreenRegistration extends ConsumerStatefulWidget {
  const ScreenRegistration({
    super.key,
  });

  @override
  ConsumerState<ScreenRegistration> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends ConsumerState<ScreenRegistration> {
  ApiServices apiServices = ApiServices();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isVisibility = false;
  bool _isButtonLoading = false;
  final _userNameKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _confirmPasswordKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    var connectivityStatusProvider = ref.watch(connectivityStatusProviders);
    if (connectivityStatusProvider == ConnectivityStatus.isConnected) {
      return OrientationSetup(
        child: Scaffold(
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              if (didPop) {
                return;
              }
              showDialog(
                barrierColor: Colors.black.withValues(alpha: 0.8),
                context: context,
                builder: (context) => const ScreenCustomExitConfirmation(),
              );
            },
            child: _mobileView(context),
          ),
        ),
      );
    } else {
      return const ScreenCustomNetworkError();
    }
  }

  Widget _mobileView(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/login_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('La',
                      style: TextStyle(
                          height: 0.9,
                          color: buttonColor,
                          fontSize: 50,
                          fontWeight: FontWeight.bold)),
                  Text('Sovrana',
                      style: TextStyle(
                          height: 0.9,
                          color: buttonColor,
                          fontSize: 50,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    ' Please register your account',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Form(
                  key: _userNameKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a valid username';
                      }
                      return null;
                    },
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.person, color: themeColor, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: _passwordKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    controller: _passwordController,
                    obscureText: !_isVisibility,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.lock, color: themeColor, size: 20),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _isVisibility = !_isVisibility;
                          });
                        },
                        child: Icon(
                          _isVisibility
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: themeColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: _confirmPasswordKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please re enter password';
                      }
                      return null;
                    },
                    controller: _confirmPasswordController,
                    obscureText: !_isVisibility,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.lock, color: themeColor, size: 20),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _isVisibility = !_isVisibility;
                          });
                        },
                        child: Icon(
                            _isVisibility
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: themeColor,
                            size: 20),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('  Already have an account?',
                        style: TextStyle(color: Colors.black)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const ScreenLogin(),
                          ),
                        );
                      },
                      child:
                          Text('Login', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  ),
                  onPressed: () async {
                    if (!(_userNameKey.currentState?.validate() ?? false) ||
                        !(_passwordKey.currentState?.validate() ?? false) ||
                        !(_confirmPasswordKey.currentState?.validate() ??
                            false)) {
                      return;
                    }
                    if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      Util.customErrorSnackBar(
                        context,
                        "Password and Confirm Password do not match.",
                      );
                      return;
                    }
                    setState(() {
                      _isButtonLoading = true;
                    });
                    try {
                      CommonResponseModel response =
                          await apiServices.fnRegisterDriver(
                        prmName: _usernameController.text,
                        prmCode: '',
                        prmEmail: '',
                        prmPassword: _passwordController.text,
                      );
                      if (!context.mounted) return;
                      if (response.data == 'Record Inserted Successfully') {
                        Util.customSuccessSnackBar(
                          context,
                          "Registration Successful\nPlease login to continue",
                        );
                      } else {
                        Util.customErrorSnackBar(
                          context,
                          "Error: ${response.data}",
                        );
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('Registration error: $e');
                      }
                      if (!context.mounted) return;
                      Util.customErrorSnackBar(
                        context,
                        "An error occurred during registration. Please try again.",
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isButtonLoading = false;
                        });
                      }
                    }
                  },
                  child: _isButtonLoading
                      ? const CustomLogoSpinner(oneSize: 10, roundSize: 30)
                      : const Text(
                          'Register',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
