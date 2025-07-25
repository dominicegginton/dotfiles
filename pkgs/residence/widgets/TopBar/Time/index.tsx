import { Variable, GLib } from "astal";
import { Gtk } from "astal/gtk3";

export default ({ format = "%H:%M - %A %e" }) => {
  const time = Variable<string>("").poll(
    1000,
    () => GLib.DateTime.new_now_local().format(format)!,
  );
  const greeting = Variable<string>("").poll(1000, () => {
    const hour = GLib.DateTime.new_now_local().get_hour();
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  });

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
          onDestroy={() => greeting.drop()}
          label={greeting()}
          halign={Gtk.Align.END}
          css={`
            font-size: 0.9em;
            font-weight: bold;
            color: #ffffff;
          `}
        />
        <label
          onDestroy={() => time.drop()}
          label={time()}
          halign={Gtk.Align.END}
          css={`
            font-size: 0.8em;
            opacity: 0.8;
            color: #ffffff;
          `}
        />
      </box>

      <box
        css={`
          background: none;
          border: none;
        `}
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        child={
          <box
            css={`
              border-radius: 100%;
            `}
            child={
              <box
                css={`
                  min-width: 32px;
                  min-height: 32px;
                  background-image: url("${GLib.getenv("HOME")}/.face");
                  background-size: cover;
                  background-position: center;
                  border-radius: 100%;
                `}
              />
            }
          />
        }
      />
    </box>
  );
};
