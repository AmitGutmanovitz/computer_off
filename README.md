# computer_off

`shutdown.py` powers off the computer. It is meant to be run on a schedule with cron.

## Test it first

```sh
python3 shutdown.py --dry-run
```

This prints the command it would run, without shutting anything down.

## Schedule it with cron

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
- The schedule uses the machine's local time. The five fields are minute, hour, day of month, month and day of week. For example, `30 22 * * 1-5` means 22:30 Monday to Friday.

On Windows there is no cron. Use Task Scheduler to run `python shutdown.py` instead.
