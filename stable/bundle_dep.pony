
use "json"
use "debug"

interface BundleDep
  fun root_path(): String
  fun packages_path(): String
  fun ref fetch()?

primitive BundleDepFactory
  fun apply(bundle: Bundle, dep: JsonObject box): BundleDep? =>
    match dep.data("type")
    | "github" => BundleDepGitHub(bundle, dep)
    | "local-git" => BundleDepLocalGit(bundle, dep)
    | "local" => BundleDepLocal(bundle, dep)
    else error
    end

class BundleDepGitHub
  let bundle: Bundle
  let info: JsonObject box
  let repo: String
  let subdir: String
  let git_tag: (String | None)
  new create(b: Bundle, i: JsonObject box)? =>
    bundle = b
    info   = i
    repo   = try info.data("repo") as String
             else bundle.log("No 'repo' key in dep: " + info.string()); error
             end
    subdir = try info.data("subdir") as String
             else ""
             end
    git_tag = try info.data("tag") as String
              else None
              end

  fun root_path(): String => ".deps/" + repo
  fun packages_path(): String => root_path() + "/" + subdir
  fun url(): String => "https://github.com/" + repo

  fun ref fetch()? =>
    try Shell("test -d "+root_path())
      Shell("git -C "+root_path()+" pull "+url())
    else
      Shell("mkdir -p "+root_path())
      Shell("git clone "+url()+" "+root_path())
    end
    _checkout_tag()

  fun _checkout_tag() ? =>
    if git_tag isnt None then
      Shell("cd " + root_path() + " && git checkout " + (git_tag as String))
    end

class BundleDepLocalGit
  let bundle: Bundle
  let info: JsonObject box
  let package_name: String
  let local_path: String
  let git_tag: (String | None)
  new create(b: Bundle, i: JsonObject box)? =>
    bundle       = b
    info         = i
    local_path   = try info.data("local-path") as String
                   else bundle.log("No 'local-path' key in dep: " + info.string()); error
                   end
    package_name = try _SubdirNameGenerator(local_path)
                   else bundle.log("Something went wrong generating dir name "); error
                   end
    bundle.log(package_name)
    git_tag      = try info.data("tag") as String
                   else None
                   end
    bundle.log(package_name)

  fun root_path(): String => ".deps/"+package_name
  fun packages_path(): String => root_path()

  fun ref fetch()? =>
    Shell("git clone "+local_path+" "+root_path())
    _checkout_tag()

  fun _checkout_tag() ? =>
    if git_tag isnt None then
      Shell("cd " + root_path() + " && git checkout " + (git_tag as String))
    end

class BundleDepLocal
  let bundle: Bundle
  let info: JsonObject box
  let local_path: String
  new create(b: Bundle, i: JsonObject box)? =>
    bundle       = b
    info         = i
    local_path   = try info.data("local-path") as String
                   else bundle.log("No 'local-path' key in dep: " + info.string()); error
                   end

  fun root_path(): String => local_path
  fun packages_path(): String => root_path()

  fun ref fetch() => None

primitive _SubdirNameGenerator
  fun apply(path: String): String val ? =>
    let dash_code: U8 = 45
    let path_name_arr = recover val
      var acc: Array[U8] = Array[U8]
      for char in path.array().values() do
        if _is_alphanum(char) then
          acc.push(char)
        else
          if acc.size() == 0 then
            acc.push(dash_code)
          elseif acc(acc.size() - 1) != dash_code then
            acc.push(dash_code)
          end
        end
      end
      acc.append(path.hash().string())
      consume acc
    end
    String.from_array(consume path_name_arr)

  fun _is_alphanum(c: U8): Bool =>
    let alphanums = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".array()
    var res = false
    try
      alphanums.find(c)
      res = true
    end
    res
