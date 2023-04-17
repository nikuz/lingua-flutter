// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i11;
import 'package:lingua_flutter/models/language/language.dart' as _i12;
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart'
    as _i13;
import 'package:lingua_flutter/models/translation_container/translation_container.dart'
    as _i10;
import 'package:lingua_flutter/screens/games/games.dart' as _i6;
import 'package:lingua_flutter/screens/landing/landing.dart' as _i2;
import 'package:lingua_flutter/screens/root.dart' as _i3;
import 'package:lingua_flutter/screens/search/search.dart' as _i5;
import 'package:lingua_flutter/screens/settings/settings.dart' as _i1;
import 'package:lingua_flutter/screens/terms/terms.dart' as _i4;
import 'package:lingua_flutter/screens/translation_view/pages/images_picker.dart'
    as _i8;
import 'package:lingua_flutter/screens/translation_view/translation_view.dart'
    as _i7;

abstract class $AppRouter extends _i9.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    SettingsRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.SettingsScreen(),
      );
    },
    LandingRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.LandingScreen(),
      );
    },
    RootRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.RootScreen(),
      );
    },
    TermsRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.TermsScreen(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.SearchScreen(),
      );
    },
    GamesRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.GamesScreen(),
      );
    },
    TranslationViewRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewRouteArgs>();
      return _i9.AutoRoutePage<_i10.TranslationContainer>(
        routeData: routeData,
        child: _i7.TranslationViewScreen(
          key: args.key,
          word: args.word,
          translateFrom: args.translateFrom,
          translateTo: args.translateTo,
          quickTranslation: args.quickTranslation,
        ),
      );
    },
    TranslationViewImagePickerRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewImagePickerRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.TranslationViewImagePickerScreen(
          key: args.key,
          word: args.word,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.SettingsScreen]
class SettingsRoute extends _i9.PageRouteInfo<void> {
  const SettingsRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i2.LandingScreen]
class LandingRoute extends _i9.PageRouteInfo<void> {
  const LandingRoute({List<_i9.PageRouteInfo>? children})
      : super(
          LandingRoute.name,
          initialChildren: children,
        );

  static const String name = 'LandingRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i3.RootScreen]
class RootRoute extends _i9.PageRouteInfo<void> {
  const RootRoute({List<_i9.PageRouteInfo>? children})
      : super(
          RootRoute.name,
          initialChildren: children,
        );

  static const String name = 'RootRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i4.TermsScreen]
class TermsRoute extends _i9.PageRouteInfo<void> {
  const TermsRoute({List<_i9.PageRouteInfo>? children})
      : super(
          TermsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TermsRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i5.SearchScreen]
class SearchRoute extends _i9.PageRouteInfo<void> {
  const SearchRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i6.GamesScreen]
class GamesRoute extends _i9.PageRouteInfo<void> {
  const GamesRoute({List<_i9.PageRouteInfo>? children})
      : super(
          GamesRoute.name,
          initialChildren: children,
        );

  static const String name = 'GamesRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i7.TranslationViewScreen]
class TranslationViewRoute extends _i9.PageRouteInfo<TranslationViewRouteArgs> {
  TranslationViewRoute({
    _i11.Key? key,
    required String word,
    required _i12.Language translateFrom,
    required _i12.Language translateTo,
    _i13.QuickTranslation? quickTranslation,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          TranslationViewRoute.name,
          args: TranslationViewRouteArgs(
            key: key,
            word: word,
            translateFrom: translateFrom,
            translateTo: translateTo,
            quickTranslation: quickTranslation,
          ),
          initialChildren: children,
        );

  static const String name = 'TranslationViewRoute';

  static const _i9.PageInfo<TranslationViewRouteArgs> page =
      _i9.PageInfo<TranslationViewRouteArgs>(name);
}

class TranslationViewRouteArgs {
  const TranslationViewRouteArgs({
    this.key,
    required this.word,
    required this.translateFrom,
    required this.translateTo,
    this.quickTranslation,
  });

  final _i11.Key? key;

  final String word;

  final _i12.Language translateFrom;

  final _i12.Language translateTo;

  final _i13.QuickTranslation? quickTranslation;

  @override
  String toString() {
    return 'TranslationViewRouteArgs{key: $key, word: $word, translateFrom: $translateFrom, translateTo: $translateTo, quickTranslation: $quickTranslation}';
  }
}

/// generated route for
/// [_i8.TranslationViewImagePickerScreen]
class TranslationViewImagePickerRoute
    extends _i9.PageRouteInfo<TranslationViewImagePickerRouteArgs> {
  TranslationViewImagePickerRoute({
    _i11.Key? key,
    required String word,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          TranslationViewImagePickerRoute.name,
          args: TranslationViewImagePickerRouteArgs(
            key: key,
            word: word,
          ),
          initialChildren: children,
        );

  static const String name = 'TranslationViewImagePickerRoute';

  static const _i9.PageInfo<TranslationViewImagePickerRouteArgs> page =
      _i9.PageInfo<TranslationViewImagePickerRouteArgs>(name);
}

class TranslationViewImagePickerRouteArgs {
  const TranslationViewImagePickerRouteArgs({
    this.key,
    required this.word,
  });

  final _i11.Key? key;

  final String word;

  @override
  String toString() {
    return 'TranslationViewImagePickerRouteArgs{key: $key, word: $word}';
  }
}
