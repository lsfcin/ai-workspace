import 'package:flutter/material.dart';

// ─── Three-tier naming + classification strategy ──────────────────────────────
//
// TIER 1 — Android PackageManager (primary, most reliable)
//   Queried at runtime via getInstalledApps() in MainActivity.kt.
//   Filters FLAG_SYSTEM == 0 → user-installed apps only.
//   Label = the display name the user sees in their launcher.
//   Stored in AppInfoService.labels. Handles ~95 % of apps.
//
// TIER 2 — Static map kAppMeta
//   Overrides or supplements PM for:
//   • Apps with confusing internal names (e.g. com.google.android.apps.tachyon → "Meet")
//   • Brand colors (PM does not provide these)
//   • Historic usage data for apps that were later uninstalled
//
// TIER 3 — labelForApp() fallback
//   Last resort for packages absent from both Tier 1 and Tier 2.
//   Strips TLD / vendor / generic segments, capitalises the brand name.
//
// CLASSIFICATION (decides whether an app appears in lists / charts)
//   isLauncherPkg() — home-screen launchers: counted but not listed
//   isSystemPkg()   — OS daemons / services: suppressed entirely
//   The PackageManager FLAG_SYSTEM filter in Kotlin handles most system apps.
//   isSystemPkg() catches the remainder (GMS, sync adapters, STK, etc.).
//
// ─────────────────────────────────────────────────────────────────────────────

// ─── App metadata ─────────────────────────────────────────────────────────────

class AppMeta {
  const AppMeta({required this.label, required this.color});
  final String label;
  final Color color;
}

/// Single source of truth for known app labels and brand colors.
/// Guarantees every entry has both a label and a color.
const kAppMeta = <String, AppMeta>{
  'com.whatsapp':                            AppMeta(label: 'WhatsApp',         color: Color(0xFF25D366)),
  'com.instagram.android':                   AppMeta(label: 'Instagram',         color: Color(0xFFFF80AB)),
  'com.instagram.barcelona':                 AppMeta(label: 'Threads',           color: Color(0xFF000000)),
  'com.tinder':                              AppMeta(label: 'Tinder',            color: Color(0xFFFE3C72)),
  'org.telegram.messenger':                  AppMeta(label: 'Telegram',          color: Color(0xFF2AABEE)),
  'com.spotify.music':                       AppMeta(label: 'Spotify',           color: Color(0xFF168D3F)),
  'com.google.android.apps.maps':            AppMeta(label: 'Maps',              color: Color(0xFF009688)),
  'com.android.chrome':                      AppMeta(label: 'Chrome',            color: Color(0xFF4285F4)),
  'com.google.android.youtube':              AppMeta(label: 'YouTube',           color: Color(0xFFFF0000)),
  'com.supercell.clashroyale':               AppMeta(label: 'Clash Royale',      color: Color(0xFF2B59C3)),
  'com.supercell.clashofclans':              AppMeta(label: 'Clash of Clans',    color: Color(0xFFFBBC04)),
  'com.bumble.app':                          AppMeta(label: 'Bumble',            color: Color(0xFFFFC629)),
  'com.openai.chatgpt':                      AppMeta(label: 'ChatGPT',           color: Color(0xFF000000)),
  'com.nu.production':                       AppMeta(label: 'Nubank',            color: Color(0xFF8A05BE)),
  'com.studiosol.cifraclub':                 AppMeta(label: 'CifraClub',         color: Color(0xFFFF6600)),
  'com.google.android.keep':                 AppMeta(label: 'Keep',              color: Color(0xFFFF7043)),
  'com.lsf.apptime':                         AppMeta(label: 'AppTime',           color: Color(0xFF6366F1)),
  'com.google.android.gm':                   AppMeta(label: 'Gmail',             color: Color(0xFFD44638)),
  'com.facebook.katana':                     AppMeta(label: 'Facebook',          color: Color(0xFF1877F2)),
  'com.miui.home':                           AppMeta(label: 'Início',            color: Color(0xFF78909C)),
  'com.google.android.apps.messaging':       AppMeta(label: 'Messages',          color: Color(0xFF1A73E8)),
  'br.com.brainweb.ifood':                   AppMeta(label: 'iFood',             color: Color(0xFFEA1D2C)),
  'com.android.deskclock':                   AppMeta(label: 'Relógio',           color: Color(0xFF607D8B)),
  'com.google.android.googlequicksearchbox': AppMeta(label: 'Google Search',     color: Color(0xFFDB4437)),
  'com.google.android.apps.bard':            AppMeta(label: 'Gemini',            color: Color(0xFFF48FB1)),
  'com.google.android.apps.aistudio':        AppMeta(label: 'AI Studio',         color: Color(0xFF000000)),
  'com.google.android.apps.docs':            AppMeta(label: 'Docs',              color: Color(0xFF1565C0)),
  'com.ovelin.guitartuna':                   AppMeta(label: 'GuitarTuna',        color: Color(0xFFAA00FF)),
  'com.stremio.one':                         AppMeta(label: 'Stremio',           color: Color(0xFF26C6DA)),
  'br.com.bradseg.segurobradescosaude':      AppMeta(label: 'Bradesco Saúde',    color: Color(0xFFCC092F)),
  'org.mozilla.firefox':                     AppMeta(label: 'Firefox',           color: Color(0xFFFF9500)),
  // ── Additional common apps ──────────────────────────────────────────────────
  'com.brave.browser':                       AppMeta(label: 'Brave',             color: Color(0xFFFF5500)),
  'com.google.android.calendar':             AppMeta(label: 'Google Calendar',   color: Color(0xFF1A73E8)),
  'com.discord':                             AppMeta(label: 'Discord',           color: Color(0xFF5865F2)),
  'br.com.bb.android':                       AppMeta(label: 'Banco do Brasil',   color: Color(0xFFFFD700)),
  'com.amazon.mShop.android.shopping':       AppMeta(label: 'Amazon Shopping',   color: Color(0xFFFF9900)),
  'com.mercadolibre':                        AppMeta(label: 'Mercado Livre',     color: Color(0xFFFFE600)),
  'com.picpay':                              AppMeta(label: 'PicPay',            color: Color(0xFF11C76F)),
  'br.com.xp.investimentos':                 AppMeta(label: 'XP Investimentos',  color: Color(0xFF005AA3)),
  'com.rico.android':                        AppMeta(label: 'Rico',              color: Color(0xFF0071BC)),
  'com.sympla.app':                          AppMeta(label: 'Sympla',            color: Color(0xFF6B2D8B)),
  'com.google.android.apps.youtube.music':   AppMeta(label: 'YouTube Music',     color: Color(0xFFFF0000)),
  'com.netflix.mediaclient':                 AppMeta(label: 'Netflix',           color: Color(0xFFE50914)),
  'com.linkedin.android':                    AppMeta(label: 'LinkedIn',          color: Color(0xFF0077B5)),
  'com.twitter.android':                     AppMeta(label: 'X (Twitter)',       color: Color(0xFF1DA1F2)),
  'com.snapchat.android':                    AppMeta(label: 'Snapchat',          color: Color(0xFFFFFC00)),
  'com.reddit.frontpage':                    AppMeta(label: 'Reddit',            color: Color(0xFFFF4500)),
  'com.pinterest':                           AppMeta(label: 'Pinterest',         color: Color(0xFFE60023)),
  'com.shazam.android':                      AppMeta(label: 'Shazam',            color: Color(0xFF1DBFFF)),
  'com.duolingo':                            AppMeta(label: 'Duolingo',          color: Color(0xFF58CC02)),
  'com.google.android.apps.translate':       AppMeta(label: 'Google Translate',  color: Color(0xFF4285F4)),
  'com.todoist.android.Todoist':             AppMeta(label: 'Todoist',           color: Color(0xFFDB4035)),
  'com.notion.id':                           AppMeta(label: 'Notion',            color: Color(0xFF000000)),
  'com.ubercab':                             AppMeta(label: 'Uber',              color: Color(0xFF000000)),
  'br.com.99app.android':                    AppMeta(label: '99',                color: Color(0xFFFFD500)),
  'com.ifood.driver':                        AppMeta(label: 'iFood Driver',      color: Color(0xFFEA1D2C)),
  'com.google.android.apps.photos':          AppMeta(label: 'Google Photos',     color: Color(0xFF4285F4)),
  'com.paypal.android.p2pmobile':            AppMeta(label: 'PayPal',            color: Color(0xFF003087)),
  'com.google.android.apps.finance':         AppMeta(label: 'Google Finance',    color: Color(0xFF34A853)),
  'com.google.android.apps.tachyon':         AppMeta(label: 'Meet',              color: Color(0xFF00897B)),
};

Color colorForApp(String pkg) => kAppMeta[pkg]?.color ?? const Color(0xFFB0BEC5);

// ─── Passive app heuristic ────────────────────────────────────────────────────
// Canonical list — single source of truth for both analytics and insights screens.
// Dating apps included: passive consumption context (swiping = dopamine scroll).
const kPassivePatterns = [
  'instagram', 'tiktok', 'youtube', 'netflix', 'twitter', 'facebook',
  'reddit', 'pinterest', 'snapchat', 'twitch', 'hulu', 'disneyplus',
  'kwai', 'likee', 'reels', 'shorts',
  'tinder', 'bumble', 'hinge', 'badoo', 'happn', 'okcupid', 'grindr',
];

bool isPassiveApp(String pkg) {
  final lower = pkg.toLowerCase();
  return kPassivePatterns.any(lower.contains);
}

// ─── Label lookup ─────────────────────────────────────────────────────────────

// Segments that carry no brand information and should be stripped when
// deriving a fallback label from a package name (Tier 3).
const _kTld      = {'com', 'org', 'net', 'io', 'br', 'uk', 'de', 'fr', 'co'};
const _kNoise    = {'android', 'app', 'apps', 'mobile', 'production', 'release',
                    'mediaclient', 'frontpage', 'katana', 'barcelona'};
// Generic English nouns that describe a category, not a brand.
const _kGeneric  = {'music', 'messenger', 'messages', 'browser', 'player',
                    'service', 'manager', 'provider', 'launcher', 'home',
                    'camera', 'gallery', 'notes', 'note', 'calendar', 'mail',
                    'clock', 'dialer', 'phone', 'contacts', 'photos', 'video',
                    'wallet', 'store', 'market', 'search', 'assistant', 'one'};

/// Returns the best display label for a package name.
/// Tier 2 (kAppMeta) → Tier 3 fallback (heuristic from package ID).
// Runtime labels loaded from PackageManager — populated once at startup.
Map<String, String> _dynamicLabels = {};
void seedDynamicLabels(Map<String, String> labels) => _dynamicLabels = labels;

// Runtime launchers resolved from CATEGORY_HOME — populated once at startup.
Set<String> _dynamicLaunchers = {};
void seedDynamicLaunchers(Set<String> launchers) => _dynamicLaunchers = launchers;

String labelForApp(String pkg) {
  final meta = kAppMeta[pkg];
  if (meta != null) return meta.label;
  if (_dynamicLabels.containsKey(pkg)) return _dynamicLabels[pkg]!;

  final segments = pkg.split('.');

  // Strip TLDs and noise from both ends, keep brand-like segments.
  final meaningful = segments
      .where((s) => !_kTld.contains(s) && !_kNoise.contains(s) && s.length > 1)
      .toList();

  if (meaningful.isEmpty) return segments.last;

  // Prefer the first segment that is NOT a generic category word.
  // e.g. ['spotify', 'music'] → 'spotify'; ['telegram', 'messenger'] → 'telegram'
  final brand = meaningful.firstWhere(
    (s) => !_kGeneric.contains(s.toLowerCase()),
    orElse: () => meaningful.first,
  );

  // Capitalise first letter only (preserve camelCase if present).
  return '${brand[0].toUpperCase()}${brand.substring(1)}';
}

bool isLauncherPkg(String pkg) =>
    _dynamicLaunchers.contains(pkg) ||
    pkg == 'com.miui.home' ||
    pkg == 'com.google.android.googlequicksearchbox' ||
    pkg.contains('.launcher') ||
    pkg.endsWith('launcher') ||
    pkg.endsWith('.home') ||
    pkg == 'com.android.systemui';

bool isSystemPkg(String pkg) {
  // ── Exact known system packages ────────────────────────────────────────────
  const exact = {
    'android',
    'com.android.phone',
    'com.android.contacts',
    'com.android.mms',
    'com.android.dialer',
    'com.android.settings',
    'com.android.systemui',
    'com.android.permissioncontroller',
    'com.android.packageinstaller',
    'com.android.documentsui',
    'com.android.stk',                  // SIM Toolkit
    'com.google.android.gms',           // Play Services
    'com.google.android.gsf',           // Google Services Framework
    'com.google.android.vending',       // Play Store process
    'com.android.vending',
    'com.google.android.packageinstaller',
    'com.google.android.providers.media.module',
    'com.google.android.documentsui',
    'com.qualcomm.qti.sta',
    'com.miui.securitycenter',
    'com.miui.securityadd',
    'com.miui.analytics',
    'com.miui.systemAdSolution',
  };
  if (exact.contains(pkg)) return true;

  // ── Vendor-namespace prefixes (all packages in these namespaces are system) ─
  if (pkg.startsWith('com.qualcomm.') ||
      pkg.startsWith('com.qti.') ||
      pkg.startsWith('com.mediatek.') ||
      pkg.startsWith('com.android.internal.') ||
      pkg.startsWith('com.google.android.syncadapters.') ||
      pkg.startsWith('com.google.android.gsf.') ||
      pkg.startsWith('com.xiaomi.bluetooth')) { return true; }

  // ── Substring patterns ──────────────────────────────────────────────────────
  return pkg.contains('photopicker')           ||
      pkg.contains('permissioncontroller')     ||
      pkg.contains('.provision')               ||
      pkg.contains('.setup')                   ||
      pkg.contains('btcontrol')                || // Bluetooth chip controllers
      pkg.contains('.inputmethod')             ||
      pkg.contains('wallpaper')                ||
      pkg.contains('.systemui')                ||
      pkg.contains('miui.system')              ||
      pkg.contains('.stk')                     || // SIM Toolkit variants
      // Background service/daemon suffixes — user apps are never named like this
      pkg.endsWith('.service')                 ||
      pkg.endsWith('.services')                ||
      pkg.endsWith('.provider')                ||
      pkg.endsWith('.providers')               ||
      pkg.endsWith('.daemon');
}

bool isUserFacingApp(String pkg) =>
    !isLauncherPkg(pkg) && !isSystemPkg(pkg);
