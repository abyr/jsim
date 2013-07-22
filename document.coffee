Document = (s) ->

  return document if not s or s is document

  if typeof s is 'function'
    document.ready s
    return undefined

  @init = (s) ->

    return s if s is document

    if s is 'html'
      return document.documentElement
    if s is 'head'
      return document.head
    if s is 'body'
      return document.body

    if s.indexOf ',' is -1
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
    document.getElementById s

  @byClass = (s) ->
    document.getElementsByClassName s

  @byTag = (s) ->
    document.getElementsByTagName s

  @bySelectors = (ss) ->
    selectors = ss.split ","
    list = []
    i = selectors.length - 1
    while i >= 0
      list.push @bySelector selectors[i]
      i--
    list

  @bySelector = (s) ->
    s0 = s[0]
    s = s.substr 1
    if s0 is '#'
      @byId s
    else if s0 is '.'
      @byClass s
    else
      false
  @init s

HTMLDocument::ready = (f) ->
  document.onreadystatechange = ->
    f() if document.readyState is "complete"

Element::html = (v) ->
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

Element::css = (k, v) ->
  k = k.toCamelCase()
  @.style[k] = v if @.style.hasOwnProperty k
  undefined
NodeList::css = (k, v) ->
  k = k.toCamelCase()
  for el in @
    el.style[k] = v if el.style.hasOwnProperty k
  undefined

String::toCamelCase = ->
  @.toLowerCase().replace /-(.)/g, (m, g) ->
    g.toUpperCase()

Element::on = (evt, callback) ->
  @addEventListener evt, callback
  undefined

$ = Document
window.$ = $
