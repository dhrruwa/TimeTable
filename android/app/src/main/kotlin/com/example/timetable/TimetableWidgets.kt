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
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.drawable.GradientDrawable
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

/**
 * Theme tokens pushed by the Flutter app (`HomeWidgetService.refresh`). Read on
 * every render so the native widget recolors on its 60s self-update tick even
 * with the app closed. Defaults reproduce the original Liquid Glass look, so an
 * un-themed install (no keys yet) is unchanged.
 */
private data class WTheme(
    val bgTop: Int,
    val bgBottom: Int,
    val textPrimary: Int,
    val textSecondary: Int,
    val accent: Int,
    val primary: Int,
    val secondary: Int,
    val radiusDp: Float,
    val ramp: String,
    val labelCurrent: String,
    val labelUpnext: String,
    val labelBreak: String,
    val assetPack: String,
    val packCount: Int,
)

private object WidgetTheme {
    private fun parse(s: String?, def: Int): Int =
        try { if (s.isNullOrEmpty()) def else Color.parseColor(s) } catch (e: Exception) { def }

    fun load(context: Context): WTheme {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return WTheme(
            bgTop = parse(p.getString("theme_bg_top", null), Color.parseColor("#FF323B4A")),
            bgBottom = parse(p.getString("theme_bg_bottom", null), Color.parseColor("#FF161B22")),
            textPrimary = parse(p.getString("theme_text_primary", null), Color.WHITE),
            textSecondary = parse(p.getString("theme_text_secondary", null), Color.parseColor("#B8C0CC")),
            accent = parse(p.getString("theme_accent", null), Color.parseColor("#FF5965C8")),
            primary = parse(p.getString("theme_primary", null), Color.parseColor("#FF5965C8")),
            secondary = parse(p.getString("theme_secondary", null), Color.parseColor("#FF8A93E0")),
            radiusDp = p.getString("theme_radius", null)?.toFloatOrNull() ?: 26f,
            ramp = p.getString("theme_progress_ramp", null) ?: "redGreen",
            labelCurrent = p.getString("theme_label_current", null) ?: "IN PROGRESS",
            labelUpnext = p.getString("theme_label_upnext", null) ?: "UP NEXT",
            labelBreak = p.getString("theme_label_break", null) ?: "ON BREAK",
            assetPack = p.getString("theme_asset_pack", null) ?: "",
            packCount = p.getString("theme_pack_count", null)?.toIntOrNull() ?: 0,
        )
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

        val theme = WidgetTheme.load(context)
        applyTheme(context, mgr, id, v, theme, variant)

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
            setBody(v, theme.labelUpnext, f.title, "Starts ${hm(f.s)}${roomSuffix(f.room)}")
        } else if (minutes >= today.last().e) {
            setBody(v, "DONE", "Classes are over", nextText(days, weekday))
        } else {
            val cur = today.firstOrNull { minutes >= it.s && minutes < it.e }
            when {
                cur == null -> {
                    val nx = today.firstOrNull { it.s > minutes }
                    setBody(
                        v, theme.labelUpnext, nx?.title ?: "Free",
                        if (nx != null) "Starts ${hm(nx.s)}${roomSuffix(nx.room)}" else "",
                    )
                }
                cur.isBreak -> {
                    // Keep the lunch/tea distinction unless a pack overrides the
                    // generic break label.
                    val breakLabel = if (theme.labelBreak != "ON BREAK") theme.labelBreak
                        else if (cur.kind == "lunch") "LUNCH BREAK" else "TEA BREAK"
                    setBody(v, breakLabel, "On a break", "Ends ${hm(cur.e)}")
                    setProgress(v, cur, minutes, theme)
                }
                else -> {
                    setBody(
                        v, theme.labelCurrent, cur.title,
                        "Ends ${hm(cur.e)}${roomSuffix(cur.room)}",
                    )
                    setProgress(v, cur, minutes, theme)
                }
            }
        }

        if (variant == Variant.LARGE) {
            if (today.isNotEmpty() && minutes < today.last().e) {
                fillList(context, v, today, minutes, theme, filterPast = true)
            } else {
                fillList(context, v, nextDayEntries(days, weekday), minutes, theme, filterPast = false)
            }
        } else {
            // Compact (small/medium): show the live % complete + the next two
            // classes. These view ids only exist in the compact layout.
            setCompactExtras(v, today, minutes, nowSec, theme, days, weekday)
        }

        mgr.updateAppWidget(id, v)
    }

    /** Paints the themed background (wallpaper if available, else gradient) and
     *  recolors all text views. */
    private fun applyTheme(
        context: Context,
        mgr: AppWidgetManager,
        id: Int,
        v: RemoteViews,
        theme: WTheme,
        variant: Variant,
    ) {
        val dm = context.resources.displayMetrics
        val radiusPx = theme.radiusDp * dm.density

        // Background: a theme-pack wallpaper (the image *is* the theme) when the
        // pack has generated art, else a themed rounded gradient. Both keep
        // rounded corners and get a readability scrim baked in for the wallpaper.
        val wallpaper = loadWallpaper(context, theme, variant, radiusPx)
        if (wallpaper != null) {
            v.setImageViewBitmap(R.id.w_bg, wallpaper)
        } else {
            val opts = mgr.getAppWidgetOptions(id)
            val minWdp = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0) ?: 0
            val minHdp = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0) ?: 0
            val wPx = (((if (minWdp > 0) minWdp else 160)) * dm.density).toInt().coerceIn(1, 1400)
            val hPx = (((if (minHdp > 0) minHdp else 160)) * dm.density).toInt().coerceIn(1, 1600)
            val gd = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(theme.bgTop, theme.bgBottom),
            )
            gd.cornerRadius = radiusPx
            gd.setBounds(0, 0, wPx, hPx)
            val bmp = Bitmap.createBitmap(wPx, hPx, Bitmap.Config.ARGB_8888)
            gd.draw(Canvas(bmp))
            v.setImageViewBitmap(R.id.w_bg, bmp)
        }

        // Text colors.
        v.setTextColor(R.id.w_day, theme.textPrimary)
        v.setTextColor(R.id.w_date, theme.textSecondary)
        v.setTextColor(R.id.w_status, theme.textPrimary)
        v.setTextColor(R.id.w_title, theme.textPrimary)
        v.setTextColor(R.id.w_subtitle, theme.textSecondary)
    }

    /** Loads the rotating wallpaper PNG bundled in flutter_assets for [variant],
     *  rounds its corners and bakes a bottom-weighted dark scrim for legibility.
     *  Returns null when the pack has no art (→ gradient fallback). The index
     *  matches the Dart `WallpaperPacks.indexFor` so both platforms agree. */
    private fun loadWallpaper(
        context: Context,
        theme: WTheme,
        variant: Variant,
        radiusPx: Float,
    ): Bitmap? {
        if (theme.packCount <= 0 || theme.assetPack.isEmpty()) return null
        val cal = Calendar.getInstance()
        val bucket = cal.get(Calendar.DAY_OF_MONTH) * 24 + cal.get(Calendar.HOUR_OF_DAY)
        val idx = (bucket % theme.packCount) + 1
        val sizeName = when (variant) {
            Variant.SMALL -> "small"
            Variant.MEDIUM -> "medium"
            Variant.LARGE -> "large"
        }
        val path = "flutter_assets/assets/theme_packs/${theme.assetPack}/${idx}_$sizeName.jpg"
        val src = try {
            context.assets.open(path).use { BitmapFactory.decodeStream(it) }
        } catch (e: Exception) {
            null
        } ?: return null

        val w = src.width
        val h = src.height
        val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = Canvas(out)
        val path2 = Path().apply {
            addRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), radiusPx, radiusPx, Path.Direction.CW)
        }
        c.clipPath(path2)
        c.drawBitmap(src, 0f, 0f, null)
        // Bottom-weighted dark scrim (strength 0.55, matching the Flutter side).
        val s = 0.55f
        val scrim = Paint().apply {
            shader = LinearGradient(
                0f, 0f, 0f, h.toFloat(),
                intArrayOf(
                    Color.argb((0.35f * 255 * s).toInt(), 0, 0, 0),
                    Color.argb((0.55f * 255 * s).toInt(), 0, 0, 0),
                    Color.argb((255 * s).toInt(), 0, 0, 0),
                ),
                floatArrayOf(0f, 0.5f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        c.drawRect(0f, 0f, w.toFloat(), h.toFloat(), scrim)
        return out
    }

    /** Live % complete (tinted on the active theme's ramp) + the next two classes. */
    private fun setCompactExtras(
        v: RemoteViews,
        today: List<Entry>,
        minutes: Int,
        nowSec: Int,
        theme: WTheme,
        days: Map<Int, List<Entry>>,
        weekday: Int,
    ) {
        v.setTextColor(R.id.w_next, theme.textSecondary)
        v.setTextColor(R.id.w_after, theme.textSecondary)
        val cur = today.firstOrNull { minutes >= it.s && minutes < it.e && !it.isBreak }
        if (cur != null) {
            val total = ((cur.e - cur.s) * 60).coerceAtLeast(1)
            val done = (nowSec - cur.s * 60).coerceIn(0, total)
            val frac = done.toFloat() / total
            val color = progressColor(frac, theme)
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

        var upcoming = today.filter { !it.isBreak && it.s > minutes }
        var nextLabel = "Next"
        if (upcoming.isEmpty()) {
            // Today's classes are over (or there are none) — fall back to the
            // next day that has classes so the widget isn't left blank.
            upcoming = nextDayEntries(days, weekday).filter { !it.isBreak }
            nextLabel = "Tomorrow"
        }
        setUpcoming(v, R.id.w_next, nextLabel, upcoming.getOrNull(0))
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
     * Live class-progress color. The ramp is selected by the active theme's
     * `ProgressRamp` name — MUST stay in parity with the Flutter
     * `Wx.progressColor` (same name → same math).
     *
     *   redGreen: #FF0000 → … → #00FF00 (the original ramp)
     *   mono:     a single accent hue (progress reads from the bar length)
     *   neon:     cool secondary → warm primary across the period
     */
    private fun progressColor(t: Float, theme: WTheme): Int {
        val x = t.coerceIn(0f, 1f)
        return when (theme.ramp) {
            "mono" -> theme.accent
            "neon" -> lerpColor(theme.secondary, theme.primary, x)
            else -> {
                val r: Int
                val g: Int
                if (x <= 0.5f) {
                    r = 255
                    g = (510 * x).toInt()
                } else {
                    r = (255 - 510 * (x - 0.5f)).toInt()
                    g = 255
                }
                Color.rgb(r.coerceIn(0, 255), g.coerceIn(0, 255), 0)
            }
        }
    }

    private fun lerpColor(a: Int, b: Int, t: Float): Int {
        val u = t.coerceIn(0f, 1f)
        fun ch(s: Int, e: Int) = (s + (e - s) * u).toInt().coerceIn(0, 255)
        return Color.argb(
            255,
            ch(Color.red(a), Color.red(b)),
            ch(Color.green(a), Color.green(b)),
            ch(Color.blue(a), Color.blue(b)),
        )
    }

    private fun setBody(v: RemoteViews, status: String, title: String, subtitle: String) {
        v.setTextViewText(R.id.w_status, status)
        v.setViewVisibility(R.id.w_status, if (status.isEmpty()) View.GONE else View.VISIBLE)
        v.setTextViewText(R.id.w_title, title)
        v.setTextViewText(R.id.w_subtitle, subtitle)
    }

    private fun setProgress(v: RemoteViews, cur: Entry, minutes: Int, theme: WTheme) {
        val total = (cur.e - cur.s).coerceAtLeast(1)
        val done = (minutes - cur.s).coerceIn(0, total)
        v.setViewVisibility(R.id.w_progress, View.VISIBLE)
        v.setProgressBar(R.id.w_progress, total, done, false)
        if (Build.VERSION.SDK_INT >= 31) {
            val frac = done.toFloat() / total
            v.setColorStateList(
                R.id.w_progress,
                "setProgressTintList",
                ColorStateList.valueOf(progressColor(frac, theme)),
            )
        }
    }

    /** [filterPast]=true hides classes that have already ended (today's remaining
     *  list); false shows every class (a future day's full timetable). */
    private fun fillList(
        context: Context,
        v: RemoteViews,
        entries: List<Entry>,
        minutes: Int,
        theme: WTheme,
        filterPast: Boolean,
    ) {
        v.removeAllViews(R.id.w_list)
        var p = 0
        for (e in entries) {
            if (!e.isBreak) p++
            if (e.isBreak) continue
            if (filterPast && e.e <= minutes) continue
            val row = RemoteViews(context.packageName, R.layout.widget_native_row)
            row.setTextViewText(R.id.row_p, "P$p")
            row.setTextColor(R.id.row_p, theme.textPrimary)
            row.setTextViewText(R.id.row_title, e.title)
            row.setTextColor(R.id.row_title, theme.textPrimary)
            row.setTextViewText(R.id.row_time, "${hm(e.s)}–${hm(e.e)}${roomSuffix(e.room)}")
            row.setTextColor(R.id.row_time, theme.textSecondary)
            v.addView(R.id.w_list, row)
        }
    }

    /** Entries for the next day (walking forward from tomorrow) that has any
     *  classes at all, or an empty list if none found within a week. */
    private fun nextDayEntries(days: Map<Int, List<Entry>>, weekday: Int): List<Entry> {
        for (off in 1..7) {
            val wd = ((weekday - 1 + off) % 7) + 1
            if (wd > 6) continue
            val list = days[wd]
            if (!list.isNullOrEmpty()) return list
        }
        return emptyList()
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
