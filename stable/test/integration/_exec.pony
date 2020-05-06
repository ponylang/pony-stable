use "ponytest"
use "files"
use "process"
//use "regex"
use "debug"

actor _Exec
  new create(
    h: TestHelper,
    args: Array[String] val,
    tmp: String,
    notifier: ProcessNotify iso)
  =>
    let stable_bin =
      try
         _env_var(h.env.vars, "STABLE_BIN")?
      else
        h.fail("STABLE_BIN not set")
        h.complete(false)
        return
      end
    try
      let auth = h.env.root as AmbientAuth
      let binPath = FilePath(h.env.root as AmbientAuth, stable_bin)?
      let tmpPath = FilePath(h.env.root as AmbientAuth, tmp)?

      let args' =
        recover val
          let args'' = args.clone()
          ifdef windows then
            args''.unshift(stable_bin)
          else
            args''.unshift("stable")
          end
          args''
        end

      let pm = ProcessMonitor(auth, auth, consume notifier, binPath,
        args', recover Array[String] end, tmpPath)
      pm.done_writing()
      h.dispose_when_done(pm)
    else
      h.fail("Could not run stable!")
      h.complete(false)
    end

  fun _env_var(vars: Array[String] val, key: String): String ? =>
    for v in vars.values() do
      if v.contains(key) then
        return v.substring(
          ISize.from[USize](key.size()) + 1,
          ISize.from[USize](v.size()))
      end
    end

    error

class _ExpectClient is ProcessNotify
  let _h: TestHelper
  let _out: Array[String] val
  let _err: Array[String] val
  let _code: I32

  var _status: Bool = true
  var _stdout: String = ""
  var _stderr: String = ""

  new iso create(
    h: TestHelper,
    stdout': (Array[String] val | None),
    stderr': (Array[String] val | None),
    code': I32)
  =>
    _h = h
    _out =
      match stdout'
      | None => []
      | let a: Array[String] val => a
      end
    _err =
      match stderr'
      | None => []
      | let a: Array[String] val => a
      end
    _code = code'

  fun ref stdout(process: ProcessMonitor ref, data: Array[U8] iso) =>
    _stdout = _stdout.add(String.from_array(consume data))

  fun ref stderr(process: ProcessMonitor ref, data: Array[U8] iso) =>
    _stderr = _stderr.add(String.from_array(consume data))

  fun ref failed(process: ProcessMonitor ref, err: ProcessError) =>
    _h.fail(err.string())
    _h.complete(false)

    Debug.out("STDOUT:")
    Debug.out(_stdout)
    Debug.out("")
    Debug.out("STDERR:")
    Debug.out(_stderr)

  fun ref dispose(process: ProcessMonitor ref, child_exit_code: I32) =>
    let code: I32 = consume child_exit_code
    _status = _status and _h.assert_eq[I32](_code, code)
    //_match_expectations("stdout", _out, _stdout)
    //_match_expectations("stderr", _err, _stderr)
    _h.complete(_status)

    Debug.out("STDOUT:")
    Debug.out(_stdout)
    Debug.out("")
    Debug.out("STDERR:")
    Debug.out(_stderr)

  /*fun ref _match_expectations(
    stream: String,
    exps: Array[String] val,
    output: String)
  =>
    for exp in exps.values() do
      try
        let r = Regex(exp)?
        _status = _status and _h.assert_no_error({ ()? => r(output)? },
          stream + " match RE: " + exp)
        _h.log(stream + " was: " + output)
      else
        _h.fail(stream + " regexp failed to compile")
        _status = false
      end
    end*/
