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
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;

import '../models/language/language.dart' as _i12;
import '../models/quick_translation/quick_translation.dart' as _i13;
import '../models/translation_container/translation_container.dart' as _i11;
import 'games/games.dart' as _i7;
import 'landing/landing.dart' as _i1;
import 'root.dart' as _i2;
import 'search/search.dart' as _i6;
import 'settings/settings.dart' as _i8;
import 'terms/terms.dart' as _i5;
import 'translation_view/pages/images_picker.dart' as _i4;
import 'translation_view/translation_view.dart' as _i3;

class AppRouter extends _i9.RootStackRouter {
  AppRouter([_i10.GlobalKey<_i10.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    LandingRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.Landing(),
        maintainState: false,
      );
    },
    RootRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i2.Root(),
        transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TranslationViewRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewRouteArgs>();
      return _i9.MaterialPageX<_i11.TranslationContainer>(
        routeData: routeData,
        child: _i3.TranslationView(
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
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i4.TranslationViewImagePicker(
          key: args.key,
          word: args.word,
        ),
      );
    },
    TermsRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.Terms(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.Search(),
      );
    },
    GamesRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.Games(),
        maintainState: false,
      );
    },
    SettingsRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i8.Settings(),
        maintainState: false,
      );
    },
  };

  @override
  List<_i9.RouteConfig> get routes => [
        _i9.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/landing',
          fullMatch: true,
        ),
        _i9.RouteConfig(
          LandingRoute.name,
          path: '/landing',
        ),
        _i9.RouteConfig(
          RootRoute.name,
          path: '/home',
          children: [
            _i9.RouteConfig(
              SearchRoute.name,
              path: 'search',
              parent: RootRoute.name,
            ),
            _i9.RouteConfig(
              GamesRoute.name,
              path: 'games',
              parent: RootRoute.name,
            ),
            _i9.RouteConfig(
              SettingsRoute.name,
              path: 'settings',
              parent: RootRoute.name,
            ),
          ],
        ),
        _i9.RouteConfig(
          TranslationViewRoute.name,
          path: 'translation_view',
        ),
        _i9.RouteConfig(
          TranslationViewImagePickerRoute.name,
          path: 'translation_view/images',
        ),
        _i9.RouteConfig(
          TermsRoute.name,
          path: 'terms',
        ),
      ];
}

/// generated route for
/// [_i1.Landing]
class LandingRoute extends _i9.PageRouteInfo<void> {
  const LandingRoute()
      : super(
          LandingRoute.name,
          path: '/landing',
        );

  static const String name = 'LandingRoute';
}

/// generated route for
/// [_i2.Root]
class RootRoute extends _i9.PageRouteInfo<void> {
  const RootRoute({List<_i9.PageRouteInfo>? children})
      : super(
          RootRoute.name,
          path: '/home',
          initialChildren: children,
        );

  static const String name = 'RootRoute';
}

/// generated route for
/// [_i3.TranslationView]
class TranslationViewRoute extends _i9.PageRouteInfo<TranslationViewRouteArgs> {
  TranslationViewRoute({
    _i10.Key? key,
    required String word,
    required _i12.Language translateFrom,
    required _i12.Language translateTo,
    _i13.QuickTranslation? quickTranslation,
  }) : super(
          TranslationViewRoute.name,
          path: 'translation_view',
          args: TranslationViewRouteArgs(
            key: key,
            word: word,
            translateFrom: translateFrom,
            translateTo: translateTo,
            quickTranslation: quickTranslation,
          ),
        );

  static const String name = 'TranslationViewRoute';
}

class TranslationViewRouteArgs {
  const TranslationViewRouteArgs({
    this.key,
    required this.word,
    required this.translateFrom,
    required this.translateTo,
    this.quickTranslation,
  });

  final _i10.Key? key;

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
/// [_i4.TranslationViewImagePicker]
class TranslationViewImagePickerRoute
    extends _i9.PageRouteInfo<TranslationViewImagePickerRouteArgs> {
  TranslationViewImagePickerRoute({
    _i10.Key? key,
    required String word,
  }) : super(
          TranslationViewImagePickerRoute.name,
          path: 'translation_view/images',
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

  final _i10.Key? key;

  final String word;

  @override
  String toString() {
    return 'TranslationViewImagePickerRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i5.Terms]
class TermsRoute extends _i9.PageRouteInfo<void> {
  const TermsRoute()
      : super(
          TermsRoute.name,
          path: 'terms',
        );

  static const String name = 'TermsRoute';
}

/// generated route for
/// [_i6.Search]
class SearchRoute extends _i9.PageRouteInfo<void> {
  const SearchRoute()
      : super(
          SearchRoute.name,
          path: 'search',
        );

  static const String name = 'SearchRoute';
}

/// generated route for
/// [_i7.Games]
class GamesRoute extends _i9.PageRouteInfo<void> {
  const GamesRoute()
      : super(
          GamesRoute.name,
          path: 'games',
        );

  static const String name = 'GamesRoute';
}

/// generated route for
/// [_i8.Settings]
class SettingsRoute extends _i9.PageRouteInfo<void> {
  const SettingsRoute()
      : super(
          SettingsRoute.name,
          path: 'settings',
        );

  static const String name = 'SettingsRoute';
}
