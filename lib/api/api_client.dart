import 'dart:convert';

/// A thin HTTP wrapper, kept deliberately small until a backend exists.
///
/// The screens all read through [BudgetApi], so pointing the app at a real
/// server is a matter of filling in [send] and setting [baseUrl] -- no screen
/// or controller changes.
class ApiClient {
  ApiClient({this.baseUrl = ''});

  final String baseUrl;

  /// Set once the user is authenticated; sent as a bearer token.
  String? authToken;

  Map<String, String> get headers => <String, String>{
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Future<Map<String, dynamic>> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    throw UnimplementedError(
      'No backend yet. The app reads and writes through AppPreferences; '
      'implement ApiClient.send and switch BudgetApi over when one exists. '
      'Request was $method $baseUrl$path '
      '${body == null ? '' : jsonEncode(body)}',
    );
  }
}
