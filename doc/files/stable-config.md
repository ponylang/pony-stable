stable-config(5) -- bundle.json file format
===========================================

## DESCRIPTION

This page describes the format of the `bundle.json` file. `bundle.json` should
be at the root of any project which uses `stable` to manage its dependencies.
As the file suffix suggests, it is a JSON file.

## deps

`bundle.json` currently only has one key at the root of the JSON document:
`deps`. This is an array of dependencies. A minimal `bundle.json` looks like

    { "deps" : [] }

The contents of this array are dependency objects. All dependency objects
have a `type`; the rest of the fields depend on the type of dependency.

## github

The `github` type represents a github repository. It has up to four keys:

* `"type"`:
  **[Required]** For the `github` dependency type, this is `"github"`.
* `"repo"`:
  **[Required]** The path of the url for your dependency project. For example,
  `pony-stable`'s repo would be `"ponylang/pony-stable"`.
* `"tag"`:
  [Optional] A specific tag to checkout from the git repo. Technically, this
  can be any git "tree-ish".
* `"subdir"`:
  [Optional] A subdirectory to use as the root of this dependency.

## local-git

The `local-git` type represents a git repository already on your workstation.
It has up to three keys:

* `"type"`:
  **[Required]** For the `local-git` dependency type, this is `"local-git"`.
* `"local-path"`:
  **[Required]** The filesystem path to your dependency's repository. May be
  relative.
* `"tag"`:
  [Optional] A specific tag to checkout from the git repo. Technically, this
  can be any git "tree-ish".

## local

The `local` type is any directory on your computer. It does not need to be
a git repository.

* `"type"`:
  **[Required]** For the `local` dependency type, this is `"local"`.
* `"local-path"`:
  **[Required]** The filesystem path to your dependency's repository. May be
  relative.

## EXAMPLES

The following is an example of a bundle.json using one of each type of dependency.

    {
      "deps": [
        {
          "type": "github",
          "repo": "ponylang/pony-stable",
          "tag": "0.1.0",
          "subdir": "stable"
        }, {
          "type": "local-git",
          "local-path": "../local-git-project"
          "tag": "1.1.5",
        }, {
          "type": "local",
          "local-path": "/home/misterEd/pony-project"
        }
      ]
    }
