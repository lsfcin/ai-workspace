# AppTime — Roadmap

## M13 — Language Support

I am brazilian and the app will likely be first used here. So:
. First I'd like to prepare the app to easily interchange between brazilian portugues and en-us. So prepare the project in a way all content of output/visible text is separated, right? Well, use industry standards for that.
. Add a config for that so the user can change.
. Make pt-br the default language.
. Can you make the language recognition an automatic selection (maybe on the first use).

## M14 — Goals and Dynamic Overlay

To implement this feature you'll likely have to read the entire milestone (M14 — Goals and Dynamic Overlay), it is not separated in small sequential bullets as other roadmap cases. Create your own todo list and write it in subsection, then follow it changing the - (todo) for x (done) step by step. Also, remember to commit changes.

### 1. Dynamic Overlay Feedback

Following "Calm Technology" principles, the overlay should move from the periphery of attention to the center only when behavior becomes risky. Here are a list of feedbacks we will explore, each with a code.

#### F.VW - Visual Weight

- **Intent:** To disrupt the "digital trance" of mindless scrolling.
- **Feedback:** **"Visual Weight."** As the passes between 80% to 100% of their limit, the overlay grow accordingly (1.2x scale, 0.01 scale addition for each % of time, e.g., 87% of the limit means 1.07x the scale). This increases its "visual salience," making the passage of time more physically felt without being intrusive.

#### F.BN - Breathing Nudge

- **Intent:** To provide a "Silent Mirror" of behavior without interrupting the task.
- **Feedback:** **"The Breathing Nudge."** The overlay uses a smooth fade-in (randomly between 2-3 seconds), stays on (randomy between 1-3 second) and fade-out (between 2-3 seconds seconds) cycle. This intermittent (and random pattern) presence prevents "banner blindness" by subtly re-engaging the user’s awareness.

#### F.PM - Personalized Message

- **Intent:** Explicitly alert user of harmful behavior.
- **Visuals:** Momentarily displays a **Personalized Message** with max 2 lines and 4 words per line. Message appears with 3 seconds fade-in, stays for 10 seconds and then fades out in 3 seconds. After another minute the message appears again. For each case in subsection 2.2 (goal x usage metric) write a pre-defined a message (or a mesage stubs/templates with gaps to be filled by apps names or any other relevant info) so we do not need to create the message on runtime. Messages should relate to the harm of the behavior based on the selected research/insights. Be kind with those messages

### 2. Goal Tiers & Parameters

These levels guide the user from simple awareness to high-performance focus. The numbers are derived from recent longitudinal studies on sleep quality and attention span. 

#### 2.1 Scientific Rationales

- **The 4-Hour Threshold:** Studies define "high risk" use as ≥ 4 hours daily, which is strongly associated with depression and irregular sleep routines.
- **The 60-Unlock Cap:** High-frequency checking (≥ 400 times/week or ~ 60/day) is a stronger predictor of poor sleep and "Nomophobia" than total time.
- **The 20-Minute Session:** This aligns with the **20-20-20 rule** (taking a break every 20 minutes to look 20 feet away) to mitigate Digital Eye Strain and "Text Neck".


#### 2.2 Awareness levels per metric and selected overlay feedbacks
For each usage metric a type of feedback (or a combined set) will be applied. User selects a global goal level and may also select app-specific goal levels, we handle the feedback.

| Goal Level | 24h Phone Time | App-Specific 24h Limit | Unlocks per 24h (Check-ins) | Max Session | Phone Usage on Sleeping Hours | Social Apps (emails, messages and social media) on Wakeup
| Minimal Use Level   | < 1.5 hours | < 15 mins | < 25 per day | 5 mins   | < 21:00 | > 9:00
| Normal Use Level    | < 2.5 hours | < 30 mins | < 40 per day | 10 mins  | < 23:00 | > 8:00
| Extensive Use Level | < 4 hours   | < 60 mins | < 60 per day | 20 mins  | < 01:00 | > 7:00

F.VW - Visual Weight
F.BN - Breathing Nudge
F.PM - Personalized Message

24h Phone Time -> F.BN; and then if time is doubled F.VW; and after 5min start cycling F.PM
App-Specific 24h Limit -> F.BN; and then if time is doubled F.VW; and after 5min start cycling F.PM
Unlocks per 24h (Check-ins) -> F.PM 3 seconds after unlock
Max Session -> F.BN; and then if time is doubled F.VW; and after 5min start cycling F.PM
Phone Usage on Sleeping Hours -> F.VW + F.PM
Social Apps (emails, messages and social media) on Wakeup -> F.VW + F.PM

### 3. Goal UI Config

Show a selector for the core/global goal level (choose how to display it, it can be just "goal"). This is also the place to explain the levels based on research. Also user can select app-specific goals levels. Consider (not obliged to) perhaps merge these interface components with others (e.g., per-app overlay deactivation).

### 4. Bullet ToDo List



## M15 — Prepare to PlayStore submission

. Review what we need to do for such purpose and write a list down here.