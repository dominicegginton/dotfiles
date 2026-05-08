import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import Gio from 'gi://Gio';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const PANEL_STYLE_CLASS = 'light-theme-default-panel';
const OVERVIEW_STYLE_CLASS = 'light-theme-default-overview';
const KEYBOARD_STYLE_CLASS = 'light-theme-default-keyboard';

export default class LightThemeDefault extends Extension {
  _updateColorScheme(scheme) {
    Main.sessionMode.colorScheme = scheme;
    St.Settings.get().notify('color-scheme');
  }

  _updatePanelStyleClass(enabled) {
    const panel = Main.panel;
    if (!panel)
      return;

    if (enabled)
      panel.add_style_class_name(PANEL_STYLE_CLASS);
    else
      panel.remove_style_class_name(PANEL_STYLE_CLASS);
  }

  _updateOverviewStyleClass(enabled) {
    const overviewGroup = Main.layoutManager?.overviewGroup;
    if (!overviewGroup)
      return;

    if (enabled)
      overviewGroup.add_style_class_name(OVERVIEW_STYLE_CLASS);
    else
      overviewGroup.remove_style_class_name(OVERVIEW_STYLE_CLASS);
  }

  _loadStylesheet() {
    if (this._stylesheet)
      return;

    const theme = St.ThemeContext.get_for_stage(global.stage).get_theme();
    this._stylesheet = Gio.File.new_for_path(`${this.path}/stylesheet.css`);
    theme.load_stylesheet(this._stylesheet);
  }

  _unloadStylesheet() {
    if (!this._stylesheet)
      return;

    const theme = St.ThemeContext.get_for_stage(global.stage).get_theme();
    theme.unload_stylesheet(this._stylesheet);
    this._stylesheet = null;
  }

  _updateKeyboardStyleClass(enabled) {
    const keyboardBox = Main.layoutManager?.keyboardBox;
    if (!keyboardBox)
      return;

    if (enabled)
      keyboardBox.add_style_class_name(KEYBOARD_STYLE_CLASS);
    else
      keyboardBox.remove_style_class_name(KEYBOARD_STYLE_CLASS);
  }

  _syncOverviewStyles() {
    const isDark = Main.sessionMode.colorScheme === 'prefer-dark';
    const isLight = !isDark;

    this._updateOverviewStyleClass(isLight);
    this._updatePanelStyleClass(isLight);
    this._updateKeyboardStyleClass(isLight);
  }

  enable() {
    this._loadStylesheet();
    this._stSettings = St.Settings.get();
    this._savedColorScheme = Main.sessionMode.colorScheme;
    this._colorSchemeChangedId = this._stSettings.connect(
      'notify::color-scheme',
      () => this._syncOverviewStyles()
    );
    this._overviewShowingId = Main.overview?.connect(
      'showing',
      () => this._syncOverviewStyles()
    ) ?? null;
    this._overviewHiddenId = Main.overview?.connect(
      'hidden',
      () => this._syncOverviewStyles()
    ) ?? null;
    this._updateColorScheme('prefer-light');
    this._syncOverviewStyles();
  }

  disable() {
    if (this._stSettings && this._colorSchemeChangedId) {
      this._stSettings.disconnect(this._colorSchemeChangedId);
      this._colorSchemeChangedId = null;
    }

    if (Main.overview && this._overviewShowingId) {
      Main.overview.disconnect(this._overviewShowingId);
      this._overviewShowingId = null;
    }

    if (Main.overview && this._overviewHiddenId) {
      Main.overview.disconnect(this._overviewHiddenId);
      this._overviewHiddenId = null;
    }

    this._stSettings = null;
    this._updateOverviewStyleClass(false);
    this._updatePanelStyleClass(false);
    this._updateKeyboardStyleClass(false);
    this._updateColorScheme(this._savedColorScheme);
    this._savedColorScheme = null;
    this._unloadStylesheet();
  }
}
