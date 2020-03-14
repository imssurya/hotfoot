import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotfoot/features/navigation_screen/presentation/bloc/navigation_screen_event.dart';
import 'package:hotfoot/features/navigation_screen/presentation/bloc/navigation_screen_state.dart';

class NavigationScreenBloc
    extends Bloc<NavigationScreenEvent, NavigationScreenState> {
  @override
  NavigationScreenState get initialState => Home();

  @override
  Stream<NavigationScreenState> mapEventToState(
    NavigationScreenEvent event,
  ) async* {
    if (event is EnteredLogin) {
      yield Login();
    } else if (event is EnteredHome) {
      yield Home();
    } else if (event is EnteredPurchaseFlow) {
      yield RequestRun();
    } else if (event is EnteredSettings) {
      yield Settings();
    }
  }
}