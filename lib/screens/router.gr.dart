// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:lingua_flutter/models/language/language.dart' as _i11;
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart'
    as _i12;
import 'package:lingua_flutter/screens/games/games.dart' as _i1;
import 'package:lingua_flutter/screens/landing/landing.dart' as _i2;
import 'package:lingua_flutter/screens/root.dart' as _i3;
import 'package:lingua_flutter/screens/search/search.dart' as _i4;
import 'package:lingua_flutter/screens/settings/settings.dart' as _i5;
import 'package:lingua_flutter/screens/terms/terms.dart' as _i6;
import 'package:lingua_flutter/screens/translation_view/pages/images_picker.dart'
    as _i7;
import 'package:lingua_flutter/screens/translation_view/translation_view.dart'
    as _i8;

/// generated route for
/// [_i1.GamesScreen]
class GamesRoute extends _i9.PageRouteInfo<void> {
  const GamesRoute({List<_i9.PageRouteInfo>? children})
      : super(
          GamesRoute.name,
          initialChildren: children,
        );

  static const String name = 'GamesRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.GamesScreen();
    },
  );
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

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.LandingScreen();
    },
  );
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

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.RootScreen();
    },
  );
}

/// generated route for
/// [_i4.SearchScreen]
class SearchRoute extends _i9.PageRouteInfo<void> {
  const SearchRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.SearchScreen();
    },
  );
}

/// generated route for
/// [_i5.SettingsScreen]
class SettingsRoute extends _i9.PageRouteInfo<void> {
  const SettingsRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i6.TermsScreen]
class TermsRoute extends _i9.PageRouteInfo<void> {
  const TermsRoute({List<_i9.PageRouteInfo>? children})
      : super(
          TermsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TermsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.TermsScreen();
    },
  );
}

/// generated route for
/// [_i7.TranslationViewImagePickerScreen]
class TranslationViewImagePickerRoute
    extends _i9.PageRouteInfo<TranslationViewImagePickerRouteArgs> {
  TranslationViewImagePickerRoute({
    _i10.Key? key,
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

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TranslationViewImagePickerRouteArgs>();
      return _i7.TranslationViewImagePickerScreen(
        key: args.key,
        word: args.word,
      );
    },
  );
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
/// [_i8.TranslationViewScreen]
class TranslationViewRoute extends _i9.PageRouteInfo<TranslationViewRouteArgs> {
  TranslationViewRoute({
    _i10.Key? key,
    required String word,
    required _i11.Language translateFrom,
    required _i11.Language translateTo,
    _i12.QuickTranslation? quickTranslation,
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

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TranslationViewRouteArgs>();
      return _i8.TranslationViewScreen(
        key: args.key,
        word: args.word,
        translateFrom: args.translateFrom,
        translateTo: args.translateTo,
        quickTranslation: args.quickTranslation,
      );
    },
  );
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

  final _i11.Language translateFrom;

  final _i11.Language translateTo;

  final _i12.QuickTranslation? quickTranslation;

  @override
  String toString() {
    return 'TranslationViewRouteArgs{key: $key, word: $word, translateFrom: $translateFrom, translateTo: $translateTo, quickTranslation: $quickTranslation}';
  }
}
