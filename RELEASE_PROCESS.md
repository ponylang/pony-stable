# How to cut a release

This document is aimed at members of the team who might be cutting a release. It serves as a checklist that can take you through doing a release step-by-step.

## Prerequisites

* You must have commit access to the this repository.
* It would be helpful to have read and write access to the ponylang [cloudsmith](https://cloudsmith.io/) account.
* Read and write access to the ponylang [appveyor](https://www.appveyor.com) account

### Validate external services are functional

* [Appveyor Status](https://appveyor.statuspage.io)
* [Bintray Status](http://status.bintray.com)
* [Cloudsmith](https://status.cloudsmith.io/)

### A GitHub issue exists for the release

All releases should have a corresponding issue in the [pony-stable repo](https://github.com/ponylang/pony-stable/issues). This issue should be used to communicate the progress of the release (updated as checklist steps are completed). You can also use the issue to notify other pony team members of problems.

## Releasing

Please note that this document was written with the assumption that you are using a clone of this repo. You have to be using a clone rather than a fork. It is advised to your do this by making a fresh clone of the repo from which you will release.

Before getting started, you will need a number for the version that you will be releasing as well as an agreed upon "golden commit" that will form the basis of the release.

The "golden commit" must be `HEAD` on the `master` branch of this repository. At this time, releasing from any other location is not supported.

For the duration of this document, that we are releasing version is `0.3.1`. Any place you see those values, please substitute your own version.

```bash
git tag release-0.3.1
git push origin release-0.3.1
```

### Update the GitHub issue as needed

At this point we are basically waiting on Travis, Appveyor and Homebrew. As each finishes, leave a note on the GitHub issue for this release letting everyone know where we stand status wise. For example: "Release 0.3.1 is now available via Homebrew".

### Update the GitHub issue

Leave a comment on the GitHub issue for this release letting everyone know that the Homebrew formula has been updated and a PR issued. Leave a link to your open PR.

### Wait on Linux Builds

Linux builds are built on GitHub via a GitHub action.

If everything worked correctly then in a few minutes, a release should appear in the [Cloudsmith releases repo](https://cloudsmith.io/~ponylang/repos/releases/packages/). If you don't see it, check the Actions tab for this repo to see where things went wrong.

### Wait on Windows builds

During the time since you push to the release branch, Appveyor has been busy building release artifacts. This can take up to a couple hours depending on how busy it is. Periodically check bintray to see if the releases are there yet.

* [Windows](https://bintray.com/pony-language/pony-stable-win/pony-stable)

The versions look something like:

`pony-stable-release-0.3.1-1526.8a8ee28`

where the `1526` is the AppVeyor build number and the `8a8ee28` is the abbreviated SHA for the commit we built from.

### Update the GitHub issue as needed

At this point we are basically waiting on Appveyor and Homebrew. As each finishes, leave a note on the GitHub issue for this release letting everyone know where we stand status wise. For example: "Release 0.3.1 is now available via Homebrew".

---

## If something goes wrong

The release process can be restarted at various points in it's lifecycle by pushing specially crafted tags.

### Start a release

As documented above, a release is started by pushing a tag of the form `release-x.y.z`.

### Build artifacts

The release process can be manually restarted from here by pushing a tag of the form `x.y.z`. The pushed tag must be on the commit to build the release artifacts from. During the normal process, that commit is the same as the one that `release-x.y.z`.

### Announce release

The release process can be manually restarted from here by push a tag of the form `announce-x.y.z`. The tag must be on a commit that is after "Release x.y.z" commit that was generated during the `Start a release` portion of the process.

If you need to restart from here, you will need to pull the latest updates from the repo as it will have changed and the commit you need to tag will not be available in your copy of the repo with pulling.

### Update Homebrew

Fork the [homebrew-core repo](https://github.com/Homebrew/homebrew-core) and then clone it locally. You are going to be editing "Formula/pony-stable.rb". If you already have a local copy of homebrew-core, make sure you sync up with the main Homebrew repo otherwise you might change an older version of the formula and end up with merge conflicts.

Make sure you do your changes on a branch:

* git checkout -b pony-stable-0.3.1

HomeBrew has [directions](https://github.com/Homebrew/homebrew-core/blob/master/CONTRIBUTING.md#submit-a-123-version-upgrade-for-the-foo-formula) on what specifically you need to update in a formula to account for an upgrade. If you are on OSX and are unsure of how to get the SHA of the release .tar.gz, download the release file (make sure it does unzip it) and run `shasum -a 256 pony-stable-0.3.1.tar.gz`. If you are on OSX, its quite possible it will try to unzip the file on your. In Safari, right clicking and selecting "Download Linked File" will get your the complete .tar.gz.

After updating the pony-stable formula, push to your fork and open a PR against homebrew-core. According to the homebrew team, their preferred naming for such PRs is `pony-stable 0.3.1` that is, the name of the formula being updated followed by the new version number.
