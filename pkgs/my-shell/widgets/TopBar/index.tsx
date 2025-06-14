import { App, Astal } from "astal/gtk3";
import { Gtk } from "astal/gtk3";
import Playback from "./Playback";
import SysTray from "./SysTray";
import niri from "../../support/niri";
import { applyOpacityTransition } from "../../support/transitions";

export default ({ monitor }: { monitor: number }) => {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  const LeftModules = (
    <box spacing={8} hexpand halign={Gtk.Align.START}>
      {[<Playback />]}
    </box>
  );

  const RightModules = (
    <box
      spacing={8}
      css={`
        margin-right: 4px;
      `}
      hexpand
      halign={Gtk.Align.END}
    >
      <SysTray />
    </box>
  );

  const win = (
    <window
      name="top-bar"
      monitor={monitor}
      visible={false}
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
          end_widget={RightModules}
        />
      }
    />
  );

  niri.overviewIsOpen.subscribe((v) => {
    applyOpacityTransition(win, v);
  });

  return win;
};
