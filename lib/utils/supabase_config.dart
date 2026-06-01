import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://kdeqqaoxhmhvpxlrguzd.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkZXFxYW94aG1odnB4bHJndXpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0MjMxNzIsImV4cCI6MjA5NDk5OTE3Mn0.Dt385w_zYcg7jYVlhzK5P1dMlsPhtTIFWr2fWLSdQmY';

/// Shortcut akses Supabase client dari mana saja
SupabaseClient get supabase => Supabase.instance.client;