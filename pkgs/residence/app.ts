import { App } from "astal/gtk3";
import TopBar from "./widgets/TopBar";
import Volume from "./widgets/Volume";

App.start({
  main() {
    for (const monitor in App.get_monitors()) {
      TopBar({ monitor: Number(monitor) });
      Volume({ monitor: Number(monitor) });
    }
  },
});
