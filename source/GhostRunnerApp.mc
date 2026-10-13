import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GhostRunnerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Called when the application starts
    function onStart(state as Dictionary?) as Void {
    }

    // Called when the application stops
    function onStop(state as Dictionary?) as Void {
    }

    // Main Ghost Runner data field
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new GhostRunnerView()];
    }

    // Settings screen opened directly on the Garmin watch
    function getSettingsView()
        as [Views] or [Views, InputDelegates] or Null {

        return [
            new GhostRunnerPacePicker(),
            new GhostRunnerPacePickerDelegate()
        ];
    }
}

function getApp() as GhostRunnerApp {
    return Application.getApp() as GhostRunnerApp;
}