# computer_off

`shutdown.py` powers off the computer. It is meant to be run on a schedule.

## Test it first

```powershell
python shutdown.py --dry-run
```

This prints the command it would run (`shutdown /s /t 0` on Windows), without shutting anything down.

## Windows: schedule it from PowerShell

Windows has no cron. Task Scheduler does the same job, and you can set it up from PowerShell.

1. Find the full path to your Python:

   ```powershell
   python -c "import sys; print(sys.executable)"
   ```

2. Create a task that runs the script every day at 23:00. Replace the two paths with yours:

   ```powershell
   $action  = New-ScheduledTaskAction -Execute "C:\Path\To\python.exe" -Argument '"C:\Path\To\computer_off\shutdown.py"'
   $trigger = New-ScheduledTaskTrigger -Daily -At 23:00
   Register-ScheduledTask -TaskName "ComputerOff" -Action $action -Trigger $trigger
   ```

   If you get "Access is denied", open PowerShell with **Run as administrator** and try again.

3. Check that the task exists and see when it will run next:

   ```powershell
   Get-ScheduledTask -TaskName "ComputerOff" | Get-ScheduledTaskInfo
   ```

The task runs while you are logged in, which is normal for shutting down your own PC.

Other schedules:

```powershell
# Weekdays only, at 22:30
New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 22:30
```

To change the time, run the three lines from step 2 again with `-Force` added to `Register-ScheduledTask`.

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
