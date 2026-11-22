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
const ink = Color(0xFF171717);
const green = Color(0xFFED7900);
const gold = Color(0xFF398FC4);
const canvas = Color(0xFFFBF9F6);

class DiscoverlyApp extends StatelessWidget {
  const DiscoverlyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DISCOVERLY',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Inter',
      useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFFBF9F6),
      colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light).copyWith(primary: green, secondary: gold, surface: Colors.white),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: ink, height: 1.08, letterSpacing: -1),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: ink, height: 1.12, letterSpacing: -.6),
        titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: ink),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink),
        bodyLarge: TextStyle(fontSize: 17, color: ink, height: 1.45),
        bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF71675F), height: 1.45),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFBF9F6), foregroundColor: ink, elevation: 0, toolbarHeight: 66, titleTextStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: ink)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white, hintStyle: const TextStyle(fontSize: 17, color: Color(0xFF98A39D)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14), prefixIconColor: green,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFEEE6DE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFEEE6DE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: green, width: 1.5)),
      ),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21), side: const BorderSide(color: Color(0xFFEEE6DE)))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, minimumSize: const Size(0, 54), textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      navigationBarTheme: NavigationBarThemeData(height: 80, backgroundColor: Colors.white, elevation: 0, indicatorColor: const Color(0xFFFFF0E3), labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
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
        colors: [Color(0xFF171717), Color(0xFF33302C)]),
      border: Border.all(color: const Color(0x99F28A19), width: 1),
      boxShadow: const [BoxShadow(color: Color(0x26ED7900), blurRadius: 12, offset: Offset(0, 4))],
    ),
    child: Stack(alignment: Alignment.center, children: [
      Container(width: size * .67, height: size * .67,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: const Color(0x99F28A19), width: 1.1))),
      Transform.rotate(angle: -.55,
        child: Icon(Icons.navigation_rounded, size: size * .48, color: const Color(0xFFFFF6EA))),
      Positioned(right: size * .19, top: size * .17,
        child: Container(width: size * .10, height: size * .10,
          decoration: const BoxDecoration(color: Color(0xFFFFA33D), shape: BoxShape.circle))),
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
    backgroundColor: const Color(0xFFFBF9F6),
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(height: 176, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E1B18), Color(0xFFB85305), Color(0xFFED7900)]),
          borderRadius: BorderRadius.circular(23),
        ), child: Stack(children: [
          Positioned(right: -45, top: -90, child: Container(width: 230, height: 230, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .09), width: 24)))),
          Positioned(right: 34, top: 23, child: Container(width: 95, height: 95, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x66FFFFFF), width: 1.2)))),
          Padding(padding: const EdgeInsets.all(19), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const DiscoverlyMark(size: 40),
              const SizedBox(width: 10), const Text('DISCOVERLY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: .8)),
              const Spacer(), const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFB45E), size: 19),
            ]),
            const Spacer(),
            Text(signup ? 'Create meaningful connections.' : 'A better way to connect.', style: const TextStyle(color: Colors.white, fontSize: 21, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -.4)),
            const SizedBox(height: 6),
            const Text('India’s discovery network for businesses, services and opportunities.', style: TextStyle(color: Color(0xFFFFEFE0), fontSize: 12, height: 1.4)),
          ])),
        ])),
        const SizedBox(height: 19),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFEEE6DE)), boxShadow: const [BoxShadow(color: Color(0x090B2920), blurRadius: 18, offset: Offset(0, 6))]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(signup ? 'Create your account' : 'Welcome back', style: const TextStyle(fontSize: 19, color: ink, fontWeight: FontWeight.w900, letterSpacing: -.3)),
          const SizedBox(height: 4), Text(signup ? 'A few details to get you started.' : 'Sign in to continue to your network.', style: const TextStyle(fontSize: 13, color: Color(0xFF71675F))),
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
          TextButton(onPressed: () => setState(() { signup = !signup; error = null; notice = null; }), child: Text(signup ? 'Already have an account? Sign in' : 'New to DISCOVERLY? Create an account', style: const TextStyle(color: green, fontSize: 13, fontWeight: FontWeight.w800))),
        ])),
        const SizedBox(height: 13),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF82766C)), SizedBox(width: 5),
          Text('SECURE AUTHENTICATION  •  SUPABASE', style: TextStyle(color: Color(0xFF82766C), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .8)),
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
    backgroundColor: const Color(0xFFFBF9F6),
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(66),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 16, 8),
        child: Row(children: [
          const DiscoverlyMark(size: 46),
          const SizedBox(width: 11),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DISCOVERLY', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w900, color: green)),
            Text(titles[index], style: const TextStyle(fontSize: 24, height: 1.1, letterSpacing: -.5, fontWeight: FontWeight.w900, color: ink)),
          ])),
          IconButton.filledTonal(
            tooltip: 'Notifications',
            style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ink, fixedSize: const Size(44, 44), side: const BorderSide(color: Color(0xFFEEE6DE))),
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
      height: 80,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      indicatorColor: const Color(0xFFFFEEDD),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
  String activeCategory = 'All industries';
  String? activeCategorySlug;
  List<Map<String, dynamic>> categories = [];
  Future<void> loadCategories() async {
    try {
      final data = await supabase.from('categories').select('id,name,slug')
        .eq('category_type', 'industry').eq('is_active', true).order('sort_order');
      if (mounted) setState(() => categories = List<Map<String, dynamic>>.from(data));
    } catch (_) {
      if (mounted) setState(() => error = 'Industry categories could not be loaded. Pull down to retry.');
    }
  }
  Future<void> find() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await supabase.rpc('search_businesses', params: {
        'search_query': search.text.trim().isEmpty ? null : search.text.trim(),
        'category_slug': activeCategorySlug, 'state_filter': null,
        'city_filter': city.text.trim().isEmpty ? null : city.text.trim(),
        'result_limit': 40, 'result_offset': 0,
      });
      if (mounted) setState(() => results = (data as List).cast<dynamic>());
    } catch (_) {
      if (mounted) setState(() => error = 'We could not load results. Check your connection and try again.');
    }
    if (mounted) setState(() => loading = false);
  }
  void chooseCategory(Map<String, dynamic>? item) {
    setState(() {
      activeCategory = item?['name']?.toString() ?? 'All industries';
      activeCategorySlug = item?['slug']?.toString();
      search.clear();
    });
    find();
  }
  @override void initState() { super.initState(); loadCategories(); find(); }
  @override void dispose() { search.dispose(); city.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: find, color: green,
    child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 32), children: [
      _DiscoveryCommandCenter(
        resultCount: results.length,
        onExplore: () {
          FocusScope.of(context).requestFocus(FocusNode());
          find();
        },
      ),
      const SizedBox(height: 17),
      Container(padding: const EdgeInsets.fromLTRB(16, 10, 10, 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFEEE6DE)), boxShadow: const [BoxShadow(color: Color(0x080B2920), blurRadius: 14, offset: Offset(0, 4))]), child: Row(children: [
        const Icon(Icons.search_rounded, color: green, size: 22), const SizedBox(width: 8),
        Expanded(child: TextField(controller: search, textInputAction: TextInputAction.search, onSubmitted: (_) => find(), decoration: const InputDecoration(hintText: 'Business, service or keyword', filled: false, border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 10)))),
        Container(width: 48, height: 48, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(12)), child: IconButton(padding: EdgeInsets.zero, onPressed: find, icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 19))),
      ])),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF8A7C70)), const SizedBox(width: 5),
        Expanded(child: TextField(controller: city, textInputAction: TextInputAction.search, onSubmitted: (_) => find(), decoration: const InputDecoration(hintText: 'Add a city to narrow your search', isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 7), hintStyle: TextStyle(fontSize: 11)))),
        TextButton(onPressed: find, style: TextButton.styleFrom(visualDensity: VisualDensity.compact), child: const Text('Apply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
      ]),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Explore categories', style: TextStyle(fontSize: 17, color: ink, fontWeight: FontWeight.w900)),
        const Text('BROWSE', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: .9)),
      ]),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 88,
        ),
        itemBuilder: (context, i) {
          final isAll = i == 0;
          final item = isAll ? null : categories[i - 1];
          final label = isAll ? 'All' : item!['name'].toString();
          final slug = isAll ? null : item!['slug'].toString();
          final selected = activeCategorySlug == slug;
          final icon = isAll ? Icons.apps_rounded : _categoryIcon(slug!);
          return Semantics(
            button: true, label: label,
            child: InkWell(
              onTap: () => chooseCategory(item),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFFE9D4) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? green : const Color(0xFFEEE6DE), width: selected ? 1.5 : 1),
                  boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 43, height: 43,
                    decoration: BoxDecoration(
                      color: selected ? green : const Color(0xFFFFF2E7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: selected ? Colors.white : green, size: 23),
                  ),
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: ink, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: Text('Businesses near your search', style: TextStyle(fontSize: 17, color: ink, fontWeight: FontWeight.w900))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(20)), child: Text('${results.length} RESULTS', style: const TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: .4))),
      ]),
      const SizedBox(height: 4),
      const Text('Real listings from the DISCOVERLY network', style: TextStyle(fontSize: 13, color: Color(0xFF81756A))),
      const SizedBox(height: 11),
      if (loading) const Padding(padding: EdgeInsets.all(25), child: Center(child: CircularProgressIndicator(color: green))),
      if (error != null) _CompactEmpty(icon: Icons.wifi_off_rounded, title: 'Could not load listings', message: error!, action: 'Try again', onTap: find),
      if (!loading && error == null && results.isEmpty) _CompactEmpty(icon: Icons.storefront_outlined, title: 'No listings yet', message: 'There are no published businesses matching this search. Try another keyword or city.', action: 'Reset search', onTap: () { search.clear(); city.clear(); setState(() => activeCategory = 'All'); find(); }),
      if (!loading && error == null) ...results.map((item) => BusinessTile(item: Map<String, dynamic>.from(item as Map))),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFFF3E8), borderRadius: BorderRadius.circular(16)), child: const Row(children: [
        Icon(Icons.tips_and_updates_outlined, color: green, size: 19), SizedBox(width: 9),
        Expanded(child: Text('Looking for something specific? Post a requirement and get discovered by relevant businesses.', style: TextStyle(fontSize: 13, height: 1.35, color: ink, fontWeight: FontWeight.w600))),
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
    height: 218,
    clipBehavior: Clip.antiAlias,
    padding: const EdgeInsets.fromLTRB(20, 17, 18, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: const Color(0xFFF0E5D9)),
      boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 22, offset: Offset(0, 8))],
    ),
    child: Stack(children: [
      Positioned(right: -82, top: -92, child: Container(
        width: 242, height: 242,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFF1E1),
          border: Border.all(color: const Color(0xFFF28A19), width: 25),
        ),
      )),
      Positioned(right: 19, top: 20, child: Container(
        width: 76, height: 76,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFF398FC4), width: 5)),
        child: const Icon(Icons.apartment_rounded, color: Color(0xFF202020), size: 35),
      )),
      Positioned(right: 4, bottom: -29, child: Transform.rotate(
        angle: -.18,
        child: Container(width: 118, height: 92, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFB56B), Color(0xFFE66B00)]),
          borderRadius: BorderRadius.circular(22),
        )),
      )),
      Positioned(right: 102, bottom: -40, child: Container(
        width: 62, height: 76,
        decoration: BoxDecoration(color: const Color(0xFF398FC4).withValues(alpha: .13), borderRadius: BorderRadius.circular(18)),
      )),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 26, height: 4, decoration: BoxDecoration(color: const Color(0xFFF28A19), borderRadius: BorderRadius.circular(5))),
          const SizedBox(width: 9),
          const Text('INDIA-WIDE NETWORK', style: TextStyle(color: Color(0xFF8A5B2B), fontSize: 11, letterSpacing: 1.05, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 22),
        const Text('Discover\nwhat’s next.', style: TextStyle(color: Color(0xFF171717), fontSize: 34, height: 1.00, letterSpacing: -1.15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        const Text('Businesses. Services. Real connections.', style: TextStyle(color: Color(0xFF6F665E), fontSize: 14, height: 1.35, fontWeight: FontWeight.w500)),
        const Spacer(),
        Row(children: [
          const Icon(Icons.storefront_outlined, size: 17, color: Color(0xFFE87908)),
          const SizedBox(width: 7),
          Text('$resultCount listings found', style: const TextStyle(color: Color(0xFF4E4842), fontSize: 12, fontWeight: FontWeight.w800)),
          const Spacer(),
          Material(
            color: const Color(0xFFED7900),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(onTap: onExplore, borderRadius: BorderRadius.circular(13), child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              child: Row(children: [Text('Explore', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)), SizedBox(width: 7), Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17)]),
            )),
          ),
        ]),
      ]),
    ]),
  );
}

IconData _categoryIcon(String slug) {
  if (slug.contains('agriculture')) return Icons.agriculture_rounded;
  if (slug.contains('automotive')) return Icons.directions_car_filled_rounded;
  if (slug.contains('beauty')) return Icons.spa_rounded;
  if (slug.contains('construction')) return Icons.apartment_rounded;
  if (slug.contains('education')) return Icons.school_rounded;
  if (slug.contains('energy')) return Icons.bolt_rounded;
  if (slug.contains('financial')) return Icons.account_balance_rounded;
  if (slug.contains('food')) return Icons.restaurant_rounded;
  if (slug.contains('health')) return Icons.health_and_safety_rounded;
  if (slug.contains('software')) return Icons.devices_rounded;
  if (slug.contains('manufacturing')) return Icons.precision_manufacturing_rounded;
  if (slug.contains('media')) return Icons.campaign_rounded;
  if (slug.contains('retail')) return Icons.shopping_bag_rounded;
  if (slug.contains('wholesale')) return Icons.inventory_2_rounded;
  if (slug.contains('logistics')) return Icons.local_shipping_rounded;
  if (slug.contains('home-local')) return Icons.home_repair_service_rounded;
  if (slug.contains('travel')) return Icons.flight_takeoff_rounded;
  if (slug.contains('government')) return Icons.volunteer_activism_rounded;
  if (slug.contains('mining')) return Icons.factory_rounded;
  return Icons.business_center_rounded;
}
class _CompactEmpty extends StatelessWidget {
  final IconData icon; final String title, message, action; final VoidCallback onTap;
  const _CompactEmpty({required this.icon, required this.title, required this.message, required this.action, required this.onTap});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFEEE6DE))), child: Row(children: [
    Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: green, size: 21)),
    const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3), Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF71675F), height: 1.35)),
      TextButton(onPressed: onTap, style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact), child: Text(action, style: const TextStyle(fontSize: 12, color: green, fontWeight: FontWeight.w900))),
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
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEEE6DE)), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 5))]), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF25211D), Color(0xFFED7900)]), borderRadius: BorderRadius.circular(14)), child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))),
      const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('$title', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ink))),
          const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFF6F1EC), borderRadius: BorderRadius.circular(5)), child: const Text('BUSINESS', style: TextStyle(fontSize: 10, letterSpacing: .5, color: Color(0xFF665D55), fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 4), Text('$desc', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF71675F))),
        if ((city ?? '').isNotEmpty || (state ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 7), child: Row(children: [
          const Icon(Icons.location_on_outlined, size: 12, color: green), const SizedBox(width: 3),
          Expanded(child: Text([city, state].where((v) => v != null && v.isNotEmpty).join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: green, fontWeight: FontWeight.w800))),
        ])),
      ])),
      const SizedBox(width: 3), const Icon(Icons.north_east_rounded, size: 15, color: Color(0xFF9C9187)),
    ]));
  }
}

class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});
  @override State<RequirementsScreen> createState() => _RequirementsScreenState();
}
class _RequirementsScreenState extends State<RequirementsScreen> {
  List<dynamic> rows = [];
  List<Map<String, dynamic>> categories = [];
  bool loading = true;
  Future<void> load() async {
    try {
      final categoryRows = await supabase.from('categories').select('id,name')
        .eq('category_type', 'industry').eq('is_active', true).order('name');
      if (mounted) setState(() => categories = List<Map<String, dynamic>>.from(categoryRows));
    } catch (_) {}
    try {
      final r = await supabase.from('requirements').select('id,title,description,city,state,status,created_at').eq('buyer_user_id', supabase.auth.currentUser!.id).order('created_at', ascending: false);
      if (mounted) setState(() => rows = r);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }
  @override void initState() { super.initState(); load(); }
  Future<void> add() async {
    final title = TextEditingController(), desc = TextEditingController(), city = TextEditingController(), state = TextEditingController();
    String? selectedCategory = categories.isNotEmpty ? categories.first['id'].toString() : null;
    var sending = false;
    final ok = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 22),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          const Text('Create a request', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: ink)),
          const SizedBox(height: 5), const Text('Tell relevant businesses what you need.', style: TextStyle(fontSize: 15, color: Color(0xFF71675F))),
          const SizedBox(height: 20),
          TextField(controller: title, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'What do you need?', prefixIcon: Icon(Icons.lightbulb_outline_rounded))),
          const SizedBox(height: 12),
          TextField(controller: desc, maxLines: 3, maxLength: 4000, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Describe your requirement (20–4000 characters)', alignLabelWithHint: true)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Industry category', prefixIcon: Icon(Icons.category_outlined)),
            items: categories.map((c) => DropdownMenuItem<String>(
              value: c['id'].toString(),
              child: Text(c['name'].toString(), overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (value) => refresh(() => selectedCategory = value),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: city, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_rounded)))),
            const SizedBox(width: 10), Expanded(child: TextField(controller: state, decoration: const InputDecoration(labelText: 'State'))),
          ]),
          const SizedBox(height: 18),
          FilledButton(onPressed: sending ? null : () async {
            if (title.text.trim().length < 5 || title.text.trim().length > 140) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Title must be between 5 and 140 characters.')));
              return;
            }
            if (desc.text.trim().length < 20 || desc.text.trim().length > 4000) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Add at least 20 characters describing your requirement.')));
              return;
            }
            if (selectedCategory == null) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please choose an industry category.')));
              return;
            }
            refresh(() => sending = true);
            try {
              await supabase.rpc('create_requirement_and_match', params: {
                'p_title': title.text.trim(), 'p_description': desc.text.trim(), 'p_requirement_type': 'other',
                'p_category_id': selectedCategory, 'p_city': city.text.trim().isEmpty ? null : city.text.trim(),
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
  Future<void> showDetails(Map<String, dynamic> requirement) async {
    List<dynamic> leads = [];
    try {
      leads = await supabase.from('leads')
        .select('id,subject,status,quotations(id,amount,currency,details,status,valid_until,created_at,companies(display_name))')
        .eq('requirement_id', requirement['id'])
        .order('created_at', ascending: false);
    } catch (_) {}
    if (!mounted) return;
    final quotes = <Map<String, dynamic>>[];
    for (final lead in leads) {
      if (lead['quotations'] is List) {
        for (final q in (lead['quotations'] as List)) {
          quotes.add({...Map<String, dynamic>.from(q as Map), 'lead_subject': lead['subject']});
        }
      }
    }
    await showModalBottomSheet(context: context, showDragHandle: true, useSafeArea: true,
      isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(27))),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false, initialChildSize: .68, minChildSize: .4, maxChildSize: .92,
        builder: (_, controller) => ListView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
          Text(requirement['title'] ?? 'Requirement', style: const TextStyle(fontSize: 22, color: ink, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          Text(requirement['description'] ?? 'No additional details provided.', style: const TextStyle(fontSize: 15, height: 1.45, color: Color(0xFF665D55))),
          const SizedBox(height: 18),
          Row(children: [const Expanded(child: Text('Business quotations', style: TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w900))), Text(quotes.length.toString(), style: const TextStyle(fontSize: 14, color: green, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 10),
          if (quotes.isEmpty) Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFFFBF6F0), borderRadius: BorderRadius.circular(15)), child: const Text('No quotations yet. Business responses will appear here.', style: TextStyle(fontSize: 15, color: Color(0xFF71675F)))),
          ...quotes.map((q) {
            final company = q['companies'] is Map ? q['companies']['display_name'] : null;
            final status = (q['status'] ?? 'sent').toString();
            return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFBF6F0), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFEEE6DE))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(company?.toString() ?? 'Business quotation', style: const TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w900))), _StatusPill(status: status)]),
              const SizedBox(height: 7), Text('₹ ' + (q['amount'] ?? '0').toString(), style: const TextStyle(fontSize: 21, color: green, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6), Text(q['details'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF665D55))),
              if (status == 'sent') ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(sheetContext); respondToQuote(q['id'].toString(), 'rejected'); }, child: const Text('Decline'))),
                  const SizedBox(width: 9),
                  Expanded(child: FilledButton(onPressed: () { Navigator.pop(sheetContext); respondToQuote(q['id'].toString(), 'accepted'); }, child: const Text('Accept quote'))),
                ]),
              ],
            ]));
          }),
        ]),
      ),
    );
  }

  Future<void> respondToQuote(String quoteId, String status) async {
    try {
      final result = await supabase.from('quotations').update({'status': status})
        .eq('id', quoteId).eq('status', 'sent').select('id').maybeSingle();
      if (result == null) throw Exception('Quotation is no longer available');
      await load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'accepted' ? 'Quotation accepted.' : 'Quotation declined.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not update this quotation. Please refresh and try again.')));
    }
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    floatingActionButton: FloatingActionButton.extended(onPressed: add, backgroundColor: green, foregroundColor: Colors.white, icon: const Icon(Icons.add_rounded), label: const Text('New request', style: TextStyle(fontWeight: FontWeight.w800))),
    body: loading ? const Center(child: CircularProgressIndicator(color: green))
      : RefreshIndicator(color: green, onRefresh: load, child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 105), children: [
        const _SectionHeading(kicker: 'BUYER WORKSPACE', title: 'Your requests', subtitle: 'Track requirements and business responses.'),
        const SizedBox(height: 15),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1F1C19), Color(0xFFD06400)]), borderRadius: BorderRadius.circular(14)), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('REQUEST OVERVIEW', style: TextStyle(color: Color(0xFFFFE0C3), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5), Text('${rows.length} active records', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2), const Text('Your posted needs in one place', style: TextStyle(color: Color(0xFFFFE8D3), fontSize: 10)),
          ])),
          Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFFFFB45E), size: 24)),
        ])),
        const SizedBox(height: 16),
        if (rows.isEmpty) _CompactEmpty(icon: Icons.post_add_rounded, title: 'No requirements posted', message: 'Create your first request and let matching businesses discover what you need.', action: 'Create a request', onTap: add)
        else ...rows.map((r) {
          final status = (r['status'] ?? 'open').toString();
          final location = [r['city'], r['state']].where((v) => v != null && v.toString().trim().isNotEmpty).join(', ');
          return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFEEE6DE))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(r['title'] ?? 'Untitled requirement', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w900))),
              _StatusPill(status: status),
            ]),
            const SizedBox(height: 7), Text(r['description'] ?? 'No additional details provided.', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF71675F), height: 1.4)),
            const SizedBox(height: 10), Row(children: [
              const Icon(Icons.location_on_outlined, color: green, size: 14), const SizedBox(width: 4),
              Expanded(child: Text(location.isEmpty ? 'Location not specified' : location, style: const TextStyle(fontSize: 12, color: green, fontWeight: FontWeight.w700))),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9C9187), size: 17),
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
      final r = await supabase.from('leads').select('id,subject,message,status,created_at,companies(display_name),quotations(status)').order('created_at', ascending: false);
      if (mounted) setState(() => rows = r);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }
  String _displayStatus(Map<String, dynamic> lead) {
    final quotes = lead['quotations'] is List ? lead['quotations'] as List : const [];
    final statuses = quotes.map((q) => (q['status'] ?? '').toString().toLowerCase()).toList();
    if (statuses.contains('accepted')) return 'accepted';
    if (statuses.isNotEmpty && statuses.every((s) => s == 'rejected')) return 'rejected';
    return (lead['status'] ?? 'new').toString();
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
          const SizedBox(height: 5), const Text('Your quote will be shared with the customer.', style: TextStyle(fontSize: 14, color: Color(0xFF71675F))),
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
  Future<void> showDetails(Map<String, dynamic> lead) async {
    final company = lead['companies'] is Map ? lead['companies']['display_name']?.toString() : null;
    final status = (lead['status'] ?? 'new').toString();
    final message = (lead['message'] ?? '').toString().trim();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(27))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Opportunity details', style: TextStyle(fontSize: 13, letterSpacing: .8, color: green, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(lead['subject']?.toString() ?? 'Business opportunity', style: const TextStyle(fontSize: 22, height: 1.15, color: ink, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.business_outlined, size: 17, color: green),
              const SizedBox(width: 7),
              Expanded(child: Text(company ?? 'DISCOVERLY customer', style: const TextStyle(fontSize: 15, color: Color(0xFF665D55), fontWeight: FontWeight.w700))),
              _StatusPill(status: status),
            ]),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFBF6F0), borderRadius: BorderRadius.circular(15)),
              child: Text(message.isEmpty ? 'The customer has not added any further details.' : message,
                style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF526158))),
            ),
            const SizedBox(height: 18),
            if (!['accepted', 'rejected', 'closed', 'completed'].contains(status.toLowerCase()))
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  sendQuote(lead);
                },
                icon: const Icon(Icons.request_quote_outlined),
                label: const Text('Prepare quotation'),
              ),
            OutlinedButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  @override Widget build(BuildContext context) {
    final visible = filter == 'All' ? rows : rows.where((r) => _displayStatus(Map<String, dynamic>.from(r)).toLowerCase() == filter.toLowerCase()).toList();
    return loading ? const Center(child: CircularProgressIndicator(color: green))
      : RefreshIndicator(color: green, onRefresh: load, child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 30), children: [
        const _SectionHeading(kicker: 'BUSINESS WORKSPACE', title: 'Opportunity desk', subtitle: 'Review incoming enquiries and matching requests.'),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _MetricTile(label: 'ALL LEADS', value: rows.length.toString(), icon: Icons.inbox_outlined)),
          const SizedBox(width: 9),
          Expanded(child: _MetricTile(label: 'NEW LEADS', value: rows.where((r) => (r['status'] ?? 'new').toString().toLowerCase() == 'new').length.toString(), icon: Icons.bolt_rounded)),
        ]),
        const SizedBox(height: 17),
        SizedBox(height: 46, child: ListView(scrollDirection: Axis.horizontal, children: ['All', 'New', 'Contacted', 'Accepted', 'Rejected'].map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(s), selected: filter == s, onSelected: (_) => setState(() => filter = s),
            selectedColor: const Color(0xFFFFEBD8), backgroundColor: Colors.white,
            side: BorderSide(color: filter == s ? green : const Color(0xFFEEE6DE)),
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: filter == s ? green : const Color(0xFF665D55))),
        )).toList())),
        const SizedBox(height: 15),
        Row(children: [const Expanded(child: Text('Incoming opportunities', style: TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w900))), Text(visible.length.toString() + ' shown', style: const TextStyle(fontSize: 13, color: Color(0xFF71675F)))]),
        const SizedBox(height: 10),
        if (visible.isEmpty) _CompactEmpty(icon: Icons.work_outline_rounded, title: filter == 'All' ? 'No opportunities yet' : 'No ' + filter + ' leads', message: 'Matching enquiries will appear here when they are available to your business account.', action: 'Refresh opportunities', onTap: load)
        else ...visible.map((r) {
          final company = r['companies'] is Map ? r['companies']['display_name'] : null;
          return Material(color: Colors.white, borderRadius: BorderRadius.circular(17), child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () => showDetails(Map<String, dynamic>.from(r)),
              child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.bolt_rounded, color: green, size: 22)),
              const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['subject'] ?? 'Business opportunity', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4), Text(company?.toString() ?? 'DISCOVERLY network', style: const TextStyle(fontSize: 13, color: Color(0xFF71675F))),
              ])),
              const SizedBox(width: 6), _StatusPill(status: _displayStatus(Map<String, dynamic>.from(r))), const Icon(Icons.chevron_right_rounded, color: Color(0xFF9C9187)),
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
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEEE6DE))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: green, size: 19)),
      const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, letterSpacing: .5, color: Color(0xFF71675F), fontWeight: FontWeight.w900)),
        const SizedBox(height: 3), Text(value, style: const TextStyle(fontSize: 20, color: ink, fontWeight: FontWeight.w900)),
      ])),
    ]),
  );
}

class _SectionHeading extends StatelessWidget {
  final String kicker, title, subtitle;
  const _SectionHeading({required this.kicker, required this.title, required this.subtitle});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(kicker, style: const TextStyle(fontSize: 11, letterSpacing: 1.15, color: green, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4), Text(title, style: const TextStyle(fontSize: 21, letterSpacing: -.4, color: ink, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF71675F))),
  ]);
}
class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});
  @override Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'accepted' || normalized == 'completed' ? const Color(0xFF17835F) : normalized == 'rejected' || normalized == 'closed' ? const Color(0xFFB75A51) : const Color(0xFF9A742E);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: .4, color: color, fontWeight: FontWeight.w900)));
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
        Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF1E1B18), borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('JOIN THE DISCOVERLY NETWORK', style: TextStyle(fontSize: 11, color: Color(0xFFFFB45E), letterSpacing: 1, fontWeight: FontWeight.w900)),
          SizedBox(height: 9), Text('Put your business on the map.', style: TextStyle(fontSize: 22, height: 1.1, color: Colors.white, fontWeight: FontWeight.w900)),
          SizedBox(height: 6), Text('Create a business draft. Your listing stays private until it is reviewed and published.', style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFFFFE8D3))),
        ])),
        const SizedBox(height: 20),
        const Text('BUSINESS IDENTITY', style: TextStyle(fontSize: 12, color: green, letterSpacing: 1, fontWeight: FontWeight.w900)),
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
        const Text('LOCATION & CONTACT', style: TextStyle(fontSize: 12, color: green, letterSpacing: 1, fontWeight: FontWeight.w900)),
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
        const Text('Your business will not be publicly searchable until it passes the platform review process.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF71675F), height: 1.4)),
      ]),
  );
}

class _AdminAccessTile extends StatelessWidget {
  const _AdminAccessTile();
  @override Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase.from('user_roles').select('role').eq('user_id', user.id),
      builder: (context, snapshot) {
        final roles = snapshot.data ?? [];
        final allowed = roles.any((r) => r['role'] == 'admin' || r['role'] == 'moderator');
        if (!allowed) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _ProfileTile(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin console',
            subtitle: 'Moderation, verification and platform review',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminConsoleScreen())),
          ),
        );
      },
    );
  }
}

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});
  @override State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}
class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> companies = [];
  List<Map<String, dynamic>> verifications = [];
  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Please sign in again.');
      final roles = await supabase.from('user_roles').select('role').eq('user_id', user.id);
      if (!roles.any((r) => r['role'] == 'admin' || r['role'] == 'moderator')) {
        throw Exception('This account does not have admin access.');
      }
      final results = await Future.wait([
        supabase.from('companies').select('id,display_name,legal_name,status,created_at').eq('status','pending_review').order('created_at').limit(30),
        supabase.from('verification_cases').select('id,company_id,verification_type,status,reference_value,document_path,submitted_at').inFilter('status',['submitted','in_review']).order('submitted_at').limit(30),
      ]);
      if (mounted) setState(() {
        companies = List<Map<String, dynamic>>.from(results[0]);
        verifications = List<Map<String, dynamic>>.from(results[1]);
        loading = false;
      });
    } catch (e) { if (mounted) setState(() { error = e.toString().replaceFirst('Exception: ', ''); loading = false; }); }
  }
  Future<void> decideCompany(String id, String status) async {
    try {
      await supabase.from('companies').update({'status':status}).eq('id',id);
      await load();
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
  }
  Future<void> decideVerification(String id, String status) async {
    try {
      await supabase.from('verification_cases').update({
        'status':status, 'reviewer_id':supabase.auth.currentUser!.id,
        'reviewed_at':DateTime.now().toUtc().toIso8601String(),
      }).eq('id',id);
      await load();
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: canvas,
    appBar: AppBar(title: const Text('Admin console'), actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh_rounded))]),
    body: loading ? const Center(child: CircularProgressIndicator(color: green))
      : RefreshIndicator(color: green, onRefresh: load, child: ListView(
        padding: const EdgeInsets.fromLTRB(18,12,18,28),
        children: [
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors:[Color(0xFF211D19),Color(0xFFB94E00)]),borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DISCOVERLY CONTROL CENTRE',style:TextStyle(color:Color(0xFFFFC17A),fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
            const SizedBox(height:8), const Text('Platform review',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900)),
            const SizedBox(height:6), Text('${companies.length} business reviews · ${verifications.length} verification cases',style:const TextStyle(color:Color(0xFFFFE8D3),fontSize:14)),
          ])),
          if (error != null) Padding(padding: const EdgeInsets.only(top:12),child:Text(error!,style:const TextStyle(color:Color(0xFFB33A3A)))),
          const SizedBox(height:20),
          const Text('BUSINESS APPROVALS',style:TextStyle(fontSize:12,color:green,fontWeight:FontWeight.w900,letterSpacing:1)),
          const SizedBox(height:9),
          if (companies.isEmpty) const Text('No businesses waiting for review.',style:TextStyle(color:Color(0xFF71675F))),
          ...companies.map((c) => Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFFEEE6DE))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text((c['display_name'] ?? c['legal_name'] ?? 'Business').toString(),style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900,color:ink)),
            const SizedBox(height:8),Row(children:[Expanded(child:OutlinedButton(onPressed:()=>decideCompany(c['id'].toString(),'rejected'),child:const Text('Reject'))),const SizedBox(width:8),Expanded(child:FilledButton(onPressed:()=>decideCompany(c['id'].toString(),'published'),child:const Text('Publish')))]),
          ]))),
          const SizedBox(height:14),
          const Text('VERIFICATION QUEUE',style:TextStyle(fontSize:12,color:green,fontWeight:FontWeight.w900,letterSpacing:1)),
          const SizedBox(height:9),
          if (verifications.isEmpty) const Text('No verification cases waiting.',style:TextStyle(color:Color(0xFF71675F))),
          ...verifications.map((v) => Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFFEEE6DE))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text((v['verification_type'] ?? 'Business verification').toString().replaceAll('_',' ').toUpperCase(),style:const TextStyle(fontSize:14,fontWeight:FontWeight.w900,color:ink)),
            if (v['reference_value'] != null) Padding(padding:const EdgeInsets.only(top:4),child:Text(v['reference_value'].toString(),style:const TextStyle(color:Color(0xFF71675F),fontSize:12))),
            const SizedBox(height:8),Row(children:[Expanded(child:OutlinedButton(onPressed:()=>decideVerification(v['id'].toString(),'rejected'),child:const Text('Reject'))),const SizedBox(width:8),Expanded(child:FilledButton(onPressed:()=>decideVerification(v['id'].toString(),'verified'),child:const Text('Verify')))]),
          ]))),
        ],
      )),
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
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1F1C19), Color(0xFFD96300)]), borderRadius: BorderRadius.circular(21)), child: Row(children: [
        Container(width: 60, height: 60, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), shape: BoxShape.circle, border: Border.all(color: const Color(0x55FFFFFF))), child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
        const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(display?.isNotEmpty == true ? display! : 'DISCOVERLY member', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5), Text(user?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFFFEFE0), fontSize: 11)),
          const SizedBox(height: 8), const Row(children: [Icon(Icons.verified_user_outlined, color: Color(0xFFFFB45E), size: 13), SizedBox(width: 5), Text('ACCOUNT ACTIVE', style: TextStyle(color: Color(0xFFFFB45E), fontSize: 11, letterSpacing: .8, fontWeight: FontWeight.w900))]),
        ])),
      ])),
      const SizedBox(height: 20),
      const Text('YOUR ACCOUNT', style: TextStyle(fontSize: 12, color: green, letterSpacing: 1, fontWeight: FontWeight.w900)),
      const SizedBox(height: 9),
      _ProfileTile(icon: Icons.person_outline_rounded, title: 'Personal information', subtitle: display?.isNotEmpty == true ? display! : 'Name and sign-in identity', onTap: () => showModalBottomSheet(context: context, showDragHandle: true, useSafeArea: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Personal information', style: TextStyle(fontSize: 21, color: ink, fontWeight: FontWeight.w900)),
        const SizedBox(height: 17), const Text('DISPLAY NAME', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: .8)),
        const SizedBox(height: 5), Text(display?.isNotEmpty == true ? display! : 'Not provided', style: const TextStyle(fontSize: 17, color: ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 15), const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w900, letterSpacing: .8)),
        const SizedBox(height: 5), Text(user?.email ?? 'Not available', style: const TextStyle(fontSize: 17, color: ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8), const Text('Profile editing will be enabled with the profile management module.', style: TextStyle(fontSize: 14, color: Color(0xFF71675F), height: 1.4)),
      ])))),
      const SizedBox(height: 8),
      _ProfileTile(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Account updates and activity', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
      const SizedBox(height: 8),
      _ProfileTile(icon: Icons.business_center_outlined, title: 'Business onboarding', subtitle: 'Register a business and manage services', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessOnboardingScreen()))),
      const SizedBox(height: 8),
      const _AdminAccessTile(),
      const SizedBox(height: 8),
      _ProfileTile(icon: Icons.shield_outlined, title: 'Privacy & security', subtitle: 'Authentication and account protection', onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Account security'), content: Text('Signed in as ' + (user?.email ?? 'your account') + '. Authentication is managed securely by Supabase.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]))),
      const SizedBox(height: 20),
      OutlinedButton.icon(onPressed: () async { await supabase.auth.signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false); }, icon: const Icon(Icons.logout_rounded, size: 18), label: const Text('Sign out'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB33A3A), minimumSize: const Size(0, 49), side: const BorderSide(color: Color(0xFFEBD4D4)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
      const SizedBox(height: 17), const Center(child: Text('DISCOVERLY  •  CONNECT WITH POSSIBILITY', style: TextStyle(color: Color(0xFF8A7D73), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8))),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEE6DE))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: green, size: 20)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: ink)),
          const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF71675F))),
        ])),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF8C8177), size: 19),
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
              Text('STAY IN THE LOOP', style: TextStyle(fontSize: 12, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              SizedBox(height: 8), Text('All caught up.', style: TextStyle(fontSize: 30, color: ink, fontWeight: FontWeight.w900)),
              SizedBox(height: 7), Text('Important updates about your account and activity will appear here.', style: TextStyle(fontSize: 16, color: Color(0xFF71675F), height: 1.45)),
              SizedBox(height: 65), Icon(Icons.notifications_none_rounded, size: 62, color: green),
              SizedBox(height: 15), Center(child: Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ink))),
              SizedBox(height: 6), Center(child: Text('We will let you know when something needs your attention.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF71675F), height: 1.4))),
            ])
          : ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 25), children: [
              const Text('UPDATES', style: TextStyle(fontSize: 12, color: green, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 7), const Text('Your notifications', style: TextStyle(fontSize: 28, color: ink, fontWeight: FontWeight.w900)),
              const SizedBox(height: 17),
              ...rows.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEEE6DE))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFFFF0E3), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_active_outlined, color: green)),
                  const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['title'] ?? 'Update', style: const TextStyle(fontSize: 17, color: ink, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5), Text(r['body'] ?? '', style: const TextStyle(fontSize: 15, color: Color(0xFF71675F), height: 1.4)),
                  ])),
                  if (r['read_at'] == null) Container(width: 7, height: 7, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                ]),
              )),
            ]),
    );
  }
}
