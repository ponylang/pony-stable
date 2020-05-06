use "ponytest"
use "files"
use "process"
use ".."

class TestUsage is UnitTest
  let _args: Array[String] val

  new iso create(args: Array[String] val) =>
    _args = args
    None

  fun name(): String =>
    let args_str = String
    for arg in _args.values() do
      args_str.append(arg)
    end
    "integration.Usage(" + args_str + ")"

  fun apply(h: TestHelper) =>
    h.long_test(2_000_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        return
      end
    h.dispose_when_done(_CleanTmp(tmp))

    let notifier: ProcessNotify iso = _ExpectClient(h,
      [ "Usage: stable COMMAND \\[\\.\\.\\.\\]"
        "A simple dependency manager for the Pony language"
        "help\\s+- Print this message"
        "version\\s+- Print version information"
        "fetch\\s+- Fetch/update the deps for this bundle"
        "env\\s+- Execute the following shell command inside an environment"
        "add\\s+- Add a new dependency. For example,"
      ],
      None, // stderr
      0)
    _Exec(h, _args, tmp.path, consume notifier)
