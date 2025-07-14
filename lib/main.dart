import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opendcim/download.dart';

void main() => runApp(const Blog2025App());

class Blog2025App extends StatelessWidget {
  const Blog2025App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // The default route (home)
      routes: {
        //'/': (context) => Blog2025App(),
        'download': (context) => download(),
        'home': (context) => Blog2025App(),
      },
      title: 'Interactive Blog 2025',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                Σ NAV-BAR                                   */
/* -------------------------------------------------------------------------- */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          _TopNavBar(),
          Divider(height: 1),
          Expanded(child: _HeroSection()),
        ],
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // לוגו (מלבן שחור זמני)
          Image.asset('opendcim.png'),
          const SizedBox(width: 32),

          // קישורים ראשיים
          const _NavLink('about'),
          const _NavLink('screenshots'),
          const _NavLink('features'),
          const _NavLink('demo'),
          const _NavLink('developrs'),
          const _NavLink('downloads'),
          const _NavLink('faq'),
          const _NavLink('participation'),
          const _NavLink('support'),
          const _NavLink('wiki'),
          const Spacer(),

          // אייקון חיפוש
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
          const _NavLink('Contact team'),
          const _NavLink('Login'),

          // כפתור “Start for Free”
          const SizedBox(width: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {},
            child: const Text('Start for Free'),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  const _NavLink(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {},
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               Σ HERO-SECTION                               */
/* -------------------------------------------------------------------------- */

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 950;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // פוסט ראשי – 2/3 מהרוחב
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _MainPostImage(),
                    SizedBox(height: 24),
                    _MainPostText(),
                  ],
                ),
              ),

              SizedBox(width: isWide ? 32 : 0, height: isWide ? 0 : 48),

              // Trending – 1/3 מהרוחב
              Flexible(
                flex: 1,
                child: Column(
                  children: const [
                    _TrendingHeader(),
                    _TrendingItem(
                      title:
                          'Learn the Current Key Features of opendcim platform',
                      date: 'Jun 26, 2024 · 14 min',
                      tag: 'learning',
                    ),
                    _TrendingItem(
                      title: 'Frequently Asked Questions about Opendcim',
                      date: 'Mar 21, 2024 · 14 min',
                      tag: 'Video podcast',
                    ),
                    _TrendingItem(
                      title: 'The implementing for Users of openDCIM',
                      date: 'Mar 5, 2024 · 10 min',
                      tag: 'Recording software',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------- Main post elements --------------------------- */

class _MainPostImage extends StatelessWidget {
  const _MainPostImage();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.asset('map.png'), // placeholder image
    );
  }
}

class _MainPostText extends StatelessWidget {
  const _MainPostText();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(color: Colors.grey[800]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to openDCIM | web based Data Center Infrastructure Management application',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'DCIM means many different things to many different people, and there is a multitude of commercial applications available. openDCIM does not contend to be a function by function replacement for commercial applications. Instead, openDCIM covers the majority of features needed by the developers - as is often the case of open source software. The software is released under the GPL v3 license.',
          style: bodyStyle,
        ),
        const SizedBox(height: 20),

        // שורת מחבר + תגיות
        Row(
          children: [
            // אווטאר זמני (ריבוע שחור)
            Container(width: 36, height: 36, color: Colors.black),
            const SizedBox(width: 10),
            Text('Stephen Robles',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('  Video & Podcast Creator', style: bodyStyle),

            const SizedBox(width: 12),
            _CategoryChip('Podcast recording'),

            const SizedBox(width: 12),
            Text('October 11, 2024 · 8 min', style: bodyStyle),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E7FD),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/* ----------------------------- Trending column ---------------------------- */

class _TrendingHeader extends StatelessWidget {
  const _TrendingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // תיבת רקע סגול-שחור (כמו בתמונה)
        gradient: const LinearGradient(
          colors: [Color(0xFF3B2BFA), Color(0xFF161033)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed("download");
        },
        child: const Text(
          'Download now!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TrendingItem extends StatelessWidget {
  final String title;
  final String date;
  final String tag;
  const _TrendingItem({
    required this.title,
    required this.date,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(color: Colors.grey[800]);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // תמונת thumbnail
          Container(width: 200, height: 90, child: Image.asset('learn.jpg')),
          const SizedBox(width: 16),

          // טקסט
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(date, style: bodyStyle),
                const SizedBox(height: 2),
                _CategoryChip(tag),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
