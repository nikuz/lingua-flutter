import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseContent extends StatefulWidget {
  const PurchaseContent({super.key});

  @override
  State<PurchaseContent> createState() => _PurchaseContentState();
}

class _PurchaseContentState extends State<PurchaseContent> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
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
    _initStoreInfo();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      if (mounted) {
        setState(() {
          _isAvailable = isAvailable;
        });
      }
      return;
    }

    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails({'full_access'});
    if (productDetailResponse.error != null) {
      if (mounted) {
        setState(() {
          _queryProductError = productDetailResponse.error!.message;
          _isAvailable = isAvailable;
          _products = productDetailResponse.productDetails;
          _notFoundIds = productDetailResponse.notFoundIDs;
          _loading = false;
        });
      }
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      if (mounted) {
        setState(() {
          _isAvailable = isAvailable;
          _products = productDetailResponse.productDetails;
          _notFoundIds = productDetailResponse.notFoundIDs;
          _loading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _notFoundIds = productDetailResponse.notFoundIDs;
        _loading = false;
      });
    }
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return const Card(child: ListTile(title: Text('Trying to connect...')));
    }

    final Widget storeHeader = ListTile(
      leading: Icon(
        _isAvailable ? Icons.check : Icons.block,
        color: _isAvailable ? Colors.green : ThemeData.light().colorScheme.error,
      ),
      title: Text('The store is ${_isAvailable ? 'available' : 'unavailable'}.'),
    );
    final children = [storeHeader];

    if (!_isAvailable) {
      children.addAll([
        const Divider(),
        ListTile(
          title: Text(
            'Not connected',
            style: TextStyle(color: ThemeData.light().colorScheme.error),
          ),
          subtitle: const Text('Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching products...'),
        ),
      );
    }

    if (!_isAvailable) {
      return const Card();
    }

    const ListTile productHeader = ListTile(title: Text('Products for Sale'));
    final List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(
        ListTile(
          title: Text(
            '[${_notFoundIds.join(", ")}] not found',
            style: TextStyle(color: ThemeData.light().colorScheme.error),
          ),
          subtitle: const Text('This app needs special configuration to run. Please see example/README.md for instructions.'),
        ),
      );
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    final Map<String, PurchaseDetails> purchases = Map<String, PurchaseDetails>.fromEntries(
      _purchases.map((PurchaseDetails purchase) {
        if (purchase.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchase);
        }
        return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
      }),
    );

    productList.addAll(_products.map((ProductDetails productDetails) {
      // final PurchaseDetails? previousPurchase = purchases[productDetails.id];
      return ListTile(
        title: Text(productDetails.title),
        subtitle: Text(productDetails.description),
        trailing: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.green[800],
          ),
          onPressed: () {
            final PurchaseParam purchaseParam = PurchaseParam(
              productDetails: productDetails,
            );

            _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
          },
          child: Text(productDetails.price),
        ),
      );
    }));

    return Card(
      child: Column(
        children: [productHeader, const Divider()] + productList,
      ),
    );
  }

  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => _inAppPurchase.restorePurchases(),
            child: const Text('Restore purchases'),
          ),
        ],
      ),
    );
  }

  void _showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    setState(() {
      _purchases.add(purchaseDetails);
      _purchasePending = false;
    });
  }

  void _handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  Future<void> _listenToPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      final status = purchaseDetails.status;
      if (status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (status == PurchaseStatus.purchased || status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        Column(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
            // _buildRestoreButton(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: const [
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: stack,
    );
  }
}