#include "ruby.h"

typedef enum {
	i8,
	ui8,
	i16,
	ui16,
	i32,
	ui32,
	i64,
	ui64
} types;

typedef uint64_t value_t;

typedef struct {
	value_t value;
	types type;
} overflow_t;

types char2type (char c)
{
	switch (c) {
	case 'c': return i8;
	case 'C': return ui8;
	case 's': return i16;
	case 'S': return ui16;
	case 'i': return i32;
	case 'I': return ui32;
	case 'l': return i32;
	case 'L': return ui32;
	case 'q': return i64;
	case 'Q': return ui64;
	default:
		rb_raise(rb_eArgError, "type %c is not support", c);
	}
}

static void
overflow_free(overflow_t* ptr)
{
	xfree(ptr);
}

static VALUE
overflow_alloc(VALUE self)
{
	overflow_t* ptr = ALLOC(overflow_t);
	return Data_Wrap_Struct(self, 0, overflow_free, ptr);
}

static VALUE
overflow_initialize(VALUE self, VALUE obj)
{
	overflow_t *ptr;
	char *p;

	if (rb_type(obj) != T_STRING) {
		rb_raise(rb_eArgError, "set a type char for `pack' template");
	}

	Data_Get_Struct(self, overflow_t, ptr);
	p = RSTRING_PTR(obj);

	ptr->type = char2type(*p);
	return self;
}

static VALUE
overflow_set(VALUE self, VALUE obj)
{
	VALUE other;
	overflow_t *ptr;
	Data_Get_Struct(self, overflow_t, ptr);

	switch (rb_type(obj)) {
	case T_FIXNUM:
		switch (ptr->type) {
		case i8:   ptr->value = (int8_t)   NUM2LL(obj); break;
		case ui8:  ptr->value = (uint8_t)  NUM2LL(obj); break;
		case i16:  ptr->value = (int16_t)  NUM2LL(obj); break;
		case ui16: ptr->value = (uint16_t) NUM2LL(obj); break;
		case i32:  ptr->value = (int32_t)  NUM2LL(obj); break;
		case ui32: ptr->value = (uint32_t) NUM2LL(obj); break;
		case i64:  ptr->value = (int64_t)  NUM2LL(obj); break;
		case ui64: ptr->value = (uint64_t) NUM2LL(obj); break;
		}
		break;
	case T_BIGNUM:
		if (RBIGNUM_POSITIVE_P(obj)) {
			other = rb_funcall(obj, rb_intern("&"), 1, ULL2NUM(0xffffffffffffffffLL));
			ptr->value = (uint64_t) NUM2ULL(other);
		} else {
			ptr->value = (int64_t) NUM2LL(obj);
		}
		break;
	}
	return self;
}

static VALUE
overflow_to_i(VALUE self)
{
	overflow_t *ptr;
	Data_Get_Struct(self, overflow_t, ptr);

	switch (ptr->type) {
	case i8:
		return INT2NUM((int8_t)ptr->value);
	case ui8:
		return UINT2NUM((uint8_t)ptr->value);
	case i16:
		return INT2NUM((int16_t)ptr->value);
	case ui16:
		return UINT2NUM((uint16_t)ptr->value);
	case i32:
		return LONG2NUM((int32_t)ptr->value);
	case ui32:
		return ULONG2NUM((uint32_t)ptr->value);
	case i64:
		return LL2NUM((int64_t)ptr->value);
	case ui64:
		return ULL2NUM((uint64_t)ptr->value);
	}
}

#define TYPE_PLUS(type, value, other) ((type)((type)(value) + (type)(other)))

static uint64_t
plus(types type, uint64_t a, uint64_t b)
{
	switch (type) {
	case i8:   return TYPE_PLUS(int8_t, a, b);
	case ui8:  return TYPE_PLUS(uint8_t, a, b);
	case i16:  return TYPE_PLUS(int16_t, a, b);
	case ui16: return TYPE_PLUS(uint16_t, a, b);
	case i32:  return TYPE_PLUS(int32_t, a, b);
	case ui32: return TYPE_PLUS(uint32_t, a, b);
	case i64:  return TYPE_PLUS(int64_t, a, b);
	case ui64: return TYPE_PLUS(uint64_t, a, b);
	}
}

static VALUE
overflow_plus(VALUE self, VALUE num)
{
	uint64_t a, b;
	overflow_t *ptr;

	Data_Get_Struct(self, overflow_t, ptr);

	if (RB_TYPE_P(num, T_BIGNUM)) {
		num = rb_funcall(num, rb_intern("&"), 1, ULL2NUM(0xffffffffffffffffLL));
	}

	a = ptr->value;
	b = NUM2ULL(num);

	ptr->value = plus(ptr->type, a, b);
	return self;
}

#define TYPE_MINUS(type, value, other) ((type)((type)(value) - (type)(other)))

static uint64_t
minus(types type, uint64_t a, uint64_t b)
{
	switch (type) {
	case i8:   return TYPE_MINUS(int8_t, a, b);
	case ui8:  return TYPE_MINUS(uint8_t, a, b);
	case i16:  return TYPE_MINUS(int16_t, a, b);
	case ui16: return TYPE_MINUS(uint16_t, a, b);
	case i32:  return TYPE_MINUS(int32_t, a, b);
	case ui32: return TYPE_MINUS(uint32_t, a, b);
	case i64:  return TYPE_MINUS(int64_t, a, b);
	case ui64: return TYPE_MINUS(uint64_t, a, b);
	}
}

static VALUE
overflow_minus(VALUE self, VALUE num)
{
	uint64_t a;
	uint64_t b;
	overflow_t *ptr;

	Data_Get_Struct(self, overflow_t, ptr);

	if (RB_TYPE_P(num, T_BIGNUM)) {
		num = rb_funcall(num, rb_intern("&"), 1, ULL2NUM(0xffffffffffffffffLL));
	}

	a = ptr->value;
	b = NUM2ULL(num);

	ptr->value = minus(ptr->type, a, b);
	return self;
}

#define TYPE_MUL(type, value, other) ((type)((type)(value) * (type)(other)))

static uint64_t
mul(types type, uint64_t a, uint64_t b)
{
	switch (type) {
	case i8:   return TYPE_MUL(int8_t, a, b);
	case ui8:  return TYPE_MUL(uint8_t, a, b);
	case i16:  return TYPE_MUL(int16_t, a, b);
	case ui16: return TYPE_MUL(uint16_t, a, b);
	case i32:  return TYPE_MUL(int32_t, a, b);
	case ui32: return TYPE_MUL(uint32_t, a, b);
	case i64:  return TYPE_MUL(int64_t, a, b);
	case ui64: return TYPE_MUL(uint64_t, a, b);
	}
}

static VALUE
overflow_mul(VALUE self, VALUE num)
{
	uint64_t a;
	uint64_t b;
	overflow_t *ptr;

	Data_Get_Struct(self, overflow_t, ptr);

	if (RB_TYPE_P(num, T_BIGNUM)) {
		num = rb_funcall(num, rb_intern("&"), 1, ULL2NUM(0xffffffffffffffffLL));
	}

	a = ptr->value;
	b = NUM2ULL(num);

	ptr->value = mul(ptr->type, a, b);
	return self;
}

static VALUE
lshift(overflow_t *ptr, long width)
{
	switch (ptr->type) {
	case i8:   return INT2NUM((int8_t)(ptr->value << width));
	case ui8:  return UINT2NUM((uint8_t)(ptr->value << width));
	case i16:  return INT2NUM((int16_t)(ptr->value << width));
	case ui16: return UINT2NUM((uint16_t)(ptr->value << width));
	case i32:  return LONG2NUM((int32_t)(ptr->value << width));
	case ui32: return ULONG2NUM((uint32_t)(ptr->value << width));
	case i64:  return LONG2NUM((int64_t)(ptr->value << width));
	case ui64: return ULONG2NUM((uint64_t)(ptr->value << width));
	}
}

static VALUE
rshift(overflow_t *ptr, long width)
{
	switch (ptr->type) {
	case i8:   return INT2NUM((int8_t)(ptr->value >> width));
	case ui8:  return UINT2NUM((uint8_t)(ptr->value >> width));
	case i16:  return INT2NUM((int16_t)(ptr->value >> width));
	case ui16: return UINT2NUM((uint16_t)(ptr->value >> width));
	case i32:  return LONG2NUM((int32_t)(ptr->value >> width));
	case ui32: return ULONG2NUM((uint32_t)(ptr->value >> width));
	case i64:  return LONG2NUM((int64_t)(ptr->value >> width));
	case ui64: return ULONG2NUM((uint64_t)(ptr->value >> width));
	}
}

static VALUE
overflow_lshift(VALUE self, VALUE obj)
{
	long width;
	overflow_t *ptr;
	Data_Get_Struct(self, overflow_t, ptr);

	if (!FIXNUM_P(obj))
		rb_raise(rb_eArgError, "over 64 left shift not support");
	
	width = FIX2LONG(obj);
	if (64 <= width)
		rb_raise(rb_eArgError, "over 64 left shift not support");

	if (width < 0) {
		return rshift(ptr, -width);
	} else {
		return lshift(ptr, width);
	}
}

static VALUE
overflow_rshift(VALUE self, VALUE obj)
{
	long width;
	overflow_t *ptr;
	Data_Get_Struct(self, overflow_t, ptr);

	if (!FIXNUM_P(obj))
		rb_raise(rb_eArgError, "over 64 right shift not support");
	
	width = FIX2LONG(obj);
	if (64 <= width)
		rb_raise(rb_eArgError, "over 64 right shift not support");

	if (width < 0) {
		return lshift(ptr, -width);
	} else {
		return rshift(ptr, width);
	}
}

void
Init_overflow(void)
{
	VALUE cOverflow;
	cOverflow = rb_define_class("Overflow", rb_cObject);
	rb_define_alloc_func(cOverflow, overflow_alloc);
	rb_define_method(cOverflow, "initialize", overflow_initialize, 1);
	rb_define_method(cOverflow, "set", overflow_set, 1);
	rb_define_method(cOverflow, "to_i", overflow_to_i, 0);
	rb_define_method(cOverflow, "+", overflow_plus, 1);
	rb_define_method(cOverflow, "-", overflow_minus, 1);
	rb_define_method(cOverflow, "*", overflow_mul, 1);
	rb_define_method(cOverflow, "<<", overflow_lshift, 1);
	rb_define_method(cOverflow, ">>", overflow_rshift, 1);
}
