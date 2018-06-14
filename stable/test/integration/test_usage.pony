use "ponytest"
use "process"
use ".."

class TestUsage is UnitTest
  new iso create() => None
  fun name(): String => "integration.Usage"

  fun apply(h: TestHelper) =>
    h.long_test(100_000_000)
    let notifier: ProcessNotify iso = _ExpectClient(h,
      [ "Usage: stable COMMAND \\[\\.\\.\\.\\]"
        "A simple dependency manager for the Pony language"
        "help\\s+- Print this message"
        "version\\s+- Print version information"
        "fetch\\s+- Fetch/update the deps for this bundle"
        "env\\s+- Execute the following shell command inside an environment"
        "add\\s+- Add a new dependency. For exemple,"
      ],
      None, // stderr
      0)
    _Exec(h, "stable", consume notifier)
