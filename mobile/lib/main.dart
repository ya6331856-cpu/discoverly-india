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
      titleSpacing: 18,
      title: Row(children: [
        Container(width: 37, height: 37, decoration: BoxDecoration(gradient: const LinearGradient(colors: [green, Color(0xFF123F32)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 21)),
        const SizedBox(width: 10), const Text('DISCOVERLY', style: TextStyle(letterSpacing: .7, fontSize: 18)),
      ]),
      actions: [
        IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFE5ECE7))),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          icon: const Icon(Icons.notifications_none_rounded, size: 23),
        ),
        const SizedBox(width: 14),
      ],
    ),
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: SafeArea(top: false, child: Container(
      margin: const EdgeInsets.fromLTRB(14, 5, 14, 10), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23), border: Border.all(color: const Color(0xFFE4EBE6)), boxShadow: const [BoxShadow(color: Color(0x120B2920), blurRadius: 20, offset: Offset(0, 6))]),
      child: Row(children: [
        _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Discover', selected: index == 0, onTap: () => setState(() => index = 0)),
        _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Requests', selected: index == 1, onTap: () => setState(() => index = 1)),
        _NavItem(icon: Icons.work_outline_rounded, activeIcon: Icons.work_rounded, label: 'Leads', selected: index == 2, onTap: () => setState(() => index = 2)),
        _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', selected: index == 3, onTap: () => setState(() => index = 3)),
      ]),
    )),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon; final String label; final bool selected; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) => Expanded(child: InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(17),
    child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: selected ? const Color(0xFFE6F2EB) : Colors.transparent, borderRadius: BorderRadius.circular(17)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(selected ? activeIcon : icon, size: 21, color: selected ? green : const Color(0xFF829088)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w900 : FontWeight.w600, color: selected ? green : const Color(0xFF829088))),
      ]),
    ),
  ));
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
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('DISCOVER ACROSS INDIA', style: TextStyle(fontSize: 9, letterSpacing: 1.25, color: green, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          const Text('Find your next connection', style: TextStyle(fontSize: 19, color: ink, fontWeight: FontWeight.w900, letterSpacing: -.35)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFE8F1EB), borderRadius: BorderRadius.circular(30)), child: const Row(children: [
          Icon(Icons.public_rounded, color: green, size: 14), SizedBox(width: 5),
          Text('India', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w800)),
        ])),
      ]),
      const SizedBox(height: 13),
      Container(
        height: 154, clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0B211C), Color(0xFF0D4938), Color(0xFF087E63)]), borderRadius: BorderRadius.circular(22)),
        child: Stack(children: [
          Positioned(right: -24, top: -53, child: Container(width: 195, height: 195, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .10), width: 22)))),
          Positioned(right: 22, top: 22, child: Container(width: 98, height: 98, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x66E4C887), width: 1.2)))),
          Positioned(right: 53, top: 53, child: Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFE8CB8D), Color(0x00E8CB8D)])))),
          Positioned(left: 17, top: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: const Text('THE NETWORK FOR WHAT’S NEXT', style: TextStyle(color: Color(0xFFDDEDE5), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .8)))),
          const Positioned(left: 17, top: 51, child: Text('Discover. Connect.\nMove forward.', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.13, fontWeight: FontWeight.w900, letterSpacing: -.5))),
          const Positioned(left: 18, bottom: 16, child: Row(children: [
            Icon(Icons.bolt_rounded, color: Color(0xFFE7C987), size: 15), SizedBox(width: 4),
            Text('Businesses  •  Services  •  Opportunities', style: TextStyle(color: Color(0xFFD3E6DD), fontSize: 9, fontWeight: FontWeight.w700)),
          ])),
        ]),
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
      SizedBox(height: 82, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 9), itemBuilder: (context, i) {
        final item = categories[i];
        final selected = activeCategory == item.label;
        return InkWell(onTap: () => chooseCategory(item), borderRadius: BorderRadius.circular(15), child: AnimatedContainer(
          duration: const Duration(milliseconds: 180), width: 73, padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(color: selected ? const Color(0xFFE4F1E9) : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? green : const Color(0xFFE6ECE7))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(item.icon, color: green, size: 21), const SizedBox(height: 6),
            Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: ink, fontWeight: FontWeight.w800)),
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
    return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE5ECE7)), boxShadow: const [BoxShadow(color: Color(0x050B2920), blurRadius: 9, offset: Offset(0, 3))]), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 47, height: 47, alignment: Alignment.center, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF123F32), Color(0xFF087E63)]), borderRadius: BorderRadius.circular(14)), child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900))),
      const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('$title', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: ink))),
          const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFF1F4F1), borderRadius: BorderRadius.circular(5)), child: const Text('BUSINESS', style: TextStyle(fontSize: 7, letterSpacing: .5, color: Color(0xFF65736B), fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 4), Text('$desc', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, height: 1.35, color: Color(0xFF718078))),
        if ((city ?? '').isNotEmpty || (state ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 7), child: Row(children: [
          const Icon(Icons.location_on_outlined, size: 12, color: green), const SizedBox(width: 3),
          Expanded(child: Text([city, state].where((v) => v != null && v.isNotEmpty).join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: green, fontWeight: FontWeight.w800))),
        ])),
      ])),
      const SizedBox(width: 3), const Icon(Icons.north_east_rounded, size: 15, color: Color(0xFF9AA69F)),
    ]));
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
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your requirement could not be posted. Please check the details and try again.'))); }
  }
  @override
  Widget build(BuildContext context) {
    final children = rows.map((r) => Container(
      margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5ECE7))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(r['title'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ink))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE5F2EB), borderRadius: BorderRadius.circular(30)), child: Text((r['status'] ?? 'open').toString().toUpperCase(), style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w900)))]),
        const SizedBox(height: 10),
        Text(r['description'] ?? 'Requirement details', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Color(0xFF718078), height: 1.4)),
        const SizedBox(height: 12),
        Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: green), const SizedBox(width: 4), Text('${r['city'] ?? ''} ${r['state'] ?? ''}', style: const TextStyle(fontSize: 12, color: green, fontWeight: FontWeight.w700))]),
      ]),
    )).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(onPressed: add, backgroundColor: green, foregroundColor: Colors.white, icon: const Icon(Icons.add_rounded), label: const Text('Post requirement', style: TextStyle(fontWeight: FontWeight.w800))),
      body: loading ? const Center(child: CircularProgressIndicator(color: green))
          : rows.isEmpty ? ListView(padding: const EdgeInsets.all(20), children: const [
              SizedBox(height: 14),
              Text('YOUR REQUESTS', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
              SizedBox(height: 8), Text('Make it happen.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: ink)),
              SizedBox(height: 7), Text('Tell businesses what you need and let the right providers find you.', style: TextStyle(fontSize: 15, color: Color(0xFF718078), height: 1.4)),
              SizedBox(height: 55),
              Icon(Icons.assignment_add, size: 58, color: green),
              SizedBox(height: 14), Center(child: Text('No requests yet', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: ink))),
              SizedBox(height: 7), Center(child: Text('Post your first requirement to start receiving relevant business matches.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF718078), height: 1.5))),
            ])
          : ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 100), children: [
              const Text('YOUR REQUESTS', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
              const SizedBox(height: 8), const Text('Your requirements', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
              const SizedBox(height: 6), const Text('Keep track of what you have requested.', style: TextStyle(fontSize: 14, color: Color(0xFF718078))),
              const SizedBox(height: 20), ...children,
            ]),
    );
  }
}

class OpportunitiesScreen extends StatefulWidget { const OpportunitiesScreen({super.key}); @override State<OpportunitiesScreen> createState() => _OpportunitiesScreenState(); }
class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<dynamic> rows = []; bool loading = true;
  Future<void> load() async { try { final r = await supabase.from('leads').select('id,subject,message,status,created_at,companies(display_name)').order('created_at', ascending: false); if (mounted) setState(() => rows = r); } catch (_) {} if (mounted) setState(() => loading = false); }
  @override void initState() { super.initState(); load(); }
  @override Widget build(BuildContext context) => loading
    ? const Center(child: CircularProgressIndicator(color: green))
    : rows.isEmpty
      ? ListView(padding: const EdgeInsets.all(20), children: const [
          SizedBox(height: 14),
          Text('OPPORTUNITY DESK', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
          SizedBox(height: 8), Text('Your next big lead.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: ink)),
          SizedBox(height: 7), Text('Relevant business opportunities will appear here.', style: TextStyle(fontSize: 15, color: Color(0xFF718078))),
          SizedBox(height: 60), Icon(Icons.work_outline_rounded, size: 58, color: green),
          SizedBox(height: 14), Center(child: Text('No opportunities yet', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: ink))),
          SizedBox(height: 7), Center(child: Text('Matching opportunities will appear here as businesses and customers connect.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF718078), height: 1.5))),
        ])
      : ListView(padding: const EdgeInsets.all(18), children: [
          const Text('OPPORTUNITY DESK', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
          const SizedBox(height: 8), const Text('Explore leads', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: ink)),
          const SizedBox(height: 6), const Text('Stay close to new business opportunities.', style: TextStyle(fontSize: 14, color: Color(0xFF718078))),
          const SizedBox(height: 20),
          ...rows.map((r) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5ECE7))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE5F2EB), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.bolt_rounded, color: green, size: 24)), const SizedBox(width: 12), Expanded(child: Text(r['subject'] ?? 'Opportunity', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ink))), Text((r['status'] ?? 'NEW').toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: green, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 12), Text(r['message'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF718078), height: 1.45)),
            const SizedBox(height: 12), const Divider(color: Color(0xFFE5ECE7)), const Row(children: [Icon(Icons.auto_awesome_outlined, size: 16, color: gold), SizedBox(width: 6), Text('DISCOVERLY opportunity', style: TextStyle(fontSize: 12, color: Color(0xFF718078), fontWeight: FontWeight.w700))]),
          ]))),
        ]);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final display = user?.userMetadata?['display_name']?.toString();
    final initial = display != null && display.trim().isNotEmpty ? display.trim()[0].toUpperCase() : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'D');
    return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 30), children: [
      const Text('YOUR SPACE', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
      const SizedBox(height: 8), const Text('Your profile', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 7), const Text('Manage your account and stay connected.', style: TextStyle(fontSize: 15, color: Color(0xFF718078))),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ink, Color(0xFF123F32), green]), borderRadius: BorderRadius.circular(25)), child: Row(children: [
        Container(width: 62, height: 62, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), shape: BoxShape.circle, border: Border.all(color: Colors.white30)), child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900))),
        const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(display?.isNotEmpty == true ? display! : 'DISCOVERLY member', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5), Text(user?.email ?? '', style: const TextStyle(color: Color(0xFFD5E7DF), fontSize: 13)),
          const SizedBox(height: 9), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(20)), child: const Text('MEMBER ACCOUNT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8))),
        ])),
      ])),
      const SizedBox(height: 27), const Text('ACCOUNT & SETTINGS', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      const SizedBox(height: 12),
      _ProfileTile(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Updates and account activity', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
      const SizedBox(height: 10), const _ProfileTile(icon: Icons.business_outlined, title: 'Business portal', subtitle: 'Manage your business from the website'),
      const SizedBox(height: 10), const _ProfileTile(icon: Icons.security_outlined, title: 'Privacy & security', subtitle: 'Your account is protected by Supabase'),
      const SizedBox(height: 24),
      OutlinedButton.icon(onPressed: () async { await supabase.auth.signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false); }, icon: const Icon(Icons.logout_rounded), label: const Text('Sign out'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB33A3A), minimumSize: const Size(0, 54), side: const BorderSide(color: Color(0xFFEBD4D4)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      const SizedBox(height: 20), const Center(child: Text('DISCOVERLY  •  CONNECT WITH POSSIBILITY', style: TextStyle(color: Color(0xFF718078), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8))),
    ]);
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback? onTap;
  const _ProfileTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  @override Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5ECE7))), child: Row(children: [
    Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFFE5F2EB), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: green, size: 23)),
    const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF718078)))])),
    const Icon(Icons.chevron_right_rounded, color: Color(0xFF718078)),
  ]))));
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
