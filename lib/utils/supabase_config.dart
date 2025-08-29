class SupabaseConfig {
  // Supabase project URL
  static const String supabaseUrl = 'https://dmxyakpnhgmvdgbvhbrx.supabase.co';
  
  // Supabase anon key (for client-side operations)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRteHlha3BuaGdtdmRnYnZoYnJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0OTE4NTgsImV4cCI6MjA3MjA2Nzg1OH0.NZWBGXCCQkoV4BXiWRHYvAgFcwHFUTiolk25JqhcpXE';
  
  // Supabase service role key (for server-side operations like storage uploads)
  // IMPORTANT: This should be kept secure and not exposed in client-side code
  // For production, consider using a backend service to handle file uploads
  static const String supabaseServiceRoleKey = 'YOUR_ACTUAL_SERVICE_ROLE_KEY_HERE'; // Replace with your actual service role key
  
  // Storage bucket name
  static const String storageBucketName = 'hasan';
}
