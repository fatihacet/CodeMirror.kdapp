class ApplicationTabView extends KDTabView
  
  constructor: (options = {}, data) ->

    options.resizeTabHandles    = yes
    options.lastTabHandleMargin = 40

    super options, data

    appView = @getDelegate()

    @on "PaneRemoved", =>
      @tabHandleContainer.repositionPlusHandle @handles

    @on 'PaneAdded', => @tabHandleContainer.repositionPlusHandle @handles