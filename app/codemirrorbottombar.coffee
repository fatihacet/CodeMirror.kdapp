class CodeMirrorBottomBar extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-bottom-bar editor-bottom-bar clearfix"
    
    super options, data
    
    @caretPos = new KDView
      cssClass: "codemirror-caret-pos caret-position section"
      partial : "1:1"
      
  updateCaretPos: (posObj) ->
    @caretPos.updatePartial "#{posObj.line + 1}:#{posObj.ch + 1}"
  
  pistachio: -> """
    {{> @caretPos}}
  """