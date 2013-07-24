$(document).ready ->
  $("#hidden").on 'click', ->
    window.console.log "by on"
  $("#hidden2").click ->
    window.console.log "by click"

  $(".ini").on 'click', ->
    window.console.log 'by on class'
