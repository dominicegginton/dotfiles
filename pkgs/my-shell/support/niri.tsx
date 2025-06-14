//
// Niri IPC integration compliant with official niri-ipc API
// Reference: https://yalter.github.io/niri/niri_ipc/
//
// Key compliance updates:
// - All field types match official API (u64 -> number, Option<String> -> string | null)
// - Field names use official naming (is_urgent instead of urgent)
// - Workspace operations use correct parameters (idx for focus, id for move)
// - Proper handling of optional fields from official API
//
import GObject, { register, property } from "astal/gobject";
import { execAsync, subprocess } from "astal/process";
import { GLib, Variable } from "astal";

export type Workspace = {
  id: number; // u64 in official API
  idx: number; // u8 in official API - index on monitor
  name: string | null; // Option<String> in official API
  output: string | null; // Option<String> in official API - output name
  is_urgent: boolean; // renamed from urgent to match official API
  is_active: boolean;
  is_focused: boolean;
  active_window_id: number | null; // Option<u64> in official API
  windows: Window[]; // Custom field for compatibility
};

export type Window = {
  id: number; // u64 in official API
  title: string | null; // Option<String> in official API
  app_id: string | null; // Option<String> in official API
  pid: number | null; // Option<i32> in official API
  workspace_id: number | null; // Option<u64> in official API
  is_focused: boolean;
  is_floating: boolean; // Added missing field from official API
  is_urgent: boolean; // renamed from urgent to match official API
};

@register({ GTypeName: "Niri" })
export class Niri extends GObject.Object {
  @property(Number)
  declare activeWorkspaceIdx: number;

  @property(Object)
  declare workspaces: Workspace[];

  @property(Object)
  declare windows: Window[];

  overviewIsOpen: Variable<boolean> = Variable(false);
  activeWindowId: Variable<number> = Variable(-1);
  private updateTimeout: number | null = null;

  constructor() {
    super();
    this.workspaces = [];
    this.windows = [];
    this.activeWorkspaceIdx = 1;

    // Start event stream - it will send initial WorkspacesChanged and WindowsChanged events
    subprocess(
      ["niri", "msg", "--json", "event-stream"],
      (event) => this.handleEvent(JSON.parse(event)),
      (err) => console.error(err)
    );
  }

  handleEvent(event: any) {
    for (const key in event) {
      const value = event[key];
      switch (key) {
        case "OverviewOpenedOrClosed":
          this.onOverviewOpenedOrClosed(value.is_open);
          break;
        case "WindowFocusChanged":
          this.onWindowFocusChanged(value.id);
          break;
        case "WorkspacesChanged":
          this.onWorkspacesChanged(value.workspaces);
          break;
        case "WorkspaceActivated":
          this.onWorkspaceActivated(value.id, value.focused);
          break;
        case "WorkspaceUrgencyChanged":
          this.onWorkspaceUrgencyChanged(value.id, value.urgent);
          break;
        case "WorkspaceActiveWindowChanged":
          this.onWorkspaceActiveWindowChanged(
            value.workspace_id,
            value.active_window_id
          );
          break;
        case "WindowsChanged":
          this.onWindowsChanged(value.windows);
          break;
        case "WindowOpenedOrChanged":
          this.onWindowOpenedOrChanged(value.window);
          break;
        case "WindowClosed":
          this.onWindowClosed(value.id);
          break;
        case "WindowUrgencyChanged":
          this.onWindowUrgencyChanged(value.id, value.urgent);
          break;
        case "KeyboardLayoutsChanged":
          // Handle if needed
          break;
        case "KeyboardLayoutSwitched":
          // Handle if needed
          break;
      }
    }
  }

  onOverviewOpenedOrClosed(isOpen: boolean) {
    this.overviewIsOpen.set(isOpen);
  }

  private debouncedNotify() {
    if (this.updateTimeout) {
      GLib.Source.remove(this.updateTimeout);
    }

    this.updateTimeout = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
      this.notify("windows");
      this.notify("workspaces");
      this.updateTimeout = null;
      return false;
    });
  }

  onWindowFocusChanged(id: number | null) {
    // This is the authoritative source for window focus
    const newActiveId = id || -1;
    this.activeWindowId.set(newActiveId);

    // Update the focused state for all windows across all workspaces
    this.updateWindowFocusState(newActiveId);
    this.debouncedNotify();
  }

  private updateWindowFocusState(activeWindowId: number) {
    // Update workspace windows
    this.workspaces = this.workspaces.map((workspace) => ({
      ...workspace,
      windows: workspace.windows.map((window) => ({
        ...window,
        is_focused: activeWindowId !== -1 && window.id === activeWindowId,
      })),
    }));

    // Update global windows array
    this.windows = this.windows.map((window) => ({
      ...window,
      is_focused: activeWindowId !== -1 && window.id === activeWindowId,
    }));
  }

  onWorkspacesChanged(workspaces: Workspace[]) {
    if (!Array.isArray(workspaces)) {
      console.warn("Invalid workspaces data received:", workspaces);
      return;
    }

    // Update workspaces but preserve windows and correct focus state
    const existingWorkspaces = this.workspaces || [];

    this.workspaces = workspaces
      .sort((a, b) => a.id - b.id)
      .map((ws) => {
        const existing = existingWorkspaces.find((ews) => ews.id === ws.id);
        // Normalize workspace data to match official API types
        return {
          id: ws.id,
          idx: ws.idx,
          name: ws.name ?? null,
          output: ws.output ?? null,
          is_urgent: ws.is_urgent || false,
          is_active: ws.is_active || ws.is_focused, // Map is_focused to is_active for compatibility
          is_focused: ws.is_focused || false,
          active_window_id: ws.active_window_id ?? null,
          windows: existing?.windows || [], // Preserve custom windows array
        };
      });

    this.activeWorkspaceIdx =
      this.workspaces.find((workspace) => workspace.is_focused)?.idx || 1;

    this.updateWorkspaceWindows();
    this.notify("windows");
    this.notify("workspaces");
  }

  onWindowsChanged(windows: Window[]) {
    if (!Array.isArray(windows)) {
      console.warn("Invalid windows data received:", windows);
      return;
    }

    // Update windows array while preserving correct focus state and normalizing optional fields
    this.windows = windows.map((window) => ({
      id: window.id,
      title: window.title ?? null,
      app_id: window.app_id ?? null,
      pid: window.pid ?? null,
      workspace_id: window.workspace_id ?? null,
      is_focused: window.is_focused || false,
      is_floating: window.is_floating || false,
      is_urgent: window.is_urgent || false,
    }));

    this.updateWorkspaceWindows();
    this.notify("windows");
    this.notify("workspaces");
  }

  updateWorkspaceWindows() {
    if (!this.workspaces || !this.windows) return;

    // Group windows by workspace while preserving the original order from niri
    const windowsByWorkspace = new Map<number, Window[]>();

    // Initialize empty arrays for each workspace
    this.workspaces.forEach((workspace) => {
      windowsByWorkspace.set(workspace.id, []);
    });

    // Add windows in the order they appear in this.windows (which comes from niri)
    this.windows.forEach((window) => {
      const workspaceId = window.workspace_id;
      // Handle null workspace_id (floating windows might not have a workspace)
      if (workspaceId !== null && windowsByWorkspace.has(workspaceId)) {
        windowsByWorkspace.get(workspaceId)!.push(window);
      }
    });

    // Update workspace windows and apply correct focus state
    const activeWindowId = this.activeWindowId.get();
    this.workspaces = this.workspaces.map((workspace) => {
      let windows = windowsByWorkspace.get(workspace.id) || [];

      // Sort windows by ID (creation order) for consistent taskbar ordering
      // This gives a predictable order that users can rely on
      windows = windows.sort((a, b) => a.id - b.id);

      // Apply current focus state to all windows while preserving order
      const windowsWithCorrectFocus = windows.map((window) => ({
        ...window,
        is_focused: activeWindowId !== -1 && window.id === activeWindowId,
      }));

      return {
        ...workspace,
        windows: windowsWithCorrectFocus,
      };
    });

    this.notify("workspaces");
    this.notify("windows");
  }

  onWorkspaceActivated(workspaceId: number, focused: boolean) {
    // Update focused state
    this.workspaces = this.workspaces.map((workspace) => ({
      ...workspace,
      is_focused: workspace.id === workspaceId && focused,
      is_active: workspace.id === workspaceId,
    }));

    // Use idx instead of id for activeWorkspaceIdx
    const activatedWorkspace = this.workspaces.find((ws) => ws.id === workspaceId);
    if (activatedWorkspace) {
      this.activeWorkspaceIdx = activatedWorkspace.idx;
    }

    this.notify("workspaces");
    this.notify("windows");
  }

  onWorkspaceUrgencyChanged(workspaceId: number, urgent: boolean) {
    this.workspaces = this.workspaces.map((workspace) => ({
      ...workspace,
      is_urgent: workspace.id === workspaceId ? urgent : workspace.is_urgent,
    }));
    this.notify("workspaces");
  }

  onWorkspaceActiveWindowChanged(workspaceId: number, windowId: number | null) {
    // Check if this is for the currently active workspace
    const currentWorkspace = this.workspaces.find((ws) => ws.is_focused);

    if (currentWorkspace && currentWorkspace.id === workspaceId) {
      // This is for the active workspace - use this as a fallback if WindowFocusChanged isn't received
      const newActiveWindowId = windowId || -1;

      this.activeWindowId.set(newActiveWindowId);
      this.updateWindowFocusState(newActiveWindowId);
      this.debouncedNotify();
    }
  }

  onWindowOpenedOrChanged(window: Window) {
    // Check if window data is valid
    if (!window || typeof window !== "object") {
      console.warn(
        "[niri] WindowOpenedOrChanged: Invalid window data received (not an object):",
        window
      );
      return;
    }

    if (window.id === undefined || window.id === null) {
      console.warn(
        "[niri] WindowOpenedOrChanged: Invalid window data received (missing id):",
        window
      );
      return;
    }

    // Ensure optional fields have proper defaults
    const normalizedWindow: Window = {
      id: window.id,
      title: window.title ?? null,
      app_id: window.app_id ?? null,
      pid: window.pid ?? null,
      workspace_id: window.workspace_id ?? null,
      is_focused: window.is_focused || false,
      is_floating: window.is_floating || false,
      is_urgent: window.is_urgent || false,
    };

    // Update or add the window in our windows array
    const existingIndex = this.windows.findIndex((w) => w.id === window.id);

    if (existingIndex >= 0) {
      // Update existing window, preserving focus state from our active window tracking
      const currentFocus = this.windows[existingIndex].is_focused;
      this.windows[existingIndex] = {
        ...normalizedWindow,
        is_focused: currentFocus,
      };
    } else {
      // Add new window, setting focus state based on current active window
      const activeWindowId = this.activeWindowId.get();
      this.windows.push({
        ...normalizedWindow,
        is_focused: activeWindowId !== -1 && window.id === activeWindowId,
      });
    }

    this.updateWorkspaceWindows();
    this.notify("workspaces");
    this.notify("windows");
  }

  onWindowClosed(windowId: number) {
    // Remove the window from our windows array
    this.windows = this.windows.filter((w) => w.id !== windowId);

    // Clear active window if it was the closed one
    if (this.activeWindowId.get() === windowId) {
      this.activeWindowId.set(-1);
    }

    this.updateWorkspaceWindows();
    this.notify("workspaces");
    this.notify("windows");
  }

  onWindowUrgencyChanged(windowId: number, urgent: boolean) {
    // Update urgency state for the window in both windows array and workspace windows
    this.windows = this.windows.map((window) => ({
      ...window,
      is_urgent: window.id === windowId ? urgent : window.is_urgent,
    }));

    this.updateWorkspaceWindows();
    this.notify("workspaces");
    this.notify("windows");
  }

  focusWorkspace(idx: number) {
    // Use workspace index (idx) for focus actions, not ID
    this.action("focus-workspace", String(idx)).then(() => {});
  }

  focusWindow(id: number) {
    this.action("focus-window", "--id", String(id)).catch((error) => {
      console.error(`Failed to focus window ${id}:`, error);
    });
  }

  closeWindow(id: number) {
    this.action("close-window", "--id", String(id)).catch((error) => {
      console.error(`Failed to close window ${id}:`, error);
    });
  }

  moveWindowToWorkspace(windowId: number, workspaceId: number) {
    // Use workspace ID for move actions, not index
    this.action(
      "move-window-to-workspace",
      "--id",
      String(windowId),
      "--workspace",
      String(workspaceId)
    ).catch((error) => {
      console.error(
        `Failed to move window ${windowId} to workspace ${workspaceId}:`,
        error
      );
    });
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
