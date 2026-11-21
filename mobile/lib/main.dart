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
        headlineLarge: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: ink, height: 1.08, letterSpacing: -1),
        headlineMedium: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: ink, height: 1.12, letterSpacing: -.6),
        titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ink),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink),
        bodyLarge: TextStyle(fontSize: 16, color: ink, height: 1.45),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF718078), height: 1.45),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF4F7F4), foregroundColor: ink, elevation: 0, toolbarHeight: 60, titleTextStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: ink)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white, hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF98A39D)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14), prefixIconColor: green,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFE5ECE7))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFE5ECE7))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: green, width: 1.5)),
      ),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21), side: const BorderSide(color: Color(0xFFE5ECE7)))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, minimumSize: const Size(0, 48), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      navigationBarTheme: NavigationBarThemeData(height: 76, backgroundColor: Colors.white, elevation: 0, indicatorColor: const Color(0xFFE5F2EB), labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ),
    home: supabase.auth.currentSession == null ? const AuthScreen() : const MainShell(),
  );
}

class DiscoverlyMark extends StatelessWidget {
  final double size;
  const DiscoverlyMark({super.key, this.size = 42});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * .29),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF123D32), Color(0xFF061D18)]),
      border: Border.all(color: const Color(0x99D9B66E), width: 1),
      boxShadow: const [BoxShadow(color: Color(0x26087E63), blurRadius: 12, offset: Offset(0, 4))],
    ),
    child: Stack(alignment: Alignment.center, children: [
      Container(width: size * .67, height: size * .67,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: const Color(0x99D9B66E), width: 1.1))),
      Transform.rotate(angle: -.55,
        child: Icon(Icons.navigation_rounded, size: size * .48, color: const Color(0xFFF4E5C3))),
      Positioned(right: size * .19, top: size * .17,
        child: Container(width: size * .10, height: size * .10,
          decoration: const BoxDecoration(color: Color(0xFFE4C17B), shape: BoxShape.circle))),
    ]),
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
        if (r.session == null && mounted) setState(() => notice = 'A confirmation link has been sent to your email. Open it to continue.');
      } else {
        await supabase.auth.signInWithPassword(email: email.text.trim(), password: password.text);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } on AuthException catch (e) { setState(() => error = e.message); }
      catch (e) { setState(() => error = 'Something went wrong. Check your internet connection and try again.'); }
    if (mounted) setState(() => busy = false);
  }
  @override void dispose() { email.dispose(); password.dispose(); name.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F6F3),
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(height: 176, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0B211C), Color(0xFF0E4B39), Color(0xFF087E63)]),
          borderRadius: BorderRadius.circular(23),
        ), child: Stack(children: [
          Positioned(right: -45, top: -90, child: Container(width: 230, height: 230, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .09), width: 24)))),
          Positioned(right: 34, top: 23, child: Container(width: 95, height: 95, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x66E7C987), width: 1.2)))),
          Padding(padding: const EdgeInsets.all(19), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const DiscoverlyMark(size: 40),
              const SizedBox(width: 10), const Text('DISCOVERLY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: .8)),
              const Spacer(), const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE7C987), size: 19),
            ]),
            const Spacer(),
            Text(signup ? 'Create meaningful connections.' : 'A better way to connect.', style: const TextStyle(color: Colors.white, fontSize: 21, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -.4)),
            const SizedBox(height: 6),
            const Text('India’s discovery network for businesses, services and opportunities.', style: TextStyle(color: Color(0xFFD5E7DF), fontSize: 10, height: 1.4)),
          ])),
        ])),
        const SizedBox(height: 19),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFE4EBE6)), boxShadow: const [BoxShadow(color: Color(0x090B2920), blurRadius: 18, offset: Offset(0, 6))]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(signup ? 'Create your account' : 'Welcome back', style: const TextStyle(fontSize: 19, color: ink, fontWeight: FontWeight.w900, letterSpacing: -.3)),
          const SizedBox(height: 4), Text(signup ? 'A few details to get you started.' : 'Sign in to continue to your network.', style: const TextStyle(fontSize: 11, color: Color(0xFF718078))),
          const SizedBox(height: 17),
          if (signup) ...[TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 10)],
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline))),
          const SizedBox(height: 10), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Color(0xFFB33A3A), fontSize: 11))),
          if (notice != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(notice!, style: const TextStyle(color: green, fontSize: 11))),
          const SizedBox(height: 15),
          FilledButton(onPressed: busy ? null : submit, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (busy) const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            if (busy) const SizedBox(width: 8), Text(busy ? 'Please wait...' : signup ? 'Create account' : 'Sign in'),
          ])),
          const SizedBox(height: 7),
          TextButton(onPressed: () => setState(() { signup = !signup; error = null; notice = null; }), child: Text(signup ? 'Already have an account? Sign in' : 'New to DISCOVERLY? Create an account', style: const TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.w800))),
        ])),
        const SizedBox(height: 13),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF87948C)), SizedBox(width: 5),
          Text('SECURE AUTHENTICATION  •  SUPABASE', style: TextStyle(color: Color(0xFF87948C), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .8)),
        ]),
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
  final titles = const ['Discover', 'Requests', 'Leads', 'Profile'];
  @override Widget build(BuildContext context) => Scaffold(
    extendBody: false,
    backgroundColor: const Color(0xFFF4F7F4),
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(66),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 16, 8),
        child: Row(children: [
          const DiscoverlyMark(size: 42),
          const SizedBox(width: 11),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DISCOVERLY', style: TextStyle(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900, color: green)),
            Text(titles[index], style: const TextStyle(fontSize: 21, height: 1.1, letterSpacing: -.5, fontWeight: FontWeight.w900, color: ink)),
          ])),
          IconButton.filledTonal(
            tooltip: 'Notifications',
            style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ink, fixedSize: const Size(44, 44), side: const BorderSide(color: Color(0xFFE5ECE7))),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
          ),
        ]),
      )),
    ),
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      height: 72,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      indicatorColor: const Color(0xFFE1F0E7),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: 'Discover'),
        NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Requests'),
        NavigationDestination(icon: Icon(Icons.work_outline_rounded), selectedIcon: Icon(Icons.work_rounded), label: 'Leads'),
        NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    ),
  );
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override State<DiscoverScreen> createState() => _DiscoverScreenState();
}
class _DiscoverScreenState extends State<DiscoverScreen> {
  final search = TextEditingController(), city = TextEditingController();
  List<dynamic> results = [];
  bool loading = false;
  String? error;
  String activeCategory = 'All';
  final categories = const [
    _DiscoverCategory('All', Icons.apps_rounded, ''),
    _DiscoverCategory('Services', Icons.home_repair_service_rounded, 'Services'),
    _DiscoverCategory('Food', Icons.restaurant_rounded, 'Food'),
    _DiscoverCategory('Shopping', Icons.shopping_bag_rounded, 'Shopping'),
    _DiscoverCategory('Tech', Icons.devices_rounded, 'Technology'),
    _DiscoverCategory('Health', Icons.health_and_safety_rounded, 'Healthcare'),
    _DiscoverCategory('Education', Icons.school_rounded, 'Education'),
    _DiscoverCategory('Travel', Icons.flight_takeoff_rounded, 'Travel'),
  ];
  Future<void> find() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await supabase.rpc('search_businesses', params: {
        'search_query': search.text.trim().isEmpty ? null : search.text.trim(),
        'category_slug': null, 'state_filter': null,
        'city_filter': city.text.trim().isEmpty ? null : city.text.trim(),
        'result_limit': 40, 'result_offset': 0,
      });
      if (mounted) setState(() => results = (data as List).cast<dynamic>());
    } catch (_) {
      if (mounted) setState(() => error = 'We could not load results. Check your connection and try again.');
    }
    if (mounted) setState(() => loading = false);
  }
  void chooseCategory(_DiscoverCategory item) {
    setState(() { activeCategory = item.label; search.text = item.query; });
    find();
  }
  @override void initState() { super.initState(); find(); }
  @override void dispose() { search.dispose(); city.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: find, color: green,
    child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 26), children: [
      _DiscoveryCommandCenter(
        resultCount: results.length,
        onExplore: () {
          FocusScope.of(context).requestFocus(FocusNode());
          find();
        },
      ),
      const SizedBox(height: 13),
      Container(padding: const EdgeInsets.fromLTRB(13, 7, 7, 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE2EAE4)), boxShadow: const [BoxShadow(color: Color(0x080B2920), blurRadius: 14, offset: Offset(0, 4))]), child: Row(children: [
        const Icon(Icons.search_rounded, color: green, size: 22), const SizedBox(width: 8),
        Expanded(child: TextField(controller: search, textInputAction: TextInputAction.search, onSubmitted: (_) => find(), decoration: const InputDecoration(hintText: 'Business, service or keyword', filled: false, border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 10)))),
        Container(width: 40, height: 40, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(12)), child: IconButton(padding: EdgeInsets.zero, onPressed: find, icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 19))),
      ])),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF829088)), const SizedBox(width: 5),
        Expanded(child: TextField(controller: city, textInputAction: TextInputAction.search, onSubmitted: (_) => find(), decoration: const InputDecoration(hintText: 'Add a city to narrow your search', isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 7), hintStyle: TextStyle(fontSize: 11)))),
        TextButton(onPressed: find, style: TextButton.styleFrom(visualDensity: VisualDensity.compact), child: const Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
      ]),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Explore categories', style: TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w900)),
        const Text('BROWSE', style: TextStyle(fontSize: 9, color: green, fontWeight: FontWeight.w900, letterSpacing: .9)),
      ]),
      const SizedBox(height: 10),
      SizedBox(height: 66, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 9), itemBuilder: (context, i) {
        final item = categories[i];
        final selected = activeCategory == item.label;
        return InkWell(onTap: () => chooseCategory(item), borderRadius: BorderRadius.circular(15), child: AnimatedContainer(
          duration: const Duration(milliseconds: 180), width: 66, padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: selected ? const Color(0xFFE4F1E9) : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? green : const Color(0xFFE6ECE7))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(item.icon, color: green, size: 18), const SizedBox(height: 6),
            Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: ink, fontWeight: FontWeight.w800)),
          ]),
        ));
      })),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: Text('Businesses near your search', style: TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w900))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFEAF2EC), borderRadius: BorderRadius.circular(20)), child: Text('${results.length} RESULTS', style: const TextStyle(fontSize: 9, color: green, fontWeight: FontWeight.w900, letterSpacing: .4))),
      ]),
      const SizedBox(height: 4),
      const Text('Real listings from the DISCOVERLY network', style: TextStyle(fontSize: 11, color: Color(0xFF7A8981))),
      const SizedBox(height: 11),
      if (loading) const Padding(padding: EdgeInsets.all(25), child: Center(child: CircularProgressIndicator(color: green))),
      if (error != null) _CompactEmpty(icon: Icons.wifi_off_rounded, title: 'Could not load listings', message: error!, action: 'Try again', onTap: find),
      if (!loading && error == null && results.isEmpty) _CompactEmpty(icon: Icons.storefront_outlined, title: 'No listings yet', message: 'There are no published businesses matching this search. Try another keyword or city.', action: 'Reset search', onTap: () { search.clear(); city.clear(); setState(() => activeCategory = 'All'); find(); }),
      if (!loading && error == null) ...results.map((item) => BusinessTile(item: Map<String, dynamic>.from(item as Map))),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFEEF3EF), borderRadius: BorderRadius.circular(16)), child: const Row(children: [
        Icon(Icons.tips_and_updates_outlined, color: green, size: 19), SizedBox(width: 9),
        Expanded(child: Text('Looking for something specific? Post a requirement and get discovered by relevant businesses.', style: TextStyle(fontSize: 11, height: 1.35, color: ink, fontWeight: FontWeight.w600))),
      ])),
    ]),
  );
}
class _DiscoveryCommandCenter extends StatelessWidget {
  final int resultCount;
  final VoidCallback onExplore;
  const _DiscoveryCommandCenter({required this.resultCount, required this.onExplore});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 17, 16, 16),
    decoration: BoxDecoration(
      color: const Color(0xFF09251D),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Color(0x1C09251D), blurRadius: 20, offset: Offset(0, 9))],
    ),
    child: Stack(children: [
      Positioned(right: -12, top: -28, child: Container(
        width: 132, height: 132,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x35D9B66E), width: 1.2)),
      )),
      Positioned(right: 13, top: -3, child: Container(
        width: 82, height: 82,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x12D9B66E), border: Border.all(color: const Color(0x55D9B66E))),
        child: const Icon(Icons.travel_explore_rounded, color: Color(0xFFE7C987), size: 35),
      )),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFE7C987), shape: BoxShape.circle)),
          const SizedBox(width: 7),
          const Text('INDIA-WIDE DISCOVERY', style: TextStyle(color: Color(0xFFBFD9CC), fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 18),
        const Text('What are you\\nlooking for today?', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.08, letterSpacing: -.6, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        const Text('Find businesses, services and opportunities.', style: TextStyle(color: Color(0xFFD1E2D9), fontSize: 11)),
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.storefront_outlined, size: 15, color: Color(0xFFE7C987)),
          const SizedBox(width: 6),
          Text('$resultCount matching listings', style: const TextStyle(color: Color(0xFFD1E2D9), fontSize: 10, fontWeight: FontWeight.w700)),
          const Spacer(),
          Material(
            color: const Color(0xFFE7C987),
            borderRadius: BorderRadius.circular(11),
            child: InkWell(onTap: onExplore, borderRadius: BorderRadius.circular(11), child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(children: [Text('Explore', style: TextStyle(color: Color(0xFF10251D), fontSize: 10, fontWeight: FontWeight.w900)), SizedBox(width: 5), Icon(Icons.arrow_forward_rounded, color: Color(0xFF10251D), size: 14)]),
            )),
          ),
        ]),
      ]),
    ]),
  );
}

class _DiscoverCategory {
  final String label; final IconData icon; final String query;
  const _DiscoverCategory(this.label, this.icon, this.query);
}
class _CompactEmpty extends StatelessWidget {
  final IconData icon; final String title, message, action; final VoidCallback onTap;
  const _CompactEmpty({required this.icon, required this.title, required this.message, required this.action, required this.onTap});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE6ECE7))), child: Row(children: [
    Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFEAF3ED), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: green, size: 21)),
    const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, color: ink, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3), Text(message, style: const TextStyle(fontSize: 10, color: Color(0xFF718078), height: 1.35)),
      TextButton(onPressed: onTap, style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact), child: Text(action, style: const TextStyle(fontSize: 10, color: green, fontWeight: FontWeight.w900))),
    ])),
  ]));
}
class BusinessTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const BusinessTile({super.key, required this.item});
  @override Widget build(BuildContext context) {
    final title = item['display_name'] ?? item['name'] ?? item['legal_name'] ?? 'Business';
    final desc = item['description'] ?? 'Discover this business and its services.';
    final city = item['city']?.toString(), state = item['state']?.toString();
    final initials = title.toString().trim().isEmpty ? 'B' : title.toString().trim()[0].toUpperCase();
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE7EDE8)))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF123F32), Color(0xFF087E63)]), borderRadius: BorderRadius.circular(14)), child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
      const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('$title', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: ink))),
          const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFF1F4F1), borderRadius: BorderRadius.circular(5)), child: const Text('BUSINESS', style: TextStyle(fontSize: 8, letterSpacing: .5, color: Color(0xFF65736B), fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 4), Text('$desc', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF718078))),
        if ((city ?? '').isNotEmpty || (state ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 7), child: Row(children: [
          const Icon(Icons.location_on_outlined, size: 12, color: green), const SizedBox(width: 3),
          Expanded(child: Text([city, state].where((v) => v != null && v.isNotEmpty).join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w800))),
        ])),
      ])),
      const SizedBox(width: 3), const Icon(Icons.north_east_rounded, size: 15, color: Color(0xFF9AA69F)),
    ]));
  }
}

class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});
  @override State<RequirementsScreen> createState() => _RequirementsScreenState();
}
class _RequirementsScreenState extends State<RequirementsScreen> {
  List<dynamic> rows = [];
  bool loading = true;
  Future<void> load() async {
    try {
      final r = await supabase.from('requirements').select('id,title,description,city,state,status,created_at').eq('buyer_user_id', supabase.auth.currentUser!.id).order('created_at', ascending: false);
      if (mounted) setState(() => rows = r);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }
  @override void initState() { super.initState(); load(); }
  Future<void> add() async {
    final title = TextEditingController(), desc = TextEditingController(), city = TextEditingController(), state = TextEditingController();
    var sending = false;
    final ok = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 22),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          const Text('Create a request', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: ink)),
          const SizedBox(height: 5), const Text('Tell relevant businesses what you need.', style: TextStyle(fontSize: 13, color: Color(0xFF718078))),
          const SizedBox(height: 20),
          TextField(controller: title, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'What do you need?', prefixIcon: Icon(Icons.lightbulb_outline_rounded))),
          const SizedBox(height: 12),
          TextField(controller: desc, maxLines: 3, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Describe your requirement', alignLabelWithHint: true)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: city, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_rounded)))),
            const SizedBox(width: 10), Expanded(child: TextField(controller: state, decoration: const InputDecoration(labelText: 'State'))),
          ]),
          const SizedBox(height: 18),
          FilledButton(onPressed: sending ? null : () async {
            if (title.text.trim().isEmpty) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please enter what you need.'))); return; }
            refresh(() => sending = true);
            try {
              await supabase.rpc('create_requirement_and_match', params: {
                'p_title': title.text.trim(), 'p_description': desc.text.trim(), 'p_requirement_type': 'other',
                'p_category_id': null, 'p_city': city.text.trim().isEmpty ? null : city.text.trim(),
                'p_state': state.text.trim().isEmpty ? null : state.text.trim(),
              });
              if (ctx.mounted) Navigator.pop(ctx, true);
            } catch (_) {
              refresh(() => sending = false);
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Could not post the request. Please try again.')));
            }
          }, child: sending ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Publish request')),
        ])),
      )),
    );
    title.dispose(); desc.dispose(); city.dispose(); state.dispose();
    if (ok == true) {
      await load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your request has been published.')));
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    floatingActionButton: FloatingActionButton.extended(onPressed: add, backgroundColor: green, foregroundColor: Colors.white, icon: const Icon(Icons.add_rounded), label: const Text('New request', style: TextStyle(fontWeight: FontWeight.w800))),
    body: loading ? const Center(child: CircularProgressIndicator(color: green))
      : RefreshIndicator(color: green, onRefresh: load, child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 95), children: [
        const _SectionHeading(kicker: 'BUYER WORKSPACE', title: 'Your requests', subtitle: 'Track requirements and business responses.'),
        const SizedBox(height: 15),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF102A22), Color(0xFF14513D)]), borderRadius: BorderRadius.circular(14)), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('REQUEST OVERVIEW', style: TextStyle(color: Color(0xFFBFD9CC), fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5), Text('${rows.length} active records', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2), const Text('Your posted needs in one place', style: TextStyle(color: Color(0xFFD3E4DC), fontSize: 10)),
          ])),
          Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFFE7C987), size: 24)),
        ])),
        const SizedBox(height: 16),
        if (rows.isEmpty) _CompactEmpty(icon: Icons.post_add_rounded, title: 'No requirements posted', message: 'Create your first request and let matching businesses discover what you need.', action: 'Create a request', onTap: add)
        else ...rows.map((r) {
          final status = (r['status'] ?? 'open').toString();
          final location = [r['city'], r['state']].where((v) => v != null && v.toString().trim().isNotEmpty).join(', ');
          return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE5ECE7))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(r['title'] ?? 'Untitled requirement', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: ink, fontWeight: FontWeight.w900))),
              _StatusPill(status: status),
            ]),
            const SizedBox(height: 7), Text(r['description'] ?? 'No additional details provided.', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF718078), height: 1.4)),
            const SizedBox(height: 10), Row(children: [
              const Icon(Icons.location_on_outlined, color: green, size: 14), const SizedBox(width: 4),
              Expanded(child: Text(location.isEmpty ? 'Location not specified' : location, style: const TextStyle(fontSize: 10, color: green, fontWeight: FontWeight.w700))),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA69F), size: 17),
            ]),
          ]));
        }),
      ])),
  );
}
class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});
  @override State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}
class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<dynamic> rows = [];
  bool loading = true;
  String filter = 'All';
  Future<void> load() async {
    setState(() => loading = true);
    try {
      final r = await supabase.from('leads').select('id,subject,message,status,created_at,companies(display_name)').order('created_at', ascending: false);
      if (mounted) setState(() => rows = r);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }
  @override void initState() { super.initState(); load(); }
  Future<void> sendQuote(Map<String, dynamic> lead) async {
    final amount = TextEditingController();
    final details = TextEditingController();
    var sending = false;
    final sent = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(27))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 22),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          const Text('Send a quotation', style: TextStyle(fontSize: 22, color: ink, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5), const Text('Your quote will be shared with the customer.', style: TextStyle(fontSize: 12, color: Color(0xFF718078))),
          const SizedBox(height: 18),
          TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quotation amount (INR)', prefixText: '₹ ')),
          const SizedBox(height: 12),
          TextField(controller: details, maxLines: 4, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Scope, inclusions and terms', alignLabelWithHint: true)),
          const SizedBox(height: 17),
          FilledButton(onPressed: sending ? null : () async {
            final value = double.tryParse(amount.text.trim());
            if (value == null || value < 0 || details.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter a valid amount and quotation details.')));
              return;
            }
            refresh(() => sending = true);
            try {
              await supabase.rpc('submit_business_quotation', params: {
                'p_lead_id': lead['id'], 'p_amount': value, 'p_details': details.text.trim(),
                'p_valid_until': DateTime.now().add(const Duration(days: 14)).toUtc().toIso8601String(),
              });
              if (ctx.mounted) Navigator.pop(ctx, true);
            } catch (_) {
              refresh(() => sending = false);
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Quotation could not be sent. Check that this lead is open and belongs to your business.')));
            }
          }, child: sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Send quotation')),
        ])),
      )),
    );
    amount.dispose(); details.dispose();
    if (sent == true) {
      await load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation sent successfully.')));
    }
  }
  @override Widget build(BuildContext context) {
    final visible = filter == 'All' ? rows : rows.where((r) => (r['status'] ?? 'new').toString().toLowerCase() == filter.toLowerCase()).toList();
    return loading ? const Center(child: CircularProgressIndicator(color: green))
      : RefreshIndicator(color: green, onRefresh: load, child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 25), children: [
        const _SectionHeading(kicker: 'BUSINESS WORKSPACE', title: 'Opportunity desk', subtitle: 'Review incoming enquiries and matching requests.'),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _MetricTile(label: 'ALL LEADS', value: rows.length.toString(), icon: Icons.inbox_outlined)),
          const SizedBox(width: 9),
          Expanded(child: _MetricTile(label: 'NEW LEADS', value: rows.where((r) => (r['status'] ?? 'new').toString().toLowerCase() == 'new').length.toString(), icon: Icons.bolt_rounded)),
        ]),
        const SizedBox(height: 17),
        SizedBox(height: 39, child: ListView(scrollDirection: Axis.horizontal, children: ['All', 'New', 'Contacted', 'Accepted', 'Rejected'].map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(s), selected: filter == s, onSelected: (_) => setState(() => filter = s),
            selectedColor: const Color(0xFFDDEFE4), backgroundColor: Colors.white,
            side: BorderSide(color: filter == s ? green : const Color(0xFFE3EAE5)),
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: filter == s ? green : const Color(0xFF65736B))),
        )).toList())),
        const SizedBox(height: 15),
        Row(children: [const Expanded(child: Text('Incoming opportunities', style: TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w900))), Text(visible.length.toString() + ' shown', style: const TextStyle(fontSize: 11, color: Color(0xFF718078)))]),
        const SizedBox(height: 10),
        if (visible.isEmpty) _CompactEmpty(icon: Icons.work_outline_rounded, title: filter == 'All' ? 'No opportunities yet' : 'No ' + filter + ' leads', message: 'Matching enquiries will appear here when they are available to your business account.', action: 'Refresh opportunities', onTap: load)
        else ...visible.map((r) {
          final company = r['companies'] is Map ? r['companies']['display_name'] : null;
          return Material(color: Colors.white, borderRadius: BorderRadius.circular(17), child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () => showModalBottomSheet(context: context, showDragHandle: true, useSafeArea: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
              builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(r['subject'] ?? 'Business opportunity', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: ink))), _StatusPill(status: (r['status'] ?? 'new').toString())]),
                const SizedBox(height: 8), Text(company?.toString() ?? 'DISCOVERLY network', style: const TextStyle(fontSize: 12, color: green, fontWeight: FontWeight.w800)),
                const SizedBox(height: 15), Text(r['message'] ?? 'No additional details provided.', style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF59675F))),
                const SizedBox(height: 15), const Text('Review the enquiry details and prepare a commercial response.', style: TextStyle(fontSize: 12, color: Color(0xFF718078), height: 1.4)),
                if (['new', 'contacted', 'quoted'].contains((r['status'] ?? 'new').toString().toLowerCase())) ...[
                  const SizedBox(height: 17), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { Navigator.pop(context); sendQuote(Map<String, dynamic>.from(r)); }, icon: const Icon(Icons.request_quote_outlined), label: const Text('Send quotation'))),
                ],
              ]))),
            child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEAF2EC), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.bolt_rounded, color: green, size: 22)),
              const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['subject'] ?? 'Business opportunity', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: ink, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4), Text(company?.toString() ?? 'DISCOVERLY network', style: const TextStyle(fontSize: 11, color: Color(0xFF718078))),
              ])),
              const SizedBox(width: 6), _StatusPill(status: (r['status'] ?? 'new').toString()), const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA69F)),
            ])),
          ));
        }),
      ]));
  }
}

class _MetricTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _MetricTile({required this.label, required this.value, required this.icon});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4EBE6))),
    child: Row(children: [
      Container(width: 37, height: 37, decoration: BoxDecoration(color: const Color(0xFFEAF2EC), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: green, size: 19)),
      const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 8, letterSpacing: .5, color: Color(0xFF718078), fontWeight: FontWeight.w900)),
        const SizedBox(height: 3), Text(value, style: const TextStyle(fontSize: 20, color: ink, fontWeight: FontWeight.w900)),
      ])),
    ]),
  );
}

class _SectionHeading extends StatelessWidget {
  final String kicker, title, subtitle;
  const _SectionHeading({required this.kicker, required this.title, required this.subtitle});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(kicker, style: const TextStyle(fontSize: 9, letterSpacing: 1.15, color: green, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4), Text(title, style: const TextStyle(fontSize: 21, letterSpacing: -.4, color: ink, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF718078))),
  ]);
}
class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});
  @override Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'accepted' || normalized == 'completed' ? const Color(0xFF17835F) : normalized == 'rejected' || normalized == 'closed' ? const Color(0xFFB75A51) : const Color(0xFF9A742E);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(status.toUpperCase(), style: TextStyle(fontSize: 8, letterSpacing: .4, color: color, fontWeight: FontWeight.w900)));
  }
}

class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});
  @override State<BusinessOnboardingScreen> createState() => _BusinessOnboardingScreenState();
}
class _BusinessOnboardingScreenState extends State<BusinessOnboardingScreen> {
  final legal = TextEditingController(), display = TextEditingController(), description = TextEditingController();
  final city = TextEditingController(), state = TextEditingController(), phone = TextEditingController(), website = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  String? categoryId;
  bool loading = true, saving = false;
  String? error, notice;

  @override void initState() { super.initState(); loadCategories(); }
  @override void dispose() {
    legal.dispose(); display.dispose(); description.dispose(); city.dispose(); state.dispose(); phone.dispose(); website.dispose(); super.dispose();
  }
  Future<void> loadCategories() async {
    try {
      final data = await supabase.from('categories').select('id,name').eq('category_type', 'industry').eq('is_active', true).order('sort_order');
      if (mounted) setState(() { categories = List<Map<String, dynamic>>.from(data); loading = false; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'Could not load business categories. Please retry.'; });
    }
  }
  Future<void> submit() async {
    if (legal.text.trim().isEmpty || display.text.trim().isEmpty || city.text.trim().isEmpty || state.text.trim().isEmpty || categoryId == null) {
      setState(() => error = 'Complete the required fields: legal name, public name, category, city and state.');
      return;
    }
    final user = supabase.auth.currentUser;
    if (user == null) { setState(() => error = 'Please sign in again to register your business.'); return; }
    setState(() { saving = true; error = null; notice = null; });
    try {
      final slugBase = display.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      final slug = (slugBase.isEmpty ? 'business' : slugBase) + '-' + DateTime.now().microsecondsSinceEpoch.toString();
      final company = await supabase.from('companies').insert({
        'legal_name': legal.text.trim(), 'display_name': display.text.trim(), 'slug': slug,
        'entity_type': 'business', 'description': description.text.trim().isEmpty ? null : description.text.trim(),
        'website_url': website.text.trim().isEmpty ? null : website.text.trim(),
        'created_by': user.id, 'status': 'draft',
      }).select('id').single();
      final companyId = company['id'];
      await supabase.from('company_categories').insert({'company_id': companyId, 'category_id': categoryId, 'is_primary': true});
      await supabase.from('company_profiles').insert({
        'company_id': companyId, 'public_email': user.email,
        'public_phone': phone.text.trim().isEmpty ? null : phone.text.trim(),
        'tagline': description.text.trim().isEmpty ? null : description.text.trim(),
        'profile_completeness': 25,
      });
      await supabase.from('company_locations').insert({
        'company_id': companyId, 'label': 'Head office', 'country_code': 'IN',
        'city': city.text.trim(), 'state': state.text.trim(), 'is_head_office': true, 'is_public': true,
      });
      if (mounted) {
        setState(() { saving = false; notice = 'Business profile saved as a draft. Complete verification before it can appear publicly.'; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business draft created successfully.')));
      }
    } catch (e) {
      if (mounted) setState(() { saving = false; error = 'We could not finish registration. If a draft was created, contact support before submitting again.'; });
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: canvas,
    appBar: AppBar(title: const Text('Register your business')),
    body: loading ? const Center(child: CircularProgressIndicator(color: green))
      : ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), children: [
        Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF0D2A21), borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('JOIN THE DISCOVERLY NETWORK', style: TextStyle(fontSize: 9, color: Color(0xFFE7C987), letterSpacing: 1, fontWeight: FontWeight.w900)),
          SizedBox(height: 9), Text('Put your business on the map.', style: TextStyle(fontSize: 22, height: 1.1, color: Colors.white, fontWeight: FontWeight.w900)),
          SizedBox(height: 6), Text('Create a business draft. Your listing stays private until it is reviewed and published.', style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFFD1E2D9))),
        ])),
        const SizedBox(height: 20),
        const Text('BUSINESS IDENTITY', style: TextStyle(fontSize: 10, color: green, letterSpacing: 1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        TextField(controller: legal, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Registered / legal business name *')),
        const SizedBox(height: 11),
        TextField(controller: display, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Public business name *')),
        const SizedBox(height: 11),
        DropdownButtonFormField<String>(value: categoryId, isExpanded: true, decoration: const InputDecoration(labelText: 'Industry category *'),
          items: categories.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['name'].toString(), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) => setState(() => categoryId = v)),
        const SizedBox(height: 11),
        TextField(controller: description, maxLines: 3, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Business description', alignLabelWithHint: true)),
        const SizedBox(height: 20),
        const Text('LOCATION & CONTACT', style: TextStyle(fontSize: 10, color: green, letterSpacing: 1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: city, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'City *'))),
          const SizedBox(width: 10), Expanded(child: TextField(controller: state, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'State *'))),
        ]),
        const SizedBox(height: 11),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Public contact phone', prefixIcon: Icon(Icons.phone_outlined))),
        const SizedBox(height: 11),
        TextField(controller: website, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Website (optional)', prefixIcon: Icon(Icons.language_rounded))),
        if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Color(0xFFB33A3A), fontSize: 12))),
        if (notice != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(notice!, style: const TextStyle(color: green, fontSize: 12))),
        const SizedBox(height: 17),
        FilledButton(onPressed: saving ? null : submit, child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save business draft')),
        const SizedBox(height: 9),
        const Text('Your business will not be publicly searchable until it passes the platform review process.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF718078), height: 1.4)),
      ]),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final display = user?.userMetadata?['display_name']?.toString();
    final initial = display != null && display.trim().isNotEmpty ? display.trim()[0].toUpperCase() : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'D');
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 25), children: [
      const _SectionHeading(kicker: 'ACCOUNT CENTRE', title: 'Your profile', subtitle: 'Your DISCOVERLY identity and account controls.'),
      const SizedBox(height: 17),
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D241E), Color(0xFF0F6048)]), borderRadius: BorderRadius.circular(21)), child: Row(children: [
        Container(width: 60, height: 60, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), shape: BoxShape.circle, border: Border.all(color: const Color(0x55FFFFFF))), child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
        const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(display?.isNotEmpty == true ? display! : 'DISCOVERLY member', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5), Text(user?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFD5E7DF), fontSize: 11)),
          const SizedBox(height: 8), const Row(children: [Icon(Icons.verified_user_outlined, color: Color(0xFFE7C987), size: 13), SizedBox(width: 5), Text('ACCOUNT ACTIVE', style: TextStyle(color: Color(0xFFE7C987), fontSize: 9, letterSpacing: .8, fontWeight: FontWeight.w900))]),
        ])),
      ])),
      const SizedBox(height: 20),
      const Text('YOUR ACCOUNT', style: TextStyle(fontSize: 10, color: green, letterSpacing: 1, fontWeight: FontWeight.w900)),
      const SizedBox(height: 9),
      _ProfileTile(icon: Icons.person_outline_rounded, title: 'Personal information', subtitle: display?.isNotEmpty == true ? display! : 'Name and sign-in identity', onTap: () => showModalBottomSheet(context: context, showDragHandle: true, useSafeArea: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Personal information', style: TextStyle(fontSize: 21, color: ink, fontWeight: FontWeight.w900)),
        const SizedBox(height: 17), const Text('DISPLAY NAME', style: TextStyle(fontSize: 9, color: green, fontWeight: FontWeight.w900, letterSpacing: .8)),
        const SizedBox(height: 5), Text(display?.isNotEmpty == true ? display! : 'Not provided', style: const TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 15), const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 9, color: green, fontWeight: FontWeight.w900, letterSpacing: .8)),
        const SizedBox(height: 5), Text(user?.email ?? 'Not available', style: const TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8), const Text('Profile editing will be enabled with the profile management module.', style: TextStyle(fontSize: 12, color: Color(0xFF718078), height: 1.4)),
      ])))),
      const SizedBox(height: 8),
      _ProfileTile(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Account updates and activity', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
      const SizedBox(height: 8),
      _ProfileTile(icon: Icons.business_center_outlined, title: 'Business onboarding', subtitle: 'Register a business and manage services', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOnboardingScreen()))),
      const SizedBox(height: 8),
      _ProfileTile(icon: Icons.shield_outlined, title: 'Privacy & security', subtitle: 'Authentication and account protection', onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Account security'), content: Text('Signed in as ' + (user?.email ?? 'your account') + '. Authentication is managed securely by Supabase.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]))),
      const SizedBox(height: 20),
      OutlinedButton.icon(onPressed: () async { await supabase.auth.signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false); }, icon: const Icon(Icons.logout_rounded, size: 18), label: const Text('Sign out'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB33A3A), minimumSize: const Size(0, 49), side: const BorderSide(color: Color(0xFFEBD4D4)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
      const SizedBox(height: 17), const Center(child: Text('DISCOVERLY  •  CONNECT WITH POSSIBILITY', style: TextStyle(color: Color(0xFF8A9790), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .8))),
    ]);
  }
}
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  const _ProfileTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  @override Widget build(BuildContext context) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(16),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5ECE7))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEAF2EC), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: green, size: 20)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: ink)),
          const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF718078))),
        ])),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF8C9991), size: 19),
      ]),
    )),
  );
}

class NotificationsScreen extends StatefulWidget { const NotificationsScreen({super.key}); @override State<NotificationsScreen> createState() => _NotificationsScreenState(); }
class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> rows = []; bool loading = true;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final r = await supabase.from('notifications').select('id,title,body,created_at,read_at').order('created_at', ascending: false).limit(50); if (mounted) setState(() => rows = r); } catch (_) {} if (mounted) setState(() => loading = false); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(title: const Text('Notifications')),
      body: loading
        ? const Center(child: CircularProgressIndicator(color: green))
        : rows.isEmpty
          ? ListView(padding: const EdgeInsets.all(22), children: const [
              SizedBox(height: 18),
              Text('STAY IN THE LOOP', style: TextStyle(fontSize: 10, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              SizedBox(height: 8), Text('All caught up.', style: TextStyle(fontSize: 30, color: ink, fontWeight: FontWeight.w900)),
              SizedBox(height: 7), Text('Important updates about your account and activity will appear here.', style: TextStyle(fontSize: 14, color: Color(0xFF718078), height: 1.45)),
              SizedBox(height: 65), Icon(Icons.notifications_none_rounded, size: 62, color: green),
              SizedBox(height: 15), Center(child: Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ink))),
              SizedBox(height: 6), Center(child: Text('We will let you know when something needs your attention.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF718078), height: 1.4))),
            ])
          : ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 25), children: [
              const Text('UPDATES', style: TextStyle(fontSize: 10, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 7), const Text('Your notifications', style: TextStyle(fontSize: 28, color: ink, fontWeight: FontWeight.w900)),
              const SizedBox(height: 17),
              ...rows.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5ECE7))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE7F2EB), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_active_outlined, color: green)),
                  const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['title'] ?? 'Update', style: const TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5), Text(r['body'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF718078), height: 1.4)),
                  ])),
                  if (r['read_at'] == null) Container(width: 7, height: 7, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                ]),
              )),
            ]),
    );
  }
}
