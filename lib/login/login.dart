import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';
import '../../custom_screens/custom_network_error.dart';
import '../../custom_widgets/custom_spinning_logo.dart';
import '../../providers/connectivity_status_provider.dart';
import '../screens/home/home_view.dart';

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
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const ScreenHomeView(),
        settings: const RouteSettings(name: '/home'),
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
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Spacer(),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Williams',
                          style: TextStyle(
                            height: 0.9,
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 200.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
                        Text(
                          'of London',
                          style: TextStyle(
                            height: 0.9,
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 400.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
                      ],
                    ),
                  ),
                  const Text(
                    'Since 1999',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .slideY(
                        duration: 400.milliseconds,
                        delay: 600.milliseconds,
                        curve: Curves.easeInOut,
                        begin: 0.1,
                        end: 0.0,
                      )
                      .fadeIn(),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
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
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .slideY(
                                duration: 400.milliseconds,
                                delay: 1000.milliseconds,
                                curve: Curves.easeInOut,
                                begin: 0.1,
                                end: 0.0,
                              )
                              .fadeIn(),
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
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 1200.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
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
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 1400.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
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
                              activeColor: Colors.white,
                              checkColor: themeColor,
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
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 1600.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
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
                            await Future.delayed(
                              const Duration(seconds: 2),
                              () {
                                _fnNavigateToHomePage();
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
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 1800.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .slideY(
                        duration: 400.milliseconds,
                        delay: 800.milliseconds,
                        curve: Curves.easeInOut,
                        begin: 0.1,
                        end: 0.0,
                      )
                      .fadeIn(),
                ],
              ),
            ),
          )
              .animate()
              .slideY(
                duration: 400.milliseconds,
                curve: Curves.easeInOut,
                begin: 0.1,
                end: 0.0,
              )
              .fadeIn(),
        ),
      );
    } else {
      return const ScreenCustomNetworkError();
    }
  }
}
