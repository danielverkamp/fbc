''
''
'' wizard -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __wizard_bi__
#define __wizard_bi__

#include once "wx-c/wx.bi"


declare function wxWizard cdecl alias "wxWizard_ctor" (byval parent as wxWindow ptr, byval id as integer, byval title as zstring ptr, byval bitmap as wxBitmap ptr, byval pos as wxPoint ptr) as wxWizard ptr
declare function wxWizard_RunWizard cdecl alias "wxWizard_RunWizard" (byval self as wxWizard ptr, byval firstPage as wxWizardPage ptr) as integer
declare sub wxWizard_SetPageSize cdecl alias "wxWizard_SetPageSize" (byval self as wxWizard ptr, byval size as wxSize ptr)

#endif
