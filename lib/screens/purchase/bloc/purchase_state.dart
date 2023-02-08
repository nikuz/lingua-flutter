import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/utils/types.dart';

part 'purchase_state.g.dart';

@JsonSerializable()
class PurchaseState extends Equatable {
  final String? purchaseId;
  final int? updatedAt;

  const PurchaseState({
    this.purchaseId,
    this.updatedAt,
  });

  factory PurchaseState.initial(SharedPreferences prefs) {
    final String? purchaseId = prefs.getString('purchaseId');
    return PurchaseState(
      purchaseId: purchaseId,
    );
  }

  PurchaseState copyWith({
    Wrapped<String?>? purchaseId,
    int? updatedAt,
  }) {
    return PurchaseState(
      purchaseId: purchaseId != null ? purchaseId.value : this.purchaseId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PurchaseState.fromJson(Map<String, dynamic> json) => _$PurchaseStateFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseStateToJson(this);

  @override
  List<Object?> get props => [
    purchaseId,
    updatedAt,
  ];
}