import Mpris from "gi://AstalMpris";
import { bind } from "astal";
import { Gtk } from "astal/gtk3";

const Player = (player) => {
  return (
    <box>
      <box
        className="artwork-container"
        valign={Gtk.Align.CENTER}
        css={`
          min-width: 36px;
          min-height: 36px;
          border-radius: 4px;
        `}
        child={
          <box
            className="artwork"
            css={bind(player, "coverArt").as(
              (cover) => `min-width: 36px;
                      min-height: 36px;
                      background-image: url('${cover}');
                      background-size: cover;
                      background-position: center;
                      border-radius: 3px;
                      `,
            )}
          />
        }
      />
      <box
        orientation={Gtk.Orientation.VERTICAL}
        css={`
          margin-left: 8px;
          margin-right: 8px;
        `}
        valign={Gtk.Align.CENTER}
      >
        <label
          css={`
            font-size: 0.9em;
            font-weight: bold;
            color: #ffffff;
          `}
          label={bind(player, "artist")}
          halign={Gtk.Align.START}
          visible={bind(player, "artist").as((artist) => !!artist)}
        />
        <label
          css={`
            font-size: 0.8em;
            opacity: 0.8;
            color: #ffffff;
          `}
          label={bind(player, "title")}
          halign={Gtk.Align.START}
        />
      </box>
    </box>
  );
};

export default () => {
  const mpris = Mpris.get_default();
  return <box>{bind(mpris, "players").as((x) => x.map(Player))}</box>;
};
