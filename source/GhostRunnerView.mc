import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

class GhostRunnerView extends WatchUi.DataField {

    hidden var mValue as Numeric;
    hidden var mElapsedTime as Numeric;
    hidden var mTargetPaceSecondsPerKm as Numeric;
    hidden var mGhostTimeSeconds as Numeric;
    hidden var mGapSeconds as Numeric;
    hidden var mCompactMode as Boolean;

    function initialize() {
        DataField.initialize();

        // Default values before activity starts
        mValue = 0.0f;
        mElapsedTime = 0;
        mGhostTimeSeconds = 0.0f;
        mGapSeconds = 0.0f;
        mCompactMode = false;

        // Read target pace from app settings
        var savedMinutes =
            Application.Properties.getValue("targetPaceMinutes");

        var savedSeconds =
            Application.Properties.getValue("targetPaceSeconds");

        // Check that both settings exist
        if (savedMinutes != null && savedSeconds != null) {

            var paceMinutes = savedMinutes as Number;
            var paceSeconds = savedSeconds as Number;

            // Extra protection against invalid settings
            if (
                paceMinutes >= 1 &&
                paceMinutes <= 20 &&
                paceSeconds >= 0 &&
                paceSeconds <= 59
            ) {
                mTargetPaceSecondsPerKm =
                    paceMinutes * 60 + paceSeconds;

            } else {
                // Default pace = 5:12 min/km
                mTargetPaceSecondsPerKm = 312;
            }

        } else {
            // Default pace = 5:12 min/km
            mTargetPaceSecondsPerKm = 312;
        }
    }

    // Choose the correct layout depending on
    // how much screen space Garmin gives the data field.
    function onLayout(dc as Dc) as Void {

        var obscurityFlags =
            DataField.getObscurityFlags();

        // Top left quadrant
        if (
            obscurityFlags ==
            (OBSCURE_TOP | OBSCURE_LEFT)
        ) {
            mCompactMode = true;

            View.setLayout(
                Rez.Layouts.TopLeftLayout(dc)
            );

        // Top right quadrant
        } else if (
            obscurityFlags ==
            (OBSCURE_TOP | OBSCURE_RIGHT)
        ) {
            mCompactMode = true;

            View.setLayout(
                Rez.Layouts.TopRightLayout(dc)
            );

        // Bottom left quadrant
        } else if (
            obscurityFlags ==
            (OBSCURE_BOTTOM | OBSCURE_LEFT)
        ) {
            mCompactMode = true;

            View.setLayout(
                Rez.Layouts.BottomLeftLayout(dc)
            );

        // Bottom right quadrant
        } else if (
            obscurityFlags ==
            (OBSCURE_BOTTOM | OBSCURE_RIGHT)
        ) {
            mCompactMode = true;

            View.setLayout(
                Rez.Layouts.BottomRightLayout(dc)
            );

        // Full screen / main layout
        } else {

            mCompactMode = false;

            View.setLayout(
                Rez.Layouts.MainLayout(dc)
            );

            var labelView =
                View.findDrawableById("label");

            if (labelView != null) {
                var labelText =
                    labelView as Text;

                labelText.locY =
                    labelText.locY - 16;
            }

            var valueView =
                View.findDrawableById("value");

            if (valueView != null) {
                var valueText =
                    valueView as Text;

                valueText.locY =
                    valueText.locY + 7;
            }
        }

        // Set "Ghost Runner" label
        var label =
            View.findDrawableById("label");

        if (label != null) {
            (label as Text)
                .setText(Rez.Strings.label);
        }
    }

    // Garmin calls compute() with live activity data.
    function compute(info as Activity.Info) as Void {

        // -----------------------------
        // DISTANCE
        // -----------------------------

        if (info has :elapsedDistance) {

            if (info.elapsedDistance != null) {

                var newDistance =
                    info.elapsedDistance as Number;

                // Ignore invalid negative values
                if (newDistance >= 0) {
                    mValue = newDistance;
                }
            }
        }

        // If Garmin temporarily sends null,
        // keep the previous valid distance.


        // -----------------------------
        // ELAPSED TIME
        // -----------------------------

        if (info has :elapsedTime) {

            if (info.elapsedTime != null) {

                var newElapsedTime =
                    info.elapsedTime as Number;

                // Ignore invalid negative values
                if (newElapsedTime >= 0) {
                    mElapsedTime =
                        newElapsedTime;
                }
            }
        }

        // If Garmin temporarily sends null,
        // keep the previous valid time.


        // -----------------------------
        // GHOST CALCULATION
        // -----------------------------

        // Convert distance from meters to kilometers
        // and calculate how long the ghost should
        // need to reach the same distance.
        mGhostTimeSeconds =
            (mValue / 1000.0f) *
            mTargetPaceSecondsPerKm;

        // Garmin elapsedTime is in milliseconds.
        //
        // Positive gap -> user is BEHIND
        // Negative gap -> user is AHEAD
        mGapSeconds =
            (mElapsedTime / 1000.0f) -
            mGhostTimeSeconds;
    }

    // Update everything visible on screen.
    function onUpdate(dc as Dc) as Void {

        // -----------------------------
        // BACKGROUND
        // -----------------------------

        var background =
            View.findDrawableById("Background");

        if (background != null) {
            (background as Text)
                .setColor(getBackgroundColor());
        }


        // -----------------------------
        // AHEAD / BEHIND / READY
        // -----------------------------

        var valueView =
            View.findDrawableById("value");

        if (valueView != null) {

            var value =
                valueView as Text;

            if (
                getBackgroundColor() ==
                Graphics.COLOR_BLACK
            ) {
                value.setColor(
                    Graphics.COLOR_WHITE
                );
            } else {
                value.setColor(
                    Graphics.COLOR_BLACK
                );
            }

            // Activity has not started yet
            if (mElapsedTime <= 0) {

                value.setText("READY");

            // Tiny difference = ON PACE
            } else if (
                mGapSeconds >= -0.5 &&
                mGapSeconds <= 0.5
            ) {

                value.setText("ON PACE");

            // Compact display for small Garmin fields
            } else if (mCompactMode) {

                if (mGapSeconds > 0) {

                    // Positive = behind
                    value.setText(
                        "+" +
                        mGapSeconds.format("%.0f") +
                        "s"
                    );

                } else {

                    // Negative = ahead
                    value.setText(
                        "-" +
                        (-mGapSeconds).format("%.0f") +
                        "s"
                    );
                }

            // Full-screen: user is slower than ghost
            } else if (mGapSeconds > 0) {

                value.setText(
                    mGapSeconds.format("%.0f") +
                    " s BEHIND"
                );

            // Full-screen: user is faster than ghost
            } else {

                value.setText(
                    (-mGapSeconds).format("%.0f") +
                    " s AHEAD"
                );
            }
        }


        // -----------------------------
        // DISTANCE
        // -----------------------------

        var distanceView =
            View.findDrawableById("distance");

        if (distanceView != null) {

            var distanceText =
                distanceView as Text;

            if (
                getBackgroundColor() ==
                Graphics.COLOR_BLACK
            ) {
                distanceText.setColor(
                    Graphics.COLOR_WHITE
                );
            } else {
                distanceText.setColor(
                    Graphics.COLOR_BLACK
                );
            }

            distanceText.setText(
                "Distance: " +
                (mValue / 1000.0f)
                    .format("%.2f") +
                " km"
            );
        }


        // -----------------------------
        // TARGET PACE
        // -----------------------------

        var targetPaceView =
            View.findDrawableById("targetPace");

        if (targetPaceView != null) {

            var targetText =
                targetPaceView as Text;

            if (
                getBackgroundColor() ==
                Graphics.COLOR_BLACK
            ) {
                targetText.setColor(
                    Graphics.COLOR_WHITE
                );
            } else {
                targetText.setColor(
                    Graphics.COLOR_BLACK
                );
            }

            var targetMinutes =
                (mTargetPaceSecondsPerKm / 60)
                    .toNumber();

            var targetSeconds =
                (mTargetPaceSecondsPerKm % 60)
                    .toNumber();

            targetText.setText(
                "Target: " +
                targetMinutes.format("%d") +
                ":" +
                targetSeconds.format("%02d") +
                "min/km"
            );
        }


        // -----------------------------
        // ELAPSED TIME
        // -----------------------------

        var timeView =
            View.findDrawableById("time");

        if (timeView != null) {

            var timeText =
                timeView as Text;

            if (
                getBackgroundColor() ==
                Graphics.COLOR_BLACK
            ) {
                timeText.setColor(
                    Graphics.COLOR_WHITE
                );
            } else {
                timeText.setColor(
                    Graphics.COLOR_BLACK
                );
            }

            // Convert milliseconds to whole seconds
            var totalSeconds =
                (mElapsedTime / 1000)
                    .toNumber();

            var hours =
                (totalSeconds / 3600)
                    .toNumber();

            var minutes =
                ((totalSeconds % 3600) / 60)
                    .toNumber();

            var seconds =
                (totalSeconds % 60)
                    .toNumber();

            // More than one hour:
            // Time: 1:04:27
            if (hours > 0) {

                timeText.setText(
                    "Time: " +
                    hours.format("%d") +
                    ":" +
                    minutes.format("%02d") +
                    ":" +
                    seconds.format("%02d")
                );

            // Less than one hour:
            // Time: 34:27
            } else {

                timeText.setText(
                    "Time: " +
                    minutes.format("%d") +
                    ":" +
                    seconds.format("%02d")
                );
            }
        }


        // Redraw the screen
        View.onUpdate(dc);
    }
}