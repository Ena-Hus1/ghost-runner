# Ghost Runner

Ghost Runner is a custom Garmin Connect IQ data field that compares a runner's real-time progress with a virtual runner moving at a predefined target pace.

The goal is to give runners a simple answer during a run:

**Am I ahead of or behind my target pace, and by how many seconds?**

## Features

- Real-time **AHEAD / BEHIND** comparison
- Configurable target pace
- Target pace can be changed directly on the Garmin watch
- Pace range from **3:00 to 15:59 min/km**
- Elapsed distance display
- Elapsed activity time display
- `READY` state before the activity starts
- `ON PACE` state when the difference is negligible
- Full-screen data field layout
- Compact display for smaller Garmin data-field layouts
- Protection against missing or invalid activity data
- Tested using Garmin Simulator and a physical Garmin device

## How It Works

Garmin provides the current activity distance and elapsed time through the Connect IQ Activity API.

Ghost Runner converts the target pace to seconds per kilometer and calculates how long the virtual runner should have taken to reach the user's current distance.

### Ghost time

```text
ghostTime = distanceInKm × targetPaceSecondsPerKm
```

### Gap

```text
gap = actualElapsedTime - ghostTime
```

The result is interpreted as:

```text
gap > 0  → BEHIND
gap < 0  → AHEAD
gap ≈ 0  → ON PACE
```

### Example

Target pace:

```text
5:00 min/km = 300 seconds/km
```

At 2 km:

```text
Ghost time = 2 × 300
           = 600 seconds
           = 10:00
```

If the runner reaches 2 km in 10:20:

```text
Gap = 620 - 600
    = +20 seconds
```

Ghost Runner displays:

```text
20 s BEHIND
```

## Display

The main data-field screen shows:

```text
Ghost Runner

12 s AHEAD

Distance: 4.25 km
Target: 5:00min/km
Time: 21:03
```

Before the activity starts:

```text
READY
```

Smaller data-field layouts use a compact representation such as:

```text
+12s
-8s
```

where positive means behind the ghost and negative means ahead.

## Target Pace Settings

The target pace can be configured directly on the Garmin watch through Ghost Runner's settings.

The user selects:

```text
Minutes: 3–15
Seconds: 00–59
```

The selected values are stored using Garmin Connect IQ application properties.

For example:

```text
4 minutes
45 seconds
```

becomes:

```text
4:45 min/km
```

## Technologies

- Garmin Connect IQ
- Monkey C
- Garmin Connect IQ SDK
- Garmin Simulator
- VS Code
- Git
- GitHub
- Confluence

## Project Structure

```text
ghost-runner/
│
├── source/
│   ├── GhostRunnerApp.mc
│   ├── GhostRunnerView.mc
│   └── GhostRunnerPacePicker.mc
│
├── resources/
│   ├── layouts/
│   ├── settings/
│   └── strings/
│
├── manifest.xml
├── monkey.jungle
├── .gitignore
└── README.md
```

## Testing

Ghost Runner was tested in several stages:

**Garmin Simulator**

Used to verify the user interface, activity data handling, target pace settings and AHEAD/BEHIND calculations.

**FIT activity playback**

A previously recorded running activity was used to test the data field with realistic activity data.

**Physical device**

The application was built as a `.prg` file, sideloaded onto a Garmin device and tested during an actual activity.

The physical-device test confirmed that distance, elapsed time, target pace and the AHEAD/BEHIND calculation work during an activity.

## Development Workflow

Development followed a Git feature-branch workflow.

Examples of branches used during development:

```text
feature/initial-garmin-app
feature/on-device-pace-settings
feature/improve-pace-settings
```

Changes were committed locally, pushed to GitHub, reviewed through Pull Requests and merged into `main`.

Completed feature branches were deleted after merging while the Pull Request and commit history remained available on GitHub.

## Version

**Ghost Runner v1.0**

First stable version of the project.

## Possible Future Improvements

Potential future versions could include:

- vibration alerts when the runner falls too far behind the ghost
- improved visual feedback
- additional pace information
- configurable alert thresholds
- further UI optimization for different Garmin screen sizes