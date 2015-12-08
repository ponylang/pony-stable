
use "files"

actor Main
  let env: Env
  let log: Log
  
  new create(env': Env) =>
    env = env'
    log = LogSimple(env.err)
    
    command(try env.args(1) else "" end, env.args.slice(2))
  
  fun _print_usage() =>
    env.out.printv(recover [
      "Usage: stable COMMAND [...]",
      "",
      "    A simple dependency manager for the Pony language.",
      "",
      "    Invoke in a working directory containing a bundle.json.",
      "",
      "Commands:",
      "    help  - Print this message",
      "    fetch - Fetch/update the deps for this bundle",
      "    env   - Execute the following shell command inside an environment",
      "            with PONYPATH set to include deps directories. For example,",
      "            `stable env ponyc myproject`",
    ""] end)
  
  fun _load_bundle(): Bundle? =>
    try Bundle(FilePath(env.root, "."), log)
    else log("Failed to load bundle in current working directory."); error
    end
  
  fun command("fetch", _) =>
    try let bundle = _load_bundle()
      for dep in bundle.deps() do
        dep.fetch()
      end
    end
  
  fun command("env", rest: Array[String] box) =>
    try let bundle = _load_bundle()
      var ponypath = recover trn String end
      let iter = bundle.deps()
      for dep in iter do
        ponypath.append(dep.path())
        if iter.has_next() then ponypath.push(':') end
      end
      
      Shell.from_array(["env", "PONYPATH="+ponypath].append(rest))
    end
  
  fun command(s: String, rest: Array[String] box) =>
    _print_usage()
