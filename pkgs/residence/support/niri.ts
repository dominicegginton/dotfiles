import GObject, { register, property } from "astal/gobject";
import { execAsync, subprocess } from "astal/process";
import { Variable } from "astal";

@register({ GTypeName: "Niri" })
export class Niri extends GObject.Object {
  overviewIsOpen: Variable<boolean> = Variable(false);

  constructor() {
    super();
    subprocess(
      ["niri", "msg", "--json", "event-stream"],
      (event) => this.handleEvent(JSON.parse(event)),
      (err) => console.error(err),
    );
  }

  handleEvent(event: any) {
    for (const key in event) {
      const value = event[key];
      switch (key) {
        case "OverviewOpenedOrClosed":
          this.onOverviewOpenedOrClosed(value.is_open);
          break;
      }
    }
  }

  onOverviewOpenedOrClosed(isOpen: boolean) {
    this.overviewIsOpen.set(isOpen);
  }

  toggleOverview() {
    if (this.overviewIsOpen.get()) {
      this.action("close-overview");
    } else {
      this.action("open-overview");
    }
  }

  action(...args: string[]) {
    return execAsync(["niri", "msg", "action", ...args]);
  }
}

export default new Niri();
