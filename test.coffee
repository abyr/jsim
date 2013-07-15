Test =
  time: (fn) ->
    start = +new Date()
    fn()
    end = +new Date()
    end - start
