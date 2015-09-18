_ = require "lodash"
betterAssert = require "better-assert"
{Type, Json, Float, Integer, Boolean, Hash, Array, String, Any} = require "../src/Data"

assert = (a, b) -> betterAssert _.isEqual a, b
vv = (valid, value) -> {valid, value}
foo = -> "foo"
bar = -> "bar"




describe "class Type", ->


	describe "#constructor", ->
		it "should takes some arguments and put them in actions.", ->
			act = {type: "test", action: foo}
			type = Type().test foo
			assert [], Type().actions
			assert [act], Type(type).actions
			assert [act, act], Type([type], type).actions


	describe "#test", ->

		it "should only add a test", ->
			type = Type()
				.test foo
				.test bar
			ret = [{type: "test", action: foo}, {type: "test", action: bar}]
			assert ret, type.actions


	describe "#format", ->

		it "should only add a format", ->
			type = Type()
				.format foo
				.format bar
			ret = [{type: "format", action: foo}, {type: "format", action: bar}]
			assert ret, type.actions


	describe "#with", ->

		it "shoudn't throw errors", ->
			action = -> throw new Error "whatever"
			assert vv(false, undefined), Type().format(action).with(0)

		it "should do nothing on empty test", ->
			assert vv(true, 0), Type().with(0)
			assert vv(true, undefined), Type().with()


		it "should execute all formats", ->
			type = Type()
				.format (x) -> x+5
				.format (x) -> x*2
			assert vv(true, 10), type.with(0)
			assert vv(true, 12), type.with(1)

		it "should execute every test", ->
			type = Type()
				.test (a) -> a.length is 1
				.test (a) -> a[0] is 0
			assert vv(true, [0]), type.with([0])
			assert vv(false, undefined), type.with([])
			assert vv(false, undefined), type.with([1])


	describe "#default", ->

		it "should always return {valid: true}", ->
			assert vv(true, 0), Type().default(0).with(0)
			assert vv(true, 1), Type().default(1).with()

		it "shouldn't set if the value if valid", ->
			assert vv(true, 0), Type().default(1).with(0)


	describe "#min", ->

		it "should verify if is more than", ->
			assert vv(false, undefined), Type().min(0).with(-1)
			assert vv(true, 1), Type().min(0).with(1)


	describe "#every", ->

		it "should test every element in the collection against the predicate", ->
			assert vv(true, [0]), Type().every((el) -> el is 0).with([0])
			assert vv(true, 0), Type().every((el) -> el is 0).with(0)
			assert vv(true, {a: 0}), Type().every((el) -> el is 0).with(a: 0)
			assert vv(false, undefined), Type().every((el) -> el is 0).with([12])


	describe "#only", ->

		it "should be always right when no type is provided", ->
			assert vv(true, [0]), Type().only().with([0])

		it "should test that every element is of the right type", ->
			assert vv(true, [0]), Type().only(Type()).with([0])
			assert vv(true, [1]), Type().only(Type().min(0)).with([1])
			assert vv(false, undefined), Type().only(Type().min(0)).with([-1, 1])
			assert vv(true, 0), Type().only(Type()).with(0)


	describe "#object", ->

		it "should test if the rbj and the ref have the same keys", ->
			type = Type().object a: Type()
			obj = {a: 0}
			assert vv(true, obj), type.with(obj)
			assert vv(false, undefined), type.with({b: 0})

		it "should test if the object match the reference", ->
			type = Type().object
				a: Type().min 0
				b: Type().min 1
			obj = {a: 1, b: 2}
			obj2 = {a: 0, b: 0}
			assert vv(true, obj), type.with(obj)
			assert vv(false, undefined), type.with(obj2)


	describe "#length", ->

		it "should test the length", ->
			assert vv(true, "a"), Type().length(1).with("a")
			assert vv(false), Type().length(2).with("a")



describe "module.exports", ->


	describe "Json", ->

		it "should give the value back when it is not a string", ->
			assert vv(true, 0), Json().with(0)

		it "should JSON.parse the value", ->
			assert vv(true, 0), Json().with("0")
			assert vv(true, [0, 1]), Json().with("[0, 1]")

		it "should assume the value is valid when not valid JSON", ->
			assert vv(true, "foo"), Json().with("foo")


	describe "Float", ->

		it "should let only JS Numbers pass", ->
			assert vv(true, 0), Float().with(0)
			assert vv(true, 0), Float().with("0")
			assert vv(false), Float().with("foo")


	describe "Integer", ->

		it "should let only Integer (Z) pass", ->
			assert vv(true, 0), Integer().with(0)
			assert vv(false), Integer().with(1.2)


	describe "Boolean", ->

		it "should let only Boolean pass", ->
			assert vv(true, true), Boolean().with("true")
			assert vv(false), Boolean().with(0)


	describe "Hash", ->

		it "should let only plain objects pass", ->
			assert vv(true, {a: 0}), Hash().with(a: 0)

		it "should test the validity of values inside the plain object", ->
			assert vv(true, {a: 0}), Hash(a: Integer()).with(a: 0)
			assert vv(false), Hash(a: Integer()).with(0)
			assert vv(false), Hash(a: Integer()).with(b: 0)


	describe "Array", ->

		it "should only test if is an array when no arguments", ->
			assert vv(true, []), Array().with([])
			assert vv(true, [0]), Array().with([0])

		it "should test the type inside the array", ->
			assert vv(true, [0]), Array(Integer()).with([0])
			assert vv(true, [0, true]), Array(Boolean(), Integer()).with("[0, true]")
			assert vv(false), Array(Integer().min(0)).with([false])
			assert vv(false), Array(Integer().min(0)).with(false)
