// NOTE: CURRENTLY NON FUNCTIONAL

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const BORDER_RADIUS = 12;

export default class RoundedWindowCorners extends Extension {
  enable() {
    this._trackedWindows = new Map();
    this._pendingWindows = new Map();
    this._windowCreatedId = null;
    this._startupCompleteId = null;
    this._warnedNoCornerApi = false;

    if (Main.layoutManager._startingUp ?? Main.layoutManager.startingUp) {
      this._startupCompleteId = Main.layoutManager.connect('startup-complete', () => {
        this._startupCompleteId = null;
        this._enableEffect();
      });
    } else {
      this._enableEffect();
    }
  }

  _enableEffect() {
    this._processAllWindows();

    this._windowCreatedId = global.display.connect('window-created', (_display, metaWindow) => {
      this._setupWindow(metaWindow);
    });
  }

  _processAllWindows() {
    for (const windowActor of global.get_window_actors()) {
      if (windowActor.meta_window) {
        this._setupWindow(windowActor.meta_window);
      }
    }
  }

  _setupWindow(metaWindow) {
    if (!metaWindow) return;

    const actor = metaWindow.get_compositor_private();
    if (!actor) {
      if (this._pendingWindows.has(metaWindow)) {
        return;
      }

      // New windows can be emitted before the compositor actor exists.
      const pendingId = metaWindow.connect('notify::compositor-private', () => {
        this._disconnectPending(metaWindow);
        this._setupWindow(metaWindow);
      });
      this._pendingWindows.set(metaWindow, pendingId);
      return;
    }

    // Skip if already tracked
    if (this._trackedWindows.has(metaWindow)) {
      return;
    }

    // Track window and its signal handlers
    const handlers = {};
    this._trackedWindows.set(metaWindow, { actor, handlers });

    // Handle window state changes
    handlers.maximized = metaWindow.connect('notify::maximized-horizontally', () => {
      this._updateWindowRadius(metaWindow);
    });

    handlers.fullscreen = metaWindow.connect('notify::fullscreen', () => {
      this._updateWindowRadius(metaWindow);
    });

    handlers.verticalMaximized = metaWindow.connect('notify::maximized-vertically', () => {
      this._updateWindowRadius(metaWindow);
    });

    handlers.unmanaging = metaWindow.connect('unmanaging', () => {
      this._teardownWindow(metaWindow);
    });

    // Initial setup
    this._updateWindowRadius(metaWindow);
  }

  _updateWindowRadius(metaWindow) {
    const actor = metaWindow.get_compositor_private();
    if (!actor) return;

    // Don't round maximized, tiled, or fullscreen windows
    if (metaWindow.get_maximized() || metaWindow.fullscreen) {
      if ('corner_radius' in actor) {
        actor.corner_radius = 0;
      }
      return;
    }

    // Apply rounded corners
    try {
      // Try the corner_radius property (GNOME 43+)
      if ('corner_radius' in actor) {
        actor.corner_radius = BORDER_RADIUS;
        return;
      }

      // Fallback: Try setting it as property
      if (actor.set_property) {
        try {
          actor.set_property('corner-radius', BORDER_RADIUS);
          return;
        } catch (e) {
          // Property doesn't exist
        }
      }

      if (!this._warnedNoCornerApi) {
        this._warnedNoCornerApi = true;
        console.warn('[RoundedWindowCorners] No supported corner radius API found on this GNOME Shell version; this extension cannot round windows with the current approach.');
      }
    } catch (e) {
      console.warn(`[RoundedWindowCorners] Could not apply rounding: ${e.message}`);
    }
  }

  disable() {
    if (this._startupCompleteId) {
      Main.layoutManager.disconnect(this._startupCompleteId);
      this._startupCompleteId = null;
    }

    // Disconnect window-created signal
    if (this._windowCreatedId) {
      global.display.disconnect(this._windowCreatedId);
      this._windowCreatedId = null;
    }

    for (const metaWindow of this._pendingWindows.keys()) {
      this._disconnectPending(metaWindow);
    }

    // Clean up tracked windows
    for (const metaWindow of this._trackedWindows.keys()) {
      this._teardownWindow(metaWindow);
    }
  }

  _disconnectPending(metaWindow) {
    const pendingId = this._pendingWindows.get(metaWindow);
    if (!pendingId) return;

    try {
      metaWindow.disconnect(pendingId);
    } catch (e) {
      // Signal may already be disconnected.
    }

    this._pendingWindows.delete(metaWindow);
  }

  _teardownWindow(metaWindow) {
    this._disconnectPending(metaWindow);

    const data = this._trackedWindows.get(metaWindow);
    if (!data) return;

    for (const id of Object.values(data.handlers)) {
      if (!id) continue;
      try {
        metaWindow.disconnect(id);
      } catch (e) {
        // Signal may already be disconnected.
      }
    }

    const actor = metaWindow.get_compositor_private();
    if (actor && 'corner_radius' in actor) {
      try {
        actor.corner_radius = 0;
      } catch (e) {
        // Ignore cleanup errors.
      }
    }

    this._trackedWindows.delete(metaWindow);
  }
}
