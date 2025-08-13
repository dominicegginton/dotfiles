import { App, Astal, hook, Gdk, Gtk } from "astal/gtk3";
import { type EventBox } from "astal/gtk3/widget";
import AstalNotifd from "gi://AstalNotifd";
import { Gtk } from "astal/gtk3";
import { type Subscribable } from "astal/binding";
import { GLib, Variable, bind, timeout } from "astal";

const isIcon = (icon: string) => !!Astal.Icon.lookup_icon(icon);

const fileExists = (path: string) => GLib.file_test(path, GLib.FileTest.EXISTS);

const time = (time: number, format = "%H:%M") =>
  GLib.DateTime.new_from_unix_local(time).format(format)!;

const urgency = ({ urgency }: AstalNotifd.Notification) => {
  const { LOW, NORMAL, CRITICAL } = AstalNotifd.Urgency;
  switch (urgency) {
    case LOW:
      return "low";
    case CRITICAL:
      return "critical";
    case NORMAL:
    default:
      return "normal";
  }
};

type Props = {
  setup(self: EventBox): void;
  hide(self: EventBox): void;
  onHoverLost(self: EventBox): void;
  notification: AstalNotifd.Notification;
};

export function Notification(props: Props) {
  const { notification: n, onHoverLost, setup, hide } = props;
  const { START, CENTER, END } = Gtk.Align;

  const icon = n.appIcon || n.desktopEntry;
  return (
    <eventbox className={urgency(n)} setup={setup} onHoverLost={onHoverLost}>
      <box vertical>
        <box className="header">
          {icon && (
            <icon className="app-icon" visible={Boolean(icon)} icon={icon} />
          )}
          <label
            className="app-name"
            halign={START}
            truncate
            label={n.appName || "Unknown"}
          />
          <label className="time" hexpand halign={END} label={time(n.time)} />
          <button
            onClicked={() => hide()}
            className="close-button"
            halign={END}
          >
            <icon icon="notification-close-symbolic" />
          </button>
          <button onClicked={() => n.dismiss()} halign={END}>
            <icon icon="notification-clear-symbolic" />
          </button>
        </box>
        <Gtk.Separator visible />
        <box className="content">
          {n.image && fileExists(n.image) && (
            <box
              valign={START}
              className="image"
              css={`
                background-image: url("${n.image}");
              `}
            />
          )}
          {n.image && isIcon(n.image) && (
            <box expand={false} valign={START}>
              <icon icon={n.image} expand halign={CENTER} valign={CENTER} />
            </box>
          )}
          <box vertical>
            <label
              className="summary"
              halign={START}
              xalign={0}
              label={n.summary}
              truncate
            />
            {n.body && (
              <label
                className="body"
                wrap
                useMarkup
                halign={START}
                xalign={0}
                justifyFill
                label={n.body}
              />
            )}
          </box>
        </box>
        <box className="actions" visible={n.get_actions().length > 0}>
          {n.get_actions().map(({ label, id }) => (
            <button hexpand onClicked={() => n.invoke(id)}>
              <label label={label} halign={CENTER} hexpand />
            </button>
          ))}
        </box>
      </box>
    </eventbox>
  );
}

// see comment below in constructor
const TIMEOUT_DELAY = 5000;

// The purpose if this class is to replace Variable<Array<Widget>>
// with a Map<number, Widget> type in order to track notification widgets
// by their id, while making it conveniently bindable as an array
class NotificationMap implements Subscribable {
  // the underlying map to keep track of id widget pairs
  private map: Map<number, Gtk.Widget> = new Map();

  // it makes sense to use a Variable under the hood and use its
  // reactivity implementation instead of keeping track of subscribers ourselves
  private var: Variable<Array<Gtk.Widget>> = Variable([]);

  // notify subscribers to rerender when state changes
  private notify() {
    this.var.set([...this.map.values()].reverse());
  }

  constructor() {
    const notifd = AstalNotifd.get_default();

    /**
     * uncomment this if you want to
     * ignore timeout by senders and enforce our own timeout
     * note that if the notification has any actions
     * they might not work, since the sender already treats them as resolved
     */
    // notifd.ignoreTimeout = true

    notifd.connect("notified", (_, id) => {
      this.set(
        id,
        Notification({
          notification: notifd.get_notification(id)!,
          onHoverLost: () => void 0,
          hide: () => this.delete(id),
          setup: () => timeout(TIMEOUT_DELAY, () => void 0),
        }),
      );
    });

    // notifications can be closed by the outside before
    // any user input, which have to be handled too
    notifd.connect("resolved", (_, id) => {
      this.delete(id);
    });
  }

  private set(key: number, value: Gtk.Widget) {
    // in case of replacecment destroy previous widget
    this.map.get(key)?.destroy();
    this.map.set(key, value);
    this.notify();
  }

  private delete(key: number) {
    this.map.get(key)?.destroy();
    this.map.delete(key);
    this.notify();
  }

  // needed by the Subscribable interface
  get() {
    return this.var.get();
  }

  // needed by the Subscribable interface
  subscribe(callback: (list: Array<Gtk.Widget>) => void) {
    return this.var.subscribe(callback);
  }
}

export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
  const { TOP, CENTER } = Astal.WindowAnchor;
  const notifs = new NotificationMap();

  return (
    <window
      name="notification-popups"
      namespace="notification-popups"
      css="background: rgba(0, 0, 0, 0.8); border-radius: 0.5em; padding: 10px; color: white;"
      gdkmonitor={gdkmonitor}
      application={App}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP | CENTER}
      marginTop={25}
      width={1000}
    >
      <box vertical>{bind(notifs)}</box>
    </window>
  );
}
