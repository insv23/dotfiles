// kooky-managed-do-not-edit — pings KookyHook on pi's session / turn / tool
// events so the sidebar agent dot tracks per-session activity (running
// while a turn runs, attention when it ends and waits on you), the pane
// status bar shows the tool pi is running right now (its tool_execution_*
// events), and the session id is reported so kooky can resume the
// conversation (`pi --session <id>`) after a restart. Safe to delete; it
// is regenerated next time kooky launches.
export default function (pi) {
  const surface = process.env.KOOKY_SURFACE_ID
  const hookBin = process.env.KOOKY_HOOK_BIN
  if (!surface || !hookBin) return

  const ping = async (state) => {
    try { await pi.exec(hookBin, ["pi", state]) } catch {}
  }
  const reportSession = async (ctx) => {
    try {
      const file = ctx && ctx.sessionManager && ctx.sessionManager.getSessionFile()
      if (!file) return
      const id = file.split("/").pop().replace(/\.jsonl$/, "")
      if (id) await pi.exec(hookBin, ["pi", "conversation", id])
    } catch {}
  }
  // The "what" shown in the tool-call pill. pi's args use `path` (not
  // Claude's `file_path`) and lowercase tool names; unknown / custom tools
  // fall back to the first non-empty string arg (keys sorted for a stable
  // pick). Mirrors KookyHookKit.extractIdentifier on the Claude side.
  const toolIdentifier = (toolName, args) => {
    if (!args || typeof args !== "object") return ""
    switch (toolName) {
      case "bash": return typeof args.command === "string" ? args.command : ""
      case "read": case "edit": case "write": case "ls":
        return typeof args.path === "string" ? args.path : ""
      case "grep": case "find":
        return typeof args.pattern === "string" ? args.pattern
          : (typeof args.path === "string" ? args.path : "")
      default:
        for (const k of Object.keys(args).sort()) {
          if (typeof args[k] === "string" && args[k]) return args[k]
        }
        return ""
    }
  }

  // Report the session id on session_start only — pi fires it on
  // new / resume / fork (every time the session file changes); turns
  // don't move the file, so per-turn reporting would just respawn for the
  // same id.
  pi.on("session_start", async (event, ctx) => { await reportSession(ctx); await ping("running") })
  pi.on("turn_start", async () => { await ping("running") })
  pi.on("turn_end", async () => { await ping("attention") })
  pi.on("session_shutdown", async () => { await ping("ended") })

  // Tool-call activity pill. tool_execution_start carries the args, so it
  // ships the identifier; tool_execution_end has no args (just result /
  // isError), so it ships an empty identifier + ok/fail. pi's toolCallId
  // is stable across the pair, so kooky matches start/end by it.
  pi.on("tool_execution_start", async (event) => {
    try {
      await pi.exec(hookBin, ["pi", "tool", "pre", event.toolCallId || "", event.toolName || "", toolIdentifier(event.toolName, event.args)])
    } catch {}
  })
  pi.on("tool_execution_end", async (event) => {
    try {
      await pi.exec(hookBin, ["pi", "tool", "post", event.toolCallId || "", event.toolName || "", "", event.isError ? "fail" : "ok"])
    } catch {}
  })
}