
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
      "    help    - Print this message",
      "    fetch   - Fetch/update the deps for this bundle",
      "    env     - Execute the following shell command inside an environment",
      "              with PONYPATH set to include deps directories. For example,",
      "              `stable env ponyc myproject`",
      "    install - Install a new dependency. For exemple,",
      "              `stable install github jemc/pony-inspect",
    ""] end)

  fun _load_bundle(createOnMissing: Bool = false): Bundle? =>
    try Bundle(FilePath(env.root as AmbientAuth, "."), log, createOnMissing)
    else log("No bundle in current working directory."); error
    end
  
  fun command("fetch", _) =>
    try _load_bundle().fetch() end
  
  fun command("env", rest: Array[String] box) =>
    let ponypath = try let bundle = _load_bundle()
      var ponypath' = recover trn String end
      let iter = bundle.paths().values()
      for path in iter do
        ponypath'.append(path)
        if iter.has_next() then ponypath'.push(':') end
      end
      
      ponypath'
    else
      ""
    end
    try
      Shell.from_array(
        ["env", "PONYPATH="+ponypath].append(rest), env~exitcode()
      )
    end

  fun command("install", rest: Array[String] box) =>
    try
      let bundle = _load_bundle(true)
      let addedJson = ProjectRepoFactory(rest(0)).install(rest.slice(1))
      bundle.addDep(addedJson)
      bundle.fetch()
    end

  fun command(s: String, rest: Array[String] box) =>
    _print_usage()
