use "ponytest"
use integration = "integration"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(TestBundle)
    test(TestBundleSelfReferentialPaths)
    test(TestBundleMutuallyRecursivePaths)
    test(TestDep)
    PrivateTests.make().tests(test)

    test(integration.TestUsage([ "stable" ])) // no arguments
    test(integration.TestUsage([ "help" ]))
    test(integration.TestUsage([ "unknown arguments" ]))
    test(integration.TestVersion)

    integration.EnvTests.make().tests(test)
