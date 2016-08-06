use "json"

primitive LocalProjectRepo
  fun tag createBundle(bundle: Bundle, dep: JsonObject box): BundleDep? =>
    _BundleDepLocal(bundle, dep)

class _BundleDepLocal
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
