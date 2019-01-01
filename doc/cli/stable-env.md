stable-env(1) -- run a command in a stable environment
======================================================

## SYNOPSIS

    stable env -- <command>

## DESCRIPTION

This command allows you to run another command with the environment
needed for `ponyc` to use your stable-managed dependencies. Use
this command with `ponyc` to build your project.

In order to separate options given to `command` from options for `stable`,
always separate the `command` with a double dash `--` from the `stable` parts of the command line.

## EXAMPLES

    stable env -- ponyc -- debug
