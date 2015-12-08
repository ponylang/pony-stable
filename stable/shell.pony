
use @system[I32](command: Pointer[U8] tag)

// TODO: Remove Shell hack in favor of cap-based implementations of actions.
primitive Shell
  fun tag apply(command: String)? =>
    let rc = @system(command.cstring())
    if rc != 0 then error end
  
  fun tag from_array(command_args: Array[String] box)? =>
    var command = recover trn String end
    for arg in command_args.values() do
      command.append(escape_arg(arg))
      command.push(' ')
    end
    apply(consume command)
  
  fun tag escape_arg(arg: String): String =>
    "'" + arg.clone().replace("'", "'\\''") + "'"
