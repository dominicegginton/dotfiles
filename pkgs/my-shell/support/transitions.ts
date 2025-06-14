import GLib from "gi://GLib?version=2.0";
import { Widget } from "astal/gtk3";

export interface TransitionOptions {
  fadeInDuration?: number;
  fadeOutDuration?: number;
  fadeInDelay?: number;
}

const defaultOptions: Required<TransitionOptions> = {
  fadeInDuration: 300,
  fadeOutDuration: 60,
  fadeInDelay: 10,
};

export function applyOpacityTransition(
  widget: Widget.Window,
  visible: boolean,
  options: TransitionOptions = {}
) {
  const opts = { ...defaultOptions, ...options };

  if (visible) {
    widget.set_visible(true);
    widget.set_opacity(0);

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, opts.fadeInDelay, () => {
      // Start fade-in animation
      const startTime = Date.now();

      const animate = () => {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / opts.fadeInDuration, 1);

        // Ease-out cubic function for smooth transition
        const easeOut = 1 - Math.pow(1 - progress, 3);
        widget.set_opacity(easeOut);

        if (progress < 1) {
          GLib.timeout_add(GLib.PRIORITY_DEFAULT, 16, () => {
            animate();
            return false;
          });
        }
        return false;
      };

      animate();
      return false;
    });
  } else {
    // Start fade-out animation
    const startTime = Date.now();
    const startOpacity = widget.get_opacity();

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / opts.fadeOutDuration, 1);

      // Ease-in cubic function for smooth transition
      const easeIn = Math.pow(progress, 3);
      const opacity = startOpacity * (1 - easeIn);
      widget.set_opacity(opacity);

      if (progress < 1) {
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 16, () => {
          animate();
          return false;
        });
      } else {
        widget.set_visible(false);
      }
      return false;
    };

    animate();
  }
}
