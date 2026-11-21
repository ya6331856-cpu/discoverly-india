import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://nkxnexjwbdopycvxwomn.supabase.co';
const supabaseKey = 'sb_publishable_IXs7KmrWzr1eIxwUnFeX8Q_9gNgow0S';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const DiscoverlyApp());
}

final supabase = Supabase.instance.client;
const ink = Color(0xFF101B19);
const green = Color(0xFF087E63);
const gold = Color(0xFFC99B45);
const canvas = Color(0xFFF5F7F5);

class DiscoverlyApp extends StatelessWidget {
  const DiscoverlyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DISCOVERLY',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light),
      appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: ink, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
    home: supabase.auth.currentSession == null ? const AuthScreen() : const MainShell(),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(), password = TextEditingController(), name = TextEditingController();
  bool signup = false, busy = false;
  String? error, notice;
  Future<void> submit() async {
    setState(() { busy = true; error = null; notice = null; });
    try {
      if (signup) {
        final r = await supabase.auth.signUp(email: email.text.trim(), password: password.text,
          data: {'display_name': name.text.trim()});
        if (r.session == null && mounted) setState(() => notice = 'Email par confirmation link bheja gaya hai. Link open karke login karein.');
      } else {
        await supabase.auth.signInWithPassword(email: email.text.trim(), password: password.text);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } on AuthException catch (e) { setState(() => error = e.message); }
      catch (e) { setState(() => error = 'Kuch problem hui. Internet check karke dobara try karein.'); }
    if (mounted) setState(() => busy = false);
  }
  @override void dispose() { email.dispose(); password.dispose(); name.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
    padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 28), Container(width: 62, height: 62, alignment: Alignment.center, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.travel_explore, color: Colors.white, size: 32)),
      const SizedBox(height: 24), const Text('DISCOVERLY', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: ink)),
      const SizedBox(height: 8), const Text('India ka business discovery network', style: TextStyle(color: Colors.black54, fontSize: 15)),
      const SizedBox(height: 34), Text(signup ? 'Apna account banayein' : 'Welcome back', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 20),
      if (signup) ...[TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')), const SizedBox(height: 12)],
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address')),
      const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      if (notice != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(notice!, style: const TextStyle(color: green))),
      const SizedBox(height: 20), FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(backgroundColor: green, padding: const EdgeInsets.all(16)), child: Text(busy ? 'Please wait...' : signup ? 'Create account' : 'Login')),
      TextButton(onPressed: () => setState(() { signup = !signup; error = null; notice = null; }), child: Text(signup ? 'Already have an account? Login' : 'New here? Create account')),
      const SizedBox(height: 24), const Text('Secure sign-in powered by Supabase', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12))
    ]))))));
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [DiscoverScreen(), RequirementsScreen(), OpportunitiesScreen(), ProfileScreen()];
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DISCOVERLY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none_rounded))]),
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v),
      destinations: const [NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'), NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Requirements'), NavigationDestination(icon: Icon(Icons.work_outline), label: 'Opportunities'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile')]),
  );
}

class DiscoverScreen extends StatefulWidget { const DiscoverScreen({super.key}); @override State<DiscoverScreen> createState() => _DiscoverScreenState(); }
class _DiscoverScreenState extends State<DiscoverScreen> {
  final search = TextEditingController(), city = TextEditingController();
  List<dynamic> results = []; bool loading = false; String? error;
  Future<void> find() async {
    setState(() { loading = true; error = null; });
    try { final data = await supabase.rpc('search_businesses', params: {'search_query': search.text.trim().isEmpty ? null : search.text.trim(), 'category_slug': null, 'state_filter': null, 'city_filter': city.text.trim().isEmpty ? null : city.text.trim(), 'result_limit': 40, 'result_offset': 0}); setState(() => results = (data as List).cast<dynamic>()); }
    catch (e) { setState(() => error = 'Search load nahi hua. Backend permissions ya network check karein.'); }
    if (mounted) setState(() => loading = false);
  }
  @override void initState() { super.initState(); find(); }
  @override Widget build(BuildContext context) => RefreshIndicator(onRefresh: find, child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [ink, Color(0xFF174E40)]), borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Find the right\nbusiness. Faster.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.15, fontWeight: FontWeight.w800)),
      SizedBox(height: 10), Text('Discover companies, products and services across India.', style: TextStyle(color: Colors.white70, height: 1.4))
    ])),
    const SizedBox(height: 18), TextField(controller: search, onSubmitted: (_) => find(), decoration: InputDecoration(hintText: 'Search business, product or service', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: find, icon: const Icon(Icons.arrow_forward)))),
    const SizedBox(height: 10), TextField(controller: city, onSubmitted: (_) => find(), decoration: const InputDecoration(hintText: 'City (e.g. Mumbai)', prefixIcon: Icon(Icons.location_on_outlined))),
    const SizedBox(height: 12), const Text('Explore businesses', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    if (loading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator())),
    if (error != null) Padding(padding: const EdgeInsets.all(16), child: Text(error!, style: const TextStyle(color: Colors.red))),
    if (!loading && results.isEmpty) const Padding(padding: EdgeInsets.all(22), child: Text('Abhi koi published business nahi mila. Search change karke dekhein.')),
    ...results.map((item) => BusinessTile(item: Map<String, dynamic>.from(item as Map)))
  ]));
}

class BusinessTile extends StatelessWidget {
  final Map<String, dynamic> item; const BusinessTile({super.key, required this.item});
  @override Widget build(BuildContext context) {
    final title = item['display_name'] ?? item['name'] ?? item['legal_name'] ?? 'Business';
    final desc = item['description'] ?? 'Business profile';
    return Card(margin: const EdgeInsets.only(top: 10), child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFE7F3EF), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.storefront_outlined, color: green)),
      const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 5),
        Text('$desc', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, height: 1.35)),
        if (item['city'] != null) Padding(padding: const EdgeInsets.only(top: 7), child: Text('📍 ${item['city']}', style: const TextStyle(fontSize: 12, color: green)))
      ]))
    ])));
  }
}

class RequirementsScreen extends StatefulWidget { const RequirementsScreen({super.key}); @override State<RequirementsScreen> createState() => _RequirementsScreenState(); }
class _RequirementsScreenState extends State<RequirementsScreen> {
  List<dynamic> rows = []; bool loading = true;
  Future<void> load() async { try { final r = await supabase.from('requirements').select('id,title,description,city,state,status,created_at').eq('buyer_user_id', supabase.auth.currentUser!.id).order('created_at', ascending: false); if (mounted) setState(() => rows = r); } catch (_) {} if (mounted) setState(() => loading = false); }
  @override void initState() { super.initState(); load(); }
  Future<void> add() async { final title = TextEditingController(), desc = TextEditingController(), city = TextEditingController(), state = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Post a requirement'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'What do you need?')), const SizedBox(height: 10), TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Details')), const SizedBox(height: 10), TextField(controller: city, decoration: const InputDecoration(labelText: 'City')), const SizedBox(height: 10), TextField(controller: state, decoration: const InputDecoration(labelText: 'State'))])), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Post'))]));
    if (ok != true || title.text.trim().isEmpty) return;
    try { await supabase.rpc('create_requirement_and_match', params: {'p_title': title.text.trim(), 'p_description': desc.text.trim(), 'p_requirement_type': 'other', 'p_category_id': null, 'p_city': city.text.trim().isEmpty ? null : city.text.trim(), 'p_state': state.text.trim().isEmpty ? null : state.text.trim()}); await load(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requirement posted successfully'))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requirement post nahi hua. Please details check karein.'))); }
  }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.transparent, floatingActionButton: FloatingActionButton.extended(onPressed: add, backgroundColor: green, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('Post requirement')), body: loading ? const Center(child: CircularProgressIndicator()) : rows.isEmpty ? const Center(child: Text('Aapki requirements yahan dikhenge.')) : ListView(padding: const EdgeInsets.all(16), children: rows.map((r) => Card(child: ListTile(title: Text(r['title'] ?? ''), subtitle: Text('${r['city'] ?? ''} ${r['state'] ?? ''} • ${r['status'] ?? ''}')))).toList());
}

class OpportunitiesScreen extends StatefulWidget { const OpportunitiesScreen({super.key}); @override State<OpportunitiesScreen> createState() => _OpportunitiesScreenState(); }
class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<dynamic> rows = []; bool loading = true;
  Future<void> load() async { try { final r = await supabase.from('leads').select('id,subject,message,status,created_at,companies(display_name)').order('created_at', ascending: false); if (mounted) setState(() => rows = r); } catch (_) {} if (mounted) setState(() => loading = false); }
  @override void initState() { super.initState(); load(); }
  @override Widget build(BuildContext context) => loading ? const Center(child: CircularProgressIndicator()) : rows.isEmpty ? const Center(child: Text('Matching opportunities yahan aayengi.')) : ListView(padding: const EdgeInsets.all(16), children: rows.map((r) => Card(child: ListTile(leading: const Icon(Icons.work_outline, color: green), title: Text(r['subject'] ?? 'Opportunity'), subtitle: Text('${r['message'] ?? ''}\nStatus: ${r['status'] ?? ''}')))).toList());
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) { final user = supabase.auth.currentUser; return ListView(padding: const EdgeInsets.all(18), children: [
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const CircleAvatar(radius: 27, backgroundColor: Color(0xFFE7F3EF), child: Icon(Icons.person, color: green, size: 30)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.userMetadata?['display_name'] ?? 'DISCOVERLY user', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), Text(user?.email ?? '', style: const TextStyle(color: Colors.black54))]))]))),
    const SizedBox(height: 12), ListTile(leading: const Icon(Icons.notifications_none), title: const Text('Notifications'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
    ListTile(leading: const Icon(Icons.business_outlined), title: const Text('Business portal'), subtitle: const Text('Manage your business from the website')),
    const SizedBox(height: 20), OutlinedButton.icon(onPressed: () async { await supabase.auth.signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false); }, icon: const Icon(Icons.logout), label: const Text('Logout'))
  ]); }
}

class NotificationsScreen extends StatefulWidget { const NotificationsScreen({super.key}); @override State<NotificationsScreen> createState() => _NotificationsScreenState(); }
class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> rows = []; bool loading = true;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final r = await supabase.from('notifications').select('id,title,body,created_at,read_at').order('created_at', ascending: false).limit(50); if (mounted) setState(() => rows = r); } catch (_) {} if (mounted) setState(() => loading = false); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Notifications')), body: loading ? const Center(child: CircularProgressIndicator()) : rows.isEmpty ? const Center(child: Text('No notifications yet')) : ListView(children: rows.map((r) => ListTile(leading: const Icon(Icons.notifications_active_outlined, color: green), title: Text(r['title'] ?? ''), subtitle: Text(r['body'] ?? ''))).toList());
}
