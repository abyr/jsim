Document = (s) ->

  return document if not s or s is document

  if typeof s is 'function'
    document.ready s
    undefined

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
    selectors = ss.split(",")
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
  return @.innerHTML unless v
  @.innerHTML = "" + v
  @

Element::val = (v) ->
  return @.value unless v
  @.value = v
  @

Element::attr = (k, v) ->
  return @getAttribute(k) unless v
  @setAttribute k, v
  this

Element::clear = ->
  @.firstChild.remove() while @.firstChild
  @

NodeList::clear = ->
  el.clear() for el in @
  @

Element::addClass = (c) ->
  @.className += " " + c + " "
  @
NodeList::addClass = (c) ->
  el.addClass() for el in @
  @

Element::removeClass = (c) ->
  r = new RegExp "\\s"+c+'\\s?', 'gi'
  @.className = (" " + @.className).replace r, ''
  @.className = @.className.substr 1 if @.className[0] is ' '
  @
NodeList::removeClass = (c) ->
  i = @length - 1
  while i >= 0
    el = this[i]
    el.removeClass c
    i--
  @

Element::hasClass = (c) ->
  @.className.split(" ").indexOf(c) isnt -1

Element::show = ->
  @.style.display = ''
NodeList::show = ->
  el.show() for el in @
  @

Element::hide = ->
  @.style.display = 'none'
NodeList::hide = ->
  el.hide() for el in @
  @

Element::css = (k, v) ->
  return @.style unless k
  return @.style[k] if @.style.hasOwnProperty k unless v
  k = k.toCamelCase()
  @.style[k] = v if @.style.hasOwnProperty k
  @

NodeList::css = (k, v) ->
  return undefined unless v
  k = k.toCamelCase()
  for el in @
    el.css k, v
  @

String::toCamelCase = ->
  @.toLowerCase().replace /-(.)/g, (m, g) ->
    g.toUpperCase()

Element::on = (evt, callback) ->
  @addEventListener evt, callback
  @
NodeList::on = (evt, callback) ->
  el.addEventListener evt, callback for el in @
  @

$ = Document
window.$ = $
