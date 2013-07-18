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
  @init s

Element::html = (v) ->
  window.console.log v
  if typeof v is 'undefined'
    return @.innerHTML
  @.innerHTML = "" + v
  undefined

Element::val = ->
  @.value

Element::addClass = (c) ->
  @.className += " " + c + " "
  undefined
Element::removeClass = (c) ->
  r = new RegExp "\s"+c+'\\s?', 'gi'
  @.className = (" " + @.className).replace r, ''
  @.className = @.className.substr 1 if @.className[0] is ' '
  undefined
Element::hasClass = (c) ->
  @.className.split(" ").indexOf(c) isnt -1

Element::show = ->
  @.style.display = ''
Element::hide = ->
  @.style.display = 'none'

NodeList::show = ->
  el.show() for el in @
  undefined
NodeList::hide = ->
  el.hide() for el in @
  undefined

$ = Document
window.$ = $