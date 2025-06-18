import 'package:json_annotation/json_annotation.dart';

part 'api_config.g.dart';

@JsonSerializable()
class ApiConfig {
  final String geminiApiKey;
  final String? geminiModel;
  final double temperature;
  final int maxTokens;

  ApiConfig({
    required this.geminiApiKey,
    this.geminiModel = 'gemini-pro',
    this.temperature = 0.7,
    this.maxTokens = 1000,
  });

  // PUBLIC_INTERFACE
  /// Creates a copy of this config with updated fields
  ApiConfig copyWith({
    String? geminiApiKey,
    String? geminiModel,
    double? temperature,
    int? maxTokens,
  }) {
    return ApiConfig(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      geminiModel: geminiModel ?? this.geminiModel,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }

  // PUBLIC_INTERFACE
  /// Converts config to JSON map
  Map<String, dynamic> toJson() => _$ApiConfigToJson(this);

  // PUBLIC_INTERFACE
  /// Creates config from JSON map
  factory ApiConfig.fromJson(Map<String, dynamic> json) => _$ApiConfigFromJson(json);

  // PUBLIC_INTERFACE
  /// Validates if the API key is properly formatted
  bool get isValid {
    return geminiApiKey.isNotEmpty && geminiApiKey.length > 10;
  }
}
