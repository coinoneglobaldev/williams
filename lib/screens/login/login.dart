import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../custom_screens/custom_network_error.dart';
import '../../custom_widgets/custom_spinning_logo.dart';
import '../../providers/connectivity_status_provider.dart';
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

  _fnNavigateToBuyerPage() {
    // Set portrait orientation for driver
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const BuyingSheetScreen(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    var connectivityStatusProvider = ref.watch(connectivityStatusProviders);
    if (connectivityStatusProvider == ConnectivityStatus.isConnected) {
      return Scaffold(
        body: Container(
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
                                  content: Text('Invalid username or password'),
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
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const ScreenCustomNetworkError();
    }
  }
}
