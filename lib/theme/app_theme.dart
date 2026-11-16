import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna aksen per modul/status, sama dengan token `--pn-*` di
/// `static/css/global.css` situs (tema "Almanak Grimoire").
enum PnTone { ecto, ember, blood, hex, frost }

/// Palet tambahan yang tidak ada di [ColorScheme]. Ambil dengan
/// `Theme.of(context).extension<PnPalette>()!` atau `PnPalette.of(context)`.
@immutable
class PnPalette extends ThemeExtension<PnPalette> {
  const PnPalette({
    required this.ecto,
    required this.ember,
    required this.blood,
    required this.hex,
    required this.frost,
    required this.muted,
    required this.raised,
  });

  /// Malam: grimoire bertinta ungu-hitam.
  static const dark = PnPalette(
    ecto: Color(0xFF9EE267), // primer / Stable
    ember: Color(0xFFF5B74A), // Critical
    blood: Color(0xFFF57565), // Flatlining / hapus
    hex: Color(0xFFBEA6FF), // Resurrected
    frost: Color(0xFF7CD1DF), // info
    muted: Color(0xFFA59C8A),
    raised: Color(0xFF2B2733),
  );

  /// Siang: almanak dapur, kertas krem dan tinta cetak.
  static const light = PnPalette(
    ecto: Color(0xFF2C6C34),
    ember: Color(0xFFA85908),
    blood: Color(0xFFBC3225),
    hex: Color(0xFF673EA6),
    frost: Color(0xFF14657D),
    muted: Color(0xFF6C6152),
    raised: Color(0xFFE9DDC2),
  );

  final Color ecto;
  final Color ember;
  final Color blood;
  final Color hex;
  final Color frost;
  final Color muted;
  final Color raised;

  static PnPalette of(BuildContext context) =>
      Theme.of(context).extension<PnPalette>() ?? dark;

  Color tone(PnTone tone) => switch (tone) {
        PnTone.ecto => ecto,
        PnTone.ember => ember,
        PnTone.blood => blood,
        PnTone.hex => hex,
        PnTone.frost => frost,
      };

  @override
  PnPalette copyWith({
    Color? ecto,
    Color? ember,
    Color? blood,
    Color? hex,
    Color? frost,
    Color? muted,
    Color? raised,
  }) =>
      PnPalette(
        ecto: ecto ?? this.ecto,
        ember: ember ?? this.ember,
        blood: blood ?? this.blood,
        hex: hex ?? this.hex,
        frost: frost ?? this.frost,
        muted: muted ?? this.muted,
        raised: raised ?? this.raised,
      );

  @override
  PnPalette lerp(ThemeExtension<PnPalette>? other, double t) {
    if (other is! PnPalette) return this;
    return PnPalette(
      ecto: Color.lerp(ecto, other.ecto, t)!,
      ember: Color.lerp(ember, other.ember, t)!,
      blood: Color.lerp(blood, other.blood, t)!,
      hex: Color.lerp(hex, other.hex, t)!,
      frost: Color.lerp(frost, other.frost, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: const Color(0xFF15131A),
        card: const Color(0xFF1E1B24),
        ink: const Color(0xFFF2EAD8),
        inkSoft: const Color(0xFFD4CBB7),
        line: const Color(0xFF968D7A),
        palette: PnPalette.dark,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: const Color(0xFFF3EAD6),
        card: const Color(0xFFFBF6EA),
        ink: const Color(0xFF1F1B16),
        inkSoft: const Color(0xFF463D32),
        line: const Color(0xFF26211C),
        palette: PnPalette.light,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color ink,
    required Color inkSoft,
    required Color line,
    required PnPalette palette,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: palette.ecto,
      onPrimary: background,
      secondary: palette.hex,
      onSecondary: background,
      tertiary: palette.frost,
      onTertiary: background,
      error: palette.blood,
      onError: background,
      surface: card,
      onSurface: ink,
      onSurfaceVariant: inkSoft,
      surfaceContainerHighest: palette.raised,
      outline: line,
      outlineVariant: palette.muted,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
    );
    final textTheme =
        googleFontsEnabled ? _fonts(base.textTheme) : base.textTheme;

    return base.copyWith(
      textTheme: textTheme,
      extensions: [palette],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: line, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  /// Font situs: Atkinson Hyperlegible (isi), Grenze Gotisch (judul), Space Mono (data).
  /// Jika font tidak tersedia, tetap memakai font bawaan.
  static TextTheme _fonts(TextTheme base) {
    TextTheme body;
    try {
      body = GoogleFonts.getTextTheme('Atkinson Hyperlegible', base);
    } catch (_) {
      body = base;
    }

    TextStyle? display(TextStyle? style) {
      try {
        return GoogleFonts.getFont('Grenze Gotisch', textStyle: style);
      } catch (_) {
        return style;
      }
    }

    return body.copyWith(
      displayLarge: display(body.displayLarge),
      displayMedium: display(body.displayMedium),
      displaySmall: display(body.displaySmall),
      headlineLarge: display(body.headlineLarge),
      headlineMedium: display(body.headlineMedium),
      headlineSmall: display(body.headlineSmall),
      titleLarge: display(body.titleLarge),
    );
  }

  /// Dimatikan di widget test supaya tidak mengunduh font dari internet.
  static bool googleFontsEnabled = true;

  /// Gaya teks monospace untuk data (endpoint, angka), seperti `--pn-font-mono`.
  static TextStyle mono(BuildContext context) {
    final base = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    if (!googleFontsEnabled) return base.copyWith(fontFamily: 'monospace');
    try {
      return GoogleFonts.getFont('Space Mono', textStyle: base);
    } catch (_) {
      return base.copyWith(fontFamily: 'monospace');
    }
  }
}
