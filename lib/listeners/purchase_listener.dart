import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/search/bloc/search_state.dart';
import 'package:lingua_flutter/screens/purchase/bloc/purchase_cubit.dart';
import 'package:lingua_flutter/screens/purchase/bloc/purchase_state.dart';
import 'package:lingua_flutter/screens/purchase/purchase_content.dart';
import 'package:lingua_flutter/app_config.dart' as config;

class PurchaseListener extends StatefulWidget {
  const PurchaseListener({Key? key}) : super(key: key);

  @override
  State<PurchaseListener> createState() => _PurchaseListenerState();
}

class _PurchaseListenerState extends State<PurchaseListener> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late PurchaseCubit _purchaseCubit;
  bool _modalIsShown = false;

  @override
  void initState() {
    super.initState();
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdate(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (Object error) {
        // handle error here.
      },
    );
    _purchaseCubit = context.read<PurchaseCubit>();
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final storeIsAvailable = await _inAppPurchase.isAvailable();
    if (storeIsAvailable) {
      _inAppPurchase.restorePurchases();
    }
  }

  Future<void> _listenToPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    final purchaseDetails = purchaseDetailsList.firstWhereOrNull((item) => (
        item.productID == config.purchaseProductId
    ));
    print('------------- purchaseDetailsList: $purchaseDetailsList');
    print('------------- purchaseDetails: $purchaseDetails');
    if (purchaseDetails != null) {
      final status = purchaseDetails.status;
      print('------------- status: $status');
      print('------------- purchaseDetails.verificationData.source: ${purchaseDetails.verificationData.source}');
      print('------------- purchaseDetails.verificationData.localVerificationData: ${purchaseDetails.verificationData.localVerificationData}');
      print('------------- purchaseDetails.verificationData.serverVerificationData: ${purchaseDetails.verificationData.serverVerificationData}');
      print('------------- purchaseDetails.purchaseID: ${purchaseDetails.purchaseID}');
      final isPurchased = status == PurchaseStatus.purchased || status == PurchaseStatus.restored;

      if (isPurchased && purchaseDetails.purchaseID != null) {
        _purchaseCubit.savePurchase(purchaseDetails.purchaseID!);
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (status == PurchaseStatus.canceled) {
        print('Purchase is canceled');
        _purchaseCubit.cancelPurchase();
      }
    }
  }

  void _showPurchaseModal() async {
    // if the app is already purchased, do not show the modal again
    if (_purchaseCubit.state.purchaseId != null) {
      return;
    }

    final storeIsAvailable = await _inAppPurchase.isAvailable();
    if (!storeIsAvailable) {
      return;
    }

    _modalIsShown = true;
    if (mounted) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return const PurchaseContent();
        },
      ).then((value) {
        _modalIsShown = false;
        // if user decided to not purchase
        if (_purchaseCubit.state.purchaseId == null) {
          _purchaseCubit.cancelPurchase();
        }
      }).catchError((error) {
        _modalIsShown = false;
      });
    }
  }

  void _closePurchaseModal() {
    if (_modalIsShown && mounted) {
      _modalIsShown = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SearchCubit, SearchState>(
          listener: (context, state) async {
            if (state.totalAmount > config.wordsAmountPurchaseThreshold && !_modalIsShown) {
              _showPurchaseModal();
            }
          },
        ),
        BlocListener<PurchaseCubit, PurchaseState>(
          listener: (context, state) async {
            if (state.purchaseId != null) {
              _closePurchaseModal();
            }
          },
        ),
      ],
      child: Container(),
    );
  }
}