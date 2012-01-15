{Serenade} = require './serenade'
{AjaxCollection} = require './ajax_collection'
{Events} = require './events'
{extend, get} = require './helpers'

class Serenade.Model extends Serenade.Model
  @store: (options) ->
    @_storeOptions = options

  @find: (id) ->
    if document = @_getFromCache(id)
      document.refresh() if @_storeOptions?.refresh in ['always']
      document.refresh() if @_storeOptions?.refresh in ['stale'] and document.isStale()
    else
      document = new this(id: id)
      document.refresh() if @_storeOptions?.refresh in ['always', 'stale', 'new']
    document

  @all: ->
    if @_all
      @_all.refresh() if @_storeOptions?.refresh in ['always']
      @_all.refresh() if @_storeOptions?.refresh in ['stale'] and @_all.isStale()
    else
      @_all = new AjaxCollection(this, @_storeOptions.url)
      @_all.refresh() if @_storeOptions?.refresh in ['always', 'stale', 'new']
    @_all

  refresh: ->
  save: ->

  isStale: ->
    @get('expires') < new Date()
