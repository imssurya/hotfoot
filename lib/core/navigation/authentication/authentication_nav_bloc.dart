import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hotfoot/core/navigation/authentication/authentication_nav_event.dart';
import 'package:hotfoot/core/navigation/authentication/authentication_nav_state.dart';
import 'package:hotfoot/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:meta/meta.dart';

class AuthenticationNavBloc
    extends Bloc<AuthenticationNavEvent, AuthenticationNavState> {
  final IAuthenticationRepository authenticationRepository;

  AuthenticationNavBloc({
    @required this.authenticationRepository,
  }) : assert(authenticationRepository != null);

  @override
  AuthenticationNavState get initialState => Uninitialized();

  @override
  Stream<AuthenticationNavState> mapEventToState(
    AuthenticationNavEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationNavState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await authenticationRepository.isSignedIn();
      if (isSignedIn) {
        final name = await authenticationRepository.getUser();
        yield Authenticated(name);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationNavState> _mapLoggedInToState() async* {
    yield Authenticated(await authenticationRepository.getUser());
  }

  Stream<AuthenticationNavState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    authenticationRepository.signOut();
  }
}