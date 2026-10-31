[⬅ Back to README](../README.md)

# 🔤 Custom Font (Optional)

Swaps CS2's menu and HUD font for **Barlow Semi Condensed**: as narrow as the original, so it fits, but with clearer numbers and letters. Characters it doesn't have (Cyrillic, Asian) still use the original fonts.

* **Apply:** close CS2, then run this from the repo folder (or pick **Font** in `install.bat`):

  ```
  powershell -ExecutionPolicy Bypass -File fonts\apply-font.ps1
  ```

* **Undo:** run it with `-Restore`, or Steam → CS2 → **Properties** → **Installed Files** → **Verify integrity of game files**.
* A CS2 update can reset the font: just run it again.
* Font changes only touch font files, not gameplay. The community considers them VAC-safe, but Valve has never officially said so.
* Font: [Barlow](https://github.com/jpt/barlow), SIL Open Font License (`fonts/OFL.txt`).
