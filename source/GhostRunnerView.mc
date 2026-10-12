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

    function initialize() {
        DataField.initialize();

        mValue = 0.0f;
        mElapsedTime = 0;
        mGhostTimeSeconds = 0.0f;
        mGapSeconds = 0.0f;

        var savedMinutes = Application.Properties.getValue("targetPaceMinutes");
        var savedSeconds = Application.Properties.getValue("targetPaceSeconds");

        if (savedMinutes != null && savedSeconds != null) {
            mTargetPaceSecondsPerKm =
                (savedMinutes as Number) * 60 +
                (savedSeconds as Number);
        } else {
            mTargetPaceSecondsPerKm = 312;
        }
    }

    // Set your layout here. Anytime the size or obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));

            var labelView = View.findDrawableById("label") as Text;
            labelView.locY = labelView.locY - 16;

            var valueView = View.findDrawableById("value") as Text;
            valueView.locY = valueView.locY + 7;
        }

        (View.findDrawableById("label") as Text).setText(Rez.Strings.label);
    }

    // The given info object contains all the current workout information.
    // Calculate values and save them locally in this method.
    function compute(info as Activity.Info) as Void {

        if (info has :elapsedDistance) {
            if (info.elapsedDistance != null) {
                mValue = info.elapsedDistance as Number;
            } else {
                mValue = 0.0f;
            }
        }

        if (info has :elapsedTime) {
            if (info.elapsedTime != null) {
                mElapsedTime = info.elapsedTime as Number;
            } else {
                mElapsedTime = 0;
            }
        }

        mGhostTimeSeconds =
            (mValue / 1000.0f) * mTargetPaceSecondsPerKm;

        mGapSeconds =
            (mElapsedTime / 1000.0f) - mGhostTimeSeconds;
    }

    // Display the values on screen.
    function onUpdate(dc as Dc) as Void {

        // Set background color
        (View.findDrawableById("Background") as Text)
            .setColor(getBackgroundColor());

        // AHEAD / BEHIND / ON PACE
        var value = View.findDrawableById("value") as Text;

        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }

        if (mGapSeconds > 0) {
            value.setText(
                mGapSeconds.format("%.0f") + " s BEHIND"
            );
        } else if (mGapSeconds < 0) {
            value.setText(
                (-mGapSeconds).format("%.0f") + " s AHEAD"
            );
        } else {
            value.setText("ON PACE");
        }

        // Distance
        var distanceView = View.findDrawableById("distance");

        if (distanceView != null) {
            var distanceText = distanceView as Text;

            if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                distanceText.setColor(Graphics.COLOR_WHITE);
            } else {
                distanceText.setColor(Graphics.COLOR_BLACK);
            }

            distanceText.setText(
                "Distance: " +
                (mValue / 1000.0f).format("%.2f") +
                " km"
            );
        }

        // Target pace
        var targetPaceView = View.findDrawableById("targetPace");

        if (targetPaceView != null) {
            var targetText = targetPaceView as Text;

            if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                targetText.setColor(Graphics.COLOR_WHITE);
            } else {
                targetText.setColor(Graphics.COLOR_BLACK);
            }

            var targetMinutes =
                (mTargetPaceSecondsPerKm / 60).toNumber();

            var targetSeconds =
                (mTargetPaceSecondsPerKm % 60).toNumber();

            targetText.setText(
                "Target: " +
                targetMinutes.format("%d") +
                ":" +
                targetSeconds.format("%02d") +
                "min/km"
            );
        }

        // Elapsed time
        var timeView = View.findDrawableById("time");

        if (timeView != null) {
            var timeText = timeView as Text;

            if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                timeText.setColor(Graphics.COLOR_WHITE);
            } else {
                timeText.setColor(Graphics.COLOR_BLACK);
            }

            var totalSeconds =
                (mElapsedTime / 1000).toNumber();

            var hours =
                (totalSeconds / 3600).toNumber();

            var minutes =
                ((totalSeconds % 3600) / 60).toNumber();

            var seconds =
                (totalSeconds % 60).toNumber();

            if (hours > 0) {
                timeText.setText(
                    "Time: " +
                    hours.format("%d") +
                    ":" +
                    minutes.format("%02d") +
                    ":" +
                    seconds.format("%02d")
                );
            } else {
                timeText.setText(
                    "Time: " +
                    minutes.format("%d") +
                    ":" +
                    seconds.format("%02d")
                );
            }
        }

        // Redraw layout
        View.onUpdate(dc);
    }
}