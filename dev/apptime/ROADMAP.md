# AppTime — Roadmap

## M8 - Fixes
- Disappearance: overlay is resilient, but at some point it is still disappearing. It is the most important feature and we must guarantee by all means it remains there
- Positioning: it is not working properly. Changing the direction (left, below, right) moves the overlay all over the corners of the screen. The intent was to move it to the left/bottom/right of the camera orifice on the screen. If it is not possible to have the camera orifice as anchor (and for exemple place the overlay on the left of it in the same region of the clock bar) then let's rephrase the config. we can just place it in the top center of the screen you know... it will be fine this way.
- Can we place the overlay in the same height as the clock bar? It would be interesting to have such freedom of placement
- Font size config is not working
- The config show border (mostrar borda) does nothing
- Displacement (sliders for vertical and horizontal) configs are not working either
x Unblock counts are simply not working
x I believe we are accumulating usage time of an app even if the screen is blocked. Maybe we are incrementing the time in other scenarios as well (not sure), for example after the app is open but we return to the launcher screen (without closing it) or go to another app. The time count should only consider when the app is on foreground.
- I believe we are not unsing any usage data natively stored by Android, is this the best option? Is it because Android data isn't precise? If we do not use it we have to be flawless and always store precise data. I understand that maybe have mixed usage data (part from our end part from Android's native analytics) can be confusing/ambiguous and lead to errors. Define an strategy that is the most precise please.
- Change monitoring policy from "Today" to "24h" meaning we're reporting on the last 24 hours of usage


## M9 — Polish

- HomeScreen "Insight of the day": 50 PT-BR texts with high-citation recognized scientific references, 3min rotation
- Adaptive icon (`flutter_launcher_icons`); Check it, I believe it is already done.
- Edge cases: MIUI home, device reboot (service won't auto-start — document limitation), active session at day rollover

## M10 — Analysis