import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/components/sidebar.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'site_paths.dart';

/// Sidebar configuration for Solana Kit docs.
class SiteSidebar extends StatelessComponent {
  const SiteSidebar({required this.basePath, super.key});

  final String basePath;

  @override
  Component build(BuildContext context) {
    String link(String route) => docsRoute(basePath, route);

    return Sidebar(
      currentRoute: link(context.page.url),
      groups: [
        SidebarGroup(
          links: [
            SidebarLink(text: 'Overview', href: link('/')),
          ],
        ),
        SidebarGroup(
          title: 'Getting Started',
          links: [
            SidebarLink(text: 'Installation', href: link('/getting-started/installation')),
            SidebarLink(text: 'Quick Start', href: link('/getting-started/quick-start')),
            SidebarLink(text: 'First Transaction', href: link('/getting-started/first-transaction')),
          ],
        ),
        SidebarGroup(
          title: 'Core Concepts',
          links: [
            SidebarLink(text: 'Architecture', href: link('/core/architecture')),
            SidebarLink(text: 'RPC & Subscriptions', href: link('/core/rpc-and-subscriptions')),
            SidebarLink(text: 'Transactions', href: link('/core/transactions')),
            SidebarLink(text: 'Errors & Diagnostics', href: link('/core/errors-and-diagnostics')),
          ],
        ),
        SidebarGroup(
          title: 'Guides',
          links: [
            SidebarLink(text: 'Build an RPC Service', href: link('/guides/build-rpc-service')),
            SidebarLink(text: 'Build a Token Transfer Flow', href: link('/guides/build-token-transfer-flow')),
            SidebarLink(text: 'Build a Program Client', href: link('/guides/build-program-client')),
            SidebarLink(text: 'Build a Realtime Observer', href: link('/guides/build-realtime-observer')),
            SidebarLink(text: 'Mobile Wallet Adapter', href: link('/guides/mobile-wallet-adapter')),
            SidebarLink(text: 'Benchmarking', href: link('/guides/benchmarking')),
            SidebarLink(text: 'Release Process', href: link('/guides/release-process')),
          ],
        ),
        SidebarGroup(
          title: 'Reference',
          links: [
            SidebarLink(text: 'Package Index', href: link('/reference/package-index')),
            SidebarLink(text: 'Complete Package Catalog', href: link('/reference/package-catalog')),
            SidebarLink(text: 'Upstream Compatibility', href: link('/reference/upstream-compatibility')),
            SidebarLink(text: 'Contributing', href: link('/contributing')),
          ],
        ),
      ],
    );
  }
}
