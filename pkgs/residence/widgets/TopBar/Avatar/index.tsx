import { Gtk } from "astal/gtk3";
import GLib from "gi://GLib";

export default () => {
  return (
    <box
      css={`
        background: transparent;
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
  );
};
