use "ponytest"
use "files"
use "process"
use ".."

class TestUsage is UnitTest
  let _args: String
  new iso create(args: String = "") =>
    _args = args
    None

  fun name(): String => "integration.Usage()"

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
      [ "usage: stable \\[\\<options\\>\\] \\<command\\> \\[\\<args\\> \\.\\.\\.\\]"
        ""
        "A simple dependency manager for the Pony language\\."
        ""
        "Invoke in a working directory containing a bundle\\.json\\."
        ""
        ""
        "Options:"
        "   -h, --help=false    Shows this text and exits."
        ""
        "Commands:"
        "   env <command>          Executes the given command within the environment defined by the local `bundle.json`."
        "   help <command>"
        "   add <type> <source>    Adds a new dependency to the local `bundle.json`."
        "   version                Prints the version of stable."
        "   fetch                  Updates the local `.deps` directory with the most recent content from the source repositories."
      ],
      None, // stderr
      0)
    _Exec(h, "stable " + _args, tmp.path, consume notifier)

class TestUsageOnError is UnitTest
  let _args: String
  new iso create(args: String = "") =>
    _args = args
    None

  fun name(): String => "integration.UsageOnError(" + _args + ")"

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
      None, // stdout
      [ "Error: .+"
        ""
        "usage: stable \\[\\<options\\>\\] \\<command\\> \\[\\<args\\> \\.\\.\\.\\]"
        ""
        "A simple dependency manager for the Pony language\\."
        ""
        "Invoke in a working directory containing a bundle\\.json\\."
        ""
        ""
        "Options:"
        "   -h, --help=false    Shows this text and exits."
        ""
        "Commands:"
        "   env <command>          Executes the given command within the environment defined by the local `bundle.json`."
        "   help <command>"
        "   add <type> <source>    Adds a new dependency to the local `bundle.json`."
        "   version                Prints the version of stable."
        "   fetch                  Updates the local `.deps` directory with the most recent content from the source repositories."
      ], //stderr
      1)
    _Exec(h, "stable " + _args, tmp.path, consume notifier)
