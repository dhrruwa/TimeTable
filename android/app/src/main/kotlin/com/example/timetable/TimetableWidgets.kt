package com.example.timetable

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Three separate home-screen widgets so each size shows up as its own pickable
 * widget in the launcher. Each just displays the PNG that Flutter rendered for
 * its size (keys: tt_small / tt_medium / tt_large).
 */
abstract class BaseTimetableWidget : HomeWidgetProvider() {

    abstract val imageKey: String

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.timetable_widget)

            val path = widgetData.getString(imageKey, null)
            if (path != null) {
                val bmp = BitmapFactory.decodeFile(path)
                if (bmp != null) views.setImageViewBitmap(R.id.widget_image, bmp)
            }

            context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?.let { launch ->
                    val pending = PendingIntent.getActivity(
                        context,
                        0,
                        launch,
                        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                    )
                    views.setOnClickPendingIntent(R.id.widget_root, pending)
                }

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

class TimetableWidgetSmall : BaseTimetableWidget() {
    override val imageKey = "tt_small"
}

class TimetableWidgetMedium : BaseTimetableWidget() {
    override val imageKey = "tt_medium"
}

class TimetableWidgetLarge : BaseTimetableWidget() {
    override val imageKey = "tt_large"
}
