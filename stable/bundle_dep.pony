
use "json"
use "debug"

interface BundleDep
  fun path(): String
  fun ref fetch()?

primitive BundleDepFactory
  fun apply(bundle: Bundle, dep: JsonObject): BundleDep? =>
    match dep.data("type")
    | "github" => BundleDepGitHub(bundle, dep)
    else error
    end

class BundleDepGitHub
  let bundle: Bundle
  let info: JsonObject
  let repo: String
  new create(b: Bundle, i: JsonObject)? =>
    bundle = b; info = i
    repo = try info.data("repo") as String
           else bundle.log("No 'repo' key in dep: " + info.string()); error
           end
  
  fun path(): String => ".deps/" + repo
  fun url(): String => "https://github.com/" + repo
  
  fun ref fetch()? =>
    try Shell("test -d "+path())
      Shell("git -C "+path()+" pull")
    else
      Shell("mkdir -p "+path())
      Shell("git clone "+url()+" "+path())
    end
