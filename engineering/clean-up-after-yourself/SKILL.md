---
name: clean-up-after-yourself
description: Use when you create state during a task — files (downloads, scratch outputs, test logs, throwaway artifacts), background processes, scheduled jobs, hooks, or notifications. Don't leave clutter behind in the home directory, /tmp, the working directory, the process table, or the harness config.
---

If you created it and you don't need it anymore, remove it. Before ending a turn, look back at the state you introduced and clean up anything that was only useful in the moment.

## Files

Delete files you wrote that you no longer need — downloaded files you glanced at once, log files a test produced, scratch scripts, temp outputs. This applies to the home directory, `/tmp`, and the project's working directory equally. "The OS will clean `/tmp` eventually" is not an excuse.

## Processes and jobs

If you started something that keeps running, stop it when you're done: background processes (dev servers, watchers, `run_in_background` tasks), scheduled jobs (cron entries, `/loop` or routines you set up to poll), and any `ScheduleWakeup` pacing you no longer need. Don't leave orphaned processes holding ports or a loop firing forever.

## Harness config and notifications

Temporary changes to the Claude Code harness are state too. If you added a hook, permission, or env var just to get through a task, remove it afterward unless the user wanted it kept. Likewise, dismiss or clear stale notifications you generated — leftover push notifications, wakeup reminders, or other alerts that no longer point at anything real.

## When you find yourself sweeping repeatedly

If you keep manually removing the same kind of thing, that may be a signal something upstream is wrong — maybe the script you wrote should clean up after itself, maybe those artifacts belong in a Makefile's `clean:` target, maybe a test should tear down what it set up, maybe a process should be spawned with a lifecycle that ends with the task. Worth considering before you just keep sweeping.
