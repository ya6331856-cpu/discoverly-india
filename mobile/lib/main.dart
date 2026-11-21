import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://nkxnexjwbdopycvxwomn.supabase.co';
const supabaseKey = 'sb_publishable_IXs7KmrWzr1eIxwUnFeX8Q_9gNgow0S';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
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
    theme: ThemeData(
      useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF4F7F4),
      colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light).copyWith(primary: green, secondary: gold, surface: Colors.white),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: ink, height: 1.08, letterSpacing: -1),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink, height: 1.12, letterSpacing: -.6),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: ink),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink),
        bodyLarge: TextStyle(fontSize: 16, color: ink, height: 1.45),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF718078), height: 1.45),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF4F7F4), foregroundColor: ink, elevation: 0, toolbarHeight: 68, titleTextStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: ink)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white, hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF98A39D)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18), prefixIconColor: green,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFE5ECE7))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFE5ECE7))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: green, width: 1.5)),
      ),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21), side: const BorderSide(color: Color(0xFFE5ECE7)))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, minimumSize: const Size(0, 54), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      navigationBarTheme: NavigationBarThemeData(height: 76, backgroundColor: Colors.white, elevation: 0, indicatorColor: const Color(0xFFE5F2EB), labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ),
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
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7F4),
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ink, Color(0xFF123F32), green]),
          borderRadius: BorderRadius.circular(29), boxShadow: const [BoxShadow(color: Color(0x260C3D31), blurRadius: 24, offset: Offset(0, 12))],
        ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 26)), const SizedBox(width: 12), const Text('DISCOVERLY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 21, letterSpacing: 1))]),
          const SizedBox(height: 35), Text(signup ? 'Start your\nnext connection.' : 'Discover the\nright connections.', style: const TextStyle(color: Colors.white, fontSize: 32, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.8)),
          const SizedBox(height: 12), const Text('India’s business discovery network. Find services, meet businesses and unlock opportunities.', style: TextStyle(color: Color(0xFFD9E9E1), fontSize: 15, height: 1.5)),
        ])),
        const SizedBox(height: 28), Text(signup ? 'Create your account' : 'Welcome back', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6), Text(signup ? 'Start discovering possibilities around you.' : 'Sign in to continue to your network.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 22),
        if (signup) ...[TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 12)],
        TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline))),
        const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
        if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
        if (notice != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(notice!, style: const TextStyle(color: green))),
        const SizedBox(height: 18), FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait...' : signup ? 'Create account' : 'Sign in')),
        const SizedBox(height: 9), OutlinedButton(onPressed: () => setState(() { signup = !signup; error = null; notice = null; }), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), side: const BorderSide(color: Color(0xFFE5ECE7)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(signup ? 'I already have an account' : 'Create a new account', style: const TextStyle(color: ink, fontWeight: FontWeight.w800))),
        const SizedBox(height: 22), const Center(child: Text('SECURE AUTHENTICATION  •  SUPABASE', style: TextStyle(color: Color(0xFF718078), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8))),
      ])),
    ))),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [DiscoverScreen(), RequirementsScreen(), OpportunitiesScreen(), ProfileScreen()];
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 68,
      title: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [green, Color(0xFF075642)]),
          borderRadius: BorderRadius.circular(13),
        ), child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 22)),
        const SizedBox(width: 11),
        const Text('DISCOVERLY'),
      ]),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ink),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          icon: const Icon(Icons.notifications_none_rounded, size: 25),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index, labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (v) => setState(() => index = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'),
        NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Requests'),
        NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Leads'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
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
    Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF102C25), Color(0xFF087E63), Color(0xFF0A5C49)]),
        borderRadius: BorderRadius.circular(27),
        boxShadow: const [BoxShadow(color: Color(0x26087E63), blurRadius: 22, offset: Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(30)),
          child: const Text('INDIA-WIDE BUSINESS NETWORK', style: TextStyle(color: Color(0xFFD6F4E8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        ),
        const SizedBox(height: 18),
        const Text('Discover more.\nConnect smarter.', style: TextStyle(color: Colors.white, fontSize: 31, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
        const SizedBox(height: 12),
        const Text('Find trusted businesses, services and new opportunities across India.', style: TextStyle(color: Color(0xFFD7E8E1), fontSize: 15, height: 1.5)),
        const SizedBox(height: 18),
        Row(children: [
          const Icon(Icons.verified_user_outlined, color: Color(0xFFE3C27D), size: 17),
          const SizedBox(width: 7),
          const Text('One platform. Endless possibilities.', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ]),
    ),
    const SizedBox(height: 23), TextField(controller: search, onSubmitted: (_) => find(), decoration: InputDecoration(hintText: 'Search business, product or service', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: find, icon: const Icon(Icons.arrow_forward)))),
    const SizedBox(height: 10), TextField(controller: city, onSubmitted: (_) => find(), decoration: const InputDecoration(hintText: 'City (e.g. Mumbai)', prefixIcon: Icon(Icons.location_on_outlined))),
    const SizedBox(height: 12), const Padding(padding: EdgeInsets.only(top: 12, bottom: 5), child: Text('Explore businesses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink))),
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
    return Card(child: Padding(
      padding: const EdgeInsets.all(17),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 54, height: 54, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE7F5EF), Color(0xFFD8EEE4)]),
          borderRadius: BorderRadius.circular(17),
        ), child: const Icon(Icons.storefront_rounded, color: green, size: 27)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$title', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: ink)),
          const SizedBox(height: 6),
          Text('$desc', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF69766F), fontSize: 14, height: 1.4)),
          if (item['city'] != null) Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              const Icon(Icons.location_on_outlined, size: 15, color: green),
              const SizedBox(width: 4),
              Text('${item['city']}', style: const TextStyle(fontSize: 13, color: green, fontWeight: FontWeight.w700)),
            ]),
          ),
        ])),
        const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Color(0xFF9AA8A1)),
      ]),
    ));
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
  @override
  Widget build(BuildContext context) {
    final children = rows.map((r) {
      return Card(
        child: ListTile(
          title: Text(r['title'] ?? ''),
          subtitle: Text('${r['city'] ?? ''} ${r['state'] ?? ''} • ${r['status'] ?? ''}'),
        ),
      );
    }).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: add, backgroundColor: green, foregroundColor: Colors.white,
        icon: const Icon(Icons.add), label: const Text('Post requirement'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
              ? const Center(child: Text('Aapki requirements yahan dikhenge.'))
              : ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
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
  @override
  Widget build(BuildContext context) {
    final children = rows.map((r) => ListTile(
      leading: const Icon(Icons.notifications_active_outlined, color: green),
      title: Text(r['title'] ?? ''),
      subtitle: Text(r['body'] ?? ''),
    )).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
              ? const Center(child: Text('No notifications yet'))
              : ListView(children: children),
    );
  }
}
