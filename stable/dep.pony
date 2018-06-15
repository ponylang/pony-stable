use "json"
use "files"

interface DepAny
  fun root_path(): String
  fun packages_path(): String
  fun ref fetch()?

primitive Dep
  fun apply(bundle: Bundle box, info: JsonObject box): DepAny ? =>
    match info.data("type")?
    | "github" => DepGitHosted(bundle, info, "https://github.com/")?
    | "gitlab" => DepGitHosted(bundle, info, "https://gitlab.com/")?
    | "local-git" => DepLocalGit(bundle, info)?
    | "local" => DepLocal(bundle, info)?
    else error
    end

class DepGitHosted
  let bundle: Bundle box
  let info: JsonObject box
  let domain: String
  let repo: String
  let subdir: String
  let git_tag: (String | None)

  new create(b: Bundle box, i: JsonObject box, d: String) ? =>
    bundle = b
    info = i
    domain = d
    repo =
      try info.data("repo")? as String
      else
        bundle.log("No 'repo' key in dep: " + info.string())
        error
      end
    subdir =
      try info.data("subdir")? as String
      else ""
      end
    git_tag =
      try info.data("tag")? as String
      else None
      end

  fun root_path(): String =>
    Path.join(bundle.path.path, Path.join(".deps", repo))

  fun packages_path(): String =>
    Path.join(root_path(), subdir)

  fun url(): String =>
    domain + repo

  fun ref fetch() ? =>
    let fpath = FilePath(bundle.path, root_path())?
    if fpath.exists() then
      Shell("git -C " + root_path() + " fetch")?
    else
      fpath.mkdir()
      Shell("git clone " + url() + " " + root_path())?
    end
    _CheckoutTag(root_path(), git_tag)?

class DepLocalGit
  let bundle: Bundle box
  let info: JsonObject box
  let package_name: String
  let local_path: String
  let git_tag: (String | None)

  new create(b: Bundle box, i: JsonObject box) ? =>
    bundle = b
    info = i
    local_path =
      try info.data("local-path")? as String
      else
        bundle.log("No 'local-path' key in dep: " + info.string())
        error
      end
    package_name =
      try _SubdirNameGenerator(local_path)?
      else
        bundle.log("Something went wrong generating dir name ")
        error
      end
    bundle.log(package_name)
    git_tag =
      try info.data("tag")? as String
      else None
      end
    bundle.log(package_name)

  fun root_path(): String =>
    Path.join(bundle.path.path, Path.join(".deps", package_name))

  fun packages_path(): String =>
    root_path()

  fun ref fetch() ? =>
    let fpath = FilePath(bundle.path, root_path())?
    if fpath.exists() then
      Shell("git -C " + root_path() + " pull " + local_path)?
    else
      fpath.mkdir()
      Shell("git clone " + local_path + " " + root_path())?
    end
    _CheckoutTag(root_path(), git_tag)?

class DepLocal
  let bundle: Bundle box
  let info: JsonObject box
  let local_path: String

  new create(b: Bundle box, i: JsonObject box) ? =>
    bundle = b
    info = i
    local_path =
      try info.data("local-path")? as String
      else
        bundle.log("No 'local-path' key in dep: " + info.string())
        error
      end

  fun root_path(): String =>
    local_path

  fun packages_path(): String =>
    root_path()

  fun ref fetch() =>
    None

primitive _CheckoutTag
  fun apply(root_path: String, git_tag: (String | None)) ? =>
    match git_tag
    | let str: String =>
      Shell("cd " + root_path + " && git checkout " + str)?
    end
