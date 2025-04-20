# My-Scripts
I'll gradually add up to this repo scripts that I find useful.

| File Name              | What it Does                                                                                                    |
|------------------------|-----------------------------------------------------------------------------------------------------------------|
| [play](/scripts/play)                   | Play musics/videos found over ssh/localy in the current/specified directory sorted by date, size, name and etc. |
| [ytdown](/scripts/ytdown)                 | Help backing up your personal youtube channel.                                                                  |
| [man-maker](/scripts/man-maker)              | Search through installed packages and read their manual pages.                                                  |
| [gource-make](/scripts/gource-make)            | Make a video of the contributions made to a repository.                                                         |
| clipboard-[save](/scripts/cliboarder-save) / [dmenu](/scripts/cliboarder-dmenu) | Cache the clipboard and spawn a dmenu to select a specific clipboard.                                           |
| [watchdog](/scripts/watchdog)               | Watchdog a file or directory.                                                                                   |
| [emojies](/scripts/emojies)               | Copy an emoji to clipboard using dmenu.                                                                                   |
| [locker](/scripts/locker)               | Lock screen for i3.                                                                                   |

## Run Script at Startup
Add the following to the cronie scheduler
```bash
@reboot /usr/bin/screen -dmS [session-name] bash -c [/path/to/script]
```
