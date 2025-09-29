import { Variable } from "astal";
import { Gtk } from "astal/gtk3";
import Battery from "gi://AstalBattery";

export default () => {
  const bat = Variable<string>("").poll(
    60000,
    () => `${Battery.get_default()?.get_percentage() * 100}%`,
  );

  // add a battery icon using font-awesome

  return (
    <box
      horizontal
      valign={Gtk.Align.CENTER}
      spacing={8}
      css={`
        padding: 8px;
        background-color: none;
      `}
    >
      <box vertical hexpand>
        <label
          css={`
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            font-size: 1.2em;
            color: #ffffff;
            opacity: 0.8;
          `}
          label={String.fromCharCode(0xf240)}
          valign={Gtk.Align.CENTER}
          halign={Gtk.Align.CENTER}
        />
        <label
          onDestroy={() => bat.drop()}
          label={bat()}
          halign={Gtk.Align.END}
          css={`
            font-size: 0.8em;
            opacity: 0.8;
            color: #ffffff;
          `}
        />
      </box>
    </box>
  );
};
