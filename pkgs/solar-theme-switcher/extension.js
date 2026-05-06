import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import GLib from 'gi://GLib';
import Geoclue from 'gi://Geoclue';
import Gio from 'gi://Gio';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const DEG = Math.PI / 180;

/**
 * Convert a JS Date to a Julian Date number.
 * @param {Date} date
 * @returns {number}
 */
function toJulianDate(date) {
  return date.getTime() / 86400000 + 2440587.5;
}

/**
 * Convert a Julian Date number back to a JS Date.
 * @param {number} jd
 * @returns {Date}
 */
function fromJulianDate(jd) {
  return new Date((jd - 2440587.5) * 86400000);
}

/**
 * Calculate sunrise and sunset times for a given location and date.
 * Uses the NOAA solar calculation algorithm.
 * https://en.wikipedia.org/wiki/Sunrise_equation
 *
 * @param {number} lat - Latitude in degrees
 * @param {number} lon - Longitude in degrees
 * @param {Date} date - The date to calculate for
 * @returns {{ sunrise: Date|null, sunset: Date|null, polarDay: boolean, polarNight: boolean }}
 */
function getSunTimes(lat, lon, date) {
  const JD = toJulianDate(date);
  const n = Math.floor(JD - 2451545.0 + 0.0008);

  // Mean solar noon
  const Jstar = n - lon / 360;

  // Solar mean anomaly (degrees)
  const M = ((357.5291 + 0.98560028 * Jstar) % 360 + 360) % 360;
  const Mrad = M * DEG;

  // Equation of centre
  const C =
    1.9148 * Math.sin(Mrad) +
    0.02 * Math.sin(2 * Mrad) +
    0.0003 * Math.sin(3 * Mrad);

  // Ecliptic longitude (degrees)
  const lambda = ((M + C + 180 + 102.9372) % 360 + 360) % 360;
  const lambdaRad = lambda * DEG;

  // Solar transit (Julian date)
  const Jtransit =
    2451545.0 +
    Jstar +
    0.0053 * Math.sin(Mrad) -
    0.0069 * Math.sin(2 * lambdaRad);

  // Declination of the Sun
  const sinD = Math.sin(lambdaRad) * Math.sin(23.4397 * DEG);
  const cosD = Math.cos(Math.asin(sinD));

  // Hour angle at horizon (-0.833° accounts for atmospheric refraction and solar disc size)
  const cosW0 =
    (Math.sin(-0.833 * DEG) - Math.sin(lat * DEG) * sinD) /
    (Math.cos(lat * DEG) * cosD);

  if (cosW0 < -1)
    return { sunrise: null, sunset: null, polarDay: true, polarNight: false };
  if (cosW0 > 1)
    return { sunrise: null, sunset: null, polarDay: false, polarNight: true };

  const W0 = Math.acos(cosW0) / DEG;

  return {
    sunrise: fromJulianDate(Jtransit - W0 / 360),
    sunset: fromJulianDate(Jtransit + W0 / 360),
    polarDay: false,
    polarNight: false,
  };
}

export default class SolarThemeSwitcher extends Extension {
  enable() {
    this._savedColorScheme = Main.sessionMode.colorScheme;
    this._interfaceSettings = new Gio.Settings({
      schema_id: 'org.gnome.desktop.interface',
    });
    this._savedInterfaceColorScheme = this._interfaceSettings.get_string('color-scheme');
    this._lat = null;
    this._lon = null;
    this._timerId = null;
    this._geoclue = null;
    this._locationChangedId = null;

    // Apply immediately on enable, then refine using geolocation.
    this._applyFallbackScheme();
    this._startGeoclue();
  }

  disable() {
    this._stopTimer();

    if (this._geoclue) {
      if (this._locationChangedId !== null) {
        this._geoclue.disconnect(this._locationChangedId);
        this._locationChangedId = null;
      }
      this._geoclue = null;
    }

    this._updateColorScheme(this._savedColorScheme);

    if (this._interfaceSettings && this._savedInterfaceColorScheme) {
      try {
        this._interfaceSettings.set_string('color-scheme', this._savedInterfaceColorScheme);
      } catch (e) {
        console.warn(`[SolarThemeSwitcher] Failed to restore interface color-scheme: ${e.message}`);
      }
    }

    this._interfaceSettings = null;
    this._savedInterfaceColorScheme = null;
    this._lat = null;
    this._lon = null;
  }

  _startGeoclue() {
    Geoclue.Simple.new(
      'solar-theme-switcher@dominicegginton',
      Geoclue.AccuracyLevel.CITY,
      null,
      (source, result) => {
        try {
          this._geoclue = Geoclue.Simple.new_finish(result);

          // Watch for future location updates (e.g., roaming between networks)
          this._locationChangedId = this._geoclue.connect(
            'notify::location',
            () => this._onLocationChanged()
          );

          this._onLocationChanged();
        } catch (e) {
          console.error(`[SolarThemeSwitcher] Failed to acquire location: ${e.message}`);
        }
      }
    );
  }

  _onLocationChanged() {
    const location = this._geoclue?.get_location();
    if (!location) return;

    this._lat = location.get_latitude();
    this._lon = location.get_longitude();

    // Location changed — reschedule from scratch
    this._stopTimer();
    this._scheduleNextSwitch();
  }

  _stopTimer() {
    if (this._timerId !== null) {
      GLib.source_remove(this._timerId);
      this._timerId = null;
    }
  }

  /**
   * Apply the correct colour scheme for the current time and schedule a
   * one-shot timer that fires at the next sunrise or sunset transition.
   */
  _scheduleNextSwitch() {
    if (this._lat === null || this._lon === null) return;

    const now = new Date();
    const { sunrise, sunset, polarDay, polarNight } = getSunTimes(
      this._lat,
      this._lon,
      now
    );

    let isDark;
    let nextSwitch;

    if (polarDay) {
      isDark = false;
      nextSwitch = null;
    } else if (polarNight) {
      isDark = true;
      nextSwitch = null;
    } else {
      if (now < sunrise) {
        // Before sunrise — currently dark
        isDark = true;
        nextSwitch = sunrise;
      } else if (now < sunset) {
        // Between sunrise and sunset — currently light
        isDark = false;
        nextSwitch = sunset;
      } else {
        // After sunset — currently dark; next switch is tomorrow's sunrise
        isDark = true;
        const tomorrow = new Date(now);
        tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
        const tomorrowTimes = getSunTimes(this._lat, this._lon, tomorrow);
        nextSwitch = tomorrowTimes.sunrise;
      }
    }

    this._applyScheme(isDark ? 'prefer-dark' : 'prefer-light');

    if (nextSwitch !== null) {
      const delaySecs = Math.max(1, Math.ceil((nextSwitch - now) / 1000));
      this._timerId = GLib.timeout_add_seconds(
        GLib.PRIORITY_DEFAULT,
        delaySecs,
        () => {
          this._timerId = null;
          this._scheduleNextSwitch();
          return GLib.SOURCE_REMOVE;
        }
      );
    }
  }

  _updateColorScheme(scheme) {
    Main.sessionMode.colorScheme = scheme;
    St.Settings.get().notify('color-scheme');

    if (!this._interfaceSettings) return;

    try {
      // GNOME interface setting reliably accepts default/prefer-dark.
      const interfaceScheme = scheme === 'prefer-dark' ? 'prefer-dark' : 'default';
      this._interfaceSettings.set_string('color-scheme', interfaceScheme);
    } catch (e) {
      console.warn(`[SolarThemeSwitcher] Failed to set interface color-scheme: ${e.message}`);
    }
  }

  _applyScheme(scheme) {
    this._updateColorScheme(scheme);
  }

  _applyFallbackScheme() {
    const hour = new Date().getHours();
    const isDark = hour < 7 || hour >= 19;
    this._applyScheme(isDark ? 'prefer-dark' : 'prefer-light');
  }
}
