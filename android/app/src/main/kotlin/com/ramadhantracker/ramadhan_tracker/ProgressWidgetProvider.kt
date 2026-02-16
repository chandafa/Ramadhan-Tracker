package com.ramadhantracker.ramadhan_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ProgressWidgetProvider : HomeWidgetProvider() {
     override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val nextPrayer = widgetData.getString("next_prayer", "Ramadhan")
                val nextPrayerTime = widgetData.getString("next_prayer_time", "Tracker")
                val progress = widgetData.getInt("progress", 0)
                val streak = widgetData.getInt("streak", 0)
                val day = widgetData.getInt("ramadhan_day", 1)

                setTextViewText(R.id.prayer_info, "$nextPrayer $nextPrayerTime")
                setTextViewText(R.id.progress_text, "Daily Progress: $progress%")
                
                // Update new views
                setProgressBar(R.id.ramadhan_progress_bar, 30, day, false)
                setTextViewText(R.id.ramadhan_day_text, "Day $day/30")
                setTextViewText(R.id.streak_text, "🔥 Streak: $streak")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
