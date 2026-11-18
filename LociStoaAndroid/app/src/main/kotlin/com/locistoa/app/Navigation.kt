package com.locistoa.app

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import com.locistoa.app.data.Contact
import com.locistoa.app.data.GavinPeopleSubView
import com.locistoa.app.data.GavinStore
import com.locistoa.app.data.GavinTab
import com.locistoa.app.ui.screens.CareerFairScreen
import com.locistoa.app.ui.screens.ChatbotScreen
import com.locistoa.app.ui.screens.CommonLinksScreen
import com.locistoa.app.ui.screens.DashboardDestination
import com.locistoa.app.ui.screens.DirectoryContactsScreen
import com.locistoa.app.ui.screens.GavinMainScreen
import com.locistoa.app.ui.screens.HomeworkPlannerScreen
import com.locistoa.app.ui.screens.LoginScreen
import com.locistoa.app.ui.screens.MapScreen
import com.locistoa.app.ui.screens.NomenclatureScreen
import com.locistoa.app.ui.screens.ScheduleScreen

@Composable
fun MainNavigation() {
    val context = LocalContext.current
    val gavinStore = remember { GavinStore(context) }

    var isLoggedIn by remember { mutableStateOf(false) }
    var activeDestination by remember { mutableStateOf<DashboardDestination?>(null) }
    var focusedContactForMap by remember { mutableStateOf<Contact?>(null) }

    BackHandler(enabled = activeDestination != null || isLoggedIn) {
        when {
            activeDestination != null -> {
                if (activeDestination == DashboardDestination.HOMEWORK_PLANNER) {
                    gavinStore.syncFromToDoRepo()
                }
                focusedContactForMap = null
                activeDestination = null
            }
            gavinStore.sheet != null -> {
                gavinStore.sheet = null
            }
            gavinStore.tab == GavinTab.PEOPLE && (gavinStore.dept != null || gavinStore.office != null || gavinStore.org != null) -> {
                gavinStore.dept = null
                gavinStore.office = null
                gavinStore.org = null
            }
            gavinStore.tab != GavinTab.HOME -> {
                gavinStore.go(GavinTab.HOME)
            }
            isLoggedIn -> {
                isLoggedIn = false
            }
        }
    }

    AnimatedContent(
        targetState = Pair(isLoggedIn, activeDestination),
        transitionSpec = {
            (fadeIn(animationSpec = tween(260)) + scaleIn(initialScale = 0.98f, animationSpec = tween(260)))
                .togetherWith(fadeOut(animationSpec = tween(200)))
        },
        label = "LociStoaRootTransition"
    ) { (loggedIn, destination) ->
        if (!loggedIn) {
            LoginScreen(
                onLoggedIn = { isLoggedIn = true }
            )
        } else {
            when (destination) {
                null -> GavinMainScreen(
                    store = gavinStore,
                    onOpenDestination = { dest ->
                        focusedContactForMap = null
                        activeDestination = dest
                    },
                    onLocateContactOnMap = { contact ->
                        focusedContactForMap = contact
                        activeDestination = DashboardDestination.MAP
                    },
                    onSignOut = {
                        activeDestination = null
                        isLoggedIn = false
                    }
                )
                DashboardDestination.MAP -> MapScreen(
                    focusedContact = focusedContactForMap,
                    onClose = {
                        focusedContactForMap = null
                        activeDestination = null
                    }
                )
                DashboardDestination.COMMON_LINKS -> CommonLinksScreen(
                    onClose = { activeDestination = null }
                )
                DashboardDestination.SCHEDULE -> ScheduleScreen(
                    onClose = { activeDestination = null }
                )
                DashboardDestination.DIRECTORY -> DirectoryContactsScreen(
                    onClose = { activeDestination = null },
                    onLocateContactOnMap = { contact ->
                        focusedContactForMap = contact
                        activeDestination = DashboardDestination.MAP
                    }
                )
                DashboardDestination.HOMEWORK_PLANNER -> HomeworkPlannerScreen(
                    onClose = {
                        gavinStore.syncFromToDoRepo()
                        activeDestination = null
                    }
                )
                DashboardDestination.CAREER_FAIR -> CareerFairScreen(
                    onClose = { activeDestination = null }
                )
                DashboardDestination.CHATBOT -> ChatbotScreen(
                    onClose = { activeDestination = null },
                    onOpenMapWithQuery = {
                        activeDestination = DashboardDestination.MAP
                    }
                )
                DashboardDestination.NOMENCLATURE -> NomenclatureScreen(
                    onClose = { activeDestination = null }
                )
            }
        }
    }
}
