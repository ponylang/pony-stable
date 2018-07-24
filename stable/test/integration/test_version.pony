use "ponytest"
use "files"
use "process"
use ".."

class TestVersion is UnitTest
  new iso create() => None
  fun name(): String => "integration.Version"

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
      ["\\d\\.\\d\\.\\d-[a-f0-9]+ \\[[a-z]+\\]"],
      None, // stderr
      0)
    _Exec(h, "stable version", tmp.path, consume notifier)
