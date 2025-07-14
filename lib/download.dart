import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'main.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_saver/file_saver.dart';
import 'dart:html' as html; // רק ל־Web

void main() => runApp(const download());

class download extends StatelessWidget {
  const download({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        children: const [_TopNavBar(), Divider(height: 1), ProductsRow()],
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
          GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("home");
              },
              child: Image.asset('opendcim.png')),
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

class ProductsRow extends StatelessWidget {
  const ProductsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView מאפשר גלילה אופקית במסכים צרים.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Row(
        children: const [
          ProductCard(
            imageUrl: 'pic1.png',
            title: 'v23.04',
            description:
                'Image mapping with custom image for creating clickable zones for each cabinet\n\n Overlay layers on map for Power, Space, Temperature, and Weight capacity \n\n Mapping of power connections from device -> power strip -> panel -> source feed \n\n Mapping of network connections to any device classified as a switch',
            buttonText: 'download v23.04',
          ),
          ProductCard(
            imageUrl: 'pic2.png',
            title: 'v23.03',
            description:
                'Chassis device support\n\n Graphical Cabinet Viewer (user must supply graphic images) \n\n Multiple levels of user rights \n\n Basic workflow system for generating rack requests \n\n Reporting on Hosting Costs by department based on a cost per U and cost per Watt formula',
            buttonText: 'download v23.03',
          ),
          ProductCard(
            imageUrl: 'pic3.png',
            title: 'v23.02',
            description:
                'Storage Room view per Data Center\n\n Support for automatic transfer switches \n\n Auto-Transfer Switches will poll SNMP for redundancy status \n\nXML Export for Computational Fluid Dynamic Analysis software',
            buttonText: 'download v23.02',
          ),
          ProductCard(
            imageUrl: 'pic4.png',
            title: 'v23.01',
            description:
                'Image mapping with custom image for creating clickable zones for each cabinet\n\n Overlay layers on map for Power, Space, Temperature, and Weight capacity \n\n Mapping of power connections from device -> power strip -> panel -> source feed \n\n Mapping of network connections to any device classified as a switch',
            buttonText: 'download v23.01',
          ),
          ProductCard(
            imageUrl: 'pic5.png',
            title: 'v21.01',
            description:
                'Image mapping with custom image for creating clickable zones for each cabinet\n\n Overlay layers on map for Power, Space, Temperature, and Weight capacity \n\n Mapping of power connections from device -> power strip -> panel -> source feed \n\n Mapping of network connections to any device classified as a switch',
            buttonText: 'download v21.01',
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.buttonText,
  });

  final String imageUrl;
  final String title;
  final String description;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 240, // שומר על רוחב קבוע לכל כרטיס
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // תמונה בחלק העליון
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Image.asset(
                imageUrl,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            // כותרת
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // תיאור
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // כפתור
            SizedBox(
              width: 180,
              child: DownloadGzButton(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class DownloadGzButton extends StatelessWidget {
  const DownloadGzButton({super.key});

  Future<void> _download() async {
    // טוען את הקובץ מה-assets
    final data = await rootBundle.load('dc.gz');
    final bytes = data.buffer.asUint8List();

    // ל-Web – יוצר <a download> עם data:URI
    final b64 = base64Encode(bytes);
    final url = 'data:application/gzip;base64,$b64';
    html.AnchorElement(href: url)
      ..download = 'dc.gz'
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
      onPressed: _download,
      child: const Text(
        'הורד את גרסה זו',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
