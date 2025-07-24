import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_saver/file_saver.dart';
import 'package:srv_hub/services/users_service.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final AuthService _authService = AuthService();

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = _authService.getCurrentUser() != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('openDCIM Downloads'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: isLoggedIn ? [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ] : [],
        leading: !isLoggedIn ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ) : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to openDCIM Downloads',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'DCIM means many different things to many different people, and there is a multitude of commercial applications available. openDCIM does not contend to be a function by function replacement for commercial applications. Instead, openDCIM covers the majority of features needed by the developers - as is often the case of open source software. The software is released under the GPL v3 license.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Available Versions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  ProductCard(
                    imageUrl: 'assets/map.png',
                    title: 'v23.04',
                    description:
                        'Image mapping with custom image for creating clickable zones for each cabinet\n\nOverlay layers on map for Power, Space, Temperature, and Weight capacity\n\nMapping of power connections from device -> power strip -> panel -> source feed\n\nMapping of network connections to any device classified as a switch',
                    buttonText: 'Download v23.04',
                  ),
                  ProductCard(
                    imageUrl: 'assets/map.png',
                    title: 'v23.03',
                    description:
                        'Chassis device support\n\nGraphical Cabinet Viewer (user must supply graphic images)\n\nMultiple levels of user rights\n\nBasic workflow system for generating rack requests\n\nReporting on Hosting Costs by department based on a cost per U and cost per Watt formula',
                    buttonText: 'Download v23.03',
                  ),
                  ProductCard(
                    imageUrl: 'assets/map.png',
                    title: 'v23.02',
                    description:
                        'Storage Room view per Data Center\n\nSupport for automatic transfer switches\n\nAuto-Transfer Switches will poll SNMP for redundancy status\n\nXML Export for Computational Fluid Dynamic Analysis software',
                    buttonText: 'Download v23.02',
                  ),
                  ProductCard(
                    imageUrl: 'assets/map.png',
                    title: 'v23.01',
                    description:
                        'Image mapping with custom image for creating clickable zones for each cabinet\n\nOverlay layers on map for Power, Space, Temperature, and Weight capacity\n\nMapping of power connections from device -> power strip -> panel -> source feed\n\nMapping of network connections to any device classified as a switch',
                    buttonText: 'Download v23.01',
                  ),
                  ProductCard(
                    imageUrl: 'assets/map.png',
                    title: 'v21.01',
                    description:
                        'Image mapping with custom image for creating clickable zones for each cabinet\n\nOverlay layers on map for Power, Space, Temperature, and Weight capacity\n\nMapping of power connections from device -> power strip -> panel -> source feed\n\nMapping of network connections to any device classified as a switch',
                    buttonText: 'Download v21.01',
                  ),
                ],
              ),
            ),
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
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Image.asset(
                imageUrl,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 100,
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: DownloadButton(version: title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadButton extends StatelessWidget {
  final String version;

  const DownloadButton({super.key, required this.version});

  Future<void> _download() async {
    try {
      if (kIsWeb) {
        final url = 'https://example.com/downloads/opendcim-$version.zip';

        await FileSaver.instance.saveFile(
          name: 'opendcim-$version',
          ext: 'zip',
          mimeType: MimeType.zip,
        );
      } else {
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _download,
      icon: const Icon(Icons.download),
      label: Text('Download $version'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
