	                __  __                      __    __  __            __
	   ____  ____ _/ /_/ /_  ____ _____        / /_  / /_/ /_____  ____/ /
	  / __ \/ __ `/ __/ __ \/ __ `/ __ \______/ __ \/ __/ __/ __ \/ __  / 
	 / / / / /_/ / /_/ / / / /_/ / / / /_____/ / / / /_/ /_/ /_/ / /_/ /  
	/_/ /_/\__,_/\__/_/ /_/\__,_/_/ /_/     /_/ /_/\__/\__/ .___/\__,_/   
	                                                     /_/              

nathan-httpd exposes a http based [REST-like](http://www.intridea.com/blog/2010/4/29/rest-isnt-what-you-think-it-is) interface to nathan.

__Quick Example__

1.	Create bucket `test`

	```http
	PUT /test/ HTTP/1.0
	```

	```http
	HTTP/1.1 204 No Content
	Location: /test
	Date: <date>
	```
2.	Insert root context for document

	```http
	POST /test/_root HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>
	
	["doc1"]
	```

	```http
	HTTP/1.1 201 Created
	Location: /test/_1
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>
	
	"_1"
	```
3.	Insert paragraphs to document

	```http
	POST /test/_1 HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	[["hello","world"],["foo","bar"]]
	```

	```http
	HTTP/1.1 201 Created
	Location: /test/_1
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	["_3","_5"]
	```

4.	Get keywords of document 1

	```http
	POST /test/_1/keywords HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	[["hello",100,20],["world",99,10],...]
	```

__Todo__

* Add /:bucket/:fetch?handles=<handles> ressource for fetching multiple contexts based on handles
* Evaluate some kind of master-slave synchronization facility to strengthen availability and data safety.
* Add description for analysis response format.
* Discuss more complex query functionality (batch processing, complex selections, association trees, etc.).

__Ressources__

Bellow you find the different ressources the API has and the verbs that can be executed. You are looking at version 1 of the API.

- [/](#)
    - [[GET] List buckets](#get-list-buckets)
- [/:bucket](#bucket)
    - [[POST] Query bucket](#post-query-bucket)
    - [[GET] Download dataspace](#get-download-dataspace)
    - [[PUT] Create or replace dataspace](#put-create-or-replace-dataspace)
    - [[DELETE] Delete dataspace](#delete-delete-dataspace)
- [/:bucket/:handle](#buckethandle)
    - [[POST] Insert context(s)](#post-insert-contexts)
    - [[GET] Fetch Context](#get-fetch-context)
    - [[PUT] Replace context](#put-replace-context)
    - [[DELETE] Remove context](#delete-remove-context)
- [/:bucket/:handle/find](#buckethandlefind)
    - [[POST] Query children](#post-query-children)
- [/:bucket/:handle/keywords](#buckethandlekeywords)
    - [[POST] Query keywords](#post-query-keywords)
- [/:bucket/associations](#bucketassociations)
    - [[POST] Query assocations](#post-query-assocations)
- [/:bucket/phonetic](#bucketphonetic)
    - [[POST] Query phonetic similarities](#post-query-phonetic-similarities)

## /<span id=""></span>

### [GET] List buckets<span id="get-list-buckets"></span>

__Description__

Lists existing buckets.

---

## /:bucket<span id="bucket"></span>

### [POST] Query bucket<span id="post-query-bucket"></span>

__Description__

TBD

---

### [GET] Download dataspace<span id="get-download-dataspace"></span>

__Description__

Download the dataspace at `/:bucket`.

---

### [PUT] Create or replace dataspace<span id="put-create-or-replace-dataspace"></span>

__Description__

Replace the dataspace at `/:bucket`.

---

### [DELETE] Delete dataspace<span id="delete-delete-dataspace"></span>

__Description__

Deletes bucket `/:bucket`.

---

## /:bucket/:handle<span id="buckethandle"></span>

A `handle` uniqly identifies a context in the bucket. It has the form `_HEX`, where HEX is a hexadecimal number. Special handle `_root` identifies the root node of the bucket. 

### [POST] Insert context(s)<span id="post-insert-contexts"></span>

__Description__

Inserts context(s) as children of `/:bucket/_root` or `/:bucket/:handle`.

__Examples__

* Append single root context:
	
	```http
	POST /test/_root HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>
	
	["doc1"]
	```

	```http
	HTTP/1.1 201 Created
	Location: /test/_1
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>
	
	"_1"
	```

* Append single child context:

	```http
	POST /test/2b HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	["hello","world"]
	```

	```http
	HTTP/1.1 201 Created
	Location: /test/_2d
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	"_2d"
	```

* Bulk append child contexts:

	```http
	POST /test/_2b HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	[["hello","world"],[1,2,3,4]]
	```

	```http
	HTTP/1.1 201 Created
	Location: /test/fetch?handles=_2d,_2f
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	["_2d","_2f"]
	```

__Dicussion__

* Add line delimited JSON stream instead of arrays for multi insert (http://en.wikipedia.org/wiki/Line_Delimited_JSON).

	```http
	POST /test/2b HTTP/1.0
	Content-Type: application/x-ldjson
	Content-Length: <length>

	["hello","world"]
	[1,2,3,4]
	```

	```http
	HTTP/1.1 201 Created
	Location: /test/fetch?handles=_2d,_2f
	Date: <date>
	Content-Type: application/x-ldjson
	Content-Length: <length>

	"_2d"
	"_2f"
	```

* Allow insert of more complex contexts (e.g. objects, etc.)

---

### [GET] Fetch Context<span id="get-fetch-context"></span>

__Description__

Fetches context of `/:bucket/:handle`.

__See also__

To bulk fetch multiple context see `/:bucket/fetch`.

__Examples__

* Fetch context `_1c`: 

	```http
	GET /test/_1c HTTP/1.0
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	["foo","bar"]
	```

* Fetch root (returns bucket name): 

	```http
	GET /test/_root HTTP/1.0
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	"test"
	```

---

### [PUT] Replace context<span id="put-replace-context"></span>

__Description__

Replaces context at `/:bucket/:handle`.

__Scope__

Not allowed on `/:bucket/_root`.

__Example__

* Replace context `_2b`:

	```http
	PUT /test/_2b HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	["foo","bar"]
	```

	```http
	HTTP/1.1 204 No Content
	Date: <date>
	```

---

### [DELETE] Remove context<span id="delete-remove-context"></span>

__Description__

Removes context at `/:bucket/:handle`.

__Scope__

Not allowed on `/:bucket/_root`.

__Example__

* Delete context `_2b`:

	```http
	DELETE /test/_2b HTTP/1.0
	```

	```http
	HTTP/1.1 204 No Content
	Date: <date>
	```

---

## /:bucket/:handle/find<span id="buckethandlefind"></span>

Find allows to query child contexts of either the `_root` handle or another context handle.

### [POST] Query children<span id="post-query-children"></span>

__Description__

Queries children contexts of `/:bucket/:handle` or of root `/:bucket`.

__Payload__

_Request_

```js
{								// default values:
								//
	"filter": <query>,			// <query> = undefined
								//
	"take": <num>,				// <num> = 128
								//
	"skip": <num>,				// <num> = 0
								//
	"fetchContext": true|false	// <fetchContext> = false
}
```

_Caption_

*	_filter_ — Filters children by their context, possible queries: `{"$and": ["foo", "bar"]}` (Match all),
	`{"$or": ["foo", "bar"]}` (Match some), `{"$match": ["foo", "bar"]}` (Match exactly).
*	_take_ — Only return `<num>` results. Default is 128.
*	_skip_ — Skip first `<num>` results. Default is 0.
*	_fetchContext_ — enables/disables fetch of child contexts, default is `false`.

__Examples__

* Query all root contexts:

	```http
	POST /test/_root/find HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	["_1", "_3", "_f"]
	```

* Query all children of `_2b`:

	```http
	POST /test/_2b/find HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	["_3a", "_3c", "_12"]
	```

* Query and fetch 10 children of `_2b` where context contains "hello" and "bar":

	```http
	POST /test/_2b/find HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{"filter": {"$and": ["hello", "bar"]}, "take": 10}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	[["foo","hello","bar"],[1,2,"hello",3.14159,"bar"],...]
	```

---

## /:bucket/:handle/keywords<span id="buckethandlekeywords"></span>

Keywords allows to retrieve a sorted list of the most important terms of a context and its subcontexts.

### [POST] Query keywords<span id="post-query-keywords"></span>

__Description__

Retrieves a list of keywords of `/:bucket/:handle`.

__Scope__

Not allowed on `/:bucket/_root`.

__Payload__

_Request_

```js
{								// default values:
								//
	"scope": <handles>,			// <handles> = undefined (all)
								//
	"sort": <order>,			// <order> = [-1,-1]
								//
	"cutoff": <threshold>		// <threshold> = [0,0]
								//
	"take": <num>,				// <num> = 128
								//
	"skip": <num>,				// <num> = 0
}
```

_Caption_

*	_scope_ — Optional. Sets the scope of the command to the specified child <handles> (e.g. [ "_10c", "_2b", "_f4" ]).
*	_sort_ — Optional. Sort result according specified <order>: 1 = ascending, -1 = descending. Order can be set 
	with `[<p>,<v>]` where `<p>` specifies order of vicinity value and `v` specifies order of vicinity value.
	To change order of sort key use `[{"v": <v>},{"p": <p>}]`.
*	_cutoff_ — Optional. Sets <threshold> `[<p>,<v>]` (`<p>` = vicinity cut-off, `v` = plausibility cut-off). Default is [0,0].
*	_take_ — Optional. Only return `<num>` results. Default is 128.
*	_skip_ — Optional. Skip first `<num>` results. Default is 0.

__Examples__

* Query keywords of `_2c` with default parameters:

	```http
	POST /test/_2c/keywords HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	[["hello",100,20],["foo",99,10],...]
	```
	
* Query keywords of `_4c` with scope set to `["_4f", "_5d"]` and cut-off on plaubility set to `10`:

	```http
	POST /test/_4c/keywords HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{"scope":["_4f","_5d"],"cutoff":[10,0]}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	[["hello",100,20],["world",99,10],...]
	```

---

## /:bucket/associations<span id="bucketassociations"></span>

### [POST] Query assocations<span id="post-query-assocations"></span>

__Description__

Finds associations to the search terms. 

__Payload__

_Request_

```js
{								// default values:
								//
	"terms": <quants>			// <quants> required. No default value.
								//
	"direction": <dir>			// <dir> = 0 (forward)
								//
	"scope": <handles>,			// <handles> = undefined (all)
								//
	"sort": <order>,			// <order> = [-1,-1]
								//
	"cutoff": <threshold>		// <threshold> = [0,0]
								//
	"take": <num>,				// <num> = 128
								//
	"skip": <num>,				// <num> = 0
}
```

_Caption_

*	_terms_ - Required. Specifies the search terms, e.g. `["green", "smooth"]`.
*	_direction_ - Optional. Specifies the direction of the associations whereas `0` = `forward` and `1` = `reverse`.
*	_scope_ — Optional. Sets the scope of the command to the specified child <handles> (e.g. [ "_10c", "_2b", "_f4" ]).
*	_sort_ — Optional. Sort result according specified <order>: 1 = ascending, -1 = descending. Order can be set 
	with `[<p>,<v>]` where `<p>` specifies order of vicinity value and `v` specifies order of vicinity value.
	To change order of sort key use `[{"v": <v>},{"p": <p>}]`.
*	_cutoff_ — Optional. Sets <threshold> `[<p>,<v>]` (`<p>` = vicinity cut-off, `v` = plausibility cut-off). Default is [0,0].
*	_take_ — Optional. Only return `<num>` results. Default is 128.
*	_skip_ — Optional. Skip first `<num>` results. Default is 0.

__Example__

* Query associations for `["green", "smooth"]`:

	```http
	POST /test/associations HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{"terms":["green", "smooth"]}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	[["apple",230,44],["green",97,44],...]
	```

---

## /:bucket/phonetic<span id="bucketphonetic"></span>

### [POST] Query phonetic similarities<span id="post-query-phonetic-similarities"></span>

__Description__

Finds similar terms for the search term.

__Payload__

_Request_

```js
{								// default values:
								//
	"term": <quant>				// <quant> required. No default value.
								//
	"scope": <handles>,			// <handles> = undefined (all)
								//
	"sort": <order>,			// <order> = [-1,-1]
								//
	"cutoff": <threshold>		// <threshold> = [0,0]
								//
	"take": <num>,				// <num> = 128
								//
	"skip": <num>,				// <num> = 0
}
```

_Caption_

*	_term_ - Required. Specifies the search term, e.g. `"aple"`.
*	_scope_ — Optional. Sets the scope of the command to the specified child <handles> (e.g. [ "_10c", "_2b", "_ff4" ]).
*	_sort_ — Optional. Sort result according specified <order>: 1 = ascending, -1 = descending. Order can be set 
	with `[<p>,<v>]` where `<p>` specifies order of vicinity value and `v` specifies order of vicinity value.
	To change order of sort key use `[{"v": <v>},{"p": <p>}]`.
*	_cutoff_ — Optional. Sets <threshold> `[<p>,<v>]` (`<p>` = vicinity cut-off, `v` = plausibility cut-off). Default is [0,0].
*	_take_ — Optional. Only return `<num>` results. Default is 128.
*	_skip_ — Optional. Skip first `<num>` results. Default is 0.

__Example__

* Query similar terms for `"aple"` take 5 results:

	```http
	POST /test/phonetic HTTP/1.0
	Content-Type: application/json
	Content-Length: <length>

	{"term":["aple"],"take":5}
	```

	```http
	HTTP/1.1 200 OK
	Date: <date>
	Content-Type: application/json
	Content-Length: <length>

	[["apple",210,66],...]
	```
