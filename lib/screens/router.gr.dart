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
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;

import 'app.dart' as _i1;
import 'search/search.dart' as _i2;
import 'settings/settings.dart' as _i6;
import 'translation_view/pages/images_picker.dart' as _i4;
import 'translation_view/pages/own_translation.dart' as _i5;
import 'translation_view/translation_view.dart' as _i3;

class AppRouter extends _i7.RootStackRouter {
  AppRouter([_i8.GlobalKey<_i8.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    AppRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.App(),
      );
    },
    SearchRoute.name: (routeData) {
      final args = routeData.argsAs<SearchRouteArgs>(
          orElse: () => const SearchRouteArgs());
      return _i7.CustomPage<dynamic>(
        routeData: routeData,
        child: _i2.Search(key: args.key),
        transitionsBuilder: _i7.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TranslationViewRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewRouteArgs>(
          orElse: () => const TranslationViewRouteArgs());
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i3.TranslationView(
          key: args.key,
          word: args.word,
        ),
      );
    },
    TranslationViewImagePickerRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewImagePickerRouteArgs>(
          orElse: () => const TranslationViewImagePickerRouteArgs());
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i4.TranslationViewImagePicker(
          key: args.key,
          word: args.word,
        ),
      );
    },
    TranslationViewOwnTranslationRoute.name: (routeData) {
      final args = routeData.argsAs<TranslationViewOwnTranslationRouteArgs>();
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i5.TranslationViewOwnTranslation(
          key: args.key,
          word: args.word,
        ),
      );
    },
    SettingsRoute.name: (routeData) {
      final args = routeData.argsAs<SettingsRouteArgs>(
          orElse: () => const SettingsRouteArgs());
      return _i7.CustomPage<dynamic>(
        routeData: routeData,
        child: _i6.Settings(key: args.key),
        transitionsBuilder: _i7.TransitionsBuilders.noTransition,
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i7.RouteConfig> get routes => [
        _i7.RouteConfig(
          AppRoute.name,
          path: '/',
          children: [
            _i7.RouteConfig(
              '#redirect',
              path: '',
              parent: AppRoute.name,
              redirectTo: 'search',
              fullMatch: true,
            ),
            _i7.RouteConfig(
              SearchRoute.name,
              path: 'search',
              parent: AppRoute.name,
            ),
            _i7.RouteConfig(
              TranslationViewRoute.name,
              path: 'translation_view',
              parent: AppRoute.name,
            ),
            _i7.RouteConfig(
              TranslationViewImagePickerRoute.name,
              path: 'translation_view/images',
              parent: AppRoute.name,
            ),
            _i7.RouteConfig(
              TranslationViewOwnTranslationRoute.name,
              path: 'translation_view/own',
              parent: AppRoute.name,
            ),
            _i7.RouteConfig(
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
class AppRoute extends _i7.PageRouteInfo<void> {
  const AppRoute({List<_i7.PageRouteInfo>? children})
      : super(
          AppRoute.name,
          path: '/',
          initialChildren: children,
        );

  static const String name = 'AppRoute';
}

/// generated route for
/// [_i2.Search]
class SearchRoute extends _i7.PageRouteInfo<SearchRouteArgs> {
  SearchRoute({_i8.Key? key})
      : super(
          SearchRoute.name,
          path: 'search',
          args: SearchRouteArgs(key: key),
        );

  static const String name = 'SearchRoute';
}

class SearchRouteArgs {
  const SearchRouteArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'SearchRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.TranslationView]
class TranslationViewRoute extends _i7.PageRouteInfo<TranslationViewRouteArgs> {
  TranslationViewRoute({
    _i8.Key? key,
    String? word,
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
    this.word,
  });

  final _i8.Key? key;

  final String? word;

  @override
  String toString() {
    return 'TranslationViewRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i4.TranslationViewImagePicker]
class TranslationViewImagePickerRoute
    extends _i7.PageRouteInfo<TranslationViewImagePickerRouteArgs> {
  TranslationViewImagePickerRoute({
    _i8.Key? key,
    String? word,
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
    this.word,
  });

  final _i8.Key? key;

  final String? word;

  @override
  String toString() {
    return 'TranslationViewImagePickerRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i5.TranslationViewOwnTranslation]
class TranslationViewOwnTranslationRoute
    extends _i7.PageRouteInfo<TranslationViewOwnTranslationRouteArgs> {
  TranslationViewOwnTranslationRoute({
    _i8.Key? key,
    required String word,
  }) : super(
          TranslationViewOwnTranslationRoute.name,
          path: 'translation_view/own',
          args: TranslationViewOwnTranslationRouteArgs(
            key: key,
            word: word,
          ),
        );

  static const String name = 'TranslationViewOwnTranslationRoute';
}

class TranslationViewOwnTranslationRouteArgs {
  const TranslationViewOwnTranslationRouteArgs({
    this.key,
    required this.word,
  });

  final _i8.Key? key;

  final String word;

  @override
  String toString() {
    return 'TranslationViewOwnTranslationRouteArgs{key: $key, word: $word}';
  }
}

/// generated route for
/// [_i6.Settings]
class SettingsRoute extends _i7.PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({_i8.Key? key})
      : super(
          SettingsRoute.name,
          path: 'settings',
          args: SettingsRouteArgs(key: key),
        );

  static const String name = 'SettingsRoute';
}

class SettingsRouteArgs {
  const SettingsRouteArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'SettingsRouteArgs{key: $key}';
  }
}
