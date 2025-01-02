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
  final _eMailKey = GlobalKey<FormState>();
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
      pref.setString('userImage', userData.usrImage.toString()),
      pref.setString('cmpId', userData.cmpId.toString()),
      pref.setString('brId', userData.brid.toString()),
      pref.setString('faId', userData.faid.toString()),
      pref.setString('appPageName', userData.appPageName.toString()),
      pref.setString('accId', userData.staffId.toString()),
      pref.setString('isAdmin', userData.isAdmin.toString()),
      pref.setString('designId', userData.desgId.toString()),
      pref.setString('userType', userData.userType.toString()),
      pref.setString('userName', _usernameController.text.trim()),
    ]);
  }

  void _navigateToBackground(String userType) {
    Widget dashboard;
    switch (userType) {
      case 'Buyer':
        dashboard = _fnNavigateToBuyerPage();
        break;
      case '':
        dashboard = _fnNavigateToHomePage();
        break;
      case 'Driver':
        dashboard = _fnNavigateToDriverPage();
        break;
      default:
        dashboard = const ScreenLogin();
    }
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => dashboard),
      (route) => false,
    );
  }

  _fnNavigateToHomePage() {
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

  _fnNavigateToDriverPage() {
    // Set portrait orientation for driver
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const DeliveryItemsListScreen(),
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
    return Container(
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
                    'Williams',
                    style: TextStyle(
                      height: 0.9,
                      color: buttonColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of London',
                    style: TextStyle(
                      height: 0.9,
                      color: buttonColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Since 1999',
                    style: TextStyle(
                      color: buttonColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
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
                  key: _eMailKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a valid email';
                      } else if (!value.contains('@') &&
                          value.contains('.') &&
                          value.length < 5) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Email',
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
                  mainAxisAlignment: MainAxisAlignment.end,
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
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password ?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),


                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  ),
                  onPressed: () async {
                    if (!_eMailKey.currentState!.validate() ||
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
                        Util.customErrorSnackbar(
                          context,
                          "Error: ${loginData.message}",
                        );
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('Login error: $e');
                      }
                      if (!context.mounted) return;
                      Util.customErrorSnackbar(
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
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabletView(BuildContext context) {
    return Container(
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
                    'Williams',
                    style: TextStyle(
                      height: 0.9,
                      color: buttonColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of London',
                    style: TextStyle(
                      height: 0.9,
                      color: buttonColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Since 1999',
                    style: TextStyle(
                      color: buttonColor,
                      fontSize: 12,
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
                        key: _eMailKey,
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a valid email';
                            } else if (!value.contains('@') &&
                                value.contains('.') &&
                                value.length < 5) {
                              return 'Please enter valid email';
                            }
                            return null;
                          },
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Email',
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
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        onPressed: () async {
                          if (!_eMailKey.currentState!.validate() ||
                              !_passwordKey.currentState!.validate()) {
                            return;
                          }
                          setState(() {
                            _isButtonLoading = true;
                          });
                          String username = _usernameController.text.trim();
                          String password = _passwordController.text.trim();
                          await Future.delayed(
                            const Duration(seconds: 2),
                            () {
                              if (username == 'p' && password == 'p') {
                                _fnNavigateToHomePage();
                              } else if (username == 'd' && password == 'd') {
                                _fnNavigateToDriverPage();
                              } else if (username == 'b' && password == 'b') {
                                _fnNavigateToBuyerPage();
                              } else {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Invalid username or password'),
                                  ),
                                );
                                setState(() {
                                  _isButtonLoading = false;
                                });
                              }
                            },
                          );
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
    );
  }
}
