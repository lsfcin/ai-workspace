import 'package:flutter/material.dart';

// ─── Brand colors ─────────────────────────────────────────────────────────────
const kAppColors = <String, Color>{
  'com.whatsapp':                            Color(0xFF25D366),
  'com.instagram.android':                   Color(0xFFFF80AB),
  'com.instagram.barcelona':                 Color(0xFFFF80AB),
  'com.tinder':                              Color(0xFFFE3C72),
  'org.telegram.messenger':                  Color(0xFF2AABEE),
  'com.spotify.music':                       Color(0xFF168D3F),
  'com.google.android.apps.maps':            Color(0xFF009688),
  'com.android.chrome':                      Color(0xFF4285F4),
  'com.google.android.youtube':              Color(0xFFFF0000),
  'com.supercell.clashroyale':               Color(0xFF2B59C3),
  'com.supercell.clashofclans':              Color(0xFFFBBC04),
  'com.bumble.app':                          Color(0xFFFFC629),
  'com.openai.chatgpt':                      Color(0xFF10A37F),
  'com.nu.production':                       Color(0xFF8A05BE),
  'com.studiosol.cifraclub':                 Color(0xFFFF6600),
  'com.google.android.keep':                 Color(0xFFFF7043),
  'com.lucasf.apptime':                      Color(0xFF6366F1),
  'com.google.android.gm':                   Color(0xFFD44638),
  'com.facebook.katana':                     Color(0xFF1877F2),
  'com.miui.home':                           Color(0xFF78909C),
  'com.google.android.apps.messaging':       Color(0xFF1A73E8),
  'br.com.brainweb.ifood':                   Color(0xFFEA1D2C),
  'com.android.deskclock':                   Color(0xFF607D8B),
  'com.google.android.googlequicksearchbox': Color(0xFFDB4437),
  'com.google.android.apps.bard':            Color(0xFFF48FB1),
  'com.google.android.apps.docs':            Color(0xFF1565C0),
  'com.ovelin.guitartuna':                   Color(0xFFAA00FF),
  'com.stremio.one':                         Color(0xFF26C6DA),
  'br.com.bradseg.segurobradescosaude':      Color(0xFFCC092F),
  'org.mozilla.firefox':                     Color(0xFFFF9500),
  // ── Additional common apps ──────────────────────────────────────────────────
  'com.brave.browser':                       Color(0xFFFF5500),
  'com.google.android.calendar':             Color(0xFF1A73E8),
  'com.discord':                             Color(0xFF5865F2),
  'br.com.bb.android':                       Color(0xFFFFD700),
  'com.amazon.mShop.android.shopping':       Color(0xFFFF9900),
  'com.mercadolibre':                        Color(0xFFFFE600),
  'com.picpay':                              Color(0xFF11C76F),
  'br.com.xp.investimentos':                 Color(0xFF005AA3),
  'com.rico.android':                        Color(0xFF0071BC),
  'com.sympla.app':                          Color(0xFF6B2D8B),
  'com.google.android.apps.youtube.music':   Color(0xFFFF0000),
  'com.netflix.mediaclient':                 Color(0xFFE50914),
  'com.linkedin.android':                    Color(0xFF0077B5),
  'com.twitter.android':                     Color(0xFF1DA1F2),
  'com.snapchat.android':                    Color(0xFFFFFC00),
  'com.reddit.frontpage':                    Color(0xFFFF4500),
  'com.pinterest':                           Color(0xFFE60023),
  'com.shazam.android':                      Color(0xFF1DBFFF),
  'com.duolingo':                            Color(0xFF58CC02),
  'com.google.android.apps.translate':       Color(0xFF4285F4),
  'com.todoist.android.Todoist':             Color(0xFFDB4035),
  'com.notion.id':                           Color(0xFF000000),
  'com.ubercab':                             Color(0xFF000000),
  'br.com.99app.android':                    Color(0xFFFFD500),
  'com.ifood.driver':                        Color(0xFFEA1D2C),
  'com.google.android.apps.photos':          Color(0xFF4285F4),
  'com.paypal.android.p2pmobile':            Color(0xFF003087),
  'com.google.android.apps.finance':         Color(0xFF34A853),
};

const kAppLabels = <String, String>{
  'com.whatsapp':                            'WhatsApp',
  'com.instagram.android':                   'Instagram',
  'com.instagram.barcelona':                 'Threads',
  'com.tinder':                              'Tinder',
  'org.telegram.messenger':                  'Telegram',
  'com.spotify.music':                       'Spotify',
  'com.google.android.apps.maps':            'Maps',
  'com.android.chrome':                      'Chrome',
  'com.google.android.youtube':              'YouTube',
  'com.supercell.clashroyale':               'Clash Royale',
  'com.supercell.clashofclans':              'Clash of Clans',
  'com.bumble.app':                          'Bumble',
  'com.openai.chatgpt':                      'ChatGPT',
  'com.nu.production':                       'Nubank',
  'com.studiosol.cifraclub':                 'CifraClub',
  'com.google.android.keep':                 'Keep',
  'com.lucasf.apptime':                      'AppTime',
  'com.google.android.gm':                   'Gmail',
  'com.facebook.katana':                     'Facebook',
  'com.miui.home':                           'Início',
  'com.google.android.apps.messaging':       'Messages',
  'br.com.brainweb.ifood':                   'iFood',
  'com.android.deskclock':                   'Relógio',
  'com.google.android.googlequicksearchbox': 'Google',
  'com.google.android.apps.bard':            'Gemini',
  'com.google.android.apps.docs':            'Docs',
  'com.ovelin.guitartuna':                   'GuitarTuna',
  'com.stremio.one':                         'Stremio',
  'br.com.bradseg.segurobradescosaude':      'Bradesco Saúde',
  'org.mozilla.firefox':                     'Firefox',
  // ── Additional common apps ──────────────────────────────────────────────────
  'com.brave.browser':                       'Brave',
  'com.google.android.calendar':             'Google Calendar',
  'com.discord':                             'Discord',
  'br.com.bb.android':                       'Banco do Brasil',
  'com.amazon.mShop.android.shopping':       'Amazon Shopping',
  'com.mercadolibre':                        'Mercado Livre',
  'com.picpay':                              'PicPay',
  'br.com.xp.investimentos':                 'XP Investimentos',
  'com.rico.android':                        'Rico',
  'com.sympla.app':                          'Sympla',
  'com.google.android.apps.youtube.music':   'YouTube Music',
  'com.netflix.mediaclient':                 'Netflix',
  'com.linkedin.android':                    'LinkedIn',
  'com.twitter.android':                     'X (Twitter)',
  'com.snapchat.android':                    'Snapchat',
  'com.reddit.frontpage':                    'Reddit',
  'com.pinterest':                           'Pinterest',
  'com.shazam.android':                      'Shazam',
  'com.duolingo':                            'Duolingo',
  'com.google.android.apps.translate':       'Google Translate',
  'com.todoist.android.Todoist':             'Todoist',
  'com.notion.id':                           'Notion',
  'com.ubercab':                             'Uber',
  'br.com.99app.android':                    '99',
  'com.google.android.apps.photos':          'Google Photos',
  'com.paypal.android.p2pmobile':            'PayPal',
  'com.google.android.apps.finance':         'Google Finance',
};

Color colorForApp(String pkg) => kAppColors[pkg] ?? const Color(0xFFB0BEC5);

/// Returns the best display label for a package name.
/// Falls back to the last meaningful segment of the package name.
String labelForApp(String pkg) {
  if (kAppLabels.containsKey(pkg)) return kAppLabels[pkg]!;
  final parts = pkg
      .split('.')
      .where((s) => s != 'android' && s != 'app' && s != 'mobile')
      .toList();
  // Guard against empty list (e.g. pkg = 'android' or 'app.mobile')
  return parts.isNotEmpty ? parts.last : pkg.split('.').last;
}

bool isLauncherPkg(String pkg) =>
    pkg == 'com.miui.home' ||
    pkg.contains('.launcher') ||
    pkg.endsWith('.home') ||
    pkg == 'com.android.systemui';

bool isSystemPkg(String pkg) {
  const exact = {
    'android',
    'com.google.android.gms',
    'com.android.vending',
    'com.google.android.providers.media.module',
    'com.android.settings',
    'com.miui.securitycenter',
    'com.android.permissioncontroller',
    'com.google.android.documentsui',
    'com.android.systemui',
    'com.miui.systemAdSolution',
    'com.android.packageinstaller',
    'com.google.android.packageinstaller',
    'com.android.stk',            // SIM Toolkit
    'com.qualcomm.qti.sta',       // Qualcomm STA
    'com.android.phone',
    'com.android.contacts',
    'com.android.mms',
    'com.android.dialer',
    'com.miui.securityadd',
    'com.miui.analytics',
  };
  if (exact.contains(pkg)) return true;
  return pkg.contains('photopicker') ||
      pkg.contains('permissioncontroller') ||
      pkg.contains('.provision') ||
      pkg.contains('.setup') ||
      pkg.contains('btcontrol') ||    // Bluetooth chip controllers
      pkg.contains('.inputmethod') ||
      pkg.contains('wallpaper') ||
      pkg.contains('.systemui') ||
      pkg.contains('miui.system') ||
      pkg.contains('.stk');           // SIM Toolkit variants
}

bool isUserFacingApp(String pkg) =>
    !isLauncherPkg(pkg) && !isSystemPkg(pkg);
