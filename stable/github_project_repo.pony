use "json"
use "options"

primitive GithubProjectRepo
  
  fun tag create_dep(bundle: Bundle box, dep: JsonObject box): BundleDep? =>
    _BundleDepGitHub(bundle, dep)
  
  fun tag add(args: Array[String] box): JsonObject ref? =>
    let json: JsonObject ref = JsonObject.create()
    json.data("type") = "github"
    json.data("repo") = args(0)
    
    let options = Options(args.slice(1))
    options.add("tag", "t", StringArgument)
    options.add("subdir", "d", StringArgument)
    for option in options do
      match option
      | (let name: String, let value: String) => json.data(name) = value
      end
    end
    
    json


class _BundleDepGitHub
  let bundle: Bundle box
  let info: JsonObject box
  let repo: String
  let subdir: String
  let git_tag: (String | None)
  new create(b: Bundle box, i: JsonObject box)? =>
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
