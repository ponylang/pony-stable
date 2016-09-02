
use "json"
use options = "options"

primitive Add
  fun apply(args: Array[String] box): JsonObject ref? =>
    let kind = args(0)
    let rest = args.slice(1)
    let prim = match kind
               | "github"    => AddGithub
               | "local-git" => AddLocalGit
               | "local"     => AddLocal
               else error
               end
    let info: JsonObject ref = JsonObject.create()
    info.data("type") = kind.clone()
    prim(rest, info)
    
    info

primitive AddGithub
  fun apply(args: Array[String] box, info: JsonObject ref)? =>
    info.data("repo") = args(0)
    
    let opts = options.Options(args.slice(1))
    opts.add("tag", "t", options.StringArgument)
    opts.add("subdir", "d", options.StringArgument)
    for opt in opts do
      match opt
      | (let name: String, let value: String) => info.data(name) = value
      end
    end

primitive AddLocalGit
  fun apply(args: Array[String] box, info: JsonObject ref)? =>
    info.data("local-path") = args(0)
    
    let opts = options.Options(args.slice(1))
    opts.add("tag", "t", options.StringArgument)
    for opt in opts do
      match opt
      | (let name: String, let value: String) => info.data(name) = value
      end
    end

primitive AddLocal
  fun apply(args: Array[String] box, info: JsonObject ref)? =>
    info.data("local-path") = args(0)
