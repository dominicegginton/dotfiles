import { App } from "astal/gtk3";
import TopBar from "./widgets/TopBar";
import OSD from "./widgets/OSD";

App.start({
  // background-color: @warning_color;
  css: `
    levelbar {
      border-radius: 2px;
    }

    levelbar .filled {
      border-radius: 2px;
      background-clip: padding-box;
    }

    levelbar.low .filled {
      background-color: @success_color;
    }

    levelbar.medium .filled {
      background-color: @theme_selected_bg_color
    }

    levelbar.high .filled {
      background-color: @error_color;
    }
    `,
  main() {
    for (const monitor in App.get_monitors()) {
      TopBar({ monitor: Number(monitor) });
      OSD({ monitor: Number(monitor) });
    }
  },
});
