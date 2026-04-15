import 'package:flutter/material.dart';

// ─── Brand colors ─────────────────────────────────────────────────────────────
// Same as analytics_screen.dart — kept in sync here as the single source.

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
  'br.com.bradseg.segurobradescosaude':      'Bradesco',
  'org.mozilla.firefox':                     'Firefox',
};

Color colorForApp(String pkg) => kAppColors[pkg] ?? const Color(0xFFB0BEC5);

String labelForApp(String pkg) =>
    kAppLabels[pkg] ??
    pkg
        .split('.')
        .where((s) => s != 'android' && s != 'app' && s != 'mobile')
        .last;

bool isLauncherPkg(String pkg) =>
    pkg == 'com.miui.home' ||
    pkg.contains('.launcher') ||
    pkg.endsWith('.home') ||
    pkg == 'com.android.systemui';

bool isSystemPkg(String pkg) {
  const exact = {
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
  };
  if (exact.contains(pkg)) return true;
  return pkg.contains('photopicker') ||
      pkg.contains('permissioncontroller') ||
      pkg.contains('.provision') ||
      pkg.contains('.setup');
}

bool isUserFacingApp(String pkg) =>
    !isLauncherPkg(pkg) && !isSystemPkg(pkg);
