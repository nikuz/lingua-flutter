// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i9;

import '../models/language.dart' as _i11;
import '../models/translation.dart' as _i10;
import 'games/games.dart' as _i6;
import 'landing/landing.dart' as _i1;
import 'root.dart' as _i2;
import 'search/search.dart' as _i3;
import 'settings/settings.dart' as _i7;
import 'translation_view/pages/images_picker.dart' as _i5;
import 'translation_view/translation_view.dart' as _i4;

class AppRouter extends _i8.RootStackRouter {
  AppRouter([_i9.GlobalKey<_i9.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    LandingRoute.name: (routeData) {
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.Landing(),
        transitionsBuilder: _i8.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RootRoute.name: (routeData) {
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i2.Root(),
        transitionsBuilder: _i8.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SearchRoute.name: (routeData) {
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i3.Search(),
        transitionsBuilder: _i8.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TranslationViewRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewRouteArgs>();
      return _i8.MaterialPageX<_i10.TranslationContainer>(
        routeData: routeData,
        child: _i4.TranslationView(
          key: args.key,
          word: args.word,
          quickTranslation: args.quickTranslation,
          translateFrom: args.translateFrom,
          translateTo: args.translateTo,
        ),
      );
    },
    TranslationViewImagePickerRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewImagePickerRouteArgs>();
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i5.TranslationViewImagePicker(
          key: args.key,
          word: args.word,
        ),
      );
    },
    GamesRoute.name: (routeData) {
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i6.Games(),
        transitionsBuilder: _i8.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SettingsRoute.name: (routeData) {
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i7.Settings(),
        transitionsBuilder: _i8.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i8.RouteConfig> get routes => [
        _i8.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/landing',
          fullMatch: true,
        ),
        _i8.RouteConfig(
          LandingRoute.name,
          path: '/landing',
        ),
        _i8.RouteConfig(
          RootRoute.name,
          path: '/home',
          children: [
            _i8.RouteConfig(
              '#redirect',
              path: '',
              parent: RootRoute.name,
              redirectTo: 'home/search',
              fullMatch: true,
            ),
            _i8.RouteConfig(
              SearchRoute.name,
              path: 'home/search',
              parent: RootRoute.name,
            ),
            _i8.RouteConfig(
              TranslationViewRoute.name,
              path: 'home/translation_view',
              parent: RootRoute.name,
            ),
            _i8.RouteConfig(
              TranslationViewImagePickerRoute.name,
              path: 'home/translation_view/images',
              parent: RootRoute.name,
            ),
            _i8.RouteConfig(
              GamesRoute.name,
              path: 'home/games',
              parent: RootRoute.name,
            ),
            _i8.RouteConfig(
              SettingsRoute.name,
              path: 'home/settings',
              parent: RootRoute.name,
            ),
          ],
        ),
      ];
}

/// generated route for
/// [_i1.Landing]
class LandingRoute extends _i8.PageRouteInfo<void> {
  const LandingRoute()
      : super(
          LandingRoute.name,
          path: '/landing',
        );

  static const String name = 'LandingRoute';
}

/// generated route for
/// [_i2.Root]
class RootRoute extends _i8.PageRouteInfo<void> {
  const RootRoute({List<_i8.PageRouteInfo>? children})
      : super(
          RootRoute.name,
          path: '/home',
          initialChildren: children,
        );

  static const String name = 'RootRoute';
}

/// generated route for
/// [_i3.Search]
class SearchRoute extends _i8.PageRouteInfo<void> {
  const SearchRoute()
      : super(
          SearchRoute.name,
          path: 'home/search',
        );

  static const String name = 'SearchRoute';
}

/// generated route for
/// [_i4.TranslationView]
class TranslationViewRoute extends _i8.PageRouteInfo<TranslationViewRouteArgs> {
  TranslationViewRoute({
    _i9.Key? key,
    required String word,
    _i10.TranslationContainer? quickTranslation,
    _i11.Language? translateFrom,
    _i11.Language? translateTo,
  }) : super(
          TranslationViewRoute.name,
          path: 'home/translation_view',
          args: TranslationViewRouteArgs(
            key: key,
            word: word,
            quickTranslation: quickTranslation,
            translateFrom: translateFrom,
            translateTo: translateTo,
          ),
        );

  static const String name = 'TranslationViewRoute';
}

class TranslationViewRouteArgs {
  const TranslationViewRouteArgs({
    this.key,
    required this.word,
    this.quickTranslation,
    this.translateFrom,
    this.translateTo,
  });

  final _i9.Key? key;

  final String word;

  final _i10.TranslationContainer? quickTranslation;

  final _i11.Language? translateFrom;

  final _i11.Language? translateTo;

  @override
  String toString() {
    return 'TranslationViewRouteArgs{key: $key, word: $word, quickTranslation: $quickTranslation, translateFrom: $translateFrom, translateTo: $translateTo}';
  }
}

/// generated route for
/// [_i5.TranslationViewImagePicker]
class TranslationViewImagePickerRoute
    extends _i8.PageRouteInfo<TranslationViewImagePickerRouteArgs> {
  TranslationViewImagePickerRoute({
    _i9.Key? key,
    required String word,
  }) : super(
          TranslationViewImagePickerRoute.name,
          path: 'home/translation_view/images',
          args: TranslationViewImagePickerRouteArgs(
            key: key,
            word: word,
          ),
        );

  static const String name = 'TranslationViewImagePickerRoute';
}

class TranslationViewImagePickerRouteArgs {
  const TranslationViewImagePickerRouteArgs({
    this.key,
    required this.word,
  });

  final _i9.Key? key;

  final String word;

  @override
  String toString() {
    return 'TranslationViewImagePickerRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i6.Games]
class GamesRoute extends _i8.PageRouteInfo<void> {
  const GamesRoute()
      : super(
          GamesRoute.name,
          path: 'home/games',
        );

  static const String name = 'GamesRoute';
}

/// generated route for
/// [_i7.Settings]
class SettingsRoute extends _i8.PageRouteInfo<void> {
  const SettingsRoute()
      : super(
          SettingsRoute.name,
          path: 'home/settings',
        );

  static const String name = 'SettingsRoute';
}
