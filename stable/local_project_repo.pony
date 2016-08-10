use "json"

primitive LocalProjectRepo
  
  fun tag create_dep(bundle: Bundle box, dep: JsonObject box): BundleDep? =>
    _BundleDepLocal(bundle, dep)
  
  fun tag add(args: Array[String] box): JsonObject ref? =>
    let json: JsonObject ref = JsonObject.create()
    json.data("type") = "local"
    json.data("local-path") = args(0)
    json


class _BundleDepLocal
  let bundle: Bundle box
  let info: JsonObject box
  let local_path: String
  new create(b: Bundle box, i: JsonObject box)? =>
    bundle       = b
    info         = i
    local_path   = try info.data("local-path") as String
                   else bundle.log("No 'local-path' key in dep: " + info.string()); error
                   end
  
  fun root_path(): String => local_path
  fun packages_path(): String => root_path()
  
  fun ref fetch() => None
