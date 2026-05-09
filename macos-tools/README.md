# macOS Tools

Small desktop automation tools for macOS.

## Open Finder Directory in Kitty Tab

Use `open-finder-dir-in-kitty-tab.applescript` in an Automator application:

1. Open Automator.
2. Create a new `Application`.
3. Add `Run AppleScript`.
4. Paste the script from `open-finder-dir-in-kitty-tab.applescript`.
5. Save the app.
6. Add it to Finder toolbar or Finder sidebar.

Kitty must allow remote control through a fixed socket for opening a new tab in an existing window:

```conf
allow_remote_control yes
listen_on unix:/tmp/kitty
```

Add those lines to `kitty/kitty.conf`, then restart Kitty.
