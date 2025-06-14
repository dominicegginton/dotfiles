import Mpris from "gi://AstalMpris";
import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";

// TODO: Automatically pause multiple playing things

function PlayPauseButton({ player }) {
  return (
    <button
      css={`
        padding: 0;
        margin: 0;
        min-width: 24px;
        min-height: 24px;
        border-radius: 100%;
        background-color: rgba(0, 0, 0, 0.6);
      `}
      on_clicked={() => player.play_pause()}
      visible={bind(player, "can_play").as((c) => c)}
      child={
        <icon
          icon={bind(player, "playbackStatus").as((s) => {
            switch (s) {
              case Mpris.PlaybackStatus.PLAYING:
                return "media-playback-pause-symbolic";
              case Mpris.PlaybackStatus.PAUSED:
              case Mpris.PlaybackStatus.STOPPED:
                return "media-playback-start-symbolic";
            }
          })}
        />
      }
    />
  );
}

const Player = (player) => {
  const isHovering = Variable(false);

  return (
    <box>
      <eventbox
        onHover={() => isHovering.set(true)}
        onHoverLost={() => isHovering.set(false)}
        child={
          <overlay>
            <box
              className="artwork-container"
              valign={Gtk.Align.CENTER}
              css={`
                min-width: 36px;
                min-height: 36px;
                border-radius: 4px;
                border: 2px solid rgba(255, 255, 255, 0.2);
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
                      `
                  )}
                />
              }
            />
            <box
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
              css={bind(isHovering).as(
                (hovering) => `
                opacity: ${hovering ? 1 : 0};
              `
              )}
              visible={bind(isHovering)}
              child={<PlayPauseButton player={player} />}
            />
          </overlay>
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
          `}
          label={bind(player, "artist")}
          halign={Gtk.Align.START}
          visible={bind(player, "artist").as((artist) => !!artist)}
        />
        <label
          css={`
            font-size: 0.8em;
            opacity: 0.8;
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
