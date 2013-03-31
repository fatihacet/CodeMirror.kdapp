class CodeMirrorTopBar extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-top-bar editor-header"
    
    super options, data