Data
====

Tester for data.

Examples
-------

	Pincode = Integer()
		.min 0
		.max 9999
		.default 4444

	Pincode.with(12) == {valid: true, value: 12}
	Pincode.with(12345) == {valid: true, value: 4444}

	Pincode.with().value == 4444

	User = Hash
		name: String()
		age: Integer().min 18

	User.with(0).valid == false
	User.with(name: "foo", age: 850).valid == true


API
---

	Data[Type, Json, Float, Integer, Boolean, Any] :: -> Type
	Data.Hash :: ({key :: String, value :: Test}) -> Type
	Data.Array :: (Type, ...) -> Type

	Type#test :: ((A) -> Boolean) -> Type
	Type#format :: ((A) -> B) -> Type
	Type#with :: (A) -> {valid: Boolean, value: B}

	Type#default :: (B) -> Type
	Type#min :: (Number) -> Type
	Type#max :: (Number) -> Type
	Type#odd :: -> Type
	Type#even :: -> Type
	Type#every :: ((A) -> Boolean) -> Type
	Type#only :: (Type, ...) -> Type
	Type#object :: ({String: Type}) -> Type
	Type#length :: Integer -> Type

