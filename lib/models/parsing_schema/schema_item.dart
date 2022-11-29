import 'package:json_annotation/json_annotation.dart';

part 'schema_item.g.dart';

@JsonSerializable(explicitToJson: true)
class SchemaItem {
  final String value;

  const SchemaItem({ required this.value });

  factory SchemaItem.fromJson(Map<String, dynamic> json) => _$SchemaItemFromJson(json);
  Map<String, dynamic> toJson() => _$SchemaItemToJson(this);
}