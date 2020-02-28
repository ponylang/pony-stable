use "files"

actor _CleanTmp
  let _fp: FilePath
  new create(fp: FilePath) =>
    _fp = fp

  be dispose() =>
    _fp.remove()
