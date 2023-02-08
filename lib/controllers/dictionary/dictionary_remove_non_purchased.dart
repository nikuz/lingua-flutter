import 'package:lingua_flutter/controllers/database/database.dart';
import 'package:lingua_flutter/app_config.dart' as config;

import './constants.dart';
import './dictionary_list.dart';
import './dictionary_remove.dart';

Future<void> removeNonPurchasedItems() async {
  final amountOfSavedWords = await getListLength();
  final amountOfNonPurchasedWords = amountOfSavedWords - config.wordsAmountPurchaseThreshold;

  final List<dynamic> items = await DBProvider().rawQuery(
    '''
      SELECT id
      FROM ${DictionaryControllerConstants.databaseTableName}
      ORDER BY created_at DESC
      LIMIT ?;
    ''',
    [amountOfNonPurchasedWords],
  );

  for (final item in items) {
    if (item['id'] != null) {
      await removeItem(item['id']);
    }
  }
}