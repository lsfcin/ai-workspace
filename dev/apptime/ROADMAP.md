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

## M10 — Analysis Blocks (done)

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

## M11 — Insights (done)

Category A: Harmful Behaviors and Alerts
🚨 Impulsivity and Checking Habits
Frequency vs. Sleep: Checking your phone more than 400 times per week increases the risk of poor sleep quality by 61%, a much stronger predictor than total screen time alone.
Reference: Mental Health Journal, 2025 Study on Objective Smartphone Use.

The Anxiety Loop: Frequent checking for notifications creates an "intermittent reward" cycle similar to slot machines, conditioning your brain to constantly seek the next dopamine hit.
Reference: Psychology of Phone Addiction Research.

The Cost of Unlocking: Each time you unlock your phone without a specific goal, you reinforce impulsive neural pathways that make it harder to sustain focus on long-term tasks.
Reference: Longitudinal Investigation of Smartphone Interaction Patterns.

Micro-usage Stress: Usage sessions shorter than 10 seconds are typically "boredom checks" that fragment your attention and increase baseline stress levels.
Reference: ARDUOUS User Interaction Analysis.

🌑 Sleep Hygiene and Blue Light
Melatonin Delay: Using screens before bed can delay the release of melatonin by up to 30 minutes, hindering your brain's ability to recover overnight.
Reference: Frontiers in Psychiatry, 2025 Digital Nudge Study.

REM Sleep Loss: People who use social media in bed lose an average of 16 minutes of sleep per night due to cognitive overstimulation and blue light exposure.
Reference: University of Wisconsin-Madison Attention Research.

Stressful Awakenings: Checking your phone within the first 5 minutes of waking up places your brain in a high-cortisol "stress-alert" state before you even leave bed.
Reference: Mindfulness and Digital Distraction Study.

Sleep Duration: Heavy smartphone use (over 63 hours per week) is directly linked to a 6.66-minute reduction in your total nightly rest.
Reference: Journal of Medical Internet Research, 2025.

🧠 Focus, Productivity, and Multitasking
The 23-Minute Rule: After a single notification interruption, it takes your brain an average of 23 minutes and 15 seconds to regain deep focus on your original task.
Reference: Gloria Mark, UCI Research on the Cost of Interrupted Work.

Temporary IQ Loss: Digital multitasking can reduce your functional IQ by 10 points—a greater cognitive impact than losing an entire night of sleep.
Reference: American Psychological Association Research on Multitasking.

Productivity Drain: Switching between apps and work can consume up to 40% of your productive time due to the cognitive load of mental reorientation.
Reference: Rubinstein, Meyer, & Evans (2001) Task-Switching Study.

Attention Erosion: Over the last 20 years, the average attention span on a single digital task has plummeted from 150 seconds to just 47 seconds.
Reference: Dr. Gloria Mark (2023) Attention Span Data.

The Multitasker Myth: Only 2.5% of the population can effectively multitask; for the other 97.5%, error rates increase by 50% when using a phone during work.
Reference: Watson & Strayer (2010) Supertasker Profiles.

🤳 Passive vs. Active Consumption
Emotion Sink: Passively scrolling through feeds without interacting is strongly linked to increased symptoms of depression, anxiety, and social envy.
Reference: Mobile Sensing Technology Mental Health Study.

Maladaptive Escape: Using your smartphone to "kill time" or avoid negative emotions often exacerbates digital fatigue and long-term mental exhaustion.
Reference: Cognitive Load Theory and Digital Fatigue Research.

Doomscrolling: Consuming endless negative news triggers the amygdala, keeping your body in a constant "fight-or-flight" state.
Reference: Emerson Health Digital Wellness Guidelines.

🦴 Physical Health and Ergonomics
Neck Pressure: Tilting your head at 60 degrees to look at your phone exerts 60 pounds (approx. 27kg) of force on your cervical spine.
Reference: "Text Neck" Biomechanical Model Research.

Chronic Pain Risk: Excessive smartphone users have a sixfold higher risk of developing chronic neck and shoulder pain due to poor postural habits.
Reference: Longitudinal Population-Based Cohort Study (Gustafsson et al.).

Digital Eye Strain: Prolonged screen use reduces your blink rate by up to 50%, leading to dry eyes, blurred vision, and persistent headaches.
Reference: Computer Vision Syndrome (CVS) and the 20-20-20 Rule Research.

👥 Social Impact (Phubbing)
The Silent Presence: Even a phone placed face-down on a table reduces the depth of conversation and emotional connection between people in the room.
Reference: Sherry Turkle, Reclaiming Conversation Research.

Digital Loneliness: "Phubbing" (ignoring others for your phone) triggers feelings of exclusion and ostracism in partners and friends, damaging long-term trust.
Reference: Seppala (2017) Phubbing and Relationship Satisfaction Study.

Empathy Decline: College students who grew up with intense technology use show 40% less empathy than generations 20 years ago.
Reference: Sherry Turkle & University of Michigan Empathy Meta-Analysis.

Category B: Positive Adjustments and Solutions
🛠️ Habit Change Techniques
The Power of Grayscale: Switching your screen to black and white reduces daily use by approximately 20-40 minutes by making apps less visually rewarding.
Reference: Holte & Ferraro (2020) Grayscale Screen Time Research.

The Friction Rule: Introducing just a 10-second delay before opening a target app is enough to dissipate most impulsive urges for mindless consumption.
Reference: "One Sec" App Psychological Mechanism Study, PNAS 2023.

Out of Sight: Keeping your phone in another room while working significantly improves your working memory and cognitive capacity.
Reference: Ward et al. (2017) "Brain Drain" Study.

Manual Passwords: Disabling biometric unlocking (FaceID/TouchID) in favor of long passwords adds a layer of "deliberate friction" that reduces impulsive opens.
Reference: Nudge-Based Intervention Randomized Controlled Trial.

The 20-20-20 Rule: Every 20 minutes of screen use, look at something 20 feet away for 20 seconds to relax your eye muscles and prevent strain.
Reference: Eye Care Practitioner Clinical Guidelines for Digital Fatigue.

🌿 Wellbeing and Recovery
Nature Reboot: Spending 3 days in nature without a phone can increase cognitive function and creative problem-solving skills by 50%.
Reference: The "Three-Day Effect" and Attention Restoration Theory.

Screen Time Detox: Reducing screen time for just 3 weeks can improve mental health indicators with an effect size comparable to antidepressants.
Reference: Georgetown University Digital Detox Study (Kushlev et al., 2025).

Prefrontal Strength: Daily "digital fasting" periods help strengthen your prefrontal cortex, returning control over your decisions and reducing internet addiction.
Reference: Mindfulness Practice for Behavioral Addiction Research.

Unitasking Training: Rebuilding your attention span requires training the brain to focus on a single app or task for 25 uninterrupted minutes.
Reference: Reclaiming Conversation - Unitasking Principles.

📊 Awareness and Environment
The Underestimation Gap: Users typically underestimate their actual smartphone usage by 20% to 50% until they see objective tracking data.
Reference: Agreement Between Self-Reported and Objective Usage Study.

Adaptive Goal Setting: Reducing your usage in small, 10% weekly increments is more effective for permanent change than attempting sudden, drastic cuts.
Reference: Rule-Based Adaptive Goals in Habit Formation.

Opportunity Cost: Visualizing your screen time as "lost hours" helps you prioritize real-world hobbies, exercise, and deep sleep.
Reference: PNAS Nexus (2025) Blocking Mobile Internet Study.

Trigger Removal: Hiding social media apps in folders off your home screen reduces the visual cues that trigger automatic "checking" behaviors.
Reference: Fogg Behavior Model and Multifaceted Nudges.

Feed Audit: Unfollowing accounts that trigger negative emotions can transform your passive usage into a more neutral or positive experience.
Reference: Digital Wellness Guidelines for Doomscrolling.

Active Recovery: Replacing a 5-minute scroll session with a short walk rejuvenates the brain and reduces mental fatigue faster than digital entertainment.
Reference: CareerBuilder Workplace Productivity Suggestion.

The Bedroom Rule: Charging your phone outside the bedroom improves sleep quality and prevents the cortisol spike associated with morning scrolling.
Reference: Digital Detox Benefits and Sleep Quality Research.

Selective Notifications: Keeping only human-to-human alerts (messaging) while disabling app-driven "pings" reduces constant environmental stress.
Reference: Intervention for Reducing Non-Essential Notification Disruptions.

Mindfulness Pause: Before opening an app, asking yourself "Why am I picking this up?" shifts your state from System 1 (automatic) to System 2 (deliberate).
Reference: Pratt Institute Digital Wellbeing Journey Guidelines.

## M12 — Active Overlay

Dynamic overlay behavior

## M13 — Permissions Onboarding (done)

. Define the best way the first-use should happen, how users should be directed towards allowing the permissions, popups? automatically?

. Implement that

## M14 — L