import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

// How close (in logical pixels) a window must be to the bottom of the panel
// before the bar is considered "touched" and becomes opaque.
const TRANSITION_DISTANCE = 5;
const OVERVIEW_SETTLE_DELAY_MS = 200;

export default class SmartTransparentTopBar extends Extension {
  enable() {
    this._actorSignalIds = new Map();
    this._windowSignalIds = new Map();
    this._overviewHiddenTimeoutId = 0;

    this._actorSignalIds.set(Main.overview, [
      Main.overview.connect('showing', this._updateTransparent.bind(this)),
      Main.overview.connect('hiding', this._updateTransparent.bind(this)),
      Main.overview.connect('hidden', this._onOverviewHidden.bind(this)),
    ]);

    this._actorSignalIds.set(Main.sessionMode, [
      Main.sessionMode.connect('updated', this._updateTransparent.bind(this)),
    ]);

    for (const metaWindowActor of global.get_window_actors()) {
      this._onWindowActorAdded(metaWindowActor.get_parent(), metaWindowActor);
    }

    this._actorSignalIds.set(global.window_group, [
      global.window_group.connect('child-added', this._onWindowActorAdded.bind(this)),
      global.window_group.connect('child-removed', this._onWindowActorRemoved.bind(this)),
    ]);

    this._actorSignalIds.set(global.window_manager, [
      global.window_manager.connect('switch-workspace', this._updateTransparent.bind(this)),
    ]);

    this._updateTransparent();
  }

  disable() {
    this._clearOverviewHiddenTimeout();

    for (const actorSignalIds of [this._actorSignalIds, this._windowSignalIds]) {
      for (const [actor, signalIds] of actorSignalIds) {
        for (const signalId of signalIds) {
          actor.disconnect(signalId);
        }
      }
    }

    this._actorSignalIds = null;
    this._windowSignalIds = null;
    this._overviewHiddenTimeoutId = 0;

    this._resetTransparent();
  }

  _onOverviewHidden() {
    this._updateTransparent();
    this._clearOverviewHiddenTimeout();
    this._overviewHiddenTimeoutId = GLib.timeout_add(
      GLib.PRIORITY_DEFAULT,
      OVERVIEW_SETTLE_DELAY_MS,
      () => {
        this._overviewHiddenTimeoutId = 0;
        this._updateTransparent();
        return GLib.SOURCE_REMOVE;
      }
    );
  }

  _clearOverviewHiddenTimeout() {
    if (this._overviewHiddenTimeoutId) {
      GLib.source_remove(this._overviewHiddenTimeoutId);
      this._overviewHiddenTimeoutId = 0;
    }
  }

  _onWindowActorAdded(container, metaWindowActor) {
    this._windowSignalIds.set(metaWindowActor, [
      metaWindowActor.connect('notify::allocation', this._updateTransparent.bind(this)),
      metaWindowActor.connect('notify::visible', this._updateTransparent.bind(this)),
    ]);
  }

  _onWindowActorRemoved(container, metaWindowActor) {
    const signalIds = this._windowSignalIds.get(metaWindowActor);
    if (!signalIds)
      return;

    for (const signalId of signalIds) {
      metaWindowActor.disconnect(signalId);
    }
    this._windowSignalIds.delete(metaWindowActor);
    this._updateTransparent();
  }

  _updateTransparent() {
    // Always transparent in the overview or non-window sessions (e.g. lock screen).
    if (Main.overview.visible || !Main.sessionMode.hasWindows) {
      this._setTransparent(true);
      return;
    }

    if (!Main.layoutManager.primaryMonitor)
      return;

    // Collect all visible, non-desktop windows on the active workspace that
    // are on the primary monitor.
    const activeWorkspace = global.workspace_manager.get_active_workspace();
    const windows = activeWorkspace.list_windows().filter(w =>
      w.is_on_primary_monitor() &&
      w.showing_on_its_workspace() &&
      !w.is_hidden() &&
      w.get_window_type() !== Meta.WindowType.DESKTOP
    );

    // Check whether any window is close enough to the panel bottom edge.
    const panelBottom =
      Main.panel.get_transformed_position()[1] + Main.panel.get_height();
    const scale = St.ThemeContext.get_for_stage(global.stage).scale_factor;
    const isNearPanel = windows.some(w =>
      w.get_frame_rect().y < panelBottom + TRANSITION_DISTANCE * scale
    );

    this._setTransparent(!isNearPanel);
  }

  _setTransparent(transparent) {
    const style = transparent
      ? `background-color: rgba(0, 0, 0, 0.0); transition-duration: 0.25s;`
      : `transition-duration: 0.25s;`;
    Main.panel.set_style(style);
  }

  _resetTransparent() {
    Main.panel.set_style(null);
  }
}
