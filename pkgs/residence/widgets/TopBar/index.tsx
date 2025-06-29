import { App, Astal } from "astal/gtk3";
import { Gtk } from "astal/gtk3";
import Playback from "./Playback";
import Time from "./Time";
import niri from "../../support/niri";
import { applyOpacityTransition } from "../../support/transitions";

export default ({ monitor }: { monitor: number }) => {
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
      monitor={monitor}
      visible={niri.overviewIsOpen.get()}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={TOP | LEFT | RIGHT}
      marginTop={104}
      marginLeft={300}
      marginRight={300}
      application={App}
      css={`
        background: transparent;
      `}
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
