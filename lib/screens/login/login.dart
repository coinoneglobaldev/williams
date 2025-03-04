import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/orientation_setup.dart';
import '../../common/responsive.dart';
import '../../constants.dart';
import '../../custom_screens/custom_network_error.dart';
import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_spinning_logo.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/login_model.dart';
import '../../providers/connectivity_status_provider.dart';
import '../../services/api_services.dart';
import '../buying_flow/buying_sheet_screen.dart';
import '../driver_flow/delivery_items_list_screen.dart';
import '../packing_flow/sales_order_list.dart';
import 'registration.dart';

class ScreenLogin extends ConsumerStatefulWidget {
  const ScreenLogin({
    super.key,
  });

  @override
  ConsumerState<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends ConsumerState<ScreenLogin> {
  ApiServices apiServices = ApiServices();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRememberMe = true;
  bool _isVisibility = false;
  bool _isButtonLoading = false;
  final _userNameKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData(LoginModel loginData) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final userData = loginData.data[0];
    await Future.wait([
      pref.setString('userId', userData.id.toString()),
      pref.setString('groupId', userData.grpid.toString()),
      pref.setString('userIuserImage', userData.usrImage.toString()),
      pref.setString('cmpId', userData.cmpId.toString()),
      pref.setString('brId', userData.brid.toString()),
      pref.setString('faId', userData.faid.toString()),
      pref.setString('appPageName', userData.appPageName.toString()),
      pref.setString('accId', userData.staffId.toString()),
      pref.setString('isAdmin', userData.isAdmin.toString()),
      pref.setString('designId', userData.desgId.toString()),
      pref.setString('userType', userData.userType.toString()),
      pref.setString('userName', _usernameController.text.trim()),
      pref.setString('password', _passwordController.text.trim()),
      pref.setBool('isRememberMe', _isRememberMe),
    ]);
    if (kDebugMode) {
      print("cmpId:${pref.getString('cmpId')}");
      print("brId:${pref.getString('brId')}");
      print("faId:${pref.getString('faId')}");
      print("userId:${pref.getString('userId')}");
      print("accId:${pref.getString('accId')}");
      print("userType:${pref.getString('userType')}");
      print("userName:${pref.getString('userName')}");
      print("password:${pref.getString('password')}");
      print("isRememberMe:${pref.getBool('isRememberMe')}");
    }
  }

  void _navigateToBackground(String userType) {
    switch (userType) {
      case 'BSHT':
        _fnNavigateToBuyerPage();
        break;
      case 'PACK':
        _fnNavigateToPackingPage();
        break;
      case 'DRVR':
        _fnNavigateToDriverPage();
        break;
      default:
        _fnNavigateToLoginPage();
    }
  }

  _fnNavigateToPackingPage() {
    // Set landscape orientation for admin
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const SalesOrderList(),
      ),
    );
  }

  _fnNavigateToBuyerPage() {
    // Set landscape orientation for buyer
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const BuyingSheetScreen(),
      ),
    );
  }

  _fnNavigateToDriverPage() async {
    // Set portrait orientation for driver
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('userName')!;
    final String accId = prefs.getString('accId')!;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => DeliveryItemsListScreen(
          name: userName,
          dNo: accId,
        ),
      ),
    );
  }

  _fnNavigateToLoginPage() {
    // Set portrait orientation for driver
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const ScreenLogin(),
      ),
    );
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
            child: Responsive(
              mobile: _mobileView(context),
              tablet: _tabletView(context),
            ),
          ),
        ),
      );
    } else {
      return const ScreenCustomNetworkError();
    }
  }

  Widget _mobileView(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: const AssetImage('assets/images/login_background.jpg'),
          fit: BoxFit.cover,
        )),
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
                    Text(
                      'La',
                      style: TextStyle(
                        height: 0.9,
                        color: buttonColor,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SovranaX',
                      style: TextStyle(
                        height: 0.9,
                        color: buttonColor,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      ' Enter your login details',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: themeColor,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: themeColor,
                            width: 1,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: themeColor,
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        hintText: 'Username',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: themeColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: themeColor,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: themeColor,
                            width: 1,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: themeColor,
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: themeColor,
                          size: 20,
                        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isRememberMe,
                        onChanged: (value) {
                          setState(() {
                            _isRememberMe = value!;
                          });
                        },
                        activeColor: Colors.black,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      Text('Don\'t have an account?',
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 12,
                          )),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const ScreenRegistration(),
                            ),
                          );
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () async {
                      if (!_userNameKey.currentState!.validate() ||
                          !_passwordKey.currentState!.validate()) {
                        return;
                      }
                      setState(() {
                        _isButtonLoading = true;
                      });
                      try {
                        LoginModel loginData = await apiServices.getUserLogIn(
                          prmUsername: _usernameController.text.trim(),
                          prmPassword: _passwordController.text.trim(),
                          prmMacAddress: '',
                          prmIpAddress: '',
                          prmLat: '',
                          prmLong: '',
                          prmAppType: '',
                        );
                        if (!mounted) return;
                        if (loginData.errorCode == 0) {
                          await _saveUserData(loginData);
                          _navigateToBackground(loginData.data[0].userType);
                        } else {
                          if (!context.mounted) return;
                          Util.customErrorSnackBar(
                            context,
                            "Error: ${loginData.message}",
                          );
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('Login error: $e');
                        }
                        if (!context.mounted) return;
                        Util.customErrorSnackBar(
                          context,
                          "An error occurred during login. Please try again.",
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
                        ? const CustomLogoSpinner(
                            oneSize: 10,
                            roundSize: 30,
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabletView(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Logo and Company Name
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'La',
                      style: TextStyle(
                        height: 0.9,
                        color: buttonColor,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sovrana',
                      style: TextStyle(
                        height: 0.9,
                        color: buttonColor,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side - Login Form
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Enter your login details',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: themeColor,
                                size: 20,
                              ),
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
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: themeColor,
                                size: 20,
                              ),
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
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Don\'t have an account?',
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: 12,
                                  )),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          const ScreenRegistration(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ]),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          onPressed: () async {
                            if (!_userNameKey.currentState!.validate() ||
                                !_passwordKey.currentState!.validate()) {
                              return;
                            }
                            setState(() {
                              _isButtonLoading = true;
                            });
                            try {
                              LoginModel loginData =
                                  await apiServices.getUserLogIn(
                                prmUsername: _usernameController.text.trim(),
                                prmPassword: _passwordController.text.trim(),
                                prmMacAddress: '',
                                prmIpAddress: '',
                                prmLat: '',
                                prmLong: '',
                                prmAppType: '',
                              );
                              if (!mounted) return;
                              if (loginData.errorCode == 0) {
                                await _saveUserData(loginData);
                                _navigateToBackground(
                                    loginData.data[0].userType);
                              } else {
                                if (!context.mounted) return;
                                Util.customErrorSnackBar(
                                  context,
                                  "Error: ${loginData.message}",
                                );
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print('Login error: $e');
                              }
                              if (!context.mounted) return;
                              Util.customErrorSnackBar(
                                context,
                                "An error occurred during login. Please try again.",
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
                              ? const CustomLogoSpinner(
                                  oneSize: 10,
                                  roundSize: 30,
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
