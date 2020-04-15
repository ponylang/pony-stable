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

    test(integration.TestUsageOnError()) // no arguments
    test(integration.TestUsageOnError("wrong")) // wrong subcommand
    test(integration.TestUsage("help"))
    test(integration.TestVersion)

    integration.EnvTests.make().tests(test)
