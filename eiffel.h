/*
-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of
-- another product.
--       Copyright (C) 1994-2002 LORIA - INRIA - U.H.P. Nancy 1 - FRANCE
--          Dominique COLNET and Suzanne COLLIN - SmallEiffel@loria.fr
--                       http://SmallEiffel.loria.fr
--
*/
/*
  This file (SmallEiffel/sys/runtime/base.h) contains all basic Eiffel
  type definitions.
  This file is automatically included in the header for all modes of
  compilation: -boost, -no_check, -require_check, -ensure_check, ...
  This file is also included in the header of any cecil file (when the
  -cecil option is used).
  This file is also included in the header file of C++ wrappers (when
  using the external "C++" clause).
*/
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <signal.h>
#include <stddef.h>
#include <stdarg.h>
#include <limits.h>
#include <float.h>
#include <setjmp.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#ifdef WIN32
#include <windows.h>
#else
#ifndef O_RDONLY
#include <sys/file.h>
#endif
#ifndef O_RDONLY
#define O_RDONLY 0000
#endif
#endif

/* Because ANSI C EXIT_* are not always defined: */
#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#endif
#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif

/*
   On Linux glibc systems, we need to use sig.* versions of jmp_buf,
   setjmp and longjmp to preserve the signal handling context.
   Currently, the way I figured to detect this is if _SIGSET_H_types has
   been defined in /usr/include/setjmp.h.
*/
#ifdef _SIGSET_H_types
#define JMP_BUF    sigjmp_buf
#define SETJMP(x)  sigsetjmp( (x), 1)
#define LONGJMP    siglongjmp
#else
#define JMP_BUF    jmp_buf
#define SETJMP(x)  setjmp( (x) )
#define LONGJMP    longjmp
#endif

/*
   Type to store reference objects Id:
 */
typedef int Tid;
typedef struct S0 T0;
struct S0{Tid id;};

/*
   The default channel used to print runtime error messages:
*/
#define SE_ERR stderr

/*
   Eiffel type INTEGER is #2:
*/
typedef int T2;
#define EIF_INTEGER T2
#define M2 (0)
#define EIF_INTEGER_BITS (CHAR_BIT*sizeof(int))
#define EIF_MINIMUM_INTEGER (INT_MIN)
#define EIF_MAXIMUM_INTEGER (INT_MAX)

/*
  Eiffel type CHARACTER is #3:
*/
typedef unsigned char T3;
#define EIF_CHARACTER T3
#define M3 (0)
#define EIF_CHARACTER_BITS (CHAR_BIT)
#define EIF_MINIMUM_CHARACTER_CODE (0)
#define EIF_MAXIMUM_CHARACTER_CODE (255)
#define T3code(x) ((T2)(x))
#define T3to_integer(x) ((T2)((char)(x)))
#define T3to_bit(x) (x)

/*
  Eiffel type REAL is #4:
*/
typedef float T4;
#define EIF_REAL T4
#define M4 (0.0)
#define EIF_REAL_BITS (CHAR_BIT*sizeof(float))
#define EIF_MINIMUM_REAL (-(FLT_MAX))
#define EIF_MAXIMUM_REAL (FLT_MAX)
#define T2toT4(x) ((T4)(x))

/*
  Eiffel type DOUBLE is #5:
*/
typedef double T5;
#define EIF_DOUBLE T5
#define M5 (0.0)
#define EIF_DOUBLE_BITS (CHAR_BIT*sizeof(double))
#define EIF_MINIMUM_DOUBLE (-(DBL_MAX))
#define EIF_MAXIMUM_DOUBLE (DBL_MAX)
#define T2toT5(x) ((T5)(x))
#define T4toT5(x) ((T5)(x))

/*
  Eiffel type BOOLEAN is #6:
*/
typedef char T6;
#define EIF_BOOLEAN T6
#define M6 (0)
#define EIF_BOOLEAN_BITS (CHAR_BIT)

/*
   Eiffel type POINTER is #8:
*/
typedef void* T8;
#define EIF_POINTER T8
#define M8 (NULL)
#define EIF_POINTER_BITS (CHAR_BIT*sizeof(void*))

/*
  To use type STRING on the C side:
*/
#define EIF_STRING T7*

/*
  Some Other EIF_* defined in ETL:
*/
#define eif_access(x) ((char*)(x))
#define EIF_REFERENCE T0*
#define EIF_OBJ T0*
#define EIF_OBJECT EIF_OBJ

/*
   Wrappers for `malloc' and `calloc':
*/
void* se_malloc(size_t size);
void* se_calloc(size_t nmemb, size_t size);
extern void*eiffel_root_object;

typedef char* T9;
/* Available Eiffel routines via -cecil:
*/
void* EVENTMAKER_make_quit(int C);
void* EVENTMAKER_make_mbdown(int C,T2 a1,T2 a2,T2 a3,T2 a4);
void* EVENTMAKER_make_keydown(int C,T2 a1,T2 a2);
