tack-add(1) -- add a dependency
=================================

## SYNOPSIS

    tack add github <url-path> [options]
    tack add gitlab <url-path> [options]
    tack add local-git <path> [options]
    tack add local <path>
    tack add

## DESCRIPTION

This command adds a dependency to the local `bundle.json` and fetches
the added repository. There are three available sources of dependencies:
github download, copying from a local git repository, and a less
featureful copying from a local directory without using git.

## SOURCES

### github

Download a github repository into your project.

  * `-t` _git-tag_, `--tag` _git-tag_:
  Specify a tag from the source repository
  * `-d` _directory_ , `--subdir` _directory_:
  Fetch only a subdirectory of the project

  ```
  tack add github jemc/pony-inspect
  ```

### gitlab

Download a gitlab repository into your project.

  * `-t` _git-tag_, `--tag` _git-tag_:
  Specify a tag from the source repository
  * `-d` _directory_ , `--subdir` _directory_:
  Fetch only a subdirectory of the project

  ```
  tack add gitlab org/repo
  ```

### local-git

Copy a local git repository into your project.

  * `-t` _git-tag_, `--tag` _git-tag_:
  Specify a tag from the source repository

### local

Copy a local directory into your project.

## EXAMPLES

    tack add github jemc/pony-inspect
    tack add local-git ../other-project -t v1.1
    tack add local ../gitless-project
