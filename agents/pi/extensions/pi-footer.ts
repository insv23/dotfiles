import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const colorize = (color: string, text: string) => `\x1b[38;2;${color}m${text}\x1b[39m`;

const COLORS = {
  model: "246;226;183",
  path: "171;223;167",
  branch: "156;222;211",
  separator: "108;112;134",
  usage: "242;181;144",
};

const formatTokens = (tokens: number) => {
  if (tokens < 1000) return `${tokens}`;
  if (tokens < 1_000_000) return `${Math.round(tokens / 1000)}k`;
  return `${(tokens / 1_000_000).toFixed(1)}M`;
};

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.setFooter((tui, _theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          const home = process.env.HOME;
          const cwd = ctx.sessionManager.getCwd();
          const directory = home && cwd.startsWith(`${home}/`)
            ? `~/${cwd.slice(home.length + 1)}`
            : cwd;
          const branch = footerData.getGitBranch();
          const model = ctx.model?.id ?? "no-model";
          const thinking = ctx.thinkingLevel ?? "off";
          const contextUsage = ctx.getContextUsage();
          const contextWindow = ctx.model?.contextWindow ?? 0;
          const contextLeft = contextUsage?.percent == null
            ? "?"
            : `${(100 - contextUsage.percent).toFixed(1)}%`;

          let cost = 0;
          for (const entry of ctx.sessionManager.getEntries()) {
            const usage = entry.type === "message" &&
              (entry.message.role === "assistant" || entry.message.role === "toolResult")
              ? entry.message.usage
              : entry.type === "compaction" || entry.type === "branch_summary"
                ? entry.usage
                : undefined;
            if (usage) cost += usage.cost.total;
          }

          const separator = colorize(COLORS.separator, " · ");
          const firstLeft = colorize(COLORS.model, model) + separator + colorize(COLORS.model, thinking);
          const firstRight = colorize(COLORS.path, directory) +
            (branch ? separator + colorize(COLORS.branch, `(${branch})`) : "");
          const secondLeft = colorize(COLORS.usage, "Context") +
            " " +
            colorize(COLORS.usage, `${contextLeft} left`) +
            colorize(COLORS.separator, " ・ ") +
            colorize(COLORS.usage, `${formatTokens(contextWindow)} context`);
          const secondRight = colorize(COLORS.usage, `$${cost.toFixed(3)}`);
          const align = (left: string, right: string) => {
            const padding = " ".repeat(
              Math.max(1, width - visibleWidth(left) - visibleWidth(right)),
            );
            return truncateToWidth(left + padding + right, width);
          };

          return [
            align(firstLeft, firstRight),
            align(secondLeft, secondRight),
          ];
        },
      };
    });
  });
}
