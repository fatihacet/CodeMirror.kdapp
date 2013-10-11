class CodeMirrorGotoDialog extends KDModalViewWithForms

  constructor: (options = {}, data) ->

    options.cssClass        = "goto"
    options.width           = 180
    options.overlay         = yes
    options.tabs            =
      forms                 :
        Go                  :
          callback          : (form) =>
            [line, char]    = form.line.split ":"
            @getDelegate().editor.getDoc().setCursor
              line          : parseInt(line - 1, 10) or 0
              ch            : parseInt(char - 1, 10) or 0
            @destroy()
          fields            :
            Line            :
              type          : "text"
              name          : "line"
              placeholder   : "Goto line:char"
              tooltip       :
                title       : "To goto line 12 and column 24, type 12:24"
                placement   : "right"
              nextElement   :
                Go          :
                  itemClass : KDButtonView
                  title     : "Go"
                  style     : "modal-clean-gray fl"
                  type      : "submit"

    super options, data

    @on "KDModalViewDestroyed", =>
      @getDelegate().gotoDialog = null
      @getDelegate().editor.focus()

    @modalTabs.forms.Go.focusFirstElement()
