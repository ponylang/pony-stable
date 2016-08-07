
use "files"
use "json"

class Bundle
  let log: Log
  let path: FilePath
  let json: JsonDoc = JsonDoc

  new create(path': FilePath, log': Log = LogNone, createOnMissing: Bool = false)? =>
    path = path'; log = log'

    let bundlePath = path.join("bundle.json")

    if not bundlePath.exists() then
      if createOnMissing then
        let f = CreateFile(bundlePath) as File
        f.write("{\"deps\":[]}")
        f.dispose()
        try json.parse("{\"deps\":[]}") end
      else
        error
      end
    else
      let file = OpenFile(bundlePath) as File
      let content: String = file.read_string(file.size())
      try json.parse(content) else
        (let err_line, let err_message) = json.parse_report()
        log("JSON error at: " + file.path.path + ":" + err_line.string()
                              + " : " + err_message)
        error
      end
    end
  
  fun deps(): Iterator[BundleDep] =>
    let deps_array = try (json.data as JsonObject box).data("deps") as JsonArray box
                     else JsonArray
                     end
    
    object is Iterator[BundleDep]
      let bundle: Bundle box = this
      let inner: Iterator[JsonType box] = deps_array.data.values()
      fun ref has_next(): Bool    => inner.has_next()
      fun ref next(): BundleDep^? =>
        let nextJson = inner.next() as JsonObject box
        ProjectRepoFactory(nextJson.data("type") as String).createDep(bundle, nextJson)
    end
  
  fun fetch() =>
    for dep in deps() do
      try dep.fetch() end
    end
    for dep in deps() do
      // TODO: detect and prevent infinite recursion here.
      try Bundle(FilePath(path, dep.root_path()), log).fetch() end
    end
  
  fun paths(): Array[String] val =>
    let out = recover trn Array[String] end
    for dep in deps() do
      out.push(dep.packages_path())
    end
    for dep in deps() do
      // TODO: detect and prevent infinite recursion here.
      try out.append(Bundle(FilePath(path, dep.packages_path()), log).paths()) end
    end
    out

  fun ref addDep(depJson: JsonObject ref) ? =>
    let deps_array = try (json.data as JsonObject).data("deps") as JsonArray
                     else JsonArray
                     end
    deps_array.data.push(consume depJson)
    let file = CreateFile(path.join("bundle.json")) as File
    file.write(json.string())
