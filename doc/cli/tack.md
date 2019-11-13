tack(1) -- pony dependency manager
====================================

## SYNOPSIS

    tack <command> [args]

## DESCRIPTION

tack is a simple dependency manager for pony. It fetches
dependencies from your local filesystem and remote sources
and provides a build environment that directs `ponyc` to use
those fetched dependencies.

`tack help` provides a list of available commands.

## INTRODUCTION

tack is generally made up of three pieces:

* `tack add`:
  Add a dependency to the local `bundle.json`. See `tack-add(1)`.
* `tack fetch`:
  Download dependencies listed in the `bundle.json`. See `tack-fetch(1)`
* `tack env`:
  Create a build environment to help you use your downloaded dependencies.
  See `tack-env(1)`

For more information on the `bundle.json` file, see `tack-config(5)`.

## EXAMPLES

* `tack fetch`:
Download dependencies for your project.

* `tack env ponyc`:
Run `ponyc` using your downloaded dependencies.

* `tack add github jemc/pony-inspect`:
Add the project at github.com/jemec/pony-inspect to your project.
