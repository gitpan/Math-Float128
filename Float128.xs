
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif

#define PERL_NO_GET_CONTEXT 1

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

void flt128_set_prec(pTHX_ int x) {
    if(x < 1)croak("1st arg (precision) to flt128_set_prec must be at least 1");
    _DIGITS = x;
}

SV * flt128_get_prec(pTHX) {
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

SV * InfF128(pTHX_ int sign) {
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

SV * NaNF128(pTHX) {
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

SV * ZeroF128(pTHX_ int sign) {
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

SV * UnityF128(pTHX_ int sign) {
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

SV * is_NaNF128(pTHX_ SV * b) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128"))
         return newSViv(_is_nan(*(INT2PTR(float128 *, SvIV(SvRV(b))))));
     }
     croak("Invalid argument supplied to Math::Float128::isNaNF128 function");
}

SV * is_InfF128(pTHX_ SV * b) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128"))
         return newSViv(_is_inf(*(INT2PTR(float128 *, SvIV(SvRV(b))))));
     }
     croak("Invalid argument supplied to Math::Float128::is_InfF128 function");
}

SV * is_ZeroF128(pTHX_ SV * b) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128"))
         return newSViv(_is_zero(*(INT2PTR(float128 *, SvIV(SvRV(b))))));
     }
     croak("Invalid argument supplied to Math::Float128::is_ZeroF128 function");
}


SV * STRtoF128(pTHX_ char * str) {
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

SV * NVtoF128(pTHX_ SV * nv) {
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

SV * IVtoF128(pTHX_ SV * iv) {
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

SV * UVtoF128(pTHX_ SV * uv) {
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

void F128toSTR(pTHX_ SV * f) {
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

void F128toSTRP(pTHX_ SV * f, int decimal_prec) {
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

void DESTROY(pTHX_ SV *  f) {
     Safefree(INT2PTR(float128 *, SvIV(SvRV(f))));
}

SV * _LDBL_DIG(pTHX) {
#ifdef LDBL_DIG
     return newSViv(LDBL_DIG);
#else 
     return newSViv(0);
#endif
}

SV * _DBL_DIG(pTHX) {
#ifdef DBL_DIG
     return newSViv(DBL_DIG);
#else 
     return newSViv(0);
#endif
}

SV * _FLT128_DIG(pTHX) {
#ifdef FLT128_DIG
     return newSViv(FLT128_DIG);
#else 
     return newSViv(0);
#endif
}

SV * _overload_add(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_mul(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_sub(pTHX_ SV * a, SV * b, SV * third) {
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

SV * _overload_div(pTHX_ SV * a, SV * b, SV * third) {
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

SV * _overload_equiv(pTHX_ SV * a, SV * b, SV * third) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
         if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) == *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0); 
       }
       croak("Invalid object supplied to Math::Float128::_overload_equiv function");
     }
     croak("Invalid argument supplied to Math::Float128::_overload_equiv function");
}

SV * _overload_not_equiv(pTHX_ SV * a, SV * b, SV * third) {
     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
         if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) == *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(0);
         return newSViv(1); 
       }
       croak("Invalid object supplied to Math::Float128::_overload_not_equiv function");
     }
     croak("Invalid argument supplied to Math::Float128::_overload_not_equiv function");
}

SV * _overload_true(pTHX_ SV * a, SV * b, SV * third) {

     if(_is_nan(*(INT2PTR(float128 *, SvIV(SvRV(a)))))) return newSViv(0);
     if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) != 0.0Q) return newSViv(1);
     return newSViv(0); 
}

SV * _overload_not(pTHX_ SV * a, SV * b, SV * third) {
     if(_is_nan(*(INT2PTR(float128 *, SvIV(SvRV(a)))))) return newSViv(1);
     if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) != 0.0L) return newSViv(0);
     return newSViv(1); 
}

SV * _overload_add_eq(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_mul_eq(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_sub_eq(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_div_eq(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_lt(pTHX_ SV * a, SV * b, SV * third) {

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
         if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) < *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0); 
       }
       croak("Invalid object supplied to Math::Float128::_overload_lt function");
     }
     croak("Invalid argument supplied to Math::Float128::_overload_lt function");
}

SV * _overload_gt(pTHX_ SV * a, SV * b, SV * third) {

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
         if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) > *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0); 
       }
       croak("Invalid object supplied to Math::Float128::_overload_gt function");
     }
     croak("Invalid argument supplied to Math::Float128::_overload_gt function");
}

SV * _overload_lte(pTHX_ SV * a, SV * b, SV * third) {

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
         if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) <= *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0); 
       }
       croak("Invalid object supplied to Math::Float128::_overload_lte function");
     }
     croak("Invalid argument supplied to Math::Float128::_overload_lte function");
}

SV * _overload_gte(pTHX_ SV * a, SV * b, SV * third) {

     if(sv_isobject(b)) {
       const char *h = HvNAME(SvSTASH(SvRV(b)));
       if(strEQ(h, "Math::Float128")) {
         if(*(INT2PTR(float128 *, SvIV(SvRV(a)))) >= *(INT2PTR(float128 *, SvIV(SvRV(b))))) return newSViv(1);
         return newSViv(0); 
       }
       croak("Invalid object supplied to Math::Float128::_overload_gte function");
     }
     croak("Invalid argument supplied to Math::Float128::_overload_gte function");
}

SV * _overload_spaceship(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_copy(pTHX_ SV * a, SV * b, SV * third) {

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

SV * F128toF128(pTHX_ SV * a) {
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

SV * _itsa(pTHX_ SV * a) {
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

SV * _overload_abs(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_int(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_sqrt(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_log(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_exp(pTHX_ SV * a, SV * b, SV * third) {

     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in _overload_exp() function");

#ifdef __MINGW64_VERSION_MAJOR /* avoid calling expq() as it's buggy */
     *f = powq(M_Eq, *(INT2PTR(float128 *, SvIV(SvRV(a)))));
#else
     *f = expq(*(INT2PTR(float128 *, SvIV(SvRV(a)))));
#endif
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");
     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_sin(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_cos(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_atan2(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_inc(pTHX_ SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

     *(INT2PTR(float128 *, SvIV(SvRV(a)))) += 1.0Q;

     return a;
}

SV * _overload_dec(pTHX_ SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

     *(INT2PTR(float128 *, SvIV(SvRV(a)))) -= 1.0Q;

     return a;
}

SV * _overload_pow(pTHX_ SV * a, SV * b, SV * third) {

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

SV * _overload_pow_eq(pTHX_ SV * a, SV * b, SV * third) {

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

SV * cmp2NV(pTHX_ SV * flt128_obj, SV * sv) {
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

SV * F128toNV(pTHX_ SV * f) {
     return newSVnv((NV)(*(INT2PTR(float128 *, SvIV(SvRV(f))))));
}

/* #define FLT128_MAX 1.18973149535723176508575932662800702e4932Q */

SV * _FLT128_MAX(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = FLT128_MAX;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define FLT128_MIN 3.36210314311209350626267781732175260e-4932Q */

SV * _FLT128_MIN(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = FLT128_MIN;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define FLT128_EPSILON 1.92592994438723585305597794258492732e-34Q */

SV * _FLT128_EPSILON(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = FLT128_EPSILON;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define FLT128_DENORM_MIN 6.475175119438025110924438958227646552e-4966Q */


SV * _FLT128_DENORM_MIN(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = FLT128_DENORM_MIN;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define FLT128_MANT_DIG 113 */

int _FLT128_MANT_DIG(void) {
    return (int)FLT128_MANT_DIG;
}

/* #define FLT128_MIN_EXP (-16381) */

int _FLT128_MIN_EXP(void) {
    return (int)FLT128_MIN_EXP;
}

/* #define FLT128_MAX_EXP 16384 */

int _FLT128_MAX_EXP(void) {
    return (int)FLT128_MAX_EXP;
}

/* #define FLT128_MIN_10_EXP (-4931) */

int _FLT128_MIN_10_EXP(void) {
    return (int)FLT128_MIN_10_EXP;
}

/* #define FLT128_MAX_10_EXP 4932 */

int _FLT128_MAX_10_EXP(void) {
    return (int)FLT128_MAX_10_EXP;
}

/* #define HUGE_VALQ __builtin_huge_valq() */


/*#define M_Eq		2.7182818284590452353602874713526625Q */  /* e */

SV * _M_Eq(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_Eq;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_LOG2Eq	1.4426950408889634073599246810018921Q */  /* log_2 e */

SV * _M_LOG2Eq(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_LOG2Eq;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_LOG10Eq	0.4342944819032518276511289189166051Q */  /* log_10 e */

SV * _M_LOG10Eq(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_LOG10Eq;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_LN2q		0.6931471805599453094172321214581766Q */  /* log_e 2 */

SV * _M_LN2q(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_LN2q;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_LN10q		2.3025850929940456840179914546843642Q */ /* log_e 10 */

SV * _M_LN10q(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_LN10q;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_PIq		3.1415926535897932384626433832795029Q */  /* pi */

SV * _M_PIq(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_PIq;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_PI_2q		1.5707963267948966192313216916397514Q */  /* pi/2 */

SV * _M_PI_2q(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_PI_2q;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_PI_4q		0.7853981633974483096156608458198757Q */  /* pi/4 */

SV * _M_PI_4q(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_PI_4q;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_1_PIq		0.3183098861837906715377675267450287Q */  /* 1/pi */

SV * _M_1_PIq(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_1_PIq;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_2_PIq		0.6366197723675813430755350534900574Q */  /* 2/pi */

SV * _M_2_PIq(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_2_PIq;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_2_SQRTPIq	1.1283791670955125738961589031215452Q */  /* 2/sqrt(pi) */

SV * _M_2_SQRTPIq(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_2_SQRTPIq;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_SQRT2q	1.4142135623730950488016887242096981Q */  /* sqrt(2) */

SV * _M_SQRT2q(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_SQRT2q;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
}

/* #define M_SQRT1_2q	0.7071067811865475244008443621048490Q */  /* 1/sqrt(2) */

SV * _M_SQRT1_2q(pTHX) {
     float128 * f;
     SV * obj_ref, * obj;

     Newx(f, 1, float128);
     if(f == NULL) croak("Failed to allocate memory in NaNF128() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::Float128");

     *f = M_SQRT1_2q;

     sv_setiv(obj, INT2PTR(IV,f));
     SvREADONLY_on(obj);
     return obj_ref;
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
	flt128_set_prec(aTHX_ x);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
flt128_get_prec ()
CODE:
  RETVAL = flt128_get_prec (aTHX);
OUTPUT:  RETVAL


SV *
InfF128 (sign)
	int	sign
CODE:
  RETVAL = InfF128 (aTHX_ sign);
OUTPUT:  RETVAL

SV *
NaNF128 ()
CODE:
  RETVAL = NaNF128 (aTHX);
OUTPUT:  RETVAL


SV *
ZeroF128 (sign)
	int	sign
CODE:
  RETVAL = ZeroF128 (aTHX_ sign);
OUTPUT:  RETVAL

SV *
UnityF128 (sign)
	int	sign
CODE:
  RETVAL = UnityF128 (aTHX_ sign);
OUTPUT:  RETVAL

SV *
is_NaNF128 (b)
	SV *	b
CODE:
  RETVAL = is_NaNF128 (aTHX_ b);
OUTPUT:  RETVAL

SV *
is_InfF128 (b)
	SV *	b
CODE:
  RETVAL = is_InfF128 (aTHX_ b);
OUTPUT:  RETVAL

SV *
is_ZeroF128 (b)
	SV *	b
CODE:
  RETVAL = is_ZeroF128 (aTHX_ b);
OUTPUT:  RETVAL

SV *
STRtoF128 (str)
	char *	str
CODE:
  RETVAL = STRtoF128 (aTHX_ str);
OUTPUT:  RETVAL

SV *
NVtoF128 (nv)
	SV *	nv
CODE:
  RETVAL = NVtoF128 (aTHX_ nv);
OUTPUT:  RETVAL

SV *
IVtoF128 (iv)
	SV *	iv
CODE:
  RETVAL = IVtoF128 (aTHX_ iv);
OUTPUT:  RETVAL

SV *
UVtoF128 (uv)
	SV *	uv
CODE:
  RETVAL = UVtoF128 (aTHX_ uv);
OUTPUT:  RETVAL

void
F128toSTR (f)
	SV *	f
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	F128toSTR(aTHX_ f);
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
	F128toSTRP(aTHX_ f, decimal_prec);
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
	DESTROY(aTHX_ f);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_LDBL_DIG ()
CODE:
  RETVAL = _LDBL_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_DBL_DIG ()
CODE:
  RETVAL = _DBL_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_FLT128_DIG ()
CODE:
  RETVAL = _FLT128_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_overload_add (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_add (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_mul (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_mul (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_sub (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_sub (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_div (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_div (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_not_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_not_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_true (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_true (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_not (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_not (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_add_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_mul_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_sub_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_div_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_lt (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_lt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_gt (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_gt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_lte (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_lte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_gte (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_gte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_spaceship (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_spaceship (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_copy (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_copy (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
F128toF128 (a)
	SV *	a
CODE:
  RETVAL = F128toF128 (aTHX_ a);
OUTPUT:  RETVAL

SV *
_itsa (a)
	SV *	a
CODE:
  RETVAL = _itsa (aTHX_ a);
OUTPUT:  RETVAL

SV *
_overload_abs (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_abs (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_int (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_int (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_sqrt (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_sqrt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_log (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_log (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_exp (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_exp (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_sin (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_sin (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_cos (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_cos (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_atan2 (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_atan2 (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_inc (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_inc (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_dec (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_dec (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_pow (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_pow (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_overload_pow_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = _overload_pow_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
cmp2NV (flt128_obj, sv)
	SV *	flt128_obj
	SV *	sv
CODE:
  RETVAL = cmp2NV (aTHX_ flt128_obj, sv);
OUTPUT:  RETVAL

SV *
F128toNV (f)
	SV *	f
CODE:
  RETVAL = F128toNV (aTHX_ f);
OUTPUT:  RETVAL

SV *
_FLT128_MAX ()
CODE:
  RETVAL = _FLT128_MAX (aTHX);
OUTPUT:  RETVAL


SV *
_FLT128_MIN ()
CODE:
  RETVAL = _FLT128_MIN (aTHX);
OUTPUT:  RETVAL


SV *
_FLT128_EPSILON ()
CODE:
  RETVAL = _FLT128_EPSILON (aTHX);
OUTPUT:  RETVAL


SV *
_FLT128_DENORM_MIN ()
CODE:
  RETVAL = _FLT128_DENORM_MIN (aTHX);
OUTPUT:  RETVAL


int
_FLT128_MANT_DIG ()
		

int
_FLT128_MIN_EXP ()
		

int
_FLT128_MAX_EXP ()
		

int
_FLT128_MIN_10_EXP ()
		

int
_FLT128_MAX_10_EXP ()
		

SV *
_M_Eq ()
CODE:
  RETVAL = _M_Eq (aTHX);
OUTPUT:  RETVAL


SV *
_M_LOG2Eq ()
CODE:
  RETVAL = _M_LOG2Eq (aTHX);
OUTPUT:  RETVAL


SV *
_M_LOG10Eq ()
CODE:
  RETVAL = _M_LOG10Eq (aTHX);
OUTPUT:  RETVAL


SV *
_M_LN2q ()
CODE:
  RETVAL = _M_LN2q (aTHX);
OUTPUT:  RETVAL


SV *
_M_LN10q ()
CODE:
  RETVAL = _M_LN10q (aTHX);
OUTPUT:  RETVAL


SV *
_M_PIq ()
CODE:
  RETVAL = _M_PIq (aTHX);
OUTPUT:  RETVAL


SV *
_M_PI_2q ()
CODE:
  RETVAL = _M_PI_2q (aTHX);
OUTPUT:  RETVAL


SV *
_M_PI_4q ()
CODE:
  RETVAL = _M_PI_4q (aTHX);
OUTPUT:  RETVAL


SV *
_M_1_PIq ()
CODE:
  RETVAL = _M_1_PIq (aTHX);
OUTPUT:  RETVAL


SV *
_M_2_PIq ()
CODE:
  RETVAL = _M_2_PIq (aTHX);
OUTPUT:  RETVAL


SV *
_M_2_SQRTPIq ()
CODE:
  RETVAL = _M_2_SQRTPIq (aTHX);
OUTPUT:  RETVAL


SV *
_M_SQRT2q ()
CODE:
  RETVAL = _M_SQRT2q (aTHX);
OUTPUT:  RETVAL


SV *
_M_SQRT1_2q ()
CODE:
  RETVAL = _M_SQRT1_2q (aTHX);
OUTPUT:  RETVAL


