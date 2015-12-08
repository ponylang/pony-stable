
use "files"
use "json"

class box Bundle
  let log: Log
  let path: FilePath
  let json: JsonDoc = JsonDoc
  
  new create(path': FilePath, log': Log = LogNone)? =>
    path = path'; log = log'
    
    let file = OpenFile(path.join("bundle.json")) as File
    let content: String = file.read_string(file.size())
    try json.parse(content) else
      (let err_line, let err_message) = json.parse_report()
      log("JSON error at: " + file.path.path + ":" + err_line.string()
                            + " : " + err_message)
      error
    end
  
  fun deps(): Iterator[BundleDep] =>
    let deps_array = try (json.data as JsonObject).data("deps") as JsonArray
                     else JsonArray
                     end
    
    object is Iterator[BundleDep]
      let bundle: Bundle = this
      let inner: Iterator[JsonType] = deps_array.data.values()
      fun ref has_next(): Bool    => inner.has_next()
      fun ref next(): BundleDep^? =>
        BundleDepFactory(bundle, inner.next() as JsonObject)
    end
