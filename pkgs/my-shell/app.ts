import { App } from "astal/gtk3";
App.start({
  css: ``,
  main() {
    for (const monitor in App.get_monitors()) {
    }
  },
});
