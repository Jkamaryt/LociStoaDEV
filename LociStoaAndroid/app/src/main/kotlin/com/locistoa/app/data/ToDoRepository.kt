package com.locistoa.app.data

import android.content.Context
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.util.UUID

@Serializable
data class ToDoItem(
    val id: String = UUID.randomUUID().toString(),
    val priority: String = "",
    val classes: String = "",
    val description: String = "",
    val dueDateMillis: Long = System.currentTimeMillis(),
    val isCompleted: Boolean = false
)

class ToDoRepository(context: Context) {
    private val prefs = context.getSharedPreferences("loci_stoa_todo_prefs", Context.MODE_PRIVATE)
    private val json = Json { ignoreUnknownKeys = true }

    fun loadItems(): List<ToDoItem> {
        val raw = prefs.getString("data", null) ?: return emptyList()
        return try {
            json.decodeFromString<List<ToDoItem>>(raw)
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun saveItems(items: List<ToDoItem>) {
        try {
            val encoded = json.encodeToString(items)
            prefs.edit().putString("data", encoded).apply()
        } catch (_: Exception) {
        }
    }
}
