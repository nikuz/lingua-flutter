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
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

import '../models/translation.dart' as _i8;
import 'app.dart' as _i1;
import 'search/search.dart' as _i2;
import 'settings/settings.dart' as _i5;
import 'translation_view/pages/images_picker.dart' as _i4;
import 'translation_view/translation_view.dart' as _i3;

class AppRouter extends _i6.RootStackRouter {
  AppRouter([_i7.GlobalKey<_i7.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    AppRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.App(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i6.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i2.Search(),
        transitionsBuilder: _i6.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TranslationViewRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewRouteArgs>();
      return _i6.MaterialPageX<_i8.Translation>(
        routeData: routeData,
        child: _i3.TranslationView(
          key: args.key,
          word: args.word,
        ),
      );
    },
    TranslationViewImagePickerRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewImagePickerRouteArgs>();
      return _i6.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i4.TranslationViewImagePicker(
          key: args.key,
          word: args.word,
        ),
      );
    },
    SettingsRoute.name: (routeData) {
      return _i6.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i5.Settings(),
        transitionsBuilder: _i6.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i6.RouteConfig> get routes => [
        _i6.RouteConfig(
          AppRoute.name,
          path: '/',
          children: [
            _i6.RouteConfig(
              '#redirect',
              path: '',
              parent: AppRoute.name,
              redirectTo: 'search',
              fullMatch: true,
            ),
            _i6.RouteConfig(
              SearchRoute.name,
              path: 'search',
              parent: AppRoute.name,
            ),
            _i6.RouteConfig(
              TranslationViewRoute.name,
              path: 'translation_view',
              parent: AppRoute.name,
            ),
            _i6.RouteConfig(
              TranslationViewImagePickerRoute.name,
              path: 'translation_view/images',
              parent: AppRoute.name,
            ),
            _i6.RouteConfig(
              SettingsRoute.name,
              path: 'settings',
              parent: AppRoute.name,
            ),
          ],
        )
      ];
}

/// generated route for
/// [_i1.App]
class AppRoute extends _i6.PageRouteInfo<void> {
  const AppRoute({List<_i6.PageRouteInfo>? children})
      : super(
          AppRoute.name,
          path: '/',
          initialChildren: children,
        );

  static const String name = 'AppRoute';
}

/// generated route for
/// [_i2.Search]
class SearchRoute extends _i6.PageRouteInfo<void> {
  const SearchRoute()
      : super(
          SearchRoute.name,
          path: 'search',
        );

  static const String name = 'SearchRoute';
}

/// generated route for
/// [_i3.TranslationView]
class TranslationViewRoute extends _i6.PageRouteInfo<TranslationViewRouteArgs> {
  TranslationViewRoute({
    _i7.Key? key,
    required String word,
  }) : super(
          TranslationViewRoute.name,
          path: 'translation_view',
          args: TranslationViewRouteArgs(
            key: key,
            word: word,
          ),
        );

  static const String name = 'TranslationViewRoute';
}

class TranslationViewRouteArgs {
  const TranslationViewRouteArgs({
    this.key,
    required this.word,
  });

  final _i7.Key? key;

  final String word;

  @override
  String toString() {
    return 'TranslationViewRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i4.TranslationViewImagePicker]
class TranslationViewImagePickerRoute
    extends _i6.PageRouteInfo<TranslationViewImagePickerRouteArgs> {
  TranslationViewImagePickerRoute({
    _i7.Key? key,
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

  final _i7.Key? key;

  final String word;

  @override
  String toString() {
    return 'TranslationViewImagePickerRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i5.Settings]
class SettingsRoute extends _i6.PageRouteInfo<void> {
  const SettingsRoute()
      : super(
          SettingsRoute.name,
          path: 'settings',
        );

  static const String name = 'SettingsRoute';
}
