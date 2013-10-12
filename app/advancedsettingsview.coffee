class CodeMirrorAdvancedSettingsView extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "editor-advanced-settings-menu"
    
    super options, data
    
    editor = @getDelegate()
    
    @lineNumbers     = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "lineNumbers"    , state
      
    @useWordWrap     = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "useWordWrap"    , state
      
    @highlightLine   = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "highlightLine"  , state
      
    @highlightWord   = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "highlightWord"  , state
      
    @scrollPastEnd   = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "scrollPastEnd"  , state
      
    @keyboardHandler = new KDSelectBox
      selectOptions  : __aceSettings.keyboardHandlers
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "keyboardHandler", value
      
    @ruler           = new KDMultipleChoice
      labels         : CodeMirrorSettings.rulers
      defaultValue   : [ 80 ]
      multiple       : yes
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "ruler"           , value
      
    @layout          = new KDSelectBox
      selectOptions  : CodeMirrorSettings.layouts
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "layout"          , value
    
    @syntax          = new KDSelectBox
      selectOptions  : CodeMirrorSettings.syntaxMap
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "syntax"          , value
      
    @theme           = new KDSelectBox
      selectOptions  : CodeMirrorSettings.themes
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "theme"           , value
      
    @fontSize        = new KDSelectBox
      selectOptions  : __aceSettings.fontSizes
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "fontSize"        , value
      
    @tabSize         = new KDSelectBox
      selectOptions  : __aceSettings.tabSizes
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "tabSize"         , value
      
  setDefaults: ->
  
  viewAppended: ->
    super
    @setDefaults()
  
  pistachio:->
    """
    <div class="ace-settings-view codemirror">
        <p>Line numbers             {{> @lineNumbers}}</p>
        <p>Use word wrapping        {{> @useWordWrap}}</p>
        <p>Highlight active line    {{> @highlightLine}}</p>
        <p>Highlight selected word  {{> @highlightWord}}</p>
        <p>Use scroll past end      {{> @scrollPastEnd}}</p>
        <p>Ruler                    {{> @ruler}}</p>
        <hr>
        <p>Layout                   {{> @layout}}</p>
        <p>Syntax                   {{> @syntax}}</p>
        <p>Theme                    {{> @theme}}</p>
        <p>Key binding              {{> @keyboardHandler}}</p>
        <p>Font size                {{> @fontSize}}</p>
        <p>Tab size                 {{> @tabSize}}</p>
      </div>
    """
