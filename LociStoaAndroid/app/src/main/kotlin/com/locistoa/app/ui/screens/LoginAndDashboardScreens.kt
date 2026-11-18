package com.locistoa.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Logout
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.locistoa.app.ui.theme.GavinDisplayFontFamily
import com.locistoa.app.ui.theme.GavinHeroWavesDecoration
import com.locistoa.app.ui.theme.GavinSecondaryButton
import com.locistoa.app.ui.theme.LociAccentDefault
import com.locistoa.app.ui.theme.LociBackgroundDefault
import com.locistoa.app.ui.theme.LociBrandState
import com.locistoa.app.ui.theme.LociTheme
import com.locistoa.app.ui.theme.ModernButton

enum class DashboardDestination {
    MAP,
    COMMON_LINKS,
    SCHEDULE,
    DIRECTORY,
    HOMEWORK_PLANNER,
    CAREER_FAIR,
    CHATBOT,
    NOMENCLATURE
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    onLoggedIn: () -> Unit
) {
    var username by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var showAdminSettings by remember { mutableStateOf(false) }

    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent
    val ink = LociBrandState.ink
    val sub = LociBrandState.sub
    val line = LociBrandState.line
    val tint = LociBrandState.tint

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(lociBackground)
            .statusBarsPadding()
            .navigationBarsPadding()
    ) {
        // Top Bar: 4 Gavin Theme Swatch Dots (Left) + Bypass Button (Right)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 18.dp, vertical = 14.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                shape = CircleShape,
                color = Color.White,
                border = androidx.compose.foundation.BorderStroke(1.dp, line)
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    LociTheme.entries.forEach { th ->
                        val active = LociBrandState.theme == th && LociBrandState.customAccent == null
                        Box(
                            modifier = Modifier
                                .size(if (active) 20.dp else 16.dp)
                                .clip(CircleShape)
                                .background(th.swatch)
                                .border(
                                    width = if (active) 2.dp else 0.dp,
                                    color = if (active) ink else Color.Transparent,
                                    shape = CircleShape
                                )
                                .clickable { LociBrandState.selectThemePreset(th) }
                        )
                    }
                }
            }

            Surface(
                onClick = onLoggedIn,
                shape = CircleShape,
                color = Color.White,
                border = androidx.compose.foundation.BorderStroke(1.dp, line)
            ) {
                Text(
                    text = "Bypass →",
                    color = lociAccent,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.ExtraBold,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }
        }

        // Main Gavin-Styled Login Card
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.Center)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp, vertical = 56.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Gavin Hero Banner Card
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(18.dp))
                    .background(Color.White)
                    .border(1.dp, line, RoundedCornerShape(18.dp))
            ) {
                GavinHeroWavesDecoration(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(125.dp)
                )

                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        text = "MICHIGAN TECHNOLOGICAL UNIVERSITY",
                        fontSize = 10.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = sub,
                        letterSpacing = 0.8.sp
                    )
                    Text(
                        text = "LociStoa",
                        fontSize = 36.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black,
                        color = LociBrandState.word
                    )
                    Text(
                        text = "Campus Management, Live Maps & Directory",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = sub
                    )
                }
            }

            // Credentials & Sign-In Card
            Surface(
                shape = RoundedCornerShape(18.dp),
                color = Color.White,
                border = androidx.compose.foundation.BorderStroke(1.dp, line),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(18.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "STUDENT & FACULTY SIGN IN",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = sub
                    )

                    OutlinedTextField(
                        value = username,
                        onValueChange = { username = it },
                        placeholder = { Text("Username or MTU ISO ID", color = sub) },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedContainerColor = tint.copy(alpha = 0.35f),
                            unfocusedContainerColor = tint.copy(alpha = 0.35f),
                            focusedBorderColor = lociAccent,
                            unfocusedBorderColor = line,
                            focusedTextColor = ink,
                            unfocusedTextColor = ink
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )

                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it },
                        placeholder = { Text("Password", color = sub) },
                        singleLine = true,
                        visualTransformation = PasswordVisualTransformation(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                        shape = RoundedCornerShape(12.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedContainerColor = tint.copy(alpha = 0.35f),
                            unfocusedContainerColor = tint.copy(alpha = 0.35f),
                            focusedBorderColor = lociAccent,
                            unfocusedBorderColor = line,
                            focusedTextColor = ink,
                            unfocusedTextColor = ink
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )

                    ModernButton(
                        text = "Sign In",
                        onClick = onLoggedIn
                    )

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 2.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        HorizontalDivider(modifier = Modifier.weight(1f), color = LociBrandState.rule)
                        Text(
                            text = "OR",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = sub
                        )
                        HorizontalDivider(modifier = Modifier.weight(1f), color = LociBrandState.rule)
                    }

                    GavinSecondaryButton(
                        text = "Sign in with Google",
                        onClick = onLoggedIn
                    )

                    GavinSecondaryButton(
                        text = "University SSO Sign-in",
                        onClick = onLoggedIn
                    )
                }
            }
        }

        // Bottom Right Admin/IT Bypass Gear Button
        Box(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp)
        ) {
            Surface(
                onClick = { showAdminSettings = true },
                shape = CircleShape,
                color = Color.White,
                border = androidx.compose.foundation.BorderStroke(1.dp, line),
                shadowElevation = 4.dp
            ) {
                Icon(
                    imageVector = Icons.Default.Settings,
                    contentDescription = "Admin Settings",
                    tint = lociAccent,
                    modifier = Modifier
                        .padding(13.dp)
                        .size(22.dp)
                )
            }
        }
    }

    if (showAdminSettings) {
        ModalBottomSheet(
            onDismissRequest = { showAdminSettings = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = LociBrandState.background
        ) {
            AdminSettingsContent(onClose = { showAdminSettings = false })
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun AdminSettingsContent(onClose: () -> Unit) {
    var isAuthenticated by remember { mutableStateOf(false) }
    var adminPin by remember { mutableStateOf("") }
    var pinError by remember { mutableStateOf(false) }

    var selectedPreset by remember { mutableStateOf(LociBrandState.theme) }
    var selectedBg by remember { mutableStateOf(LociBrandState.background) }
    var selectedAccent by remember { mutableStateOf(LociBrandState.accent) }
    var useCustomSwatches by remember { mutableStateOf(LociBrandState.customAccent != null) }
    var serverIp by remember { mutableStateOf(LociBrandState.serverIp) }

    val bgSwatches = listOf(
        LociBackgroundDefault,
        Color(0xFFDCE8F7), // Gavin Blue BG
        Color(0xFFDDEBE3), // Gavin Green BG
        Color(0xFFF2F4F6), // Gavin Copper BG
        Color(0xFFFFF4D6)  // MTU Gold Tint
    )
    val accentSwatches = listOf(
        LociAccentDefault,
        Color(0xFF1F5FA8), // Gavin Blue
        Color(0xFF1E6B4E), // Gavin Green
        Color(0xFFA84B22), // Gavin Copper
        Color(0xFFB8860B)  // MTU Gold
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 22.dp)
            .padding(bottom = 32.dp)
    ) {
        // Header bar
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            TextButton(onClick = onClose) {
                Text("Close", color = LociBrandState.accent, fontWeight = FontWeight.Bold)
            }
            Text(
                text = if (isAuthenticated) "Tenant Settings" else "Restricted",
                fontWeight = FontWeight.Black,
                fontFamily = GavinDisplayFontFamily,
                fontSize = 18.sp,
                color = LociBrandState.ink
            )
            Spacer(modifier = Modifier.size(48.dp))
        }

        Spacer(modifier = Modifier.height(12.dp))

        if (!isAuthenticated) {
            Surface(
                shape = RoundedCornerShape(18.dp),
                color = Color.White,
                border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(22.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Security,
                        contentDescription = "IT Administrator Access",
                        tint = LociBrandState.accent,
                        modifier = Modifier.size(52.dp)
                    )

                    Text(
                        text = "IT Administrator Access",
                        fontSize = 20.sp,
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black,
                        color = LociBrandState.ink
                    )

                    OutlinedTextField(
                        value = adminPin,
                        onValueChange = {
                            adminPin = it
                            pinError = false
                        },
                        placeholder = { Text("Enter Admin PIN (1234)") },
                        singleLine = true,
                        visualTransformation = PasswordVisualTransformation(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth()
                    )

                    if (pinError) {
                        Text(
                            text = "Invalid PIN. Enter 1234.",
                            color = Color(0xFFD32F2F),
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }

                    ModernButton(
                        text = "Authenticate",
                        onClick = {
                            if (adminPin == "1234") {
                                isAuthenticated = true
                            } else {
                                pinError = true
                            }
                        }
                    )
                }
            }
        } else {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                // Gavin Theme Presets
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Text(
                            text = "GAVIN EDITION THEME PRESETS",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = LociBrandState.sub
                        )
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            LociTheme.entries.forEach { preset ->
                                val active = selectedPreset == preset && !useCustomSwatches
                                Surface(
                                    onClick = {
                                        selectedPreset = preset
                                        selectedBg = preset.bg
                                        selectedAccent = preset.accent
                                        useCustomSwatches = false
                                    },
                                    shape = RoundedCornerShape(10.dp),
                                    color = if (active) preset.tint else Color.White,
                                    border = androidx.compose.foundation.BorderStroke(
                                        if (active) 2.dp else 1.dp,
                                        if (active) preset.swatch else LociBrandState.line
                                    ),
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Column(
                                        modifier = Modifier.padding(vertical = 8.dp),
                                        horizontalAlignment = Alignment.CenterHorizontally,
                                        verticalArrangement = Arrangement.spacedBy(4.dp)
                                    ) {
                                        Box(
                                            modifier = Modifier
                                                .size(20.dp)
                                                .clip(CircleShape)
                                                .background(preset.swatch)
                                        )
                                        Text(
                                            text = preset.label,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = LociBrandState.ink
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // Custom Tenant Swatches
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Text(
                            text = "UNIVERSITY BRANDING COLORS",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = LociBrandState.sub
                        )

                        Text("Primary Background", fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                        FlowRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            bgSwatches.forEach { swatch ->
                                val isSel = (selectedBg == swatch)
                                Box(
                                    modifier = Modifier
                                        .size(36.dp)
                                        .clip(CircleShape)
                                        .background(swatch)
                                        .border(
                                            width = if (isSel) 3.dp else 1.dp,
                                            color = if (isSel) LociBrandState.accent else Color.LightGray,
                                            shape = CircleShape
                                        )
                                        .clickable {
                                            selectedBg = swatch
                                            useCustomSwatches = true
                                        },
                                    contentAlignment = Alignment.Center
                                ) {
                                    if (isSel) {
                                        Icon(
                                            imageVector = Icons.Default.Check,
                                            contentDescription = null,
                                            tint = Color.Black,
                                            modifier = Modifier.size(16.dp)
                                        )
                                    }
                                }
                            }
                        }

                        HorizontalDivider(color = LociBrandState.rule)

                        Text("Secondary Accent", fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                        FlowRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            accentSwatches.forEach { swatch ->
                                val isSel = (selectedAccent == swatch)
                                Box(
                                    modifier = Modifier
                                        .size(36.dp)
                                        .clip(CircleShape)
                                        .background(swatch)
                                        .border(
                                            width = if (isSel) 3.dp else 1.dp,
                                            color = if (isSel) Color.Black else Color.LightGray,
                                            shape = CircleShape
                                        )
                                        .clickable {
                                            selectedAccent = swatch
                                            useCustomSwatches = true
                                        },
                                    contentAlignment = Alignment.Center
                                ) {
                                    if (isSel) {
                                        Icon(
                                            imageVector = Icons.Default.Check,
                                            contentDescription = null,
                                            tint = Color.White,
                                            modifier = Modifier.size(16.dp)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "DIRECTORY API SERVER (OPTIONAL)",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = LociBrandState.sub
                        )
                        OutlinedTextField(
                            value = serverIp,
                            onValueChange = { serverIp = it },
                            label = { Text("Mac Wi-Fi IP (Port 8080)") },
                            singleLine = true,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }

                ModernButton(
                    text = "Save & Deploy to Tenant",
                    onClick = {
                        LociBrandState.theme = selectedPreset
                        if (useCustomSwatches) {
                            LociBrandState.customBackground = selectedBg
                            LociBrandState.customAccent = selectedAccent
                        } else {
                            LociBrandState.customBackground = null
                            LociBrandState.customAccent = null
                        }
                        LociBrandState.serverIp = serverIp.trim().ifEmpty { "141.219.229.21" }
                        onClose()
                    }
                )
            }
        }
    }
}

data class ChatMessage(val sender: String, val text: String, val isUser: Boolean)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatbotScreen(
    onClose: () -> Unit,
    onOpenMapWithQuery: (String) -> Unit
) {
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    val messages = remember {
        mutableStateListOf(
            ChatMessage(
                sender = "Ask LociStoa",
                text = "Hi Husky! Ask me about any MTU building, professor office, winter skywalk route, tutoring center (CCLC), or campus service.",
                isUser = false
            )
        )
    }
    var inputText by remember { mutableStateOf("") }

    fun sendMessage(queryText: String) {
        val q = queryText.trim()
        if (q.isEmpty()) return
        messages.add(ChatMessage("You", q, true))
        val lower = q.lowercase()
        val reply = when {
            lower.contains("cclc") || lower.contains("tutor") ->
                "The Computer Science Learning Center (CCLC) is in Rekhi Hall Rm 209 (2nd Floor West Wing), coordinated by Dr. Leo Ureel II. Walk-in peer tutoring is available!"
            lower.contains("skywalk") || lower.contains("winter") || lower.contains("tunnel") ->
                "MTU's heated skywalk & tunnel network connects MUB (2F) → Van Pelt Library → Rekhi Hall → EERC so you can walk between classes snow-free."
            lower.contains("advisor") || lower.contains("advising") ->
                "CS Advising (Denise Landsberg) is in Rekhi Hall 322. ECE Advising (Kit Cischke) is in EERC 520. Business Advising (Ryan Neely) is in AOB 108."
            lower.contains("rekhi") ->
                "Rekhi Hall (Bldg #28) houses the College of Computing across 3 floors, including Rekhi 214 Lecture Hall, CCLC (Rm 209), and CS Main Office (Rm 322)."
            lower.contains("career") ->
                "Career Services is located in Administration Building Rm 220 (2nd Floor). The Fall Career Fair hosts companies including Ford, Stryker, Dow, Caterpillar, GM, and Oshkosh."
            else ->
                "I found matches in the MTU Campus Directory! You can also jump directly to any office or room in the Live Interactive Map."
        }
        messages.add(ChatMessage("Ask LociStoa", reply, false))
    }

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Ask LociStoa",
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black,
                        color = LociBrandState.ink
                    )
                },
                navigationIcon = {
                    TextButton(onClick = onClose) {
                        Text("Close", color = lociAccent, fontWeight = FontWeight.Bold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 10.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                listOf("Where is CCLC?", "Winter Skywalks", "CS Advising").forEach { chip ->
                    Surface(
                        onClick = { sendMessage(chip) },
                        shape = CircleShape,
                        color = Color.White,
                        border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line)
                    ) {
                        Text(
                            text = chip,
                            color = lociAccent,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                        )
                    }
                }
            }

            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                messages.forEach { msg ->
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = if (msg.isUser) Arrangement.End else Arrangement.Start
                    ) {
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = if (msg.isUser) lociAccent else Color.White,
                            border = if (msg.isUser) null else androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line),
                            modifier = Modifier.fillMaxWidth(0.84f)
                        ) {
                            Column(modifier = Modifier.padding(14.dp)) {
                                Text(
                                    text = msg.sender,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = if (msg.isUser) Color.White.copy(alpha = 0.8f) else lociAccent
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = msg.text,
                                    fontSize = 14.sp,
                                    color = if (msg.isUser) Color.White else LociBrandState.ink
                                )
                            }
                        }
                    }
                }
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = inputText,
                    onValueChange = { inputText = it },
                    placeholder = { Text("Ask about any room, office, or service...") },
                    singleLine = true,
                    shape = RoundedCornerShape(24.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = Color.White,
                        unfocusedContainerColor = Color.White,
                        focusedBorderColor = lociAccent,
                        unfocusedBorderColor = LociBrandState.line
                    ),
                    modifier = Modifier.weight(1f)
                )
                Surface(
                    onClick = {
                        sendMessage(inputText)
                        inputText = ""
                    },
                    shape = CircleShape,
                    color = lociAccent
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.Send,
                        contentDescription = "Send",
                        tint = Color.White,
                        modifier = Modifier.padding(12.dp)
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NomenclatureScreen(onClose: () -> Unit) {
    val lociBackground = LociBrandState.background
    val lociAccent = LociBrandState.accent

    val terms = listOf(
        Triple("Rekhi Hall (Bldg #28)", "Kanwal and Ann Rekhi Hall", "Home of the College of Computing, CS Department (Rm 322), CCLC (Rm 209), and Lecture Hall 214."),
        Triple("EERC (Bldg #7)", "Electrical Energy Resources Center", "Houses Electrical & Computer Engineering, Applied Computing (4F), and The Alley Makerspace (Rm 518)."),
        Triple("MUB (Bldg #34)", "Memorial Union Building", "Student union featuring Husky Den dining (2F), Campus Bookstore (1F), Ballroom (3F), and Skywalk Hub."),
        Triple("AOB (Bldg #5)", "Academic Office Building", "College of Business faculty offices, Advising (Rm 108), and APMP Financial Trading Lab (GF)."),
        Triple("GLRC (Bldg #102)", "Great Lakes Research Center", "Waterfront marine & AI research facility connected via the U.S. 41 pedestrian overpass."),
        Triple("CCLC", "Computer Science Learning Center", "Walk-in peer tutoring center in Rekhi Hall Rm 209."),
        Triple("SDC (Bldg #24)", "Student Development Complex", "MTU Athletics, John MacInnes Student Ice Arena, Fitness Center, and Pool."),
        Triple("Wads (Bldg #37)", "Wadsworth Hall", "Largest residence hall on East Campus, housing Residence Education (Rm 153) & Dining Hall."),
        Triple("Banweb", "MTU Student Information System", "Used for course registration, financial aid, transcripts, and degree audits.")
    )

    Scaffold(
        containerColor = lociBackground,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Campus Nomenclature",
                        fontFamily = GavinDisplayFontFamily,
                        fontWeight = FontWeight.Black,
                        color = LociBrandState.ink
                    )
                },
                navigationIcon = {
                    TextButton(onClick = onClose) {
                        Text("Close", color = lociAccent, fontWeight = FontWeight.Bold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = lociBackground)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            terms.forEach { (code, full, desc) ->
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = Color.White,
                    border = androidx.compose.foundation.BorderStroke(1.dp, LociBrandState.line),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = code,
                                fontWeight = FontWeight.ExtraBold,
                                fontSize = 15.sp,
                                color = lociAccent
                            )
                            Text(
                                text = full,
                                fontWeight = FontWeight.SemiBold,
                                fontSize = 11.sp,
                                color = LociBrandState.sub
                            )
                        }
                        Text(
                            text = desc,
                            fontSize = 13.sp,
                            color = LociBrandState.ink
                        )
                    }
                }
            }
        }
    }
}
