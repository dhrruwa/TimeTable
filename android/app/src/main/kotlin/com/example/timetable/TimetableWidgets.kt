package com.example.timetable

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.graphics.Color
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.Calendar

/**
 * Native, self-updating home-screen widgets.
 *
 * Instead of displaying a PNG that Flutter rendered (which only works while the
 * app is foregrounded), these read the per-day timeline JSON the app saved
 * (`tt_timelines`) and compute the CURRENT period from the system clock. An
 * AlarmManager tick re-renders them roughly once a minute, so they stay live in
 * the background without the Flutter engine.
 */

enum class Variant { SMALL, MEDIUM, LARGE }

private const val PREFS = "HomeWidgetPreferences"
const val ACTION_TICK = "com.example.timetable.WIDGET_TICK"

private data class Entry(
    val s: Int,
    val e: Int,
    val title: String,
    val kind: String,
    val room: String,
) {
    val isBreak get() = kind == "tea" || kind == "lunch"
}

private object WidgetData {
    fun days(context: Context): Map<Int, List<Entry>> {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("tt_timelines", null) ?: return emptyMap()
        return try {
            val obj = JSONObject(raw)
            val out = HashMap<Int, List<Entry>>()
            for (d in 1..6) {
                val arr = obj.optJSONArray(d.toString()) ?: continue
                val list = ArrayList<Entry>(arr.length())
                for (i in 0 until arr.length()) {
                    val o = arr.getJSONObject(i)
                    list.add(
                        Entry(
                            o.optInt("s"),
                            o.optInt("e"),
                            o.optString("t"),
                            o.optString("k"),
                            o.optString("room"),
                        )
                    )
                }
                out[d] = list
            }
            out
        } catch (e: Exception) {
            emptyMap()
        }
    }
}

object WidgetRenderer {
    private val MONTHS = arrayOf(
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    )
    private val DAYS = arrayOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")

    fun render(context: Context, mgr: AppWidgetManager, id: Int, variant: Variant) {
        val layout = if (variant == Variant.LARGE)
            R.layout.widget_native_large else R.layout.widget_native_compact
        val v = RemoteViews(context.packageName, layout)
        setClick(context, v)

        val cal = Calendar.getInstance()
        val weekday = isoWeekday(cal)
        val minutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
        val nowSec = cal.get(Calendar.HOUR_OF_DAY) * 3600 +
            cal.get(Calendar.MINUTE) * 60 + cal.get(Calendar.SECOND)

        v.setTextViewText(R.id.w_day, DAYS[(weekday - 1).coerceIn(0, 6)])
        v.setTextViewText(
            R.id.w_date,
            "${cal.get(Calendar.DAY_OF_MONTH)} ${MONTHS[cal.get(Calendar.MONTH)]}",
        )

        val days = WidgetData.days(context)
        val today = days[weekday] ?: emptyList()
        v.setViewVisibility(R.id.w_progress, View.GONE)

        if (today.isEmpty()) {
            setBody(v, "", "No classes today", nextText(days, weekday))
        } else if (minutes < today.first().s) {
            val f = today.first()
            setBody(v, "UP NEXT", f.title, "Starts ${hm(f.s)}${roomSuffix(f.room)}")
        } else if (minutes >= today.last().e) {
            setBody(v, "DONE", "Classes are over", nextText(days, weekday))
        } else {
            val cur = today.firstOrNull { minutes >= it.s && minutes < it.e }
            when {
                cur == null -> {
                    val nx = today.firstOrNull { it.s > minutes }
                    setBody(
                        v, "UP NEXT", nx?.title ?: "Free",
                        if (nx != null) "Starts ${hm(nx.s)}${roomSuffix(nx.room)}" else "",
                    )
                }
                cur.isBreak -> {
                    setBody(
                        v,
                        if (cur.kind == "lunch") "LUNCH BREAK" else "TEA BREAK",
                        "On a break", "Ends ${hm(cur.e)}",
                    )
                    setProgress(v, cur, minutes)
                }
                else -> {
                    setBody(
                        v, "IN PROGRESS", cur.title,
                        "Ends ${hm(cur.e)}${roomSuffix(cur.room)}",
                    )
                    setProgress(v, cur, minutes)
                }
            }
        }

        if (variant == Variant.LARGE) {
            fillList(context, v, today, minutes)
        } else {
            // Compact (small/medium): show the live % complete + the next two
            // classes. These view ids only exist in the compact layout.
            setCompactExtras(v, today, minutes, nowSec)
        }

        mgr.updateAppWidget(id, v)
    }

    /** Live % complete (tinted on the red→green ramp) + the next two classes. */
    private fun setCompactExtras(v: RemoteViews, today: List<Entry>, minutes: Int, nowSec: Int) {
        val cur = today.firstOrNull { minutes >= it.s && minutes < it.e && !it.isBreak }
        if (cur != null) {
            val total = ((cur.e - cur.s) * 60).coerceAtLeast(1)
            val done = (nowSec - cur.s * 60).coerceIn(0, total)
            val frac = done.toFloat() / total
            val color = progressColor(frac)
            v.setTextViewText(R.id.w_pct, "${(frac * 100).toInt()}%")
            v.setTextColor(R.id.w_pct, color)
            v.setViewVisibility(R.id.w_pct, View.VISIBLE)
            if (Build.VERSION.SDK_INT >= 31) {
                v.setColorStateList(
                    R.id.w_progress, "setProgressTintList", ColorStateList.valueOf(color),
                )
            }
        } else {
            v.setViewVisibility(R.id.w_pct, View.GONE)
        }

        val upcoming = today.filter { !it.isBreak && it.s > minutes }
        setUpcoming(v, R.id.w_next, "Next", upcoming.getOrNull(0))
        setUpcoming(v, R.id.w_after, "Then", upcoming.getOrNull(1))
    }

    private fun setUpcoming(v: RemoteViews, id: Int, label: String, e: Entry?) {
        if (e == null) {
            v.setViewVisibility(id, View.GONE)
        } else {
            v.setTextViewText(id, "$label · ${e.title} · ${hm(e.s)}${roomSuffix(e.room)}")
            v.setViewVisibility(id, View.VISIBLE)
        }
    }

    /**
     * The shared red→green ramp, matching the Flutter `Wx.progressColor`:
     * #FF0000 → #FF5500 → #FFAA00 → #FFFF00 → #AAFF00 → #55FF00 → #00FF00.
     */
    fun progressColor(t: Float): Int {
        val x = t.coerceIn(0f, 1f)
        val r: Int
        val g: Int
        if (x <= 0.5f) {
            r = 255
            g = (510 * x).toInt()
        } else {
            r = (255 - 510 * (x - 0.5f)).toInt()
            g = 255
        }
        return Color.rgb(r.coerceIn(0, 255), g.coerceIn(0, 255), 0)
    }

    private fun setBody(v: RemoteViews, status: String, title: String, subtitle: String) {
        v.setTextViewText(R.id.w_status, status)
        v.setViewVisibility(R.id.w_status, if (status.isEmpty()) View.GONE else View.VISIBLE)
        v.setTextViewText(R.id.w_title, title)
        v.setTextViewText(R.id.w_subtitle, subtitle)
    }

    private fun setProgress(v: RemoteViews, cur: Entry, minutes: Int) {
        val total = (cur.e - cur.s).coerceAtLeast(1)
        val done = (minutes - cur.s).coerceIn(0, total)
        v.setViewVisibility(R.id.w_progress, View.VISIBLE)
        v.setProgressBar(R.id.w_progress, total, done, false)
    }

    private fun fillList(context: Context, v: RemoteViews, today: List<Entry>, minutes: Int) {
        v.removeAllViews(R.id.w_list)
        var p = 0
        for (e in today) {
            if (!e.isBreak) p++
            if (e.e <= minutes || e.isBreak) continue // list only upcoming classes
            val row = RemoteViews(context.packageName, R.layout.widget_native_row)
            row.setTextViewText(R.id.row_p, "P$p")
            row.setTextViewText(R.id.row_title, e.title)
            row.setTextViewText(R.id.row_time, "${hm(e.s)}–${hm(e.e)}${roomSuffix(e.room)}")
            v.addView(R.id.w_list, row)
        }
    }

    private fun nextText(days: Map<Int, List<Entry>>, weekday: Int): String {
        for (off in 1..7) {
            val wd = ((weekday - 1 + off) % 7) + 1
            if (wd > 6) continue
            val first = days[wd]?.firstOrNull { !it.isBreak } ?: continue
            val label = if (off == 1) "Tomorrow" else DAYS[wd - 1]
            return "$label · ${first.title} ${hm(first.s)}"
        }
        return "Enjoy the break!"
    }

    private fun roomSuffix(room: String) = if (room.isNotEmpty()) " · $room" else ""

    private fun hm(m: Int): String = "%d:%02d".format(m / 60, m % 60)

    private fun isoWeekday(cal: Calendar): Int {
        val dow = cal.get(Calendar.DAY_OF_WEEK) // Sun=1..Sat=7
        return if (dow == Calendar.SUNDAY) 7 else dow - 1
    }

    private fun setClick(context: Context, v: RemoteViews) {
        val launch = context.packageManager
            .getLaunchIntentForPackage(context.packageName) ?: return
        val flags = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        v.setOnClickPendingIntent(
            R.id.w_root,
            PendingIntent.getActivity(context, 0, launch, flags),
        )
    }
}

// ─── Providers (one per size) ───────────────────────────────────────────────

abstract class BaseTimetableWidget : AppWidgetProvider() {
    abstract val variant: Variant

    override fun onUpdate(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        for (id in ids) WidgetRenderer.render(context, mgr, id, variant)
        WidgetScheduler.schedule(context)
    }

    override fun onEnabled(context: Context) = WidgetScheduler.schedule(context)

    override fun onDisabled(context: Context) {
        if (!WidgetScheduler.anyWidgets(context)) WidgetScheduler.cancel(context)
    }
}

class TimetableWidgetSmall : BaseTimetableWidget() {
    override val variant = Variant.SMALL
}

class TimetableWidgetMedium : BaseTimetableWidget() {
    override val variant = Variant.MEDIUM
}

class TimetableWidgetLarge : BaseTimetableWidget() {
    override val variant = Variant.LARGE
}

// ─── Tick / boot receiver: re-renders every size, then reschedules ──────────

class WidgetTickReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val mgr = AppWidgetManager.getInstance(context)
        updateAll(context, mgr, TimetableWidgetSmall::class.java, Variant.SMALL)
        updateAll(context, mgr, TimetableWidgetMedium::class.java, Variant.MEDIUM)
        updateAll(context, mgr, TimetableWidgetLarge::class.java, Variant.LARGE)
        WidgetScheduler.schedule(context)
    }

    private fun updateAll(
        context: Context,
        mgr: AppWidgetManager,
        cls: Class<*>,
        variant: Variant,
    ) {
        for (id in mgr.getAppWidgetIds(ComponentName(context, cls))) {
            WidgetRenderer.render(context, mgr, id, variant)
        }
    }
}

object WidgetScheduler {
    private const val REQ = 7711

    private fun pendingTick(context: Context): PendingIntent {
        val i = Intent(context, WidgetTickReceiver::class.java).setAction(ACTION_TICK)
        val flags = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        return PendingIntent.getBroadcast(context, REQ, i, flags)
    }

    /** Inexact repeating alarm ~once a minute (no special permission needed). */
    fun schedule(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val next = ((System.currentTimeMillis() / 60000L) + 1) * 60000L
        am.setRepeating(AlarmManager.RTC, next, 60_000L, pendingTick(context))
    }

    fun cancel(context: Context) {
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
            .cancel(pendingTick(context))
    }

    fun anyWidgets(context: Context): Boolean {
        val mgr = AppWidgetManager.getInstance(context)
        return listOf(
            TimetableWidgetSmall::class.java,
            TimetableWidgetMedium::class.java,
            TimetableWidgetLarge::class.java,
        ).any { mgr.getAppWidgetIds(ComponentName(context, it)).isNotEmpty() }
    }
}
