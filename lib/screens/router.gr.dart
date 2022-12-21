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
import 'root.dart' as _i1;
import 'search/search.dart' as _i5;
import 'settings/settings.dart' as _i7;
import 'terms/terms.dart' as _i4;
import 'translation_view/pages/images_picker.dart' as _i3;
import 'translation_view/translation_view.dart' as _i2;

class AppRouter extends _i8.RootStackRouter {
  AppRouter([_i9.GlobalKey<_i9.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    RootRoute.name: (routeData) {
      return _i8.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.Root(),
        transitionsBuilder: _i8.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TranslationViewRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewRouteArgs>();
      return _i8.MaterialPageX<_i10.TranslationContainer>(
        routeData: routeData,
        child: _i2.TranslationView(
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
        child: _i3.TranslationViewImagePicker(
          key: args.key,
          word: args.word,
        ),
      );
    },
    TermsRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.Terms(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.Search(),
      );
    },
    GamesRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.Games(),
      );
    },
    SettingsRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.Settings(),
      );
    },
  };

  @override
  List<_i8.RouteConfig> get routes => [
        _i8.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/home',
          fullMatch: true,
        ),
        _i8.RouteConfig(
          RootRoute.name,
          path: '/home',
          children: [
            _i8.RouteConfig(
              SearchRoute.name,
              path: 'search',
              parent: RootRoute.name,
            ),
            _i8.RouteConfig(
              GamesRoute.name,
              path: 'games',
              parent: RootRoute.name,
            ),
            _i8.RouteConfig(
              SettingsRoute.name,
              path: 'settings',
              parent: RootRoute.name,
            ),
          ],
        ),
        _i8.RouteConfig(
          TranslationViewRoute.name,
          path: 'translation_view',
        ),
        _i8.RouteConfig(
          TranslationViewImagePickerRoute.name,
          path: 'translation_view/images',
        ),
        _i8.RouteConfig(
          TermsRoute.name,
          path: 'terms',
        ),
      ];
}

/// generated route for
/// [_i1.Root]
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
/// [_i2.TranslationView]
class TranslationViewRoute extends _i8.PageRouteInfo<TranslationViewRouteArgs> {
  TranslationViewRoute({
    _i9.Key? key,
    required String word,
    _i10.TranslationContainer? quickTranslation,
    _i11.Language? translateFrom,
    _i11.Language? translateTo,
  }) : super(
          TranslationViewRoute.name,
          path: 'translation_view',
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
/// [_i3.TranslationViewImagePicker]
class TranslationViewImagePickerRoute
    extends _i8.PageRouteInfo<TranslationViewImagePickerRouteArgs> {
  TranslationViewImagePickerRoute({
    _i9.Key? key,
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

  final _i9.Key? key;

  final String word;

  @override
  String toString() {
    return 'TranslationViewImagePickerRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i4.Terms]
class TermsRoute extends _i8.PageRouteInfo<void> {
  const TermsRoute()
      : super(
          TermsRoute.name,
          path: 'terms',
        );

  static const String name = 'TermsRoute';
}

/// generated route for
/// [_i5.Search]
class SearchRoute extends _i8.PageRouteInfo<void> {
  const SearchRoute()
      : super(
          SearchRoute.name,
          path: 'search',
        );

  static const String name = 'SearchRoute';
}

/// generated route for
/// [_i6.Games]
class GamesRoute extends _i8.PageRouteInfo<void> {
  const GamesRoute()
      : super(
          GamesRoute.name,
          path: 'games',
        );

  static const String name = 'GamesRoute';
}

/// generated route for
/// [_i7.Settings]
class SettingsRoute extends _i8.PageRouteInfo<void> {
  const SettingsRoute()
      : super(
          SettingsRoute.name,
          path: 'settings',
        );

  static const String name = 'SettingsRoute';
}
