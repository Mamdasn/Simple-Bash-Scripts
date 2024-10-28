# My-Scripts
I'll gradually add up to this repo scripts that I find useful.

| File Name              | What it Does                                                                                                    |
|------------------------|-----------------------------------------------------------------------------------------------------------------|
| play                   | Play musics/videos found over ssh/localy in the current/specified directory sorted by date, size, name and etc. |
| ytdown                 | Help backing up your personal youtube channel.                                                                  |
| man-maker              | Search through installed packages and read their manual pages.                                                  |
| gource-make            | Make a video of the contributions made to a repository.                                                         |
| clipboard-{save,dmenu} | Cache the clipboard and spawn a dmenu to select a specific clipboard.                                           |

## Run Script at Startup
Add the following to the cronie scheduler
```bash
@reboot /usr/bin/screen -dmS [session-name] bash -c [/path/to/script]
```
