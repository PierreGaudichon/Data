_ = require "lodash"

class Type

	constructor: () ->
		@actions = _ Array.prototype.slice.call arguments
			.flatten true
			.pluck "actions"
			.flatten true
			.value()

	test: (fn) ->
		@actions.push {type: "test", action: fn}
		@

	format: (fn) ->
		@actions.push {type: "format", action: fn}
		@

	with: (value) ->
		valid = true
		i = 0
		while valid and (i < @actions.length)
			{action, type} = @actions[i++]
			try switch type
				when "test" then valid = action(value, valid) ? true
				when "format" then value = action(value, valid) ? value
			catch
				valid = false
		return {value: (if valid then value), valid}



	default: (def) -> @format (value, valid) ->
		if (not valid) or (not value?) then def else value

	min: (m) -> @test (n) -> n > m

	max: (m) -> @test (n) -> n < m

	odd: -> @test (n) -> n%2 == 1

	even: -> @test (n) -> n%2 == 0

	every: (fn) -> @test (coll) ->
		_.every coll, fn

	only: () ->
		types = _.flatten Array.prototype.slice.call arguments
		@every (el) ->
			return true if types.length is 0
			_.any types, (type) ->
				type.with(el).valid

	object: (ref) -> @test (obj) ->
		return true if _.isEqual ref, {}
		return false unless _.isEqual Object.keys(obj), Object.keys(ref)
		_.every ref, (type, key) ->
			obj[key]? and type.with(obj[key]).valid

	length: (l) -> @test (v) -> v.length is l if l?



module.exports = Data =

	Type: () ->
		new Type arguments

	Json: -> Data.Type().format (v) ->
		if _.isString v
			try
				JSON.parse(v)
			catch
				v
		else
			v

	Float: ->
		Data.Json()
			.test _.isNumber

	Integer: ->
		Data.Float()
			.test (v) -> v is Math.floor v

	Boolean: ->
		Data.Json()
			.test _.isBoolean

	Hash: (ref = {}) ->
		Data.Json()
			.test _.isPlainObject
			.object ref

	Array: () ->
		Data.Json()
			.test _.isArray
			.only arguments

	String: (l) ->
		Data.Test()
			.length l

	Any: ->
		Type()




