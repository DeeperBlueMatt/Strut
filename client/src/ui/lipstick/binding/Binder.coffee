define([],
() ->
	if !$.event.special.destroyed
		$.event.special.destroyed =
	    	remove: (o) ->
	    		if o.handler
	    			o.handler()

	class Bindings
		###
		#	opts {
		#		model: backbone model,
		#		el: element
		#		mapping: binding mapping
		# 	}
		###
		constructor: (opts) ->
			@model = opts.model
			@$el = if opts.el instanceof $ then opts.el else $(opts.el)

			# When $el is removed from the dom, unapply
			# our data bindings
			@$el.bind("destroyed", () =>
				@dispose()
			)

			@_bind(opts.mapping)

		dispose: () ->
			@model.off(null, null, @)

		on: () ->
			# use on for middleware attachment...?

		_bind: (mapping) ->
			for selector, binding of mapping
				$target = @$el.find(selector)
				@_applyBinding($target, binding)

		_applyBinding: ($target, binding) ->
			field = binding.field
			# TODO: special case collections....
			if typeof @model[field] is "function"
				@_bindToComputedProperty($target, binding)
			else
				# TODO: we need to special case backbone collections
				# TODO: what if someone wants to bind to arbitrary events and not fields?
				# What about bindings in the other direction? view to model isntead of model to view
				# should we automatically assume bindings are bi-directional
				# when the view element is an input element?
				console.log "Binding: " + field
				@model.on("change:" + field, (model, value) ->
					$target[binding.fn](value)
				)

		_bindToComputedProperty: ($target, binding) ->
			dependencies = {}
			oldGet = @_replaceGet(dependencies)
			@model[binding.field]()
			@_restoreGet(oldGet)

			fn = (model, value) =>
					$target[binding.fn](@model[binding.field]())

			for field,value of dependencies
				@model.on("change:" + field, fn)

		_replaceGet: (dependencies) ->
			oldGet = @model.get
			@model.get = (key) =>
				result = oldGet.apply(@model, arguments)
				dependencies[key] = true
				result

			oldGet

		_restoreGet: (oldGet) ->
			@model.get = oldGet

)

# Requirements:
# Should be able to use existing tempaltes as much as possible.  Writing new templates is annoying
# Should not require data-bind attributes in code
# Should be able to add "middleware" to intercept bound events...
# Should be similar to backbone "events:" hash

# mapping hash:
###
	"attribute selector": "fieldName"  (where attribute is some jquery func: text, val, css, addClass, removeClass, etc.)
	well what if we want one func on true and another on false.. that is a common use case...

	#alternative:

		"selector": 
			fn: "jQuery fn to apply"  (what about ender and so on?)
			field: "name of model field to observe"
			# optional funcs to apply with certain values
			fn_false:
			fn_missing:
			events: [list of events to bind from view back to model]???

		What about middleware?  Allow that to be passed in through the mapping variable?

	How should / could we handle computed properties?
	How do we know what properties a func will depend on?
		1. We can specify it in the mapping..
		2. We can use wizardry (error prone)
		3. We can run the function and see what "gets" it calls...
		  The gets that are called then obviously make up our computed property
			if the func has side effects then that is a non-starter
			add the stipulation that it can't had side effects?  It is a getter anyway...
###