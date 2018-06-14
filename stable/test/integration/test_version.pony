use "ponytest"
use "process"
use ".."

class TestVersion is UnitTest
  new iso create() => None
  fun name(): String => "integration.Version"

  fun apply(h: TestHelper) =>
    h.long_test(100_000_000)
    let notifier: ProcessNotify iso = _ExpectClient(h,
      [as String: "\\d\\.\\d\\.\\d-[a-f0-9]+ \\[[a-z]+\\]"],
      None, // stderr
      0)
    _Exec(h, "stable version", consume notifier)
