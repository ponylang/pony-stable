use "ponytest"
use "files"
use "process"
use ".."

class TestUsage is UnitTest
  let _args: String
  new iso create(args: String = "") =>
    _args = args
    None

  fun name(): String => "integration.Usage(" + _args + ")"

  fun apply(h: TestHelper) =>
    h.long_test(200_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        return
      end

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
    _Exec(h, "stable " + _args, tmp.path, _CleanTmp(tmp), consume notifier)
