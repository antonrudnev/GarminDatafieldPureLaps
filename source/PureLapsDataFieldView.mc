import Toybox.Activity;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.Time;
import Toybox.WatchUi;

class PureLapsDataFieldView extends WatchUi.SimpleDataField {

    hidden var markLocation = null;
    hidden var distanceAtMark = 0;
    hidden var lapCounter = 0;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = Properties.getValue("DefaultTag");
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        if (info.elapsedDistance != null && info.currentLocationAccuracy != null 
                && info.currentLocationAccuracy >= Position.QUALITY_POOR) {
            if (markLocation == null) {
                markLocation = info.currentLocation;
            } else {
                if (info.elapsedDistance - distanceAtMark >= Properties.getValue("MinLapDistance")) {
                    if (distanceBetween(markLocation, info.currentLocation) <= Properties.getValue("MarkAccuracy")) {
                        lapCounter += 1;
                        distanceAtMark = info.elapsedDistance;
                    } else {
                        if (info.elapsedDistance - distanceAtMark >= Properties.getValue("MaxLapDistance")) {
                            markLocation = null;
                        }
                    }
                }
            }
        }
        return lapCounter;
    }

    function onTimerStop() as Void {
        if (Properties.getValue("FieldReset")) {
            lapCounter = 0;
            markLocation = null;
        }
    }

    function distanceBetween(pos1 as Position.Location, pos2 as Position.Location) as Numeric {
        var p1 = pos1.toRadians();
        var p2 = pos2.toRadians();
        var dLat = (p2[0]-p1[0]);
        var dLon = (p2[1]-p1[1]);
        var a = Math.pow(Math.sin(dLat / 2), 2) + Math.pow(Math.sin(dLon / 2), 2) * Math.cos(p1[0]) * Math.cos(p2[0]);
        var c = 6371000 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return c.toNumber();
    }

}