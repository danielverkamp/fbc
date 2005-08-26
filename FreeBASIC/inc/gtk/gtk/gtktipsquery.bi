''
''
'' gtktipsquery -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __gtktipsquery_bi__
#define __gtktipsquery_bi__

#include once "gtk/gtk/gtklabel.bi"

type GtkTipsQuery as _GtkTipsQuery
type GtkTipsQueryClass as _GtkTipsQueryClass

type _GtkTipsQuery
	label as GtkLabel
	emit_always:1 as guint
	in_query:1 as guint
	label_inactive as zstring ptr
	label_no_tip as zstring ptr
	caller as GtkWidget ptr
	last_crossed as GtkWidget ptr
	query_cursor as GdkCursor ptr
end type

type _GtkTipsQueryClass
	parent_class as GtkLabelClass
	start_query as sub cdecl(byval as GtkTipsQuery ptr)
	stop_query as sub cdecl(byval as GtkTipsQuery ptr)
	widget_entered as sub cdecl(byval as GtkTipsQuery ptr, byval as GtkWidget ptr, byval as zstring ptr, byval as zstring ptr)
	widget_selected as function cdecl(byval as GtkTipsQuery ptr, byval as GtkWidget ptr, byval as zstring ptr, byval as zstring ptr, byval as GdkEventButton ptr) as gint
	_gtk_reserved1 as sub cdecl()
	_gtk_reserved2 as sub cdecl()
	_gtk_reserved3 as sub cdecl()
	_gtk_reserved4 as sub cdecl()
end type

declare function gtk_tips_query_get_type cdecl alias "gtk_tips_query_get_type" () as GtkType
declare function gtk_tips_query_new cdecl alias "gtk_tips_query_new" () as GtkWidget ptr
declare sub gtk_tips_query_start_query cdecl alias "gtk_tips_query_start_query" (byval tips_query as GtkTipsQuery ptr)
declare sub gtk_tips_query_stop_query cdecl alias "gtk_tips_query_stop_query" (byval tips_query as GtkTipsQuery ptr)
declare sub gtk_tips_query_set_caller cdecl alias "gtk_tips_query_set_caller" (byval tips_query as GtkTipsQuery ptr, byval caller as GtkWidget ptr)
declare sub gtk_tips_query_set_labels cdecl alias "gtk_tips_query_set_labels" (byval tips_query as GtkTipsQuery ptr, byval label_inactive as zstring ptr, byval label_no_tip as zstring ptr)

#endif
