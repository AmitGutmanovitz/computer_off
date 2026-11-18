# computer_off

`shutdown.py` powers off the computer. It is meant to be run on a schedule.

## Test it first

```powershell
python shutdown.py --dry-run
```

This prints the command it would run (`shutdown /s /t 0` on Windows), without shutting anything down.

## Windows: schedule it with `schedule_shutdown.ps1`

Windows has no cron, so `schedule_shutdown.ps1` creates a Task Scheduler task instead. It finds Python and `shutdown.py` by itself, so you don't type any paths.

Open PowerShell in this folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\schedule_shutdown.ps1
```

This schedules a shutdown every **Wednesday at 23:00** and prints when it will run next. Keep `schedule_shutdown.ps1` and `shutdown.py` in the same folder. If you move them, run the script again.

To use a different day or time, run it again with `-Day` and `-Time`. The new schedule replaces the old one:

```powershell
powershell -ExecutionPolicy Bypass -File .\schedule_shutdown.ps1 -Day Friday -Time 22:30
powershell -ExecutionPolicy Bypass -File .\schedule_shutdown.ps1 -Day "Monday,Wednesday"
```

- `-ExecutionPolicy Bypass` is needed because Windows blocks `.ps1` files by default. It applies to this one run only.
- If you get "Access is denied", open PowerShell with **Run as administrator** and try again.
- The task runs while you are logged in, which is normal for shutting down your own PC.

To check the task:

```powershell
Get-ScheduledTask -TaskName "ComputerOff" | Get-ScheduledTaskInfo
```

To remove the task:

```powershell
Unregister-ScheduledTask -TaskName "ComputerOff" -Confirm:$false
```

`Start-ScheduledTask -TaskName "ComputerOff"` runs the task immediately, so it **will** shut the computer down.

## Linux / macOS: schedule it with cron

Shutting down needs root, so add the job to **root's** crontab:

```sh
sudo crontab -e
```

Then add a line such as this one, which shuts down every day at 23:00:

```
0 23 * * * /usr/bin/python3 /full/path/to/shutdown.py >> /var/log/computer_off.log 2>&1
```

- Use full paths for both `python3` (find yours with `which python3`) and the script, because cron runs with a minimal `PATH`.
- The `>> ... 2>&1` part saves any errors to a log file, so you can see why a run failed.
- The five fields are minute, hour, day of month, month and day of week. For example, `30 22 * * 1-5` means 22:30 Monday to Friday.
