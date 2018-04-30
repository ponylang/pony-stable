stable(1) -- pony dependency manager
====================================

## SYNOPSIS

    stable <command> [args]

## DESCRIPTION

stable is a simple dependency manager for pony. It fetches
dependencies from your local filesystem and remote sources
and provides a build environment that directs `ponyc` to use
those fetched dependencies.

`stable help` provides a list of available commands.

## INTRODUCTION

stable is generally made up of three pieces:

* `stable add`:
  Add a dependency to the local `bundle.json`. See `stable-add(1)`.
* `stable fetch`:
  Download dependencies listed in the `bundle.json`. See `stable-fetch(1)`
* `stable env`:
  Create a build environment to help you use your downloaded dependencies.
  See `stable-env(1)`

For more information on the `bundle.json` file, see `stable-config(5)`.

## EXAMPLES

* `stable fetch`:
Download dependencies for your project.

* `stable env ponyc`:
Run `ponyc` using your downloaded dependencies.

* `stable add github jemc/pony-inspect`:
Add the project at github.com/jemec/pony-inspect to your project.
