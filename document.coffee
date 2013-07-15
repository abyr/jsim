Document = (s) ->

  @init = (s) ->
    if s is 'html'
      return document.documentElement
    if s is 'head'
      return document.head
    if s is 'body'
      return document.body

    if s.indexOf ',' is -1
      window.console.log 'single selector', s
      s0 = s[0]
      s = s.substr 1
      if s0 is '#'
        return @byId s
      else if s0 is '.'
        return @byClass s
      else
        return @byTag s0 + s
    @bySelectors s

  @byId = (s) ->
    window.console.log 'by id', s
    document.getElementById s

  @byClass = (s) ->
    window.console.log 'by class', s
    document.getElementsByClassName s

  @byTag = (s) ->
    window.console.log 'by tag', s
    document.getElementsByTagName s

  @bySelectors = (ss) ->
    window.console.log 'by selectors', ss
    selectors = ss.split ","
    list = []
    i = selectors.length - 1
    while i >= 0
      list.push @bySelector selectors[i]
      i--
    list

  @bySelector = (s) ->
    window.console.log 'by selector', s
    s0 = s[0]
    s = s.substr 1
    if s0 is '#'
      @byId s
    else if s0 is '.'
      @byClass s
    else
      false

  @val = (el) ->
    undefined

  @html = (el) ->
    undefined

  @init s

Element::html = (v) ->
  return @.innerHTML unless v
  @.innerHTML = "" + v if v
  undefined

jd = Document
window.jd = jd

window.onload = ->
  window.console.log '=', jd '#target'
