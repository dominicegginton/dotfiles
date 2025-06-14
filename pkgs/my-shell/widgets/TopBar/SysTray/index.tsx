import Tray from "gi://AstalTray";
import { bind } from "astal";

export default () => {
  const tray = Tray.get_default();

  return (
    <box className="SysTray">
      {bind(tray, "items").as((items) =>
        items.map((item) => (
          <menubutton
            tooltipMarkup={bind(item, "tooltipMarkup")}
            usePopover={false}
            actionGroup={bind(item, "actionGroup").as((ag) => ["dbusmenu", ag])}
            menuModel={bind(item, "menuModel")}
            css={`
              min-width: 28px;
              min-height: 28px;
              padding: 4px;
            `}
            child={
              <icon
                gicon={bind(item, "gicon")}
                css={`
                  font-size: 18px;
                `}
              />
            }
          />
        ))
      )}
    </box>
  );
};
