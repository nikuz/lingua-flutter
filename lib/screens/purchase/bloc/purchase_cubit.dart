import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/controllers/dictionary/dictionary.dart' as dictionary_controller;

import 'purchase_state.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  SharedPreferences prefs;

  PurchaseCubit(this.prefs) : super(PurchaseState.initial(prefs));

  void savePurchase(String purchaseId) async {
    await prefs.setString('purchaseId', purchaseId);
    emit(state.copyWith(
      purchaseId: Wrapped.value(purchaseId),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  void cancelPurchase() async {
    await prefs.remove('purchaseId');
    await dictionary_controller.removeNonPurchasedItems();

    emit(state.copyWith(
      purchaseId: const Wrapped.value(null),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}