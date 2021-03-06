import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotfoot/features/login/presentation/bloc/login_bloc.dart';
import 'package:hotfoot/features/login/presentation/bloc/login_event.dart';
import 'package:hotfoot/features/login/presentation/bloc/login_state.dart';
import 'package:hotfoot/features/login/presentation/ui/widgets/create_account_button.dart';
import 'package:hotfoot/features/login/presentation/ui/widgets/login_button.dart';
import 'package:hotfoot/features/navigation_auth/presentation/bloc/navigation_auth_bloc.dart';
import 'package:hotfoot/features/navigation_auth/presentation/bloc/navigation_auth_event.dart';
import 'package:hotfoot/core/style/style.dart';

class LoginForm extends StatefulWidget {
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginBloc _loginBloc;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Login Failure', style: style.copyWith(fontSize: 16, fontWeight: FontWeight.bold),), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Logging In...', style: style.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<NavigationAuthBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset('assets/HotFoot.png', height: 250),
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (_) {
                      _emailFocus.unfocus();
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                    controller: _emailController,
                    style: style.copyWith(fontSize: 16.0),
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return displayEmailErrorMessage(
                          Text(_emailController.text).toString(), state);
                    },
                  ),
                  SizedBox(height: 14.0,),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (_) {
                      if (isLoginButtonEnabled(state)) {
                        _onFormSubmitted();
                      }
                    },
                    controller: _passwordController,
                    style: style.copyWith(fontSize: 16.0),
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                    obscureText: true,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return displayPasswordErrorMessage(
                          Text(_passwordController.text).toString(), state);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: <Widget>[
                        ButtonTheme(
                          minWidth:MediaQuery.of(context).size.width * 8 / 9,
                          child: LoginButton(
                            onPressed: isLoginButtonEnabled(state)
                                ? _onFormSubmitted
                                : null,
                          ),
                        ),
                        SizedBox(height: 10,),
                        CreateAccountButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to help with displaying an appropriate message
  String displayEmailErrorMessage(
      String _emailAddress, LoginState _emailAddressState) {
    if (_emailAddressState.isEmailValid) {
      return null;
    } else {
      return 'Example, john.doe@bison.howard.edu';
    }
  }

  String displayPasswordErrorMessage(
      String _password, LoginState _passwordState) {
    if (_passwordState.isPasswordValid) {
      return null;
    } else {
      return 'Password is invalid';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginWithCredentialsPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
