import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract interface for Supabase operations
/// This allows us to mock Supabase in tests
abstract class SupabaseService {
  GoTrueClient get auth;
  SupabaseQueryBuilder from(String table);
  PostgrestFilterBuilder<T> rpc<T>(String fn, {Map<String, dynamic>? params});

  /// Invoke a Supabase Edge Function
  Future<Map<String, dynamic>> invokeEdgeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  });
}

/// Production implementation using real Supabase client
class SupabaseServiceImpl implements SupabaseService {
  final SupabaseClient _client;

  SupabaseServiceImpl(this._client);

  @override
  GoTrueClient get auth => _client.auth;

  @override
  SupabaseQueryBuilder from(String table) => _client.from(table);

  @override
  PostgrestFilterBuilder<T> rpc<T>(String fn, {Map<String, dynamic>? params}) =>
      _client.rpc(fn, params: params);

  @override
  Future<Map<String, dynamic>> invokeEdgeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.functions.invoke(
      functionName,
      body: body,
    );

    if (response.status != 200) {
      throw Exception(
        'Edge Function error: ${response.status} - ${response.data}',
      );
    }

    return response.data as Map<String, dynamic>;
  }
}
