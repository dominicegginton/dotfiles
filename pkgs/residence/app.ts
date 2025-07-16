import { App } from "astal/gtk3";
import TopBar from "./widgets/TopBar";
import Volume from "./widgets/Volume";

let monitors: Record<number, any> = {};

App.start({
  instanceName: "residence" + Math.random().toString(36).substring(2, 15),
  main() {
    function render() {
      for (const monitor in App.get_monitors()) {
        TopBar({ monitor: Number(monitor) });
        Volume({ monitor: Number(monitor) });
      }
    }
    setInterval(() => {
      const newMonitors = App.get_monitors();
      if (Object.keys(newMonitors).length !== Object.keys(monitors).length) {
        monitors = newMonitors;
        render();
      }
    }, 2000);
    render();
  },
});
