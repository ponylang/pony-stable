use "cli"
use "files"

primitive EnvCmd
  fun name(): String => "env"

  fun command_spec(): CommandSpec ?=>
    CommandSpec.leaf(
      name(),
      "Executes the given command within the environment defined by the local `bundle.json`.",
      [], // options
      [ // args
        ArgSpec.string_seq(
          "command",
          "The command to execute.")
      ]
      )?

  fun apply(env: Env, cmd: Command, bundle: Bundle, log: Log) ? =>
    let command = cmd.arg("command").string_seq()
    if command.size() == 0 then
      log("Please provide a command to execute.")
      error
    end
    let ponypath =
      try
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
        var exec: String trn = recover String end
        exec.append("cmd /C \"set \"PONYPATH=")
        exec.append(ponypath)
        exec.append("\" &&")
        for arg in command.values() do
          exec.append(" ")
          exec.append(arg)
        end
        exec.append("\"")
        Shell(consume exec, env.exitcode)?
      else
        Shell.from_array(
          ["env"; "PONYPATH=" + ponypath] .> append(command), env.exitcode)?
      end
    end

