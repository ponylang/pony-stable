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
          "    help    - Print this message"
          "    version - Print version information"
          "    fetch   - Fetch/update the deps for this bundle"
          "    env     - Execute the following shell command inside an environment"
          "              with PONYPATH set to include deps directories. For example,"
          "              `stable env ponyc myproject`"
          "    add     - Add a new dependency. For example,"
          "              `stable add github jemc/pony-inspect"
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

  fun command_fetch() =>
    try _load_bundle()?.fetch() end

  fun command_env(rest: Array[String] box) =>
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
        Shell(consume cmd, env.exitcode)?
      else
        Shell.from_array(
          ["env"; "PONYPATH=" + ponypath] .> append(rest), env.exitcode)?
      end
    end

  fun command_add(rest: Array[String] box) =>
    try
      let bundle = _load_bundle(true)?
      let added_json = Add(rest, log)?
      bundle.add_dep(added_json)?
      bundle.fetch()
    end

  fun command_version(rest: Array[String] box) =>
    env.out.print(Version())

  fun command(s: String, rest: Array[String] box) =>
    match s
    | "fetch" =>
      command_fetch()
    | "env" =>
      command_env(rest)
    | "add" =>
      command_add(rest)
    | "version" =>
      command_version(rest)
    else
      _print_usage()
    end
