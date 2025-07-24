import { App, Astal, Gtk } from "astal/gtk3";
import { timeout } from "astal/time";
import Variable from "astal/variable";
import Wp from "gi://AstalWp";

const OnScreenProgress = ({ visible }) => {
  const speaker = Wp.get_default()!.get_default_speaker();
  const value = Variable(0);
  let count = 0;

  function show(v: number) {
    visible.set(true);
    if (v > 1) v = 1;
    value.set(v);
    count++;
    timeout(1000, () => {
      count--;
      if (count === 0) visible.set(false);
    });
  }

  return (
    <box
      setup={(self) => {
        self.hook(speaker, "notify::volume", () => show(speaker.get_volume()));
      }}
      spacing={16}
      halign={Gtk.Align.END}
      valign={Gtk.Align.CENTER}
      vertical={true}
      css="margin-right: 1em;"
    >
      <levelbar
        css={`
          min-width: 0.4em;
          border-radius: 0.4em;
          border: none;
          box-shadow: none;
        `}
        halign={Gtk.Align.CENTER}
        heightRequest={100}
        value={value()}
        vertical={true}
        inverted={true}
      />
    </box>
  );
};

export default function OSD(monitor: Astal.Monitor) {
  const visible = Variable(false);
  const { RIGHT } = Astal.WindowAnchor;

  return (
    <window
      name="osd"
      visible={visible()}
      reactive={false}
      css="background: none;"
      gdkmonitor={monitor}
      application={App}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={RIGHT}
      keymode={Astal.Keymode.NONE}
      halign={Gtk.Align.END}
      valign={Gtk.Align.CENTER}
    >
      <OnScreenProgress visible={visible} />
    </window>
  );
}
