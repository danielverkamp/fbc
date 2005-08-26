''
''
'' helpevent -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __helpevent_bi__
#define __helpevent_bi__

#include once "wx-c/wx.bi"

declare function wxHelpEvent cdecl alias "wxHelpEvent_ctor" (byval type as wxEventType) as wxHelpEvent ptr
declare sub wxHelpEvent_GetPosition cdecl alias "wxHelpEvent_GetPosition" (byval self as wxHelpEvent ptr, byval inp as wxPoint ptr)
declare sub wxHelpEvent_SetPosition cdecl alias "wxHelpEvent_SetPosition" (byval self as wxHelpEvent ptr, byval pos as wxPoint ptr)
declare function wxHelpEvent_GetLink cdecl alias "wxHelpEvent_GetLink" (byval self as wxHelpEvent ptr) as wxString ptr
declare sub wxHelpEvent_SetLink cdecl alias "wxHelpEvent_SetLink" (byval self as wxHelpEvent ptr, byval link as zstring ptr)
declare function wxHelpEvent_GetTarget cdecl alias "wxHelpEvent_GetTarget" (byval self as wxHelpEvent ptr) as wxString ptr
declare sub wxHelpEvent_SetTarget cdecl alias "wxHelpEvent_SetTarget" (byval self as wxHelpEvent ptr, byval target as zstring ptr)

#endif
