' TEST_MODE : COMPILE_ONLY_FAIL

type Parent
	as integer i
	private:
	declare sub foo( )
end type

sub Parent.foo( )
end sub

type Child extends Parent
	declare sub test( )
end type

sub Child.test( )
	base.foo( )
end sub
