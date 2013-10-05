
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <quadmath.h>
#include <float.h>
#include <stdlib.h>

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

#ifdef FLT128_DIG
int _DIGITS = FLT128_DIG;
#else
int _DIGITS = 33;
#endif

#ifdef __MINGW64__
typedef __float128 float128 __attribute__ ((aligned(8)));
#else
typedef __float128 float128;
#endif

void flt128_set_prec(int x) {
    if(x < 1)croak("1st arg (precision) to flt128_set_prec must be at least 1");
    _DIGITS = x;
}

SV * flt128_get_prec(void) {
     return newSVuv(_DIGITS);
}

int _is_nan(float128 x) {
    if(x != x) return 1;
    return 0;
}

int  _is_inf(float128 x) {
     if(x != x) return 0; /* NaN  */
     if(x == 0.0Q) return 0; /* Zero */
     if(x/x != x/x) {
       if(x < 0.0Q) return -1;
       else return 1;
     }
     return 0; /* Finite Real */
}

int  _is_zero(float128 x) {
     char * buffer;

     if(x != 0.0Q) return 0;

     Newx(buffer, 2, char);

     quadmath_snprintf(buffer, sizeof buffer, "%.0Qf", x);

     if(!strcmp(buffer, "-0")) {
       Safefree(buffer);
       return -1;
     }   

     Safefree(buffer);
     return 1;
}

float128 _get_inf(int sign) {
    float128 ret;
    ret = 1.0Q / 0.0Q;
    if(sign < 0) ret *= -1.0Q;
    return ret;    
}

float128 _get_nan(void) {
     float128 inf = _get_inf(1);
     return inf / inf;
}

SV * InfF128(int sign) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in InfF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = _get_inf(sign);

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * NaNF128(void) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = _get_nan();

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * ZeroF128(int sign) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in ZeroF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = 0.0Q;
     if(sign < 0) *f *= -1;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * UnityF128(int sign) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in UnityF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = 1.0Q;
     if(sign < 0) *f *= -1;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

int is_NaNF128(SV * b) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128"))
         return _is_nan(*(INT2PTR(float128 *, SvIV(SvRV(b)))));
     }
     croak("Invalid argument supplied to Math::Float128::isNaNF128 function");
}

int is_InfF128(SV * b) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128"))
         return _is_inf(*(INT2PTR(float128 *, SvIV(SvRV(b)))));
     }
     croak("Invalid argument supplied to Math::Float128::is_InfF128 function");
}

int is_ZeroF128(SV * b) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128"))
         return _is_zero(*(INT2PTR(float128 *, SvIV(SvRV(b)))));
     }
     croak("Invalid argument supplied to Math::Float128::is_ZeroF128 function");
}


SV * STRtoF128(char * str) {
     float128 * f;
     SV * obj_ref, * obj;
     char * ptr;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in STRtoF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = strtoflt128(str, &ptr);

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * NVtoF128(SV * nv) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NVtoF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = (float128)SvNV(nv);

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * IVtoF128(SV * iv) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in IVtoF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = (float128)SvIV(iv);

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * UVtoF128(SV * uv) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in UVtoF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = (float128)SvUV(uv);

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

void F128toSTR(SV * f) {
     dXSARGS;
     float128 t;
     char * buffer;

     if(sv_isobject(f)) {
       const char *h = HvNAME(SvSTASH(SvRV(f)));
       if(strEQ(h, "Math::Float128")) {
          EXTEND(SP, 1);
          t = *(INT2PTR(float128 *, SvIV(SvRV(f))));

          Newx(buffer, 15 + _DIGITS, char);
          if(buffer == NULL) croak("Failed to allocate memory in F128toSTR()");
          quadmath_snprintf(buffer, 15 + _DIGITS, "%.*Qe", _DIGITS - 1, t);
          ST(0) = sv_2mortal(newSVpv(buffer, 0));
          Safefree(buffer);
          XSRETURN(1);
       }
       else croak("Invalid object supplied to Math::Float128::F128toSTR function");
     }
     else croak("Invalid argument supplied to Math::Float128::F128toSTR function");
}

void F128toSTRP(SV * f, int decimal_prec) {
     dXSARGS;
     float128 t;
     char * buffer;

     if(decimal_prec < 1)croak("2nd arg (precision) to F128toSTRP  must be at least 1");

     if(sv_isobject(f)) {
       const char *h = HvNAME(SvSTASH(SvRV(f)));
       if(strEQ(h, "Math::Float128")) {
          EXTEND(SP, 1);
          t = *(INT2PTR(float128 *, SvIV(SvRV(f))));

          Newx(buffer, 12 + decimal_prec, char);
          if(buffer == NULL) croak("Failed to allocate memory in F128toSTRP()");
          quadmath_snprintf(buffer, 12 + decimal_prec, "%.*Qe", decimal_prec - 1, t);
          ST(0) = sv_2mortal(newSVpv(buffer, 0));
          Safefree(buffer);
          XSRETURN(1);
       }
       else croak("Invalid object supplied to Math::Float128::F128toSTRP function");
     }
     else croak("Invalid argument supplied to Math::Float128::F128toSTRP function");
}

void DESTROY(SV *  f) {
     Safefree(INT2PTR(float128 *, SvIV(SvRV(f))));
}

SV * _LDBL_DIG(void) {
#ifdef LDBL_DIG
     return newSViv(LDBL_DIG);
#else 
     return newSViv(0);
#endif
}

SV * _DBL_DIG(void) {
#ifdef DBL_DIG
     return newSViv(DBL_DIG);
#else 
     return newSViv(0);
#endif
}

SV * _F128_DIG(void) {
#ifdef F128_DIG
     return newSViv(F128_DIG);
#else 
     return newSViv(0);
#endif
}

SV * _overload_add(SV * a, SV * b, SV * third) {

     float128 * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, float128);
     if(ld == NULL) croak("Failed to allocate memory in _overload_add() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *ld = *(INT2PTR(float128 *, SvIV(SvRV(a)))) + *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_add function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_add function");
}

SV * _overload_mul(SV * a, SV * b, SV * third) {

     float128 * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, float128);
     if(ld == NULL) croak("Failed to allocate memory in _overload_mul() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *ld = *(INT2PTR(float128 *, SvIV(SvRV(a)))) * *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_mul function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_mul function");
}

SV * _overload_sub(SV * a, SV * b, SV * third) {
     float128 * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, float128);
     if(ld == NULL) croak("Failed to allocate memory in _overload_sub() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *ld = *(INT2PTR(float128 *, SvIV(SvRV(a)))) - *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_sub function");
    }

    else {
      if(third == &PL_sv_yes) {
        *ld = *(INT2PTR(float128 *, SvIV(SvRV(a)))) * -1.0L;
        return obj_ref;
      }
    }

    croak("Invalid argument supplied to Math::Float128::_overload_sub function");

}

SV * _overload_div(SV * a, SV * b, SV * third) {
     float128 * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, float128);
     if(ld == NULL) croak("Failed to allocate memory in _overload_div() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *ld = *(INT2PTR(float128 *, SvIV(SvRV(a)))) / *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_div function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_div function");
}

int _overload_equiv(SV * a, SV * b, SV * third) {
    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) == *(INT2PTR(float128 *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_equiv function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_equiv function");
}

int _overload_not_equiv(SV * a, SV * b, SV * third) {
    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) == *(INT2PTR(float128 *, SvIV(SvRV(b))))) return 0;
        return 1; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_not_equiv function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_not_equiv function");
}

int _overload_true(SV * a, SV * b, SV * third) {

     if(_is_nan(*(INT2PTR(float128 *, SvIV(SvRV(a)))))) return 0;
     if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) != 0.0Q) return 1;
     return 0; 
}

int _overload_not(SV * a, SV * b, SV * third) {
     if(_is_nan(*(INT2PTR(float128 *, SvIV(SvRV(a)))))) return 1;
     if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) != 0.0L) return 0;
     return 1; 
}

SV * _overload_add_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *(INT2PTR(float128 *, SvIV(SvRV(a)))) += *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Float128::_overload_add_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Float128::_overload_add_eq function");
}

SV * _overload_mul_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *(INT2PTR(float128 *, SvIV(SvRV(a)))) *= *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Float128::_overload_mul_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Float128::_overload_mul_eq function");
}

SV * _overload_sub_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *(INT2PTR(float128 *, SvIV(SvRV(a)))) -= *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Float128::_overload_sub_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Float128::_overload_sub_eq function");
}

SV * _overload_div_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *(INT2PTR(float128 *, SvIV(SvRV(a)))) /= *(INT2PTR(float128 *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Float128::_overload_div_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Float128::_overload_div_eq function");
}

int _overload_lt(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) < *(INT2PTR(float128 *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_lt function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_lt function");
}

int _overload_gt(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) > *(INT2PTR(float128 *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_gt function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_gt function");
}

int _overload_lte(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) <= *(INT2PTR(float128 *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_lte function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_lte function");
}

int _overload_gte(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) >= *(INT2PTR(float128 *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_gte function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_gte function");
}

SV * _overload_spaceship(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) < *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(-1);
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) > *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(1);
        if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) == *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(0);
        return &PL_sv_undef; /* it's a nan */  
      }
      croak("Invalid object supplied to Math::Float128::_overload_spaceship function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_spaceship function");
}

SV * _overload_copy(SV * a, SV * b, SV * third) {

     float128 * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, float128);
     if(ld == NULL) croak("Failed to allocate memory in _overload_copy() function");

     *ld = *(INT2PTR(float128 *, SvIV(SvRV(a))));

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * F128toF128(SV * a) {
     float128 * f;
     SV * obj_ref, * obj;

     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Float128")) {

         Newx(f, 1, float128);
         if(f == NULL) croak("Failed to allocate memory in F128toF128() function");

         *f = *(INT2PTR(float128 *, SvIV(SvRV(a))));

         obj_ref = newSV(0);
         obj = newSVrv(obj_ref, "Math::Float128");
         sv_setiv(obj, INT2PTR(IV,f));
         SvREADONLY_on(obj);
         return obj_ref;
       }
       croak("Invalid object supplied to Math::Float128::F128toF128 function"); 
     }
     croak("Invalid argument supplied to Math::Float128::F128toF128 function");
}

SV * _itsa(SV * a) {
     if(SvUOK(a)) return newSVuv(1);
     if(SvIOK(a)) return newSVuv(2);
     if(SvNOK(a)) return newSVuv(3);
     if(SvPOK(a)) return newSVuv(4);
     if(sv_isobject(a)) {
       const char *h = HvNAME(SvSTASH(SvRV(a)));
       if(strEQ(h, "Math::Float128")) return newSVuv(113);
     }
     return newSVuv(0);
}

SV * _overload_abs(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_abs() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);

     *f = fabsq(*(INT2PTR(float128 *, SvIV(SvRV(a)))));
     return obj_ref; 
}

SV * _overload_int(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_int() function");

     *f = *(INT2PTR(float128 *, SvIV(SvRV(a))));

     if(*f < 0.0Q) *f = ceilq(*f);
     else *f = floorq(*f);

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_sqrt(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_sqrt() function");

     *f = sqrtq(*(INT2PTR(float128 *, SvIV(SvRV(a)))));
 
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_log(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_log() function");

     *f = logq(*(INT2PTR(float128 *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_exp(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_exp() function");

     *f = expq(*(INT2PTR(float128 *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_sin(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_sin() function");

     *f = sinq(*(INT2PTR(float128 *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_cos(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_cos() function");

     *f = cosq(*(INT2PTR(float128 *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_atan2(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_atan2() function");

     *f = atan2q(*(INT2PTR(float128 *, SvIV(SvRV(a)))), *(INT2PTR(float128 *, SvIV(SvRV(b)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_inc(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

     *(INT2PTR(float128 *, SvIV(SvRV(a)))) += 1.0Q;

     return a;
}

SV * _overload_dec(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

     *(INT2PTR(float128 *, SvIV(SvRV(a)))) -= 1.0Q;

     return a;
}

SV * _overload_pow(SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_pow() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *f = powq(*(INT2PTR(float128 *, SvIV(SvRV(a)))), *(INT2PTR(float128 *, SvIV(SvRV(b)))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::Float128::_overload_pow function");
    }
    croak("Invalid argument supplied to Math::Float128::_overload_pow function");
}

SV * _overload_pow_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
        *(INT2PTR(float128 *, SvIV(SvRV(a)))) = powq(*(INT2PTR(float128 *, SvIV(SvRV(a)))),
                                                        *(INT2PTR(float128 *, SvIV(SvRV(b)))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::Float128::_overload_pow_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::Float128::_overload_pow_eq function");
}

SV * cmp2NV(SV * flt128_obj, SV * sv) {
     float128 f;
     NV nv;
 
     if(sv_isobject(flt128_obj)) {
       const char *h = HvNAME(SvSTASH(SvRV(flt128_obj)));
       if(strEQ(h, "Math::Float128")) {    
         f = *(INT2PTR(float128 *, SvIV(SvRV(flt128_obj))));
         nv = SvNV(sv);

         if((f != f) || (nv != nv)) return &PL_sv_undef;
         if(f < (float128)nv) return newSViv(-1);
         if(f > (float128)nv) return newSViv(1);
         return newSViv(0);
       }
       croak("Invalid object supplied to Math::Float128::cmp2NV function"); 
     }
     croak("Invalid argument supplied to Math::Float128::cmp_NV function");
}

SV * F128toNV(SV * f) {
     return newSVnv((NV)(*(INT2PTR(float128 *, SvIV(SvRV(f))))));
}



MODULE = Math::Float128	PACKAGE = Math::Float128	

PROTOTYPES: DISABLE


void
flt128_set_prec (x)
	int	x
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	flt128_set_prec(x);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
flt128_get_prec ()
		

SV *
InfF128 (sign)
	int	sign

SV *
NaNF128 ()
		

SV *
ZeroF128 (sign)
	int	sign

SV *
UnityF128 (sign)
	int	sign

int
is_NaNF128 (b)
	SV *	b

int
is_InfF128 (b)
	SV *	b

int
is_ZeroF128 (b)
	SV *	b

SV *
STRtoF128 (str)
	char *	str

SV *
NVtoF128 (nv)
	SV *	nv

SV *
IVtoF128 (iv)
	SV *	iv

SV *
UVtoF128 (uv)
	SV *	uv

void
F128toSTR (f)
	SV *	f
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	F128toSTR(f);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
F128toSTRP (f, decimal_prec)
	SV *	f
	int	decimal_prec
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	F128toSTRP(f, decimal_prec);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
DESTROY (f)
	SV *	f
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	DESTROY(f);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_LDBL_DIG ()
		

SV *
_DBL_DIG ()
		

SV *
_F128_DIG ()
		

SV *
_overload_add (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_mul (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sub (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_div (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_not_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_true (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_not (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_lt (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_gt (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_lte (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_gte (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_spaceship (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_copy (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
F128toF128 (a)
	SV *	a

SV *
_itsa (a)
	SV *	a

SV *
_overload_abs (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_int (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sqrt (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_log (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_exp (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sin (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_cos (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_atan2 (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_inc (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_dec (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_pow (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_pow_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
cmp2NV (flt128_obj, sv)
	SV *	flt128_obj
	SV *	sv

SV *
F128toNV (f)
	SV *	f

