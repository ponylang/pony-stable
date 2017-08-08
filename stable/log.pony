
interface tag Log
  fun tag apply(s: String) => None

primitive LogNone is Log

actor LogSimple is Log
  let out: OutStream

  new create(out': OutStream) =>
    out = out'

  be apply(s: String) =>
    out.print(s)
