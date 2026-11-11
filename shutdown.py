#!/usr/bin/env python3
"""Power off this computer. Meant to be run from cron (as root).

Usage:
    python3 shutdown.py            # shut down now
    python3 shutdown.py --dry-run  # print the command instead of running it
"""
import os
import platform
import shutil
import subprocess
import sys


def shutdown_command():
    if platform.system() == "Windows":
        return ["shutdown", "/s", "/t", "0"]

    # Linux / macOS. Cron runs with a minimal PATH (often just /usr/bin:/bin),
    # which usually does not include the directory holding `shutdown`.
    search_path = os.pathsep.join(
        [os.environ.get("PATH", ""), "/sbin", "/usr/sbin", "/usr/bin", "/bin"]
    )
    exe = shutil.which("shutdown", path=search_path)
    if exe is None:
        sys.exit("shutdown.py: could not find the 'shutdown' command")
    return [exe, "-h", "now"]


def main():
    cmd = shutdown_command()
    if "--dry-run" in sys.argv[1:]:
        print(" ".join(cmd))
        return
    subprocess.run(cmd, check=True)


if __name__ == "__main__":
    main()
