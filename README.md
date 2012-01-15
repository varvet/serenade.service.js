# Serenade.Service.js

## NOTE: This project is a work in progress and does not currently work.

[Serenade.js](https://github.com/elabs/serenade.js) is a client side MVC framework.
This library provides an extension to Serenade.js to facilitate mapping model
objects to server resources. You can inherit from Serenade.Service like this:

``` coffeescript
class Person extends Person.Service
```

``` javascript
var Person = Person.Service.extend('Person');
```

In most regards it works the same as `Serenade.Model` aside from the fact
that you can specify a storage location and retrieve data from this location
via AJAX calls.

## Mapping models to server resources

In order to be able to retrieve and store objects from the server store, you
will need to call the store function on the constructor function:

``` coffeescripPerson
Person.store url: '/people'
```

There are two main ways of retrieving objects from the server, through `find`
and through `all`.

## Find

`find` takes and id and returns a single document, if the document has been
previously cached in memory, that in memory document is returned. If the
document has not been cached in memory, a new record with the given id is
returned immediately.

This is important to understand, `Serenade.Serenade` does not take a callback,
instead it returns something akin to a future or promise, an object with no
data. Once this document is instantiated, an AJAX request is dispatched to the
server immediately. As soon as the AJAX request is completed, the document is
updated with the properties retrieved from the server and a change event is
triggered. If the model has been previously bound to a view, these new
properties are now reflected in the view. This architecture allows you to treat
`find` as though it were a synchronous operation, returning an object
immediately, and then immediately binding that object to a view. As soon as the
data is ready, that data will be shown in the view.

``` coffeescript
john = Person.find(1)
Serenade.render('person', john)
```

You might still want to indicate to the user that the data is currently
unavailable, this can be done through the special `loadState` property on
documents. This property can be one of `ready` when the document is ready and
loaded or `loading` while it is retrieving data from the server. You can
observe changes to the `loadState` property by listening to the
`change:loadState` event, just as you would with any other property. If a view
binds to `loadState`, changes to it are of course reflected in the view
automatically. A convenient use case for this might be to bind the `class`
attribute of an element to the `loadState` property, to indicate if there is
activity:

``` slim
div[id="person" class=loadState]
  h1 name
```

``` css
#person.loading {
  opacity: 0.5;
  background: url('spinner.gif');
}
```

You can manually trigger a refresh of the data in the document by calling the
`refresh` function. This will cause the `loadState` to change back to
`loading`.

## URL

The URL for retrieving the data for a single document is taken from the first
parameter sent to the `store` declaration, joined with the document id. So if
we have declare this:

``` coffeescript
Person.store url: '/people'
```

Then the URL for a document with id `1` would be `/people/1`. This follows
conventions used by many popular server side frameworks, such as Ruby on Rails.
The response is expected to have a status of 200 or 201 and contain a body with
well-formatted JSON.

## Errors

If the response status is any value in the 1XX, 4XX or 5XX ranges, `loadStatus`
is changed to `error`. Additionally, the global `ajaxError` event is triggered.
You can bind to this event to inform the user in any way you choose is
appropriate.

The event receives the document causing the error, the status code of the
response and the parsed response body as arguments.

``` coffeescript
Serenade.Service.bind 'ajaxError', (document, status, response) ->
  MyFancyModalPlugin.showModal("This didn't go so well")
```

## All

The `all` function allows a collection of objects to be fetched from the
backend storage. Just like `find`, it is synchronous and returns an empty
collection immediately. When the request finishes, the collection is filled and
any views it is bound to will update automatically and show the retrieved
objects.

## Save

Serenade.js can also save objects back to the backend store, it will use the same
URL, only it will issue a POST request, with the given data. As established by
popular convention, it will set the `_method` parameter to `PUT`, thus
frameworks such as Ruby on Rails will see it as a `PUT` request.

`Serenade.Service` uses the same mechanism for serialization as `Serenade.Model`,
check the section on serialization in the Serenade README.

The `save` function will persist documents to the server. This function
is asynchronous, and while it is saving, the magic `saveState` property will
transition from `new` or `saved` depending on whether the record has previously
been saved, to `saving`. You can listen to changes on `change:saveState` to
trigger behaviour as the save state changes.

`update` is a higher level function which will set the given properties, as
well as call the save function.

## Configuring refresh

If you do not provide a URL to your model by calling `store`, no communication
with the server will occur. `save` and `refresh` will do nothing. If you do
call the `store` function, you can declare when a refresh should occur:

``` coffeescript
Post.store url: '/posts', refresh: 'always'
```

The possible values for `refresh` are `always`, `never`, `stale` and `new`. The
`never` option is simple: `refresh` is never triggered automatically. Likewise
the `always` means that a refresh is always triggered after a call to `find` or
`all`, no matter where the result came from previously. `new` will only trigger
a refresh on a cache miss, that is if the document or collection has not
previously been retrieved

In order to understand the `stale` option, we need to take a look at
configuring the cache duration for models first. You can specify a cache
duration by specifying the `expires` option with a time interval in
milliseonds. For example, to cache posts for five minutes, you could do this:

``` coffeescript
Post.store url: '/posts', refresh: 'stale', expires: 300000
```

The `stale` option then only triggers a refresh if more time than the cache
duration has passed. Since these two options work together, you should always
specify both.

## HTML5 Local Storage

Just like `Serenade.Model` documents, `Serenade.Service` documents can be
locally cached in HTML5 local storage, see the section in the Serenade README.

Collections returned by `all` are also cached in local storage in
`Serenade.Service`.  Unlike indicidual documents, these collections are always
cached immediately when they are retrieved. Only the ids of the items in the
collection are cached.

Document or collections cached in HTML5 local storage are affected by the
`refresh` option in just the same was as those cached in memory.
