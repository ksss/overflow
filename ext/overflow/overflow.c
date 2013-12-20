#include "ruby.h"

typedef enum {
	i8,
	ui8,
	i16,
	ui16,
	in,
	uin,
	i32,
	ui32,
	i64,
	ui64
} types;

typedef struct {
	types type;
	uint64_t value;
} overflow_t;

static VALUE overflow_set(VALUE self, VALUE obj);

types char2type (char c)
{
	switch (c) {
	case 'c': return i8;
	case 'C': return ui8;
	case 's': return i16;
	case 'S': return ui16;
	case 'i': return in;
	case 'I': return uin;
	case 'l': return i32;
	case 'L': return ui32;
	case 'q': return i64;
	case 'Q': return ui64;
	default:
		rb_raise(rb_eArgError, "type %c is not support", c);
	}
}

static VALUE
overflow_alloc(VALUE self)
{
	overflow_t* ptr = ALLOC(overflow_t);
	return Data_Wrap_Struct(self, 0, -1, ptr);
}

static VALUE
overflow_initialize(int argc, VALUE *argv, VALUE self)
{
	overflow_t *ptr;
	char *p;
	VALUE obj = argv[0];

	if (argc < 1 || rb_type(obj) != T_STRING) {
		rb_raise(rb_eArgError, "set a type char for `pack' template");
	}

	Data_Get_Struct(self, overflow_t, ptr);
	p = RSTRING_PTR(obj);

	ptr->type = char2type(*p);
	ptr->value = 0;
	if (1 < argc) {
		overflow_set(self, argv[1]);
	}
	return self;
}

static VALUE
overflow_initialize_copy(VALUE copy, VALUE origin)
{
	overflow_t *ptr_copy, *ptr_origin;

	if (copy == origin) return copy;

	rb_check_frozen(copy);

	Data_Get_Struct(copy, overflow_t, ptr_copy);
	Data_Get_Struct(origin, overflow_t, ptr_origin);

	ptr_copy->value = ptr_origin->value;
	ptr_copy->type  = ptr_origin->type;

	return copy;
}

static VALUE
overflow_to_i(VALUE self)
{
	overflow_t *ptr;
	Data_Get_Struct(self, overflow_t, ptr);

	switch (ptr->type) {
	case i8:   return INT2NUM((int8_t)ptr->value);
	case ui8:  return UINT2NUM((uint8_t)ptr->value);
	case i16:  return INT2NUM((int16_t)ptr->value);
	case ui16: return UINT2NUM((uint16_t)ptr->value);
	case in:   return LONG2NUM((int)ptr->value);
	case uin:  return ULONG2NUM((unsigned int)ptr->value);
	case i32:  return LONG2NUM((int32_t)ptr->value);
	case ui32: return ULONG2NUM((uint32_t)ptr->value);
	case i64:  return LL2NUM((int64_t)ptr->value);
	case ui64: return ULL2NUM((uint64_t)ptr->value);
	}
	rb_raise(rb_eRuntimeError, "undefined type seted");
	return Qnil;
}

static VALUE
overflow_coerce(VALUE self, VALUE other)
{
	if (CLASS_OF(self) == CLASS_OF(other)) {
		return rb_assoc_new(overflow_to_i(other), overflow_to_i(self));
	}
	return rb_assoc_new(other, overflow_to_i(self));
}

static VALUE
overflow_cmp(VALUE self, VALUE other)
{
	VALUE i;

	if (self == other) return 0;

	i = overflow_to_i(self);
	if (i == other) return INT2FIX(0);

	if (FIXNUM_P(i)) {
		if (FIXNUM_P(other)) {
			if (FIX2LONG(i) < FIX2LONG(other)) {
				return INT2FIX(-1);
			} else {
				return INT2FIX(1);
			}
		} else if (RB_TYPE_P(other, T_BIGNUM)) {
			return rb_big_cmp(rb_int2big(FIX2LONG(i)), other);
		}
	} else if (RB_TYPE_P(i, T_BIGNUM)) {
		return rb_big_cmp(i, other);
	}
	return rb_num_coerce_cmp(self, other, rb_intern("<=>"));
}

static VALUE
overflow_hash(VALUE self)
{
	st_index_t h[2];
	overflow_t *ptr;
	Data_Get_Struct(self, overflow_t, ptr);
	h[0] = NUM2LONG(rb_hash(INT2FIX(ptr->type)));
	h[1] = NUM2LONG(rb_hash(overflow_to_i(self)));
	return LONG2FIX(rb_memhash(h, sizeof(h)));
}

static VALUE
overflow_eql(VALUE self, VALUE other)
{
	overflow_t *ptr_self;
	overflow_t *ptr_other;

	if (TYPE(other) != T_DATA) {
		return Qfalse;
	}
	Data_Get_Struct(self, overflow_t, ptr_self);
	Data_Get_Struct(other, overflow_t, ptr_other);
	if (ptr_self->type != ptr_other->type) {
		return Qfalse;
	}
	if (ptr_self->value != ptr_other->value) {
		return Qfalse;
	}
	return Qtrue;
}

static VALUE
overflow_to_f(VALUE self)
{
	return DBL2NUM((double)FIX2LONG(overflow_to_i(self)));
}

static VALUE
overflow_modulo(VALUE self, VALUE other)
{
	return rb_funcall(overflow_to_i(self), '-', 1,
			rb_funcall(other, '*', 1,
				rb_funcall(overflow_to_i(self), rb_intern("div"), 1, other)));
}

static VALUE
overflow_int_p(VALUE self)
{
	return Qtrue;
}

#define OVERFLOW_TYPES_ALL_CASE(ptr, callback) do { \
	switch (ptr->type) { \
	case i8:   ptr->value = (int8_t)       callback; break; \
	case ui8:  ptr->value = (uint8_t)      callback; break; \
	case i16:  ptr->value = (int16_t)      callback; break; \
	case ui16: ptr->value = (uint16_t)     callback; break; \
	case in:   ptr->value = (int)          callback; break; \
	case uin:  ptr->value = (unsigned int) callback; break; \
	case i32:  ptr->value = (int32_t)      callback; break; \
	case ui32: ptr->value = (uint32_t)     callback; break; \
	case i64:  ptr->value = (int64_t)      callback; break; \
	case ui64: ptr->value = (uint64_t)     callback; break; \
	} \
} while(0)

static VALUE
overflow_set(VALUE self, VALUE obj)
{
	VALUE other;
	overflow_t *ptr;
	Data_Get_Struct(self, overflow_t, ptr);

	switch (rb_type(obj)) {
	case T_FIXNUM:
		OVERFLOW_TYPES_ALL_CASE(ptr, NUM2LL(obj));
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

static inline VALUE
pre_arithmetic(VALUE num)
{
	switch (rb_type(num)) {
	case T_FIXNUM:
		return num;
	case T_BIGNUM:
		return rb_funcall(num, rb_intern("&"), 1, ULL2NUM(0xffffffffffffffffLL));
	case T_DATA: // self
		return overflow_to_i(num);
	}
	rb_raise(rb_eArgError, "cannot arithmetic");
	return Qnil;
}

#define TYPE_PLUS(type, value, other)  ((type)((type)(value) + (type)(other)))
#define TYPE_MINUS(type, value, other) ((type)((type)(value) - (type)(other)))
#define TYPE_MUL(type, value, other)   ((type)((type)(value) * (type)(other)))
#define TYPE_DIV(type, value, other)   ((type)((type)(value) / (type)(other)))

#define SWITCH_MACRO(type, macro, a, b) do { \
	switch (type) { \
	case i8:   a = macro(int8_t, a, b); break; \
	case ui8:  a = macro(uint8_t, a, b); break; \
	case i16:  a = macro(int16_t, a, b); break; \
	case ui16: a = macro(uint16_t, a, b); break; \
	case in:   a = macro(int, a, b); break; \
	case uin:  a = macro(unsigned int, a, b); break; \
	case i32:  a = macro(int32_t, a, b); break; \
	case ui32: a = macro(uint32_t, a, b); break; \
	case i64:  a = macro(int64_t, a, b); break; \
	case ui64: a = macro(uint64_t, a, b); break; \
	} \
} while(0)

static inline VALUE
overflow_arithmetic(VALUE self, char method, VALUE other)
{
	uint64_t b;
	overflow_t *ptr;
	VALUE clone = rb_obj_clone(self);

	Data_Get_Struct(clone, overflow_t, ptr);

	b = NUM2ULL(pre_arithmetic(other));

	switch (method) {
	case '+':
		SWITCH_MACRO(ptr->type, TYPE_PLUS, ptr->value, b);
		break;
	case '-':
		SWITCH_MACRO(ptr->type, TYPE_MINUS, ptr->value, b);
		break;
	case '*':
		SWITCH_MACRO(ptr->type, TYPE_MUL, ptr->value, b);
		break;
	case '/':
		SWITCH_MACRO(ptr->type, TYPE_DIV, ptr->value, b);
		break;
	}
	return clone;
}

static VALUE
overflow_plus(VALUE self, VALUE num)
{
	return overflow_arithmetic(self, '+', num);
}

static VALUE
overflow_minus(VALUE self, VALUE num)
{
	return overflow_arithmetic(self, '-', num);
}

static VALUE
overflow_mul(VALUE self, VALUE num)
{
	return overflow_arithmetic(self, '*', num);
}

static VALUE
overflow_div(VALUE self, VALUE num)
{
	return overflow_arithmetic(self, '/', num);
}

static VALUE
overflow_rev(VALUE self)
{
	VALUE clone = rb_obj_clone(self);
	overflow_t *ptr;
	Data_Get_Struct(clone, overflow_t, ptr);

	ptr->value = ~ptr->value;
	return clone;
}

static VALUE
overflow_and(VALUE self, VALUE num)
{
	VALUE clone = rb_obj_clone(self);
	overflow_t *ptr;
	Data_Get_Struct(clone, overflow_t, ptr);

	ptr->value = ptr->value & NUM2ULL(pre_arithmetic(num));
	return clone;
}

static VALUE
overflow_or(VALUE self, VALUE num)
{
	VALUE clone = rb_obj_clone(self);
	overflow_t *ptr;
	Data_Get_Struct(clone, overflow_t, ptr);

	ptr->value = ptr->value | NUM2ULL(pre_arithmetic(num));
	return clone;
}

static VALUE
overflow_xor(VALUE self, VALUE num)
{
	VALUE clone = rb_obj_clone(self);
	overflow_t *ptr;
	Data_Get_Struct(clone, overflow_t, ptr);

	ptr->value = ptr->value ^ NUM2ULL(pre_arithmetic(num));
	return clone;
}

static void
lshift(overflow_t *ptr, long width)
{
	OVERFLOW_TYPES_ALL_CASE(ptr, (ptr->value << width));
}

static void
rshift(overflow_t *ptr, long width)
{
	OVERFLOW_TYPES_ALL_CASE(ptr, (ptr->value >> width));
}

static VALUE
overflow_lshift(VALUE self, VALUE obj)
{
	VALUE clone = rb_obj_clone(self);
	long width;
	overflow_t *ptr;
	Data_Get_Struct(clone, overflow_t, ptr);

	if (!FIXNUM_P(obj))
		rb_raise(rb_eArgError, "too big shift not support");

	width = FIX2LONG(obj);

	if (width < 0) {
		rshift(ptr, -width);
	} else {
		lshift(ptr, width);
	}
	return clone;
}

static VALUE
overflow_rshift(VALUE self, VALUE obj)
{
	VALUE clone = rb_obj_clone(self);
	long width;
	overflow_t *ptr;
	Data_Get_Struct(clone, overflow_t, ptr);

	if (!FIXNUM_P(obj))
		rb_raise(rb_eArgError, "too big shift not support");

	width = FIX2LONG(obj);

	if (width < 0) {
		lshift(ptr, -width);
	} else {
		rshift(ptr, width);
	}
	return clone;
}

void
Init_overflow(void)
{
	VALUE cOverflow;

	cOverflow = rb_define_class("Overflow", rb_cNumeric);
	rb_define_const(cOverflow, "VERSION", rb_str_new2("0.0.1"));
	rb_define_alloc_func(cOverflow, overflow_alloc);
	rb_define_method(cOverflow, "initialize", overflow_initialize, -1);
	rb_define_method(cOverflow, "initialize_copy", overflow_initialize_copy, 1);

	/* override on Numeric */
	rb_define_method(cOverflow, "coerce", overflow_coerce, 1);
	rb_define_method(cOverflow, "<=>", overflow_cmp, 1);
	rb_define_method(cOverflow, "hash", overflow_hash, 0);
	rb_define_method(cOverflow, "eql?", overflow_eql, 1);
	rb_define_method(cOverflow, "to_f", overflow_to_f, 0);
	rb_define_method(cOverflow, "%", overflow_modulo, 1);
	rb_define_method(cOverflow, "modulo", overflow_modulo, 1);
	rb_define_method(cOverflow, "integer?", overflow_int_p, 0);
	// rb_define_method(cOverflow, "step", overflow_step, -1);

	rb_define_method(cOverflow, "set", overflow_set, 1);
	rb_define_method(cOverflow, "to_i", overflow_to_i, 0);

	rb_define_method(cOverflow, "+", overflow_plus, 1);
	rb_define_method(cOverflow, "-", overflow_minus, 1);
	rb_define_method(cOverflow, "*", overflow_mul, 1);
	rb_define_method(cOverflow, "/", overflow_div, 1);

	rb_define_method(cOverflow, "~", overflow_rev, 0);
	rb_define_method(cOverflow, "&", overflow_and, 1);
	rb_define_method(cOverflow, "|", overflow_or, 1);
	rb_define_method(cOverflow, "^", overflow_xor, 1);

	rb_define_method(cOverflow, "<<", overflow_lshift, 1);
	rb_define_method(cOverflow, ">>", overflow_rshift, 1);
}
