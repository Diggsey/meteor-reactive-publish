override = (obj, dict) ->
	result = {}

	for key of dict
		do (key) ->
			impl = dict[key]
			
			oldImpl = obj[key]
			obj[key] = impl

			result[key] = (args2...) -> oldImpl.call(args2...)
	
	result

Cursor = Object.getPrototypeOf(Meteor.users.find {_id: null}).constructor
parent = override Cursor.prototype,
	observeChanges: (callbacks) ->
		handle = parent.observeChanges(@, callbacks)
		if Deps.active and @._cursorDescription.options.reactive
			Deps.onInvalidate ->
				handle.stop()
		handle
		
	_depend: (changers) ->
		if Deps.active
			v = new Deps.Dependency
			v.depend()
			ready = false
			
			notifyChange = Meteor.bindEnvironment ->
				if ready
					v.changed()

			options = {}
			_.each ['added', 'changed', 'removed', 'addedBefore', 'movedBefore'], (fnName) =>
				if changers[fnName]
					options[fnName] = notifyChange

			@observeChanges(options)
			
			ready = true

	forEach: (args...) ->
		if @._cursorDescription.options.reactive
			@._depend {added: true, changed: true, removed: true}
		parent.forEach @, args...
		
	map: (args...) ->
		if @._cursorDescription.options.reactive
			@._depend {added: true, changed: true, removed: true}
		parent.map @, args...
		
	fetch: (args...) ->
		if @._cursorDescription.options.reactive
			@._depend {added: true, changed: true, removed: true}
		parent.fetch @, args...
		
	count: (args...) ->
		if @._cursorDescription.options.reactive
			@._depend {added: true, removed: true}
		parent.count @, args...
		
Meteor.reactivePublish = (name, f) ->
	Meteor.publish name, ->
		oldRecords = {}
		depends = []
		isPublishing = false
		
		handle = Deps.autorun =>
			newRecords = {}
			
			addCursor = (cursor) =>
				if cursor
					collectionName = cursor._cursorDescription.collectionName
				
					record =
						cursor: cursor
						ids: {}
					
					newRecords[collectionName] = record
					oldRecord = oldRecords[collectionName] ? {ids: {}}
					
					cursor.observeChanges
						added: (id, fields) =>
							if id of oldRecord.ids
								delete oldRecord.ids[id]
							else
								record.ids[id] = true
								@added(collectionName, id, fields)
								
						removed: (id) =>
							delete record.ids[id]
							@removed(collectionName, id)
							
						changed: (id, fields) =>
							@changed(collectionName, id, fields)
			
			result = f.call(@)
			
			if _.isArray(result)
				for cursor in result
					addCursor cursor
			else
				addCursor result
			
			for collectionName, record of oldRecords
				for id of record.ids
					@removed(collectionName, id)
				record.ids = {}
			
			oldRecords = newRecords
			
		@onStop =>
			handle.stop()
		
		@ready()
		return
		