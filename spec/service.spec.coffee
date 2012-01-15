{Serenade} = require '../src/serenade'
{AjaxCollection} = require '../src/ajax_collection'

expired = ->
  now = new Date()
  new Date(now.getTime() - 20000)
fresh = ->
  now = new Date()
  new Date(now.getTime() + 20000)

describe 'Serenade.Service', ->
  describe '.find', ->
    beforeEach -> spyOn(Serenade.Service.prototype, 'refresh')
    it 'creates a new blank object with the given id', ->
      document = Serenade.Service.find('j123')
      expect(document.get('id')).toEqual('j123')
    it 'returns the same object if it has previously been initialized', ->
      john1 = new Serenade.Service(id: 'j123', name: 'John')
      john1.test = true
      john2 = Serenade.Service.find('j123')
      expect(john2.test).toBeTruthy()
      expect(john2.get('name')).toEqual('John')
    context 'with refresh:always', ->
      beforeEach -> Serenade.Service.store expiration: 200000, refresh: 'always'
      it 'triggers a refresh on cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Service.find('j123')
        expect(document.refresh).toHaveBeenCalled()
      it 'triggers a refresh on stale cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Service.find('j123')
        expect(document.refresh).toHaveBeenCalled()
      it 'triggers a refresh on cache miss', ->
        document = Serenade.Service.find('j123')
        expect(document.refresh).toHaveBeenCalled()
    context 'with refresh:stale', ->
      beforeEach -> Serenade.Service.store expiration: 200000, refresh: 'stale'
      it 'does not trigger a refresh on cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Service.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'triggers a refresh on stale cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Service.find('j123')
        expect(document.refresh).toHaveBeenCalled()
      it 'triggers a refresh on cache miss', ->
        document = Serenade.Service.find('j123')
        expect(document.refresh).toHaveBeenCalled()
    context 'with refresh:new', ->
      beforeEach -> Serenade.Service.store expiration: 200000, refresh: 'new'
      it 'does not trigger a refresh on cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Service.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'does not trigger a refresh on stale cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Service.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'triggers a refresh on cache miss', ->
        document = Serenade.Service.find('j123')
        expect(document.refresh).toHaveBeenCalled()
    context 'with refresh:never', ->
      beforeEach -> Serenade.Service.store expiration: 200000, refresh: 'never'
      it 'does not trigger a refresh on cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: fresh())
        document = Serenade.Service.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'does not trigger a refresh on stale cache hit', ->
        new Serenade.Service(id: 'j123', name: 'John', expires: expired())
        document = Serenade.Service.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()
      it 'does not trigger a refresh on cache miss', ->
        document = Serenade.Service.find('j123')
        expect(document.refresh).not.toHaveBeenCalled()

  describe '.all', ->
    beforeEach -> @sinon.spy(AjaxCollection.prototype, 'refresh')
    beforeEach -> @clock = @sinon.useFakeTimers()
    it 'create a new blank collection', ->
      Serenade.Service.store url: '/models'
      collection = Serenade.Service.all()
      expect(collection.url).toEqual('/models')
      expect(collection.constructor).toEqual(Serenade.Service)

    it 'returns the same collection if it has been used previously', ->
      Serenade.Service.store url: '/models'
      collection1 = Serenade.Service.all()
      collection1.test = true
      collection2 = Serenade.Service.all()
      expect(collection2.test).toBeTruthy()

    context 'with refresh:always', ->
      beforeEach -> Serenade.Service.store url: '/models', refresh: 'always', expires: 20000
      it 'triggers a refresh on cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(1200)
        collection = Serenade.Service.all()
        expect(collection.refresh.calledTwice).toBeTruthy()
      it 'triggers a refresh on stale cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(120000)
        collection = Serenade.Service.all()
        expect(collection.refresh.calledTwice).toBeTruthy()
      it 'triggers a refresh on cache miss', ->
        collection = Serenade.Service.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
    context 'with refresh:stale', ->
      beforeEach -> Serenade.Service.store url: '/models', refresh: 'stale', expires: 20000
      it 'does not trigger a refresh on cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(1200)
        collection = Serenade.Service.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
      it 'triggers a refresh on stale cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(120000)
        collection = Serenade.Service.all()
        expect(collection.refresh.calledTwice).toBeTruthy()
      it 'triggers a refresh on cache miss', ->
        collection = Serenade.Service.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
    context 'with refresh:new', ->
      beforeEach -> Serenade.Service.store url: '/models', refresh: 'new', expires: 20000
      it 'does not trigger a refresh on cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(1200)
        collection = Serenade.Service.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
      it 'does not trigger a refresh on stale cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(120000)
        collection = Serenade.Service.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
      it 'triggers a refresh on cache miss', ->
        collection = Serenade.Service.all()
        expect(collection.refresh.calledOnce).toBeTruthy()
    context 'with refresh:never', ->
      beforeEach -> Serenade.Service.store url: '/models', refresh: 'never', expires: 20000
      it 'does not trigger a refresh on cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(1200)
        collection = Serenade.Service.all()
        expect(collection.refresh.called).toBeFalsy()
      it 'does not trigger a refresh on stale cache hit', ->
        collection = Serenade.Service.all()
        @clock.tick(120000)
        collection = Serenade.Service.all()
        expect(collection.refresh.called).toBeFalsy()
      it 'does not trigger a refresh on cache miss', ->
        collection = Serenade.Service.all()
        expect(collection.refresh.called).toBeFalsy()

  describe '#refresh()', ->
    it 'sets the load state to "loading"', ->
    it 'does nothing when triggered while already loading', ->
    it 'does nothing when no url is specified for store', ->
    it 'resets the expiration time', ->
    context 'with successful response', ->
      it 'sets the load state to "ready"', ->
      it 'updates the object with the given properties', ->
    context 'with server error', ->
      it 'sets the load state to "error"', ->
      it 'dispatches a global ajaxError event', ->
    context 'with timeout', ->
      it 'sets the load state to "error"', ->
      it 'dispatches a global ajaxError event', ->

  describe '#save()', ->
    it 'takes the serialized document and sends it to the server', ->
    it 'uses a POST request if the document is new', ->
    it 'uses a PUT request (via _method hack) if the document is saved', ->
    it 'sets save state to "saving"', ->
    it 'enqueues request if already saving', ->
    it 'does nothing when no url is specified for store', ->
    context 'with successful response', ->
      it 'sets the load state to "saved"', ->
      it 'updates the object with the given properties', ->
      it 'resets the expiration time if properties given', ->
      it 'does nothing when the response body is blank', ->
    context 'with server error', ->
      it 'sets the save state to "error"', ->
      it 'dispatches a global ajaxError event', ->
    context 'with timeout', ->
      it 'sets the save state to "error"', ->
      it 'dispatches a global ajaxError event', ->
