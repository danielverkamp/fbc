'' variable declarations (DIM, REDIM, COMMON, EXTERN or STATIC)
''
'' chng: sep/2004 written [v1ctor]


#include once "fb.bi"
#include once "fbint.bi"
#include once "parser.bi"
#include once "rtl.bi"
#include once "ast.bi"

declare sub cAutoVarDecl( byval attrib as FB_SYMBATTRIB )

sub hComplainIfAbstractClass _
	( _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr _
	)

	if( typeGetDtAndPtrOnly( dtype ) = FB_DATATYPE_STRUCT ) then
		if( symbCompGetAbstractCount( subtype ) > 0 ) then
			errReport( FB_ERRMSG_OBJECTOFABSTRACTCLASS )
		end if
	end if

end sub

sub hSymbolType _
	( _
		byref dtype as integer, _
		byref subtype as FBSYMBOL ptr, _
		byref lgt as longint _
	)

	'' parse the symbol type (INTEGER, STRING, etc...)
	if( cSymbolType( dtype, subtype, lgt ) = FALSE ) then
		errReport( FB_ERRMSG_EXPECTEDIDENTIFIER )
		'' error recovery: fake a type
		dtype = FB_DATATYPE_INTEGER
		subtype = NULL
		lgt = typeGetSize( dtype )
	end if

	'' ANY?
	if( dtype = FB_DATATYPE_VOID ) then
		errReport( FB_ERRMSG_INVALIDDATATYPES )
		'' error recovery: fake a type
		dtype = typeAddrOf( dtype )
		subtype = NULL
		lgt = typeGetSize( dtype )
	end if

end sub

function hCheckScope() as integer
	if( parser.scope > FB_MAINSCOPE ) then
		if( fbIsModLevel( ) = FALSE ) then
			errReport( FB_ERRMSG_ILLEGALINSIDEASUB )
		else
			errReport( FB_ERRMSG_ILLEGALINSIDEASCOPE )
		end if
		function = FALSE
	else
		function = TRUE
	end if
end function

'':::::
''VariableDecl    =   (REDIM PRESERVE?|DIM|COMMON) SHARED? SymbolDef
''				  |   EXTERN IMPORT? SymbolDef ALIAS STR_LIT
''                |   STATIC SymbolDef .
''
function cVariableDecl( byval attrib as FB_SYMBATTRIB ) as integer
	dim as integer dopreserve = any, tk = any

#macro hCheckPrivPubAttrib( attrib )
	if( (attrib and (FB_SYMBATTRIB_PUBLIC or FB_SYMBATTRIB_PRIVATE)) <> 0 ) then
		errReport( FB_ERRMSG_PRIVORPUBTTRIBNOTALLOWED )
		attrib and= not FB_SYMBATTRIB_PUBLIC or FB_SYMBATTRIB_PRIVATE
	end if
#endmacro

	dopreserve = FALSE

	tk = lexGetToken( )

	select case as const tk
	'' REDIM
	case FB_TK_REDIM
		'' REDIM generates code, check if allowed
		if( cCompStmtIsAllowed( FB_CMPSTMT_MASK_CODE ) = FALSE ) then
			hSkipStmt( )
			return TRUE
		end if

		hCheckPrivPubAttrib( attrib )

		lexSkipToken( )
		attrib or= FB_SYMBATTRIB_DYNAMIC

		'' PRESERVE?
		if( hMatch( FB_TK_PRESERVE ) ) then
			dopreserve = TRUE
		end if

	'' COMMON
	case FB_TK_COMMON
		'' can't use COMMON inside a proc or inside a scope block
		if( hCheckScope( ) = FALSE ) then
			'' error recovery: don't share it
			attrib = FB_SYMBATTRIB_STATIC or FB_SYMBATTRIB_DYNAMIC
		else
			attrib or= FB_SYMBATTRIB_COMMON or _
					   FB_SYMBATTRIB_STATIC or _
					   FB_SYMBATTRIB_DYNAMIC	'' this will be removed, if it's not a array
		end if

		hCheckPrivPubAttrib( attrib )

		lexSkipToken( )

	'' EXTERN
	case FB_TK_EXTERN
		if( attrib = FB_SYMBATTRIB_NONE ) then
			'' ambiguity with EXTERN "mangling spec"
			if( lexGetLookAheadClass( 1 ) = FB_TKCLASS_STRLITERAL ) then
				return FALSE
			end if
		end if

		'' can't use EXTERN inside a proc
		if( hCheckScope( ) = FALSE ) then
			'' error recovery: don't make it extern
			attrib = FB_SYMBATTRIB_STATIC
		else
			attrib or= FB_SYMBATTRIB_EXTERN or _
					   FB_SYMBATTRIB_SHARED or _
					   FB_SYMBATTRIB_STATIC
		end if

		hCheckPrivPubAttrib( attrib )

		lexSkipToken( )

	'' STATIC
	case FB_TK_STATIC
		if( cCompStmtIsAllowed( FB_CMPSTMT_MASK_DECL or FB_CMPSTMT_MASK_CODE ) = FALSE ) then
			hSkipStmt( )
			return TRUE
		end if

		lexSkipToken( )

		attrib or= FB_SYMBATTRIB_STATIC

		'' VAR?
		if( lexGetToken( ) = FB_TK_VAR ) then
			cAutoVarDecl( attrib )
			return TRUE
		end if

	'' VAR
	case FB_TK_VAR
		cAutoVarDecl( attrib )
		return TRUE

	case else
		if( cCompStmtIsAllowed( FB_CMPSTMT_MASK_DECL or FB_CMPSTMT_MASK_CODE ) = FALSE ) then
			hSkipStmt( )
			return TRUE
		end if

		lexSkipToken( )

	end select

	'' OPTION DYNAMIC enabled?
	if( env.opt.dynamic ) then
		attrib or= FB_SYMBATTRIB_DYNAMIC
	end if

	if( (attrib and FB_SYMBATTRIB_EXTERN) = 0 ) then
		'' SHARED?
		if( lexGetToken( ) = FB_TK_SHARED ) then
			'' can't use SHARED inside a proc
			if( hCheckScope( ) = FALSE ) then
				'' error recovery: don't make it shared
				attrib or= FB_SYMBATTRIB_STATIC
			else
				attrib or= FB_SYMBATTRIB_SHARED or _
						   FB_SYMBATTRIB_STATIC
			end if
			lexSkipToken( )
		end if
	else
		'' IMPORT?
		if( lexGetToken( ) = FB_TK_IMPORT ) then
			lexSkipToken( )

			'' only if target is Windows
			select case env.clopt.target
			case FB_COMPTARGET_WIN32, FB_COMPTARGET_CYGWIN
				attrib or= FB_SYMBATTRIB_IMPORT
			end select
		end if
	end if

	if( symbGetProcStaticLocals( parser.currproc ) ) then
		attrib or= FB_SYMBATTRIB_STATIC
	end if

	cVarDecl( attrib, dopreserve, tk, FALSE )
	function = TRUE
end function

'':::::
private function hIsConst _
	( _
		byval dimensions as integer, _
		exprTB() as ASTNODE ptr _
	) as integer

	for i as integer = 0 to dimensions-1
		if( astIsCONST( exprTB(i, 0) ) = FALSE ) then
			return FALSE
		elseif( exprTB(i, 1) = NULL ) then
			'' do nothing, allow NULL expression here for ellipsis
		elseif( astIsCONST( exprTB(i, 1) ) = FALSE ) then
			return FALSE
		end if
	next

	function = TRUE

end function

'':::::
private sub hVarExtToPub _
	( _
		byval sym as FBSYMBOL ptr, _
		byval attrib as FB_SYMBATTRIB _
	)

	'' Remove EXTERN (or it won't be emitted), add PUBLIC (and SHARED
	'' for safety), and preserve visibility attributes.
	symbSetAttrib( sym, (symbGetAttrib( sym ) and (not FB_SYMBATTRIB_EXTERN)) or _
				FB_SYMBATTRIB_PUBLIC or FB_SYMBATTRIB_SHARED )

    '' array? update the descriptor attributes too
    if( symbGetArrayDimensions( sym ) <> 0 ) then
    	dim as FBSYMBOL ptr desc = symbGetArrayDescriptor( sym )

    	attrib = (symbGetAttrib( desc ) and (not FB_SYMBATTRIB_EXTERN)) or _
    	  	  	 FB_SYMBATTRIB_SHARED

    	'' not dynamic? descriptor can't be public
    	if( symbIsDynamic( sym ) = FALSE ) then
			attrib and= not FB_SYMBATTRIB_PUBLIC
		else
			attrib or= FB_SYMBATTRIB_PUBLIC
		end if

		symbSetAttrib( desc, attrib )

		'' Add an initializer to the descriptor, now that we know this
		'' EXTERN will be allocated in this module, and the EXTERN
		'' attribute was removed
		symbSetTypeIniTree( desc, astBuildArrayDescIniTree( desc, sym, NULL ) )
	end if

end sub

private sub hCheckExternArrayDimensions _
	( _
		byval sym as FBSYMBOL ptr, _
		byval id as zstring ptr, _
		byval dimensions as integer, _
		dTB() as FBARRAYDIM _
	)

	'' Not an array?
	if( symbGetArrayDimensions( sym ) = 0 ) then
		exit sub
	end if

	'' Different dimension count?
	if( dimensions <> symbGetArrayDimensions( sym ) ) then
		errReportEx( FB_ERRMSG_WRONGDIMENSIONS, *id )
		exit sub
	end if

	'' Same lbound/ubound for each dimension?
	for i as integer = 0 to dimensions - 1
		if( (symbArrayLbound( sym, i ) <> dTB(i).lower) or _
		    ((symbArrayUbound( sym, i ) <> dTB(i).upper) and _
		     (dTB(i).upper <> FB_ARRAYDIM_UNKNOWN)) ) then
			errReportEx( FB_ERRMSG_BOUNDSDIFFERFROMEXTERN, *id )
			exit sub
		end if
	next

end sub

private function hDeclExternVar _
	( _
		byval sym as FBSYMBOL ptr, _
		byval id as zstring ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval attrib as integer, _
		byval addsuffix as integer, _
		byval dimensions as integer, _
		dTB() as FBARRAYDIM _
	) as FBSYMBOL ptr

    function = NULL

    if( sym = NULL ) then
    	exit function
    end if

    '' not extern?
    if( symbIsExtern( sym ) = FALSE ) then
    	exit function
    end if

    '' check type
	if( (dtype <> symbGetFullType( sym )) or _
		(subtype <> symbGetSubType( sym )) ) then
		errReportEx( FB_ERRMSG_TYPEMISMATCH, *id )
	end if

	dim as integer setattrib = TRUE

	'' dynamic?
	if( symbIsDynamic( sym ) ) then
		if( (attrib and FB_SYMBATTRIB_DYNAMIC) = 0 ) then
			errReportEx( FB_ERRMSG_EXPECTEDDYNAMICARRAY, *id )
		end if

	'' static..
	else
		if( (attrib and FB_SYMBATTRIB_DYNAMIC) <> 0 ) then
			errReportEx( FB_ERRMSG_EXPECTEDDYNAMICARRAY, *id )
		end if

		'' no extern static as local
		if( hCheckScope( ) = FALSE ) then
			'' error recovery: don't make it shared
			setattrib = FALSE
		end if
	end if

	hCheckExternArrayDimensions( sym, id, dimensions, dTB() )

    '' dup extern?
    if( (attrib and FB_SYMBATTRIB_EXTERN) <> 0 ) then
    	return sym
    end if

    '' set type
    if( setattrib ) then
    	hVarExtToPub( sym, attrib )
	end if

    function = sym
end function

'':::::
private function hDeclStaticVar _
	( _
		byval sym as FBSYMBOL ptr, _
		byval id as zstring ptr, _
		byval idalias as zstring ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval lgt as longint, _
		byval addsuffix as integer, _
		byval attrib as integer, _
		byval dimensions as integer, _
		dTB() as FBARRAYDIM _
	) as FBSYMBOL ptr

    '' any var already defined?
    dim as integer is_extern = any
    if( sym <> NULL ) then
    	is_extern = symbIsExtern( sym )
    else
    	is_extern = FALSE
    end if

    '' new (or dup) var?
    if( is_extern = FALSE ) then
		dim as FB_SYMBOPT options = FB_SYMBOPT_NONE

		if( addsuffix ) then
			attrib or= FB_SYMBATTRIB_SUFFIXED
		end if

		if( fbLangOptIsSet( FB_LANG_OPT_SCOPE ) = FALSE ) then
			options or= FB_SYMBOPT_UNSCOPE
		end if

		sym = symbAddVar( id, idalias, dtype, subtype, lgt, _
		                  dimensions, dTB(), attrib, options )

    '' already declared extern..
    else
    	sym = hDeclExternVar( sym, id, dtype, subtype, attrib, _
    		  			      addsuffix, dimensions, dTB() )
	end if

	if( sym = NULL ) then
		errReportEx( FB_ERRMSG_DUPDEFINITION, id )
		'' no error recovery: already parsed
	end if

	function = sym

end function

private function hDeclDynArray _
	( _
		byval sym as FBSYMBOL ptr, _
		byval id as zstring ptr, _
		byval idalias as zstring ptr, _
		byval dtype as integer, _
		byval subtype as FBSYMBOL ptr, _
		byval is_typeless as integer, _
		byval lgt as longint, _
		byval addsuffix as integer, _
		byval attrib as integer, _
		byval dimensions as integer, _
		byval token as integer _
	) as FBSYMBOL ptr

    static as FBARRAYDIM dTB(0 to FB_MAXARRAYDIMS-1)		'' always 0

    function = NULL

    if( dimensions <> -1 ) then
		'' DIM'g dynamic arrays gens code, check if allowed
    	if( cCompStmtIsAllowed( FB_CMPSTMT_MASK_CODE ) = FALSE ) then
		hSkipStmt( )
    		exit function
    	end if
	end if

    '' any variable already defined?
    if( sym <> NULL ) then
    	'' array in a udt?
    	if( symbIsField( sym ) ) then
    		errReportEx( FB_ERRMSG_CANTREDIMARRAYFIELDS, *id )
    		exit function
    	end if

   		'' typeless REDIM's?
   		if( is_typeless ) then
   			dtype = symbGetType( sym )
   			subtype = symbGetSubtype( sym )
   			lgt = symbGetLen( sym )
   		end if
    end if

    '' new var?
   	if( sym = NULL ) then
		dim as FB_SYMBOPT options = FB_SYMBOPT_NONE

		if( addsuffix ) then
			attrib or= FB_SYMBATTRIB_SUFFIXED
		end if

		if( fbLangOptIsSet( FB_LANG_OPT_SCOPE ) = FALSE ) then
			options or= FB_SYMBOPT_UNSCOPE
		end if

		sym = symbAddVar( id, idalias, dtype, subtype, lgt, _
		                  -1, dTB(), attrib, options )

	'' check reallocation..
	else
		'' not dynamic?
		if( symbGetIsDynamic( sym ) = FALSE ) then
   			'' could be an external..
   			sym = hDeclExternVar( sym, id, dtype, subtype, attrib, addsuffix, _
   								  dimensions, dTB() )
		else
			'' var already exists; dup checks

			'' EXTERNal?
			if( symbIsExtern( sym ) ) then
				'' another EXTERN? (declared twice)
				if( (attrib and FB_SYMBATTRIB_EXTERN) <> 0 ) then
   					sym = NULL
				else
	   				'' define it...
					hVarExtToPub( sym, attrib )
				end if
			'' [re]dim ()?
			elseif( dimensions = -1 ) then
				sym = NULL

			'' dim foo(variable)? (without a preceeding COMMON)
			elseif( (token <> FB_TK_REDIM) and (symbIsCommon( sym ) = FALSE) ) then
				sym = NULL
			end if
		end if
	end if

   	if( sym = NULL ) then
   		errReportEx( FB_ERRMSG_DUPDEFINITION, *id )
		'' no error recovery, caller will take care of that
		exit function
	end if

	'' don't allow const dynamic arrays...
	'' they can't be assigned even if resized...
	if( typeIsConst( symbGetFullType( sym ) ) ) then
		errReport( FB_ERRMSG_DYNAMICARRAYSCANTBECONST )
	end if

	attrib = symbGetAttrib( sym )

	'' external? don't do any checks..
	if( (attrib and FB_SYMBATTRIB_EXTERN) <> 0 ) then
		return sym
	end if

	if( (dtype <> symbGetFullType( sym )) or _
	    (subtype <> symbGetSubType( sym )) ) then
		errReportEx( FB_ERRMSG_DUPDEFINITION, *id )
		'' no error recovery, caller will take care of that
		exit function
	end if

	'' Check dimensions, unless it's a bydesc param or a COMMON array,
	'' then we don't know the dimensions at compile-time.
	if( (attrib and (FB_SYMBATTRIB_PARAMBYDESC or FB_SYMBATTRIB_COMMON)) = 0 ) then
		if( symbGetArrayDimensions( sym ) > 0 ) then
			if( dimensions <> symbGetArrayDimensions( sym ) ) then
				errReportEx( FB_ERRMSG_WRONGDIMENSIONS, *id )
				'' no error recovery, ditto
				exit function
			end if
		end if
	end if

    function = sym
end function

'':::::
private function hGetId _
	( _
		byval parent as FBSYMBOL ptr, _
		byval id as zstring ptr, _
		byref suffix as integer, _
		byval options as FB_IDOPT _
	) as FBSYMCHAIN ptr

	dim as FBSYMCHAIN ptr chain_ = any

	'' no parent? read as-is
	if( parent = NULL ) then
		chain_ = lexGetSymChain( )
	else
		chain_ = symbLookupAt( parent, _
							   lexGetText( ), _
							   FALSE, _
							   (options and FB_IDOPT_ISDECL) = 0 )
	end if

	'' ID
	select case as const lexGetClass( )
	case FB_TKCLASS_IDENTIFIER
		if( fbLangOptIsSet( FB_LANG_OPT_PERIODS ) ) then
			'' if inside a namespace, symbols can't contain periods (.)'s
			if( symbIsGlobalNamespc( ) = FALSE ) then
				if( lexGetPeriodPos( ) > 0 ) then
					errReport( FB_ERRMSG_CANTINCLUDEPERIODS )
				end if
			end if
		end if

		*id = *lexGetText( )
		suffix = lexGetType( )

	case FB_TKCLASS_QUIRKWD
		if( env.clopt.lang <> FB_LANG_QB ) then
			'' only if inside a ns and if not local
			if( (parent = NULL) or (parser.scope > FB_MAINSCOPE) ) then
				errReport( FB_ERRMSG_DUPDEFINITION )
				'' error recovery: fake an id
				*id = *symbUniqueLabel( )
				suffix = FB_DATATYPE_INVALID
			else
				*id = *lexGetText( )
				suffix = lexGetType( )
			end if

		'' QB mode..
		else
			*id = *lexGetText( )
			suffix = lexGetType( )
		end if

	case FB_TKCLASS_KEYWORD, FB_TKCLASS_OPERATOR
		if( env.clopt.lang <> FB_LANG_QB ) then
			errReport( FB_ERRMSG_DUPDEFINITION )
			'' error recovery: fake an id
			*id = *symbUniqueLabel( )
			suffix = FB_DATATYPE_INVALID

		'' QB mode..
		else
			*id = *lexGetText( )
			suffix = lexGetType( )

			'' must have a suffix if it is a keyword
			if( suffix = FB_DATATYPE_INVALID ) then
				errReport( FB_ERRMSG_DUPDEFINITION )
				'' error recovery: fake an id
				*id = *symbUniqueLabel( )
				suffix = FB_DATATYPE_INVALID
			end if
		end if

	case else
		errReport( FB_ERRMSG_EXPECTEDIDENTIFIER )
		'' error recovery: fake an id
		*id = *symbUniqueLabel( )
		suffix = FB_DATATYPE_INVALID
	end select

	hCheckSuffix( suffix )

	lexSkipToken( )

	function = chain_

end function

private function hLookupVar _
	( _
		byval chain_ as FBSYMCHAIN ptr, _
		byval dtype as integer, _
		byval is_typeless as integer, _
		byval has_suffix as integer _
	) as FBSYMBOL ptr

	dim as FBSYMBOL ptr sym = any

	if( chain_ = NULL ) then
		exit function
	end if

	if( is_typeless ) then
		if( fbLangOptIsSet( FB_LANG_OPT_DEFTYPE ) ) then
			sym = symbFindVarByDefType( chain_, dtype )
		else
			sym = symbFindByClass( chain_, FB_SYMBCLASS_VAR )
		end if
	elseif( has_suffix ) then
		sym = symbFindVarBySuffix( chain_, dtype )
	else
		sym = symbFindVarByType( chain_, dtype )
	end if

	function = sym
end function

private function hLookupVarAndCheckParent _
	( _
		byval parent as FBSYMBOL ptr, _
		byval chain_ as FBSYMCHAIN ptr, _
		byval dtype as integer, _
		byval is_typeless as integer, _
		byval has_suffix as integer, _
		byval is_decl as integer _
	) as FBSYMBOL ptr

	dim as FBSYMBOL ptr sym = any

	sym = hLookupVar( chain_, dtype, is_typeless, has_suffix )

	'' Namespace prefix explicitly given?
	if( parent ) then
		if( sym ) then
			'' "DIM Parent.foo" is only allowed if there was an
			'' "EXTERN foo" in the Parent namespace, or if it's a
			'' "REDIM Parent.foo" redimming an array declared in
			'' the Parent namespace.
			'' No EXTERN, or different parent, and not REDIM?
			if( ((symbIsExtern( sym ) = FALSE) or _
			     (symbGetNamespace( sym ) <> parent)) and _
			    is_decl ) then
				errReport( FB_ERRMSG_DECLOUTSIDECLASS )
			end if
		else
			'' Symbol not found in the specified parent namespace
			errReport( FB_ERRMSG_DECLOUTSIDENAMESPC, TRUE )
		end if
	else
		'' The looked up symbol may be an existing var. If it's from
		'' another namespace, then we ignore it, so that this new
		'' declaration declares a new var in the current namespace,
		'' i.e. a duplicate. However if it's from the current namespace
		'' already, then we cannot allow declaring a second variable
		'' with that name. Unless this is a REDIM, of course.
		if( sym ) then
			if( (symbGetNamespace( sym ) <> symbGetCurrentNamespc( )) and _
			    is_decl ) then
				sym = NULL
			end if
		end if
	end if

	function = sym
end function

private sub hMakeArrayDimTB _
	( _
		byval dimensions as integer, _
		exprTB() as ASTNODE ptr, _
		dTB() as FBARRAYDIM _
	)

	if( dimensions = -1 ) then
		exit sub
	end if

	for i as integer = 0 to dimensions-1
		dim as ASTNODE ptr expr = any

		'' lower bound
		dTB(i).lower = astConstFlushToInt( exprTB(i, 0) )

		'' upper bound
		expr = exprTB(i, 1)
		if( expr = NULL ) then
			'' if a null expr is found, that means it was an ellipsis for the
			'' upper bound, so we set a special upper value, and CONTINUE in
			'' order to skip the check
			dTB(i).upper = FB_ARRAYDIM_UNKNOWN
			continue for
		else
			dTB(i).upper = astConstFlushToInt( expr )
		end if

		'' Besides the upper < lower case, also complain about FB_ARRAYDIM_UNKNOWN being
		'' specified, otherwise we'd think ellipsis was given...
		if( (dTB(i).upper < dTB(i).lower) or (dTB(i).upper = FB_ARRAYDIM_UNKNOWN) ) then
			errReport( FB_ERRMSG_INVALIDSUBSCRIPT )
    	end if
	next

end sub

'':::::
private function hVarInitDefault _
	( _
		byval sym as FBSYMBOL ptr, _
		byval is_decl as integer, _
		byval has_defctor as integer _
	) as ASTNODE ptr

	function = NULL

	if( sym = NULL ) then
		exit function
	end if

	'' No default initialization for EXTERNs
	'' (they're initialized when defined by corresponding DIM)
	if( symbIsExtern( sym ) ) then
		exit function
	end if

	'' If it's marked as CONST we require it to have an initializer,
	'' because that's the only way for the coder to set the value.
	if( typeIsConst( symbGetFullType( sym ) ) ) then
		errReport( FB_ERRMSG_AUTONEEDSINITIALIZER )
		'' error recovery: fake an expr
		return astNewCONSTi( 0 )
	end if

	'' Has default constructor?
	if( has_defctor ) then
		'' not already declared nor dynamic array?
		if( (not is_decl) and ((symbGetAttrib( sym ) and (FB_SYMBATTRIB_DYNAMIC or FB_SYMBATTRIB_COMMON)) = 0) ) then
			'' Check visibility
			if( symbCheckAccess( symbGetCompDefCtor( symbGetSubtype( sym ) ) ) = FALSE ) then
				errReport( FB_ERRMSG_NOACCESSTODEFAULTCTOR )
			end if
			function = astBuildTypeIniCtorList( sym )
		end if
	else
		'' Complain about lack of default ctor if there are others
		if( symbHasCtor( sym ) ) then
			errReport( FB_ERRMSG_NODEFAULTCTORDEFINED )
		end if
	end if

end function

'':::::
private function hVarInit _
	( _
        byval sym as FBSYMBOL ptr, _
        byval isdecl as integer _
	) as ASTNODE ptr

	dim as integer attrib = any, ignoreattribs = any
	dim as ASTNODE ptr initree = any

	function = NULL

	if( sym <> NULL ) then
		attrib = symbGetAttrib( sym )
	else
		attrib = 0
	end if

	'' already declared, extern or common?
	if( isdecl or _
		((attrib and (FB_SYMBATTRIB_EXTERN or FB_SYMBATTRIB_COMMON)) <> 0) ) then
		errReport( FB_ERRMSG_CANNOTINITEXTERNORCOMMON )
		'' error recovery: skip
		hSkipUntil( FB_TK_EOL )
		exit function
	end if

	if( fbLangOptIsSet( FB_LANG_OPT_INITIALIZER ) = FALSE ) then
		errReportNotAllowed( FB_LANG_OPT_INITIALIZER )
		'' error recovery: skip
		hSkipUntil( FB_TK_EOL )
		exit function
	end if

	'' '=' | '=>'
	lexSkipToken( )

	if( sym = NULL ) then
		'' error recovery: skip until next ','
		hSkipUntil( CHAR_COMMA )
		exit function
	end if

    '' ANY?
	if( lexGetToken( ) = FB_TK_ANY ) then

		'' don't allow arrays with ellipsis denoting unknown size at this time
		if( symbArrayHasUnknownDimensions( sym ) ) then
			errReport( FB_ERRMSG_CANTUSEANYINITELLIPSIS )
			exit function
		end if

		'' don't allow var-len strings
		if( symbGetType( sym ) = FB_DATATYPE_STRING ) then
			errReport( FB_ERRMSG_INVALIDDATATYPES )
		else
			symbSetDontInit( sym )
		end if

		'' ...or const-qualified vars
		if( typeIsConst( symbGetFullType( sym ) ) ) then
			errReport( FB_ERRMSG_AUTONEEDSINITIALIZER )
			'' error recovery: fake an expr
			return astNewCONSTi( 0 )
		end if

		lexSkipToken( )
		exit function
	end if

	initree = cInitializer( sym, FB_INIOPT_ISINI )
	if( initree = NULL ) then
		'' fake an expression
		initree = astNewCONSTi( 0 )
	end if

	'' static or shared?
	if( (symbGetAttrib( sym ) and (FB_SYMBATTRIB_STATIC or FB_SYMBATTRIB_SHARED)) <> 0 ) then
		''
		'' In general, STATIC/SHARED var initializers must be constants,
		'' that includes OFFSETs (address of other global symbols),
		'' because they're emitted into .data/.bss sections, so no code
		'' (that needs to be executed) can be allowed.
		''
		'' (Currently) the only exception are vars with constructors:
		'' - the constructor must be called with certain parameters
		'' - so code is executed, and the initializer can aswell allow
		''   more than just constants
		'' - temp vars are ok, because they will be duplicated as
		''   needed by the TYPEINI scope handling
		'' - local non-static vars cannot be allowed, since they're
		''   from a different scope
		''
		'' SHARED var initializers must not reference local STATICs,
		'' because those symbols will be deleted by the time the global
		'' is emitted. This can only happen with STATICs from the
		'' implicit main() because those from inside procedures aren't
		'' visible to SHARED declarations at the toplevel.
		''
		'' The other way round (STATIC non-SHARED initializer using a
		'' non-STATIC SHARED) is ok though; it will be "forward
		'' referenced" in the .asm output, because STATICs are emitted
		'' before globals, but it works.
		''
		'' Even constant initializers can reference other global vars,
		'' in form of OFFSETs (address-of), because of this the
		'' astTypeIniUsesLocals() check must run in both constant and
		'' non-constant initializer cases.
		''

		'' Check for constant initializer?
		'' (doing this check first, it results in a nicer error message)
		if( symbHasCtor( sym ) = FALSE ) then
			if( astTypeIniIsConst( initree ) = FALSE ) then
				errReport( FB_ERRMSG_EXPECTEDCONST )
				'' error recovery: discard the tree
				astDelTree( initree )
				exit function
			end if
		end if

		'' Ensure the initializer doesn't reference any vars it mustn't

		'' Allow temp vars and temp array descriptors
		ignoreattribs = FB_SYMBATTRIB_TEMP or FB_SYMBATTRIB_DESCRIPTOR

		'' Allow only non-SHARED STATICs to reference STATICs
		if( symbIsShared( sym ) = FALSE ) then
			ignoreattribs or= FB_SYMBATTRIB_STATIC
		end if

		if( astTypeIniUsesLocals( initree, ignoreattribs ) ) then
			errReport( FB_ERRMSG_INVALIDREFERENCETOLOCAL )
			'' error recovery: discard the tree
			astDelTree( initree )
			exit function
		end if
	end if

	function = initree
end function

'':::::
function hFlushDecl _
	( _
		byval var_decl as ASTNODE ptr _
	) as ASTNODE ptr

	'' respect scopes?
	if( fbLangOptIsSet( FB_LANG_OPT_SCOPE ) ) then
		function = var_decl

	'' move to function scope..
	else
		'' note: addUnscoped() won't flush the dtor list
		astAddUnscoped( var_decl )
		function = NULL
	end if

end function

private function hWrapInStaticFlag( byval code as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr t = any
	dim as FBARRAYDIM dTB(0) = any
	dim as FBSYMBOL ptr flag = any, label = any

	'' static flag as integer
	flag = symbAddVar( symbUniqueLabel( ), NULL, FB_DATATYPE_INTEGER, NULL, 0, _
	                   0, dTB(), FB_SYMBATTRIB_STATIC )
	symbSetIsImplicit( flag )
	t = astNewDECL( flag, TRUE )

	'' if flag = 0 then
	label = symbAddLabel( NULL )
	t = astNewLINK( t, _
		astBuildBranch( _
			astNewBOP( AST_OP_EQ, astNewVAR( flag ), astNewCONSTi( 0 ) ), _
			label, FALSE ) )

	'' flag = 1
	t = astNewLINK( t, astBuildVarAssign( flag, 1 ) )

	'' <code>
	t = astNewLINK( t, code )

	'' end if
	function = astNewLINK( t, astNewLABEL( label ) )
end function

private function hCallStaticCtor _
	( _
		byval sym as FBSYMBOL ptr, _
		byval var_decl as ASTNODE ptr, _
		byval initree as ASTNODE ptr, _
		byval has_dtor as integer _
	) as ASTNODE ptr

	dim as ASTNODE ptr t = any, initcode = any
	dim as FBSYMBOL ptr proc = any

	t = hFlushDecl( var_decl )
	initcode = NULL

	if( initree ) then
		'' static var's initializer
		initcode = astTypeIniFlush( sym, initree, AST_INIOPT_ISINI )
	end if

	if( has_dtor ) then
		'' Register an atexit() handler to call the static var's dtor
		'' at program exit.
		'' atexit( @static_proc )
		proc = astProcAddStaticInstance( sym )
		initcode = astNewLINK( initcode, rtlAtExit( astBuildProcAddrof( proc ) ) )
	end if

	'' Any initialization code for a static var must be wrapped with a
	'' static flag, to ensure it'll be only executed once, not everytime the
	'' parent procedure is called.
	if( initcode ) then
		t = astNewLINK( t, hWrapInStaticFlag( initcode ) )
	end if

	function = t
end function

'':::::
private function hCallGlobalCtor _
	( _
		byval sym as FBSYMBOL ptr, _
		byval var_decl as ASTNODE ptr, _
		byval initree as ASTNODE ptr, _
		byval has_dtor as integer _
	) as ASTNODE ptr

	var_decl = hFlushDecl( var_decl )

	if( (initree = NULL) and (has_dtor = FALSE) ) then
		return var_decl
	end if

	astProcAddGlobalInstance( sym, initree, has_dtor )

	'' No temp dtors should be left registered after the TYPEINI build-up
	assert( astDtorListIsEmpty( ) )

	'' cannot call astAdd() before deleting the dtor list or it
	'' would be flushed
	function = var_decl

end function

'':::::
private function hFlushInitializer _
	( _
		byval sym as FBSYMBOL ptr, _
		byval var_decl as ASTNODE ptr, _
		byval initree as ASTNODE ptr, _
		byval has_dtor as integer _
	) as ASTNODE ptr

	'' object?
	if( has_dtor ) then
		'' check visibility
		if( symbCheckAccess( symbGetCompDtor( symbGetSubtype( sym ) ) ) = FALSE ) then
			errReport( FB_ERRMSG_NOACCESSTODTOR )
		end if
	end if

	'' no initializer?
	if( initree = NULL ) then
		'' static or shared?
        if( (symbGetAttrib( sym ) and (FB_SYMBATTRIB_STATIC or _
        						   	   FB_SYMBATTRIB_SHARED or _
        						   	   FB_SYMBATTRIB_COMMON)) <> 0 ) then
			'' object?
        	if( has_dtor ) then
        		'' local?
           		if( symbIsLocal( sym ) ) then
           			var_decl = hCallStaticCtor( sym, var_decl, NULL, TRUE )

           		'' global..
          		else
        			var_decl = hCallGlobalCtor( sym, var_decl, NULL, TRUE )
           		end if
			end if
		end if

		return var_decl
	end if

	'' not static or shared?
    if( (symbGetAttrib( sym ) and (FB_SYMBATTRIB_STATIC or _
    							   FB_SYMBATTRIB_SHARED or _
    							   FB_SYMBATTRIB_COMMON)) = 0 ) then

		var_decl = hFlushDecl( var_decl )

		return astNewLINK( var_decl, astTypeIniFlush( sym, initree, AST_INIOPT_ISINI ) )
	end if

	'' not an object?
	if( symbHasCtor( sym ) = FALSE ) then
		'' let emit flush it..
		symbSetTypeIniTree( sym, initree )

		'' no dtor?
		if( has_dtor = FALSE ) then
			return hFlushDecl( var_decl )
		end if

		'' must be added to the dtor list..
		initree = NULL
	end if

    '' local?
    if( symbIsLocal( sym ) ) then
       	'' the only possibility is static, SHARED can't be
        '' used in -lang fb..
        function = hCallStaticCtor( sym, var_decl, initree, has_dtor )

	'' global.. add to the list, to be emitted later
    else
    	function = hCallGlobalCtor( sym, var_decl, initree, has_dtor )
	end if

end function

'':::::
''VarDecl         =   ID ('(' ArrayDecl? ')')? (AS SymbolType)? ('=' VarInitializer)?
''                       (',' SymbolDef)* .
''
function cVarDecl _
	( _
		byval attrib as integer, _
		byval dopreserve as integer, _
		byval token as integer, _
		byval is_fordecl as integer _
	) as FBSYMBOL ptr

    static as zstring * FB_MAXNAMELEN+1 id
    static as ASTNODE ptr exprTB(0 to FB_MAXARRAYDIMS-1, 0 to 1)
    static as FBARRAYDIM dTB(0 to FB_MAXARRAYDIMS-1)
    dim as FBSYMBOL ptr sym, subtype = any
	dim as ASTNODE ptr initree = any, redimcall = any
	dim as integer addsuffix = any, is_multdecl = any
	dim as integer is_typeless = any, is_decl = any
	dim as integer dtype = any
	dim as longint lgt = any
    dim as integer dimensions = any, suffix = any
    dim as zstring ptr palias = any
    dim as ASTNODE ptr assign_initree = any
	dim as FB_IDOPT options = any

    function = NULL

	'' inside a namespace but outside a proc?
	if( symbIsGlobalNamespc( ) = FALSE ) then
		if( fbIsModLevel( ) ) then
			'' variables will be always shared..
			attrib or= FB_SYMBATTRIB_SHARED or FB_SYMBATTRIB_STATIC
		end if
	end if

	'' (AS SymbolType)?
	is_multdecl = FALSE
	if( lexGetToken( ) = FB_TK_AS ) then
		lexSkipToken( )

		'' parse the symbol type (INTEGER, STRING, etc...)
		hSymbolType( dtype, subtype, lgt )

		'' Disallow creating objects of abstract classes
		hComplainIfAbstractClass( dtype, subtype )

		addsuffix = FALSE
		is_multdecl = TRUE
	end if

	options = FB_IDOPT_DEFAULT or FB_IDOPT_ALLOWSTRUCT or FB_IDOPT_ISVAR

	'' It's a declaration unless it's a REDIM (REDIMs are code,
	'' not declarations), except when it's SHARED, because a REDIM SHARED
	'' is always a declaration and never a code REDIM.
	if( (token <> FB_TK_REDIM) or ((attrib and FB_SYMBATTRIB_SHARED) <> 0) ) then
		options or= FB_IDOPT_ISDECL
	end if

    do
		dim as FBSYMBOL ptr parent = cParentId( options )
		dim as FBSYMCHAIN ptr chain_ = hGetId( parent, @id, suffix, options )

		is_typeless = FALSE

    	if( is_multdecl = FALSE ) then
    		dtype = suffix
    		subtype	= NULL
    		lgt	= 0
    		addsuffix = TRUE
    	else
    		'' the user did 'DIM AS _____', and then
    		'' specified a suffix on a symbol, e.g.
    		''
    		'' DIM AS INTEGER x, y$
    		if( suffix <> FB_DATATYPE_INVALID ) then
				errReportEx( FB_ERRMSG_SYNTAXERROR, @id )
				'' error recovery: the symbol gets the
				'' type specified 'AS'
				suffix = FB_DATATYPE_INVALID
    		end if
    	end if

		'' ('(' ArrayDecl? ')')?
		dimensions = 0
		if( (lexGetToken( ) = CHAR_LPRNT) and (is_fordecl = FALSE) ) then
			lexSkipToken( )

			'' '()'
			if( lexGetToken( ) = CHAR_RPRNT ) then
				'' fake it
				dimensions = -1
				attrib or= FB_SYMBATTRIB_DYNAMIC

			'' '(' ArrayDecl ')'
			else
				'' COMMON? No subscripts allowed
				if( attrib and FB_SYMBATTRIB_COMMON ) then
					errReport( FB_ERRMSG_SYNTAXERROR )
					'' error recovery: skip until next ')'
					hSkipUntil( CHAR_RPRNT )
				else
					cArrayDecl( dimensions, exprTB() )
				end if
			end if

			'' ')'
			if( lexGetToken( ) <> CHAR_RPRNT ) then
				errReport( FB_ERRMSG_EXPECTEDRPRNT )
			else
				lexSkipToken( )
			end if

		'' Scalar, no array subscripts
		else
			'' With REDIM it must have array subscripts though
			if( token = FB_TK_REDIM ) then
				errReportEx( FB_ERRMSG_EXPECTEDARRAY, @id )
			end if

			'' (could have been added due to OPTION DYNAMIC,
			'' but if it's not an array, then it can't be DYNAMIC)
			attrib and= not FB_SYMBATTRIB_DYNAMIC
		end if

		palias = NULL
		if( (attrib and (FB_SYMBATTRIB_PUBLIC or FB_SYMBATTRIB_EXTERN)) <> 0 ) then
			'' [ALIAS "id"]
			palias = cAliasAttribute()
		end if

		if( is_multdecl = FALSE ) then
			'' (AS SymbolType)?
			if( lexGetToken( ) = FB_TK_AS ) then
				if( dtype <> FB_DATATYPE_INVALID ) then
					errReport( FB_ERRMSG_SYNTAXERROR )
					dtype = FB_DATATYPE_INVALID
				end if

				lexSkipToken( )

				'' parse the symbol type (INTEGER, STRING, etc...)
				hSymbolType( dtype, subtype, lgt )

				'' Disallow creating objects of abstract classes
				hComplainIfAbstractClass( dtype, subtype )

				addsuffix = FALSE

			'' no explicit type..
			else
				if( fbLangOptIsSet( FB_LANG_OPT_DEFTYPE ) = FALSE ) then
					'' it's not an error if REDIM'g an already declared array
					if( (chain_ = NULL) or (token <> FB_TK_REDIM) ) then
						errReportNotAllowed( FB_LANG_OPT_DEFTYPE, FB_ERRMSG_DEFTYPEONLYVALIDINLANG )
						'' error recovery: fake a type
						dtype = FB_DATATYPE_INTEGER
					end if
				end if

				if( dtype = FB_DATATYPE_INVALID ) then
					is_typeless = TRUE
					dtype = symbGetDefType( id )
				end if

    			lgt	= symbCalcLen( dtype, subtype )
    		end if
    	end if

		sym = hLookupVarAndCheckParent( parent, chain_, dtype, is_typeless, _
						(suffix <> FB_DATATYPE_INVALID), _
						((options and FB_IDOPT_ISDECL) <> 0) )

		if( dimensions > 0 ) then
			'' QB quirk: when the symbol was defined already by a preceeding COMMON
			'' statement, then a DIM will work the same way as a REDIM
			if( token = FB_TK_DIM ) then
				if( (attrib and FB_SYMBATTRIB_DYNAMIC) = 0 ) then
					if( sym <> NULL ) then
						if( symbIsCommon( sym ) ) then
							if( symbGetArrayDimensions( sym ) <> 0 ) then
								attrib or= FB_SYMBATTRIB_DYNAMIC
							end if
						end if
					end if
				end if
			end if

			'' if subscripts are constants, convert exprTB to dimTB
			if( hIsConst( dimensions, exprTB() ) ) then
				'' only if not explicitly dynamic (ie: not REDIM, COMMON)
				if( (attrib and FB_SYMBATTRIB_DYNAMIC) = 0 ) then
					hMakeArrayDimTB( dimensions, exprTB(), dTB() )
				end if
			else
				'' Non-constant array bounds, must be dynamic
				attrib or= FB_SYMBATTRIB_DYNAMIC
			end if

			if( attrib and FB_SYMBATTRIB_DYNAMIC ) then
				'' Disallow ellipsis dimensions (nicer than "ellipsis requires initializer" +
				'' "cannot initialize dynamic array" errors)
				for i as integer = 0 to dimensions - 1
					if( exprTB(i,1) = NULL ) then
						errReport( FB_ERRMSG_DYNAMICARRAYWITHELLIPSIS )
						'' Error recovery: Allow further use of the exprTB() as if there were no ellipsis
						exprTB(i,1) = astNewCONSTi( 0 )
					end if
				next
			else
				'' "array too big/huge array on stack" check
				if( symbCheckArraySize( dimensions, @dTB(0), lgt, _
				                        ((attrib and (FB_SYMBATTRIB_SHARED or FB_SYMBATTRIB_STATIC)) = 0) ) = FALSE ) then
					errReport( FB_ERRMSG_ARRAYTOOBIG )
					'' error recovery: use small array
					dimensions = 1
					dTB(0).lower = 0
					dTB(0).upper = 0
				end if
			end if
		elseif( dimensions = 0 ) then
			'' "huge variable on stack" check
			if( ((attrib and (FB_SYMBATTRIB_SHARED or FB_SYMBATTRIB_STATIC)) = 0) and _
			    (lgt > env.clopt.stacksize) ) then
				errReportWarn( FB_WARNINGMSG_HUGEVARONSTACK )
			end if
		end if

		'' don't allow COMMON object instances
		if( (attrib and FB_SYMBATTRIB_COMMON) <> 0 ) then
			if( typeHasCtor( dtype, subtype ) or typeHasDtor( dtype, subtype ) ) then
				errReport( FB_ERRMSG_COMMONCANTBEOBJINST, TRUE )
			end if
		end if

		if( attrib and FB_SYMBATTRIB_DYNAMIC ) then
			sym = hDeclDynArray( sym, id, palias, dtype, subtype, is_typeless, _
					lgt, addsuffix, attrib, dimensions, token )
		else
			sym = hDeclStaticVar( sym, id, palias, _
								  dtype, subtype, _
    							  lgt, addsuffix, attrib, _
    							  dimensions, dTB() )
		end if

		dim as integer has_defctor = FALSE, has_dtor = FALSE

		if( sym <> NULL ) then
			is_decl = symbGetIsDeclared( sym )
			has_defctor = symbHasDefCtor( sym )
			has_dtor = symbHasDtor( sym )
		else
			is_decl = FALSE
		end if

		'' check for an initializer
		if( is_fordecl = FALSE ) then

			'' assume no assignment
			assign_initree = NULL

			'' '=' | '=>' ?
			if( hIsAssignToken( ) ) then
				initree = hVarInit( sym, is_decl )

				if( ( initree <> NULL ) and ( fbLangOptIsSet( FB_LANG_OPT_SCOPE ) = FALSE ) ) then
					'' local?
					if( (symbGetAttrib( sym ) and (FB_SYMBATTRIB_STATIC or _
												   FB_SYMBATTRIB_SHARED or _
												   FB_SYMBATTRIB_COMMON)) = 0 ) then

						''
						'' The variable will be unscoped, i.e. it needs a default initree
						'' for the implicit declaration at procedure level, plus the assignment
						'' with the initializer in the nested scope where it was defined.
						''
						''      scope
						''          dim as integer i = 5
						''      end scope
						''
						''  becomes:
						''
						''      dim as integer i
						''      scope
						''          i = 5
						''      end scope
						''
						assign_initree = initree
						initree = hVarInitDefault( sym, is_decl, has_defctor )
					end if
				end if
			else
				'' default initialization
				if( sym ) then
					if( symbArrayHasUnknownDimensions( sym ) ) then
						errReport( FB_ERRMSG_MUSTHAVEINITWITHELLIPSIS )
						hSkipStmt( )
						exit function
					end if
				end if

				initree = hVarInitDefault( sym, is_decl, has_defctor )
			end if
		else
			initree = NULL
			assign_initree = NULL
		end if

		'' add to AST
		if( sym <> NULL ) then
			'' do nothing if it's EXTERN
			if( token <> FB_TK_EXTERN ) then
				dim as FBSYMBOL ptr desc = NULL
				dim as ASTNODE ptr var_decl = NULL

				'' not declared already?
				if( is_decl = FALSE ) then
					'' Don't init if it's a temp FOR var, it will
					'' have the start condition put into it.
					var_decl = astNewDECL( sym, _
							((initree = NULL) and (not is_fordecl)) )

					'' add the descriptor too, if any
					desc = symbGetArrayDescriptor( sym )
					if( desc <> NULL ) then
						'' Note: descriptor may not have an initree here, in case it's COMMON
						'' FIXME: should probably not add DECL nodes for COMMONs/SHAREDs in the first place (not done for EXTERNs either)
						var_decl = astNewLINK( var_decl, astNewDECL( desc, (symbGetTypeIniTree( desc ) = NULL) ) )
					end if
				end if

				'' handle arrays (must be done after adding the decl node)

				'' array?
				if( ((attrib and FB_SYMBATTRIB_DYNAMIC) <> 0) or (dimensions > 0) ) then
					'' not declared yet?
					if( is_decl = FALSE ) then
						'' local?
						if( (symbGetAttrib( sym ) and (FB_SYMBATTRIB_STATIC or _
												   	   FB_SYMBATTRIB_SHARED or _
												   	   FB_SYMBATTRIB_COMMON)) = 0 ) then

							'' flush the decl node, safe to do here as it's a non-static
							'' local var (and because the decl must be flushed first)
							var_decl = hFlushDecl( var_decl )

							'' bydesc array params have no descriptor
							if( desc <> NULL ) then
								var_decl = astNewLINK( var_decl, astTypeIniFlush( desc, symbGetTypeIniTree( desc ), AST_INIOPT_ISINI ) )
								symbSetTypeIniTree( desc, NULL )
							end if

							if( fbLangOptIsSet( FB_LANG_OPT_SCOPE ) ) then
								astAdd( var_decl )
							else
								astAddUnscoped( var_decl )
							end if
							var_decl = NULL
						end if
					end if
				end if

				'' all set as declared
				symbSetIsDeclared( sym )

				'' not declared already?
				if( is_decl = FALSE ) then
					if( fbLangOptIsSet( FB_LANG_OPT_SCOPE ) ) then
            			'' flush the init tree (must be done after adding the decl node)
						astAdd( hFlushInitializer( sym, var_decl, initree, has_dtor ) )
					'' unscoped
					else
						'' flush the init tree (must be done after adding the decl node)
						astAddUnscoped( hFlushInitializer( sym, var_decl, initree, has_dtor ) )

						'' initializer as assignment?
						if( assign_initree ) then
							dim as ASTNODE ptr assign_vardecl = any

							'' clear it before it's initialized?
							if( symbGetVarHasDtor( sym ) ) then
								astAdd( astBuildVarDtorCall( sym, TRUE ) )
							end if

							assign_vardecl = astNewDECL( sym, FALSE )
							assign_vardecl = hFlushDecl( assign_vardecl )

							'' use the initializer as an assignment
							astAdd( astNewLINK( assign_vardecl, _
								astTypeIniFlush( sym, assign_initree, AST_INIOPT_ISINI ) ) )
						end if
					end if
				end if

				'' Dynamic array? If the dimensions are known, redim it.
				if( ((attrib and FB_SYMBATTRIB_DYNAMIC) <> 0) and (dimensions > 0) ) then
					redimcall = rtlArrayRedim( sym, symbGetLen( sym ), dimensions, exprTB(), _
								dopreserve, (not symbGetDontInit( sym )) )

					'' If this is a local STATIC (not SHARED/COMMON) array declaration (and not
					'' a typeless REDIM), then the redim call should be executed only once, not
					'' during every call to the parent procedure.
					if( symbIsStatic( sym ) and symbIsLocal( sym ) and _
					    ((symbGetAttrib( sym ) and (FB_SYMBATTRIB_SHARED or FB_SYMBATTRIB_COMMON)) = 0) and _
					    (not is_decl) ) then
						redimcall = hWrapInStaticFlag( redimcall )
					end if

					astAdd( redimcall )
					redimcall = NULL
				end if
			end if
		end if

		''
		if( is_fordecl ) then
			return sym
		end if

		'' (',' SymbolDef)*
		if( lexGetToken( ) <> CHAR_COMMA ) then
			exit do
		end if

		lexSkipToken( )
    loop
end function

'' look for ... followed by ')', ',' or TO
private function hMatchEllipsis( ) as integer
	function = FALSE

	if( lexGetToken( ) = CHAR_DOT ) then
		if( lexGetLookAhead( 1 ) = CHAR_DOT ) then
			if( lexGetLookAhead( 2 ) = CHAR_DOT ) then
				select case lexGetLookAhead( 3 )
					case CHAR_COMMA, CHAR_RPRNT, FB_TK_TO
						function = TRUE
						' Skip the dots
						lexSkipToken( )
						lexSkipToken( )
						lexSkipToken( )
				end select
			end if
		end if
	end if
end function

''
'' ArrayDimension =
''    Expression [TO Expression]
''
'' ArrayDecl =
''    '(' ArrayDimension (',' ArrayDimension)* ')'
''
sub cStaticArrayDecl( byref dimensions as integer, dTB() as FBARRAYDIM )
	dimensions = 0

	'' '('
	assert( lexGetToken( ) = CHAR_LPRNT )
	lexSkipToken( )

	do
		if( dimensions >= FB_MAXARRAYDIMS ) then
			errReport( FB_ERRMSG_TOOMANYDIMENSIONS )
			'' error recovery: skip to next ')'
			hSkipUntil( CHAR_RPRNT )
			exit do
		end if

		'' First value, may be lbound or ubound: Expression (integer constant)
		dTB(dimensions).lower = cConstIntExpr( cExpression( ), env.opt.base )

		'' TO?
		if( lexGetToken( ) = FB_TK_TO ) then
			lexSkipToken( )

			'' Second value, ubound: Expression (integer constant)
			dTB(dimensions).upper = cConstIntExpr( cExpression( ), dTB(dimensions).lower )
		else
			'' First value was ubound, use default for lbound
			dTB(dimensions).upper = dTB(dimensions).lower
			dTB(dimensions).lower = env.opt.base
		end if

		'' Besides the upper < lower case, also complain about FB_ARRAYDIM_UNKNOWN being
		'' specified, otherwise we'd think ellipsis was given...
		if( (dTB(dimensions).upper < dTB(dimensions).lower) or (dTB(dimensions).upper = FB_ARRAYDIM_UNKNOWN) ) then
			errReport( FB_ERRMSG_INVALIDSUBSCRIPT )
		end if

		dimensions += 1

		'' ','?
	loop while( hMatch( CHAR_COMMA ) )

	'' ')'
	if( lexGetToken( ) <> CHAR_RPRNT ) then
		errReport( FB_ERRMSG_EXPECTEDRPRNT )
	else
		lexSkipToken( )
	end if
end sub

private function hIntExpr( byval defaultexpr as ASTNODE ptr ) as ASTNODE ptr
	dim as ASTNODE ptr expr = any, intexpr = any

	expr = cExpression( )

	if( expr ) then
		'' expression must be integral (no strings, etc.)
		intexpr = astNewCONV( FB_DATATYPE_INTEGER, NULL, expr )
		if( intexpr ) then
			expr = intexpr
		else
			errReport( FB_ERRMSG_INVALIDDATATYPES, TRUE )
			astDelTree( expr )
			expr = NULL
		end if
	else
		errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
		'' error recovery: fake an expr
		if( lexGetToken( ) <> FB_TK_TO ) then
			hSkipUntil( CHAR_COMMA )
		end if
	end if

	if( expr = NULL ) then
		if( defaultexpr ) then
			expr = astCloneTree( defaultexpr )
		else
			expr = astNewCONSTi( env.opt.base )
		end if
	end if

	function = expr
end function

''
'' ArrayDimension =
''    Expression [TO Expression]
''
'' ArrayDecl =
''    ArrayDimension (',' ArrayDimension)*
''
sub cArrayDecl( byref dimensions as integer, exprTB() as ASTNODE ptr )
	dimensions = 0

	do
		if( dimensions >= FB_MAXARRAYDIMS ) then
			errReport( FB_ERRMSG_TOOMANYDIMENSIONS )
			'' error recovery: skip to next ')'
			hSkipUntil( CHAR_RPRNT )
			exit do
		end if

		'' 1st expression: lbound or ubound
		'' (depends on whether there's a TO and a 2nd expression following)
		if( hMatchEllipsis( ) ) then
			exprTB(dimensions,0) = NULL
		else
			'' Expression
			exprTB(dimensions,0) = hIntExpr( NULL )
		end if

		'' TO
		if( lexGetToken( ) = FB_TK_TO ) then
			lexSkipToken( )

			'' lbound can't be unknown
			if( exprTB(dimensions,0) = NULL ) then
				errReport( FB_ERRMSG_CANTUSEELLIPSISASLOWERBOUND )
				exprTB(dimensions,0) = astNewCONSTi( 0 )
			end if

			'' ubound
			if( hMatchEllipsis( ) ) then
				exprTB(dimensions,1) = NULL
			else
				'' Expression
				exprTB(dimensions,1) = hIntExpr( exprTB(dimensions,0) )
			end if
		else
			'' 1st expression was ubound, not lbound
			exprTB(dimensions,1) = exprTB(dimensions,0)
			exprTB(dimensions,0) = astNewCONSTi( env.opt.base )
		end if

		dimensions += 1

		'' ','?
	loop while( hMatch( CHAR_COMMA ) )
end sub

''
'' AutoVar =
''    SymbolDef '=' Initializer
''
'' AutoVarDecl =
''    VAR [SHARED] AutoVar (',' AutoVar)*
''
private sub cAutoVarDecl( byval attrib as FB_SYMBATTRIB )
	static as FBARRAYDIM dTB(0 to FB_MAXARRAYDIMS-1) '' needed for hDeclStaticVar()
	static as zstring * FB_MAXNAMELEN+1 id
	dim as FBSYMBOL ptr parent = any, sym = any

	'' allowed?
	if( fbLangOptIsSet( FB_LANG_OPT_AUTOVAR ) = FALSE ) then
		errReportNotAllowed( FB_LANG_OPT_AUTOVAR, FB_ERRMSG_AUTOVARONLYVALIDINLANG )
		'' error recovery: skip stmt
		hSkipStmt( )
		return
	end if

	if( cCompStmtIsAllowed( FB_CMPSTMT_MASK_DECL or FB_CMPSTMT_MASK_CODE ) = FALSE ) then
		hSkipStmt( )
		exit sub
	end if

	'' VAR
	lexSkipToken( )

	'' SHARED?
	if( lexGetToken( ) = FB_TK_SHARED ) then
		'' can't use SHARED inside a proc
		if( hCheckScope( ) = FALSE ) then
			'' error recovery: don't make it shared
			attrib or= FB_SYMBATTRIB_STATIC
		else
			attrib or= FB_SYMBATTRIB_SHARED or FB_SYMBATTRIB_STATIC
		end if
		lexSkipToken( )
	end if

	'' this proc static?
	if( symbGetProcStaticLocals( parser.currproc ) ) then
		attrib or= FB_SYMBATTRIB_STATIC
	end if

	'' inside a namespace but outside a proc?
	if( symbIsGlobalNamespc( ) = FALSE ) then
		if( fbIsModLevel( ) ) then
			'' variables will be always shared..
			attrib or= FB_SYMBATTRIB_SHARED or FB_SYMBATTRIB_STATIC
		end if
	end if

	do
		'' id.id? if not, NULL
		parent = cParentId( FB_IDOPT_DEFAULT or FB_IDOPT_ISDECL or _
					FB_IDOPT_ALLOWSTRUCT or FB_IDOPT_ISVAR )

		'' get id
		dim as integer suffix = any
		dim as FBSYMCHAIN ptr chain_ = hGetId( parent, @id, suffix, 0 )

		if( suffix <> FB_DATATYPE_INVALID ) then
			errReportEx( FB_ERRMSG_SYNTAXERROR, @id )
		end if

		'' array? rejected.
		if( lexGetToken( ) = CHAR_LPRNT ) then
			errReport( FB_ERRMSG_TYPEMISMATCH )
			'' error recovery: skip until next ')'
			hSkipUntil( CHAR_RPRNT, TRUE )
		end if

		sym = hLookupVarAndCheckParent( parent, chain_, FB_DATATYPE_INVALID, _
						TRUE, FALSE, TRUE )

		'' '=' | '=>' ?
		if( cAssignToken( ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDEQ )
		end if

		'' parse expression
		dim as ASTNODE ptr expr = cExpression( )
		if( expr = NULL ) then
			errReport( FB_ERRMSG_AUTONEEDSINITIALIZER )
			'' error recovery: fake an expr
			expr = astNewCONSTi( 0 )
		end if

		dim as integer dtype = astGetFullType( expr )
		dim as FBSYMBOL ptr subtype = astGetSubType( expr )

		'' check for special types
		dim as integer has_ctor = any, has_dtor = any

		has_ctor = typeHasCtor( dtype, subtype )
		has_dtor = typeHasDtor( dtype, subtype )

		select case as const typeGetDtAndPtrOnly( dtype )
		'' wstrings not allowed...
		case FB_DATATYPE_WCHAR
			errReport( FB_ERRMSG_INVALIDDATATYPES, TRUE )
			'' error recovery: create a fake expression
			astDelTree( expr )
			expr = astNewCONSTi( 0 )
			dtype = FB_DATATYPE_INTEGER
			subtype = NULL

		'' zstring... convert to string
		case FB_DATATYPE_CHAR, FB_DATATYPE_FIXSTR
			dtype = FB_DATATYPE_STRING

		'' if it's a function pointer and not a fun ptr prototype, create one
		case typeAddrOf( FB_DATATYPE_FUNCTION )
			if( symbGetIsFuncPtr( subtype ) = FALSE ) then
				subtype = symbAddProcPtrFromFunction( subtype )
			end if

		end select

		'' add var after parsing the expression, or the the var itself could be used
		sym = hDeclStaticVar( sym, id, NULL, _
		                      dtype, subtype, _
		                      symbCalcLen( dtype, subtype ), FALSE, attrib, _
		                      0, dTB() )

		if( sym <> NULL ) then
			'' build a ini-tree
			dim as ASTNODE ptr initree = any

			initree = astTypeIniBegin( astGetFullType( expr ), subtype, symbIsLocal( sym ) )

			'' not an object?
			if( has_ctor = FALSE ) then
				astTypeIniAddAssign( initree, expr, sym )
			'' handle constructors..
			else
				dim as integer is_ctorcall = any
				expr = astBuildImplicitCtorCallEx( sym, expr, cBydescArrayArgParens( expr ), is_ctorcall )

				if( expr <> NULL ) then
					if( is_ctorcall ) then
						astTypeIniAddCtorCall( initree, sym, expr )
					else
						'' no proper ctor, try an assign
						astTypeIniAddAssign( initree, expr, sym )
					end if
				end if
			end if

			if( (symbGetAttrib( sym ) and (FB_SYMBATTRIB_STATIC or _
							FB_SYMBATTRIB_SHARED)) <> 0 ) then
				'' only if it's not an object, static or global instances are allowed
				if( has_ctor = FALSE ) then
					if( astTypeIniIsConst( initree ) = FALSE ) then
						'' error recovery: discard the tree
						astDelTree( expr )
						expr = astNewCONSTz( dtype, subtype )
						dtype = FB_DATATYPE_INTEGER
						subtype = NULL
						has_dtor = FALSE
					end if
				end if
			end if

			astTypeIniEnd( initree, TRUE )

			'' add to AST
			dim as ASTNODE ptr var_decl = astNewDECL( sym, FALSE )

			'' set as declared
			symbSetIsDeclared( sym )

			'' flush the init tree (must be done after adding the decl node)
			astAdd( hFlushInitializer( sym, var_decl, initree, has_dtor ) )
		end if

		'' (',' SymbolDef)*
		if( lexGetToken( ) <> CHAR_COMMA ) then
			exit do
		end if

		lexSkipToken( )
	loop
end sub
