''
''
'' fcgiapp -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __fcgiapp_bi__
#define __fcgiapp_bi__

#inclib "fcgi"

#define FCGX_UNSUPPORTED_VERSION -2
#define FCGX_PROTOCOL_ERROR -3
#define FCGX_PARAMS_ERROR -4
#define FCGX_CALL_SEQ_ERROR -5

type FCGX_Stream
	rdNext as ubyte ptr
	wrNext as ubyte ptr
	stop as ubyte ptr
	stopUnget as ubyte ptr
	isReader as integer
	isClosed as integer
	wasFCloseCalled as integer
	FCGI_errno as integer
	fillBuffProc as sub cdecl(byval as FCGX_Stream ptr)
	emptyBuffProc as sub cdecl(byval as FCGX_Stream ptr, byval as integer)
	data as any ptr
end type

type FCGX_ParamArray as byte ptr ptr

#define FCGI_FAIL_ACCEPT_ON_INTR 1

type FCGX_Request
	requestId as integer
	role as integer
	in as FCGX_Stream ptr
	out as FCGX_Stream ptr
	err as FCGX_Stream ptr
	envp as byte ptr ptr
	
	'' Don't use anything below here
	paramsPtr as any ptr
	ipcFd as integer
	isBeginProcessed as integer
	keepConnection as integer
	appStatus as integer
	nWriters as integer
	flags as integer
	listen_sock as integer
end type

declare function FCGX_IsCGI cdecl alias "FCGX_IsCGI" () as integer
declare function FCGX_Init cdecl alias "FCGX_Init" () as integer
declare function FCGX_OpenSocket cdecl alias "FCGX_OpenSocket" (byval path as zstring ptr, byval backlog as integer) as integer
declare function FCGX_InitRequest cdecl alias "FCGX_InitRequest" (byval request as FCGX_Request ptr, byval sock as integer, byval flags as integer) as integer
declare function FCGX_Accept_r cdecl alias "FCGX_Accept_r" (byval request as FCGX_Request ptr) as integer
declare sub FCGX_Finish_r cdecl alias "FCGX_Finish_r" (byval request as FCGX_Request ptr)
declare sub FCGX_Free cdecl alias "FCGX_Free" (byval request as FCGX_Request ptr, byval close as integer)
declare function FCGX_Accept cdecl alias "FCGX_Accept" (byval in as FCGX_Stream ptr ptr, byval out as FCGX_Stream ptr ptr, byval err as FCGX_Stream ptr ptr, byval envp as FCGX_ParamArray ptr) as integer
declare sub FCGX_Finish cdecl alias "FCGX_Finish" ()
declare function FCGX_StartFilterData cdecl alias "FCGX_StartFilterData" (byval stream as FCGX_Stream ptr) as integer
declare sub FCGX_SetExitStatus cdecl alias "FCGX_SetExitStatus" (byval status as integer, byval stream as FCGX_Stream ptr)
declare function FCGX_GetParam cdecl alias "FCGX_GetParam" (byval name as zstring ptr, byval envp as FCGX_ParamArray) as zstring ptr
declare function FCGX_GetChar cdecl alias "FCGX_GetChar" (byval stream as FCGX_Stream ptr) as integer
declare function FCGX_UnGetChar cdecl alias "FCGX_UnGetChar" (byval c as integer, byval stream as FCGX_Stream ptr) as integer
declare function FCGX_GetStr cdecl alias "FCGX_GetStr" (byval str as zstring ptr, byval n as integer, byval stream as FCGX_Stream ptr) as integer
declare function FCGX_GetLine cdecl alias "FCGX_GetLine" (byval str as zstring ptr, byval n as integer, byval stream as FCGX_Stream ptr) as zstring ptr
declare function FCGX_HasSeenEOF cdecl alias "FCGX_HasSeenEOF" (byval stream as FCGX_Stream ptr) as integer
declare function FCGX_PutChar cdecl alias "FCGX_PutChar" (byval c as integer, byval stream as FCGX_Stream ptr) as integer
declare function FCGX_PutStr cdecl alias "FCGX_PutStr" (byval str as zstring ptr, byval n as integer, byval stream as FCGX_Stream ptr) as integer
declare function FCGX_PutS cdecl alias "FCGX_PutS" (byval str as zstring ptr, byval stream as FCGX_Stream ptr) as integer
declare function FCGX_FPrintF cdecl alias "FCGX_FPrintF" (byval stream as FCGX_Stream ptr, byval format as zstring ptr, ...) as integer
''''''' declare function FCGX_VFPrintF cdecl alias "FCGX_VFPrintF" (byval stream as FCGX_Stream ptr, byval format as zstring ptr, byval arg as va_list) as integer
declare function FCGX_FFlush cdecl alias "FCGX_FFlush" (byval stream as FCGX_Stream ptr) as integer
declare function FCGX_FClose cdecl alias "FCGX_FClose" (byval stream as FCGX_Stream ptr) as integer
declare function FCGX_GetError cdecl alias "FCGX_GetError" (byval stream as FCGX_Stream ptr) as integer
declare sub FCGX_ClearError cdecl alias "FCGX_ClearError" (byval stream as FCGX_Stream ptr)
declare function FCGX_CreateWriter cdecl alias "FCGX_CreateWriter" (byval socket as integer, byval requestId as integer, byval bufflen as integer, byval streamType as integer) as FCGX_Stream ptr
declare sub FCGX_FreeStream cdecl alias "FCGX_FreeStream" (byval stream as FCGX_Stream ptr ptr)
declare sub FCGX_ShutdownPending cdecl alias "FCGX_ShutdownPending" ()

#endif
