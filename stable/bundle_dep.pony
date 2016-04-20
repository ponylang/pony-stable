
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
    else error
    end

class BundleDepGitHub
  let bundle: Bundle
  let info: JsonObject box
  let repo: String
  let subdir: String
  new create(b: Bundle, i: JsonObject box)? =>
    bundle = b
    info   = i
    repo   = try info.data("repo") as String
             else bundle.log("No 'repo' key in dep: " + info.string()); error
             end
    subdir = try info.data("subdir") as String
             else ""
             end

  fun root_path(): String => ".deps/" + repo
  fun packages_path(): String => root_path() + "/" + subdir
  fun url(): String => "https://github.com/" + repo

  fun ref fetch()? =>
    try Shell("test -d "+root_path())
      Shell("git -C "+root_path()+" pull")
    else
      Shell("mkdir -p "+root_path())
      Shell("git clone "+url()+" "+root_path())
    end
