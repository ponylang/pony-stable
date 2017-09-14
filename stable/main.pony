use "files"

actor Main
  let env: Env
  let log: Log

  new create(env': Env) =>
    env = env'
    log = LogSimple(env.err)

    command(try env.args(1)? else "" end, env.args.slice(2))

  fun _print_usage() =>
    env.out.printv(
      recover
        [ "Usage: stable COMMAND [...]"
          ""
          "    A simple dependency manager for the Pony language."
          ""
          "    Invoke in a working directory containing a bundle.json."
          ""
          "Commands:"
          "    help  - Print this message"
          "    fetch - Fetch/update the deps for this bundle"
          "    env   - Execute the following shell command inside an environment"
          "            with PONYPATH set to include deps directories. For example,"
          "            `stable env ponyc myproject`"
          "    add   - Add a new dependency. For exemple,"
          "            `stable add github jemc/pony-inspect"
          ""
        ]
      end)

  fun _load_bundle(create_on_missing: Bool = false): Bundle ? =>
    let cwd = Path.cwd()
    var path = cwd
    while path.size() > 0 do
      try
        return Bundle(FilePath(env.root as AmbientAuth, path)?, log, false)?
      else
        path = Path.split(path)._1
      end
    end
    if create_on_missing then
      Bundle(FilePath(env.root as AmbientAuth, cwd)?, log, true)?
    else
      log("No bundle.json in current working directory or ancestors.")
      error
    end

  fun command("fetch", _) =>
    try _load_bundle()?.fetch() end

  fun command("env", rest: Array[String] box) =>
    let ponypath =
      try
        let bundle = _load_bundle()?
        let ponypath' = recover trn String end
        let iter = bundle.paths().values()
        let sep = Path.list_sep()(0)?
        for path in iter do
          ponypath'.append(path)
          if iter.has_next() then ponypath'.push(sep) end
        end

        ponypath'
      else
        ""
      end
    try
      ifdef windows then
        var cmd: String trn = recover String end
        cmd.append("cmd /C \"set \"PONYPATH=")
        cmd.append(ponypath)
        cmd.append("\" &&")
        for arg in rest.values() do
          cmd.append(" ")
          cmd.append(arg)
        end
        cmd.append("\"")
        Shell(consume cmd, env~exitcode())?
      else
        Shell.from_array(
          ["env"; "PONYPATH=" + ponypath] .> append(rest), env~exitcode())?
      end
    end

  fun command("add", rest: Array[String] box) =>
    try
      let bundle = _load_bundle(true)?
      let added_json = Add(rest, log)?
      bundle.add_dep(added_json)?
      bundle.fetch()
    end

  fun command(s: String, rest: Array[String] box) =>
    _print_usage()
