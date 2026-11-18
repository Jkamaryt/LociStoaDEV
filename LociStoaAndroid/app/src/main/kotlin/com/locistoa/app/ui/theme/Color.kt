package com.locistoa.app.ui.theme

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color

/**
 * Exact match to `LociTheme` in `GavinDesignSystem.swift` and `Main.dc.html`
 * (.th-purple, .th-blue, .th-green, .th-copper)
 */
enum class LociTheme(
    val id: String,
    val label: String,
    val swatch: Color,
    val bg: Color,
    val ink: Color,
    val sub: Color,
    val tint: Color,
    val line: Color,
    val rule: Color,
    val strong: Color,
    val check: Color,
    val accent: Color,
    val word: Color,
    val h1: Color,
    val h2: Color,
    val sk2: Color
) {
    PURPLE(
        id = "purple",
        label = "Purple",
        swatch = Color(0xFF734FC2),
        bg = Color(0xFFD9D9FF),
        ink = Color(0xFF2B1F52),
        sub = Color(0xFF5E5873),
        tint = Color(0xFFECE7FB),
        line = Color(0xFFCFCBEE),
        rule = Color(0xFFEEEBFA),
        strong = Color(0xFFBDB6E0),
        check = Color(0xFF7A6FA6),
        accent = Color(0xFF734FC2),
        word = Color(0xFF4A2F96),
        h1 = Color(0xFFD6CFF2),
        h2 = Color(0xFFEDE9FB),
        sk2 = Color(0xFFF6F3FF)
    ),
    BLUE(
        id = "blue",
        label = "Blue",
        swatch = Color(0xFF1F5FA8),
        bg = Color(0xFFDCE8F7),
        ink = Color(0xFF12284A),
        sub = Color(0xFF4E5D73),
        tint = Color(0xFFE6EEF9),
        line = Color(0xFFC5D3E8),
        rule = Color(0xFFEAF0F8),
        strong = Color(0xFFAFC0DA),
        check = Color(0xFF6F82A0),
        accent = Color(0xFF1F5FA8),
        word = Color(0xFF174A85),
        h1 = Color(0xFFC9D7EC),
        h2 = Color(0xFFE6EEF9),
        sk2 = Color(0xFFF3F7FC)
    ),
    GREEN(
        id = "green",
        label = "Green",
        swatch = Color(0xFF1E6B4E),
        bg = Color(0xFFDDEBE3),
        ink = Color(0xFF12332A),
        sub = Color(0xFF4D6259),
        tint = Color(0xFFE6F1EB),
        line = Color(0xFFC4D8CD),
        rule = Color(0xFFEAF3EE),
        strong = Color(0xFFAEC7BA),
        check = Color(0xFF6B8A7C),
        accent = Color(0xFF1E6B4E),
        word = Color(0xFF17533C),
        h1 = Color(0xFFC7DCD1),
        h2 = Color(0xFFE4F0EA),
        sk2 = Color(0xFFF2F8F5)
    ),
    COPPER(
        id = "copper",
        label = "Copper",
        swatch = Color(0xFFA84B22),
        bg = Color(0xFFF2F4F6),
        ink = Color(0xFF10202B),
        sub = Color(0xFF51606B),
        tint = Color(0xFFE6ECF0),
        line = Color(0xFFE1E6EA),
        rule = Color(0xFFEEF1F4),
        strong = Color(0xFFC9D2D9),
        check = Color(0xFF7D8B95),
        accent = Color(0xFFA84B22),
        word = Color(0xFFA84B22),
        h1 = Color(0xFFC3CED6),
        h2 = Color(0xFFE3EAEE),
        sk2 = Color(0xFFF4F7F9)
    );

    companion object {
        fun fromId(id: String?): LociTheme {
            return entries.firstOrNull { it.id.equals(id, ignoreCase = true) } ?: PURPLE
        }
    }
}

val LociBackgroundDefault = LociTheme.PURPLE.bg
val LociAccentDefault = LociTheme.PURPLE.accent

object LociBrandState {
    var theme by mutableStateOf(LociTheme.PURPLE)
    var customBackground by mutableStateOf<Color?>(null)
    var customAccent by mutableStateOf<Color?>(null)
    var serverIp by mutableStateOf("141.219.229.21")

    var background: Color
        get() = customBackground ?: theme.bg
        set(value) {
            customBackground = value
        }

    var accent: Color
        get() = customAccent ?: theme.accent
        set(value) {
            customAccent = value
        }

    val ink: Color get() = theme.ink
    val sub: Color get() = theme.sub
    val tint: Color get() = theme.tint
    val line: Color get() = theme.line
    val rule: Color get() = theme.rule
    val strong: Color get() = theme.strong
    val check: Color get() = theme.check
    val word: Color get() = customAccent ?: theme.word
    val h1: Color get() = theme.h1
    val h2: Color get() = theme.h2
    val sk2: Color get() = theme.sk2

    fun selectThemePreset(preset: LociTheme) {
        theme = preset
        customBackground = null
        customAccent = null
    }

    fun resetToDefaults() {
        theme = LociTheme.PURPLE
        customBackground = null
        customAccent = null
    }
}

val primaryLight = LociAccentDefault
val primaryContainerLight = Color(0xFFEADDFF)
val secondaryLight = Color(0xFF625B71)
val tertiaryLight = Color(0xFF7D5260)

val primaryDark = Color(0xFFD0BCFF)
val primaryContainerDark = Color(0xFF4F378B)
val secondaryDark = Color(0xFFCCC2DC)
val tertiaryDark = Color(0xFFEFB8C8)
