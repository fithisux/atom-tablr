{View} = require 'atom'
{CompositeDisposable} = require 'event-kit'
React = require 'react-atom-fork'
TableComponent = require './table-component'

module.exports =
class TableView extends View
  @content: ->
    @div class: 'table-edit', =>
      @table outlet: 'tableHeaderView', class: 'table-edit-header'
      @div outlet: 'scrollView', class: 'scroll-view', =>
        @div outlet: 'tableNode', class: 'table'

  initialize: (@table) ->
    @subscriptions = new CompositeDisposable
    @scroll = 0

    props = {@table, parentView: this}
    @component = React.renderComponent(TableComponent(props), @tableNode[0])

    @subscriptions.add @table.onDidChangeRows @requestUpdate

  destroy: ->
    @subscriptions.dispose()
    @remove()

  getRowHeight: -> @rowHeight

  setRowHeight: (@rowHeight) ->
    @component.setState rowHeight: @getRowHeight()

  getRowOverdraw: -> @rowOverdraw or 0

  setRowOverdraw: (@rowOverdraw) -> @requestUpdate()

  getFirstVisibleRow: ->
    row = Math.floor(@scrollView.scrollTop() / @getRowHeight())

  getLastVisibleRow: ->
    scrollViewHeight = @scrollView.height()

    row = Math.floor((@scrollView.scrollTop() + scrollViewHeight) / @getRowHeight())

  scrollTop: (scroll) ->
    if scroll?
      @scrollView.scrollTop(scroll)
      @requestUpdate()

    @scrollView.scrollTop()

  requestUpdate: =>
    return if @updateRequested

    @updateRequested = true
    requestAnimationFrame =>
      @update()
      @updateRequested = false

  update: =>
    firstVisibleRow = @getFirstVisibleRow()
    lastVisibleRow = @getLastVisibleRow()

    return if firstVisibleRow >= @firstRenderedRow and lastVisibleRow <= @lastRenderedRow

    firstRow = Math.max 0, firstVisibleRow - @rowOverdraw
    lastRow = Math.min @table.getRowsCount(), lastVisibleRow + @rowOverdraw

    @component.setState {
      firstRow
      lastRow
      totalRows: @table.getRowsCount()
    }

    @firstRenderedRow = firstRow
    @lastRenderedRow = lastRow