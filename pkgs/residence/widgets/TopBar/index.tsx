import { App, Astal } from "astal/gtk3";
import { Gtk, Gdk } from "astal/gtk3";
import Playback from "./Playback";
import Time from "./Time";
import niri from "../../support/niri";
import { applyOpacityTransition } from "../../support/transitions";

export default (monitor: Gdk.Monitor) => {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  const LeftModules = (
    <box
      spacing={8}
      hexpand
      halign={Gtk.Align.START}
      valign={Gtk.Align.CENTER}
      css="background: rgba(0, 0, 0, 0);"
    >
      <Playback />
    </box>
  );

  const CenterModules = (
    <box
      spacing={8}
      hexpand
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
      css="background: rgba(0, 0, 0, 0);"
    >
      {/* Add any center modules here if needed */}
    </box>
  );

  const RightModules = (
    <box
      spacing={8}
      hexpand
      halign={Gtk.Align.END}
      valign={Gtk.Align.CENTER}
      css="background: rgba(0, 0, 0, 0);"
    >
      <Time />
    </box>
  );

  const win = (
    <window
      name="top-bar"
      namespace="top-bar"
      application={App}
      gdkmonitor={monitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.TOP}
      visible={niri.overviewIsOpen.get()}
      anchor={TOP | LEFT | RIGHT}
      marginTop={20}
      marginLeft={20}
      marginRight={20}
      css="background: transparent;"
      child={
        <centerbox
          start_widget={LeftModules}
          center_widget={CenterModules}
          end_widget={RightModules}
        />
      }
    />
  );

  niri.overviewIsOpen.subscribe((open) => applyOpacityTransition(win, open));

  return win;
};
