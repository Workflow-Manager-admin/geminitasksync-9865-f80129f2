// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiConfig _$ApiConfigFromJson(Map<String, dynamic> json) => ApiConfig(
  geminiApiKey: json['geminiApiKey'] as String,
  geminiModel: json['geminiModel'] as String? ?? 'gemini-pro',
  temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
  maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 1000,
);

Map<String, dynamic> _$ApiConfigToJson(ApiConfig instance) => <String, dynamic>{
  'geminiApiKey': instance.geminiApiKey,
  'geminiModel': instance.geminiModel,
  'temperature': instance.temperature,
  'maxTokens': instance.maxTokens,
};
