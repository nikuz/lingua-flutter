import 'package:lingua_flutter/controllers/database/database.dart';
import './constants.dart';

Future<void> updateCloudId(int id, int cloudId) async {
  // update db
  await DBProvider().rawQuery(
    '''
      UPDATE ${DictionaryControllerConstants.databaseTableName} 
      SET cloudId=?
      WHERE id=?;
    ''',
    [cloudId, id],
  );
}