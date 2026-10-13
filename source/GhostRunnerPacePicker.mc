import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Minutes: 3 to 10
class PaceMinutesFactory extends WatchUi.PickerFactory {

    function initialize() {
        PickerFactory.initialize();
    }

    function getSize() {
        return 8;
    }

    function getValue(item) {
        return item + 3;
    }

    function getDrawable(item, isSelected) {

        var value = item + 3;

        return new WatchUi.Text({
            :text => value.format("%d") + ":",
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_LARGE
        });
    }
}


// Seconds: 00 to 59
class PaceSecondsFactory extends WatchUi.PickerFactory {

    function initialize() {
        PickerFactory.initialize();
    }

    function getSize() {
        return 60;
    }

    function getValue(item) {
        return item;
    }

    function getDrawable(item, isSelected) {

        return new WatchUi.Text({
            :text => item.format("%02d"),
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_LARGE
        });
    }
}


// Screen where user chooses target pace
class GhostRunnerPacePicker extends WatchUi.Picker {

    function initialize() {

        var savedMinutes =
            Application.Properties.getValue("targetPaceMinutes") as Number;

        var savedSeconds =
            Application.Properties.getValue("targetPaceSeconds") as Number;

        var title = new WatchUi.Text({
            :text => "Target pace (min/km)",
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
            :color => Graphics.COLOR_WHITE
        });

        Picker.initialize({
            :title => title,

            :pattern => [
                new PaceMinutesFactory(),
                new PaceSecondsFactory()
            ],

            :defaults => [
                savedMinutes - 3,
                savedSeconds
            ]
        });
    }

    function onUpdate(dc) {

        dc.setColor(
            Graphics.COLOR_BLACK,
            Graphics.COLOR_BLACK
        );

        dc.clear();

        Picker.onUpdate(dc);
    }
}


// Handles Save / Cancel
class GhostRunnerPacePickerDelegate
    extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onAccept(values) {

        var minutes = values[0] as Number;
        var seconds = values[1] as Number;

        Application.Properties.setValue(
            "targetPaceMinutes",
            minutes
        );

        Application.Properties.setValue(
            "targetPaceSeconds",
            seconds
        );

        WatchUi.popView(
            WatchUi.SLIDE_IMMEDIATE
        );

        return true;
    }

    function onCancel() {

        WatchUi.popView(
            WatchUi.SLIDE_IMMEDIATE
        );

        return true;
    }
}