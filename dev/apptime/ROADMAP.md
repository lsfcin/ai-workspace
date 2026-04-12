# AppTime — Roadmap

## M8 - Fixes
x Disappearance: overlay is resilient, but at some point it is still disappearing. It is the most important feature and we must guarantee by all means it remains there
x Positioning: it is not working properly. Changing the direction (left, below, right) moves the overlay all over the corners of the screen. The intent was to move it to the left/bottom/right of the camera orifice on the screen. If it is not possible to have the camera orifice as anchor (and for exemple place the overlay on the left of it in the same region of the clock bar) then let's rephrase the config. we can just place it in the top center of the screen you know... it will be fine this way.
x Can we place the overlay in the same height as the clock bar? It would be interesting to have such freedom of placement
x Font size config is not working
x The config show border (mostrar borda) does nothing
x Displacement (sliders for vertical and horizontal) configs are not working either
x Unblock counts are simply not working
x I believe we are accumulating usage time of an app even if the screen is blocked. Maybe we are incrementing the time in other scenarios as well (not sure), for example after the app is open but we return to the launcher screen (without closing it) or go to another app. The time count should only consider when the app is on foreground.
x I believe we are not unsing any usage data natively stored by Android, is this the best option? Is it because Android data isn't precise? If we do not use it we have to be flawless and always store precise data. I understand that maybe have mixed usage data (part from our end part from Android's native analytics) can be confusing/ambiguous and lead to errors. Define an strategy that is the most precise please.
x Change monitoring policy from "Today" to "24h" meaning we're reporting on the last 24 hours of usage


## M9 — Polish

- HomeScreen "Insight of the day": 50 PT-BR texts with high-citation recognized scientific references, 3min rotation
x Adaptive icon (`flutter_launcher_icons`); Check it, I believe it is already done.
- Edge cases: MIUI home, device reboot (service won't auto-start — document limitation), active session at day rollover

## M10 — Analysis Blocks

List of analysis blocks to place in the analysis tab (under the correct subtab: 24h | 7days | 30days):

1. Sleep Hygiene and Circadian Rhythm
Icon: 🌙 (Moon / Sleep)

Graph: Time Bar Chart (X-axis: 00h-23h; Y-axis: Minutes of use).

Visual distinguishing feature: Highlight in contrasting color (e.g., dark purple) for the 10 PM to 6 AM interval.

Analysis Text: "Your use between 10 PM and 2 AM represents [X]% of your total time. Research indicates that blue light and cognitive stimulation during this period delay melatonin secretion by up to 30 minutes, impairing the REM phase of sleep."

Variation (7/30 days): Shows the average "late use" per day of the week to identify if the problem is chronic or occasional (e.g., weekends).

2. Impulsivity Index (Checking Habit)
Icon: ⚡ (Bolt / Impulse)

Graph: Scatter Plot (X-axis: Hours of the day; Y-axis: Number of openings).

Visual differentiator: Larger or more vibrant points where the density of openings per hour is greater than 10.

Analysis Text: "You opened apps [X] times today. The frequency of openings (unlocks) is a stronger predictor of anxiety and poor sleep quality than total screen time. Opening your phone more than 50 times a day is correlated with elevated cortisol levels."

3. Focus Fragmentation (Deep Work vs. Interruptions)
Icon: 🧩 (Puzzle / Focus)

Graph: Session Duration Histogram (X-axis: Time ranges such as <1min, 1-5min, 5-15min, >15min; Y-axis: Frequency).

Distinguishing Visual: An "Alert" bar for sessions shorter than 1 minute (so-called "micro-usage").

Analysis Text: "[X]% of your sessions lasted less than 60 seconds. This indicates an impulsive 'checking habit' that fragments your attention and prevents the 'Flow' state. Users with high fragmentation take up to 20% longer to complete complex tasks."

4. Engagement Balance (Active vs. Passive)
Icon: ⚖️ (Balance / Scales)

Chart: Donut Chart comparing app categories.

Distinguishing Visual: Clear division between "Communicative/Active" apps (Messaging, Tools) vs. "Passive Consumption" (Social Networks, Videos).

Analysis Text: "Your usage was [X]% passive today. Non-communicative feed consumption is linked to rumination and symptoms of depression, while active usage (actual messaging) may have a protective effect on mental health."

5. The "Dopamine Drain" (Dominant App)
Icon: 🧠 (Brain / Spark)

Chart: Ranked Horizontal Bars of the top 5 most opened apps.

Distinguishing Visual: "Danger gradient" color for the app that combines a high number of opens with short sessions. Analysis Text: "App X was your biggest trigger today, with X openings. Infinite scrolling apps are designed like 'slot machines' to release intermittent dopamine, creating a cycle of searching that's hard to break without intervention."

6. Relapse and Trend Analysis (7/30-day Windows)
Icon: 📉 (Trending Down)

Chart: Comparative Line Graph (This week's usage vs. last week's average).

Visual Difference: Shaded area between the two lines to show "recovered time" or "lost time".

Analysis Text: "You reduced your usage by X% compared to last week. Maintaining this trend for 21 days is the scientific benchmark for neural habit rewiring and prefrontal cortex strengthening."

7. The "Opportunity Cost" (Offline Life)
Icon: ⏳ (Hourglass)

Graph: Comparative Text Infographic.

Distinguishing Visual: Offline activity icons (Book, Walk, Sleep) with equivalent time.

Analysis Text: "Today's [X] hours are equivalent to: reading 40 pages of a book, walking 10km, or 2 complete cycles of deep sleep. What did you choose to trade for your smartphone today?"

8. "Weekend Spike" Pattern (30-day Window)
Icon: 🏖️ (Beach / Weekend)

Graph: Heatmap Calendar.

Distinguishing Visual: Squares that become redder as usage exceeds the daily goal.

Analysis Text: "Your usage increases [X]% on Saturdays and Sundays. Although it seems like leisure, excessive use on rest days prevents cognitive recovery from weekly stress, resulting in greater fatigue on Monday."

9. "Phubbing" Alert (Use During Social Moments)
Icon: 👥 (People / Social)

Graph: Intensity Bar Graph at traditional meal times (12pm-2pm and 7pm-9pm).

Distinguishing Visual: Emphasis on the number of times your phone is opened during these times.

Analysis Text: "You opened your phone [X] times during lunch/dinner. 'Phubbing' (ignoring those who are physically present) weakens social bonds and increases feelings of loneliness in the long term."

Implementation Tip: In the Roadmap, prioritize the Sleep Hygiene and Impulsivity Index blocks for the 24-hour tab, as they offer the most actionable and immediate feedback for the user. For the 30-day tab, focus on the Trend and Heat Map blocks, which help visualize the change in behavioral identity.

## M11 — Insights