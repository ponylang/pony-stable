use "cli"

primitive FetchCmd
  fun name(): String => "fetch"

  fun command_spec(): CommandSpec ? =>
    CommandSpec.leaf(
      name(),
      "Updates the local `.deps` directory with the most recent content from the source repositories."
    )?

  fun apply(cmd: Command, bundle: Bundle, log: Log) =>
    bundle.fetch()

