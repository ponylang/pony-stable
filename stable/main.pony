use "files"
use "cli"

actor Main
  let env: Env
  let log: Log

  new create(env': Env) =>
    env = env'
    log = LogSimple(env.err)

    let cs =
      try
        CommandSpec.parent(
          "stable",
          """
          A simple dependency manager for the Pony language.

          Invoke in a working directory containing a bundle.json.
          """,
          [], // options
          [   // subcommands
            VersionCmd.command_spec()?
            FetchCmd.command_spec()?
            EnvCmd.command_spec()?
            AddCmd.command_spec()?
          ])? .> add_help("help", "Shows this text and exits.")?
      else
        log("Error instantiating stable cli.")
        env.exitcode(1)
        return
      end
    let cmd =
      match CommandParser(cs).parse(env.args, env.vars)
      | let c: Command => c
      | let ch: CommandHelp =>
        ch.print_help(env.out)
        env.exitcode(0)
        return
      | let se: SyntaxError =>
        log(se.string())
        log("")
        Help.general(cs).print_help(env.err)
        env.exitcode(1)
        return
      end

    let locator =
      try
        _BundleLocator(env.root as AmbientAuth, log)
      else
        log("unable to locate bundle.json, no sufficient Auth provided.")
        env.exitcode(1)
        return
      end
    // dispatch to subcommands
    try
      match cmd.spec().name()
      | VersionCmd.name() =>
        env.out.print(VersionCmd())
      | FetchCmd.name() =>
        let bundle = locator.load_from_cwd()?
        FetchCmd(cmd, bundle, log)
      | EnvCmd.name() =>
        let bundle = locator.load_from_cwd()?
        EnvCmd(env, cmd, bundle, log)?
        return // avoid overwriting the exitcode
      | AddCmd.name() =>
        let bundle = locator.load_from_cwd(true)?
        AddCmd(cmd, bundle, log)?
      else
        log("unknown subcommand")
        Help.general(cs).print_help(env.err)
        env.exitcode(1)
      end
      env.exitcode(0)
    else
      env.exitcode(1)
    end

