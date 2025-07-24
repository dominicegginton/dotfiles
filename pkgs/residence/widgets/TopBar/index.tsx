import { App, Astal } from "astal/gtk3";
import { Gtk, Gdk } from "astal/gtk3";
import Playback from "./Playback";
import Time from "./Time";
import niri from "../../support/niri";
import { applyOpacityTransition } from "../../support/transitions";

export default (monitor: Gdk.Monitor) => {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  const LeftModules = (
    <box spacing={8} hexpand halign={Gtk.Align.START} valign={Gtk.Align.CENTER}>
      <Playback />
    </box>
  );

  const CenterModules = (
    <box
      spacing={8}
      hexpand
      hhalign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      {/* Add any center modules here if needed */}
    </box>
  );

  const RightModules = (
    <box spacing={8} hexpand halign={Gtk.Align.END} valign={Gtk.Align.CENTER}>
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
      marginTop={100}
      marginLeft={50}
      marginRight={50}
      css="background: none;"
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
