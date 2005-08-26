''
''
'' xmlerror -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __xmlerror_bi__
#define __xmlerror_bi__

#include once "libxml/parser.bi"

enum xmlErrorLevel
	XML_ERR_NONE = 0
	XML_ERR_WARNING = 1
	XML_ERR_ERROR = 2
	XML_ERR_FATAL = 3
end enum


enum xmlErrorDomain
	XML_FROM_NONE = 0
	XML_FROM_PARSER
	XML_FROM_TREE
	XML_FROM_NAMESPACE
	XML_FROM_DTD
	XML_FROM_HTML
	XML_FROM_MEMORY
	XML_FROM_OUTPUT
	XML_FROM_IO
	XML_FROM_FTP
	XML_FROM_HTTP
	XML_FROM_XINCLUDE
	XML_FROM_XPATH
	XML_FROM_XPOINTER
	XML_FROM_REGEXP
	XML_FROM_DATATYPE
	XML_FROM_SCHEMASP
	XML_FROM_SCHEMASV
	XML_FROM_RELAXNGP
	XML_FROM_RELAXNGV
	XML_FROM_CATALOG
	XML_FROM_C14N
	XML_FROM_XSLT
	XML_FROM_VALID
	XML_FROM_CHECK
	XML_FROM_WRITER
	XML_FROM_MODULE
end enum

type xmlError as _xmlError
type xmlErrorPtr as xmlError ptr

type _xmlError
	domain as integer
	code as integer
	message as byte ptr
	level as xmlErrorLevel
	file as byte ptr
	line as integer
	str1 as byte ptr
	str2 as byte ptr
	str3 as byte ptr
	int1 as integer
	int2 as integer
	ctxt as any ptr
	node as any ptr
end type

enum xmlParserErrors
	XML_ERR_OK = 0
	XML_ERR_INTERNAL_ERROR
	XML_ERR_NO_MEMORY
	XML_ERR_DOCUMENT_START
	XML_ERR_DOCUMENT_EMPTY
	XML_ERR_DOCUMENT_END
	XML_ERR_INVALID_HEX_CHARREF
	XML_ERR_INVALID_DEC_CHARREF
	XML_ERR_INVALID_CHARREF
	XML_ERR_INVALID_CHAR
	XML_ERR_CHARREF_AT_EOF
	XML_ERR_CHARREF_IN_PROLOG
	XML_ERR_CHARREF_IN_EPILOG
	XML_ERR_CHARREF_IN_DTD
	XML_ERR_ENTITYREF_AT_EOF
	XML_ERR_ENTITYREF_IN_PROLOG
	XML_ERR_ENTITYREF_IN_EPILOG
	XML_ERR_ENTITYREF_IN_DTD
	XML_ERR_PEREF_AT_EOF
	XML_ERR_PEREF_IN_PROLOG
	XML_ERR_PEREF_IN_EPILOG
	XML_ERR_PEREF_IN_INT_SUBSET
	XML_ERR_ENTITYREF_NO_NAME
	XML_ERR_ENTITYREF_SEMICOL_MISSING
	XML_ERR_PEREF_NO_NAME
	XML_ERR_PEREF_SEMICOL_MISSING
	XML_ERR_UNDECLARED_ENTITY
	XML_WAR_UNDECLARED_ENTITY
	XML_ERR_UNPARSED_ENTITY
	XML_ERR_ENTITY_IS_EXTERNAL
	XML_ERR_ENTITY_IS_PARAMETER
	XML_ERR_UNKNOWN_ENCODING
	XML_ERR_UNSUPPORTED_ENCODING
	XML_ERR_STRING_NOT_STARTED
	XML_ERR_STRING_NOT_CLOSED
	XML_ERR_NS_DECL_ERROR
	XML_ERR_ENTITY_NOT_STARTED
	XML_ERR_ENTITY_NOT_FINISHED
	XML_ERR_LT_IN_ATTRIBUTE
	XML_ERR_ATTRIBUTE_NOT_STARTED
	XML_ERR_ATTRIBUTE_NOT_FINISHED
	XML_ERR_ATTRIBUTE_WITHOUT_VALUE
	XML_ERR_ATTRIBUTE_REDEFINED
	XML_ERR_LITERAL_NOT_STARTED
	XML_ERR_LITERAL_NOT_FINISHED
	XML_ERR_COMMENT_NOT_FINISHED
	XML_ERR_PI_NOT_STARTED
	XML_ERR_PI_NOT_FINISHED
	XML_ERR_NOTATION_NOT_STARTED
	XML_ERR_NOTATION_NOT_FINISHED
	XML_ERR_ATTLIST_NOT_STARTED
	XML_ERR_ATTLIST_NOT_FINISHED
	XML_ERR_MIXED_NOT_STARTED
	XML_ERR_MIXED_NOT_FINISHED
	XML_ERR_ELEMCONTENT_NOT_STARTED
	XML_ERR_ELEMCONTENT_NOT_FINISHED
	XML_ERR_XMLDECL_NOT_STARTED
	XML_ERR_XMLDECL_NOT_FINISHED
	XML_ERR_CONDSEC_NOT_STARTED
	XML_ERR_CONDSEC_NOT_FINISHED
	XML_ERR_EXT_SUBSET_NOT_FINISHED
	XML_ERR_DOCTYPE_NOT_FINISHED
	XML_ERR_MISPLACED_CDATA_END
	XML_ERR_CDATA_NOT_FINISHED
	XML_ERR_RESERVED_XML_NAME
	XML_ERR_SPACE_REQUIRED
	XML_ERR_SEPARATOR_REQUIRED
	XML_ERR_NMTOKEN_REQUIRED
	XML_ERR_NAME_REQUIRED
	XML_ERR_PCDATA_REQUIRED
	XML_ERR_URI_REQUIRED
	XML_ERR_PUBID_REQUIRED
	XML_ERR_LT_REQUIRED
	XML_ERR_GT_REQUIRED
	XML_ERR_LTSLASH_REQUIRED
	XML_ERR_EQUAL_REQUIRED
	XML_ERR_TAG_NAME_MISMATCH
	XML_ERR_TAG_NOT_FINISHED
	XML_ERR_STANDALONE_VALUE
	XML_ERR_ENCODING_NAME
	XML_ERR_HYPHEN_IN_COMMENT
	XML_ERR_INVALID_ENCODING
	XML_ERR_EXT_ENTITY_STANDALONE
	XML_ERR_CONDSEC_INVALID
	XML_ERR_VALUE_REQUIRED
	XML_ERR_NOT_WELL_BALANCED
	XML_ERR_EXTRA_CONTENT
	XML_ERR_ENTITY_CHAR_ERROR
	XML_ERR_ENTITY_PE_INTERNAL
	XML_ERR_ENTITY_LOOP
	XML_ERR_ENTITY_BOUNDARY
	XML_ERR_INVALID_URI
	XML_ERR_URI_FRAGMENT
	XML_WAR_CATALOG_PI
	XML_ERR_NO_DTD
	XML_ERR_CONDSEC_INVALID_KEYWORD
	XML_ERR_VERSION_MISSING
	XML_WAR_UNKNOWN_VERSION
	XML_WAR_LANG_VALUE
	XML_WAR_NS_URI
	XML_WAR_NS_URI_RELATIVE
	XML_ERR_MISSING_ENCODING
	XML_NS_ERR_XML_NAMESPACE = 200
	XML_NS_ERR_UNDEFINED_NAMESPACE
	XML_NS_ERR_QNAME
	XML_NS_ERR_ATTRIBUTE_REDEFINED
	XML_DTD_ATTRIBUTE_DEFAULT = 500
	XML_DTD_ATTRIBUTE_REDEFINED
	XML_DTD_ATTRIBUTE_VALUE
	XML_DTD_CONTENT_ERROR
	XML_DTD_CONTENT_MODEL
	XML_DTD_CONTENT_NOT_DETERMINIST
	XML_DTD_DIFFERENT_PREFIX
	XML_DTD_ELEM_DEFAULT_NAMESPACE
	XML_DTD_ELEM_NAMESPACE
	XML_DTD_ELEM_REDEFINED
	XML_DTD_EMPTY_NOTATION
	XML_DTD_ENTITY_TYPE
	XML_DTD_ID_FIXED
	XML_DTD_ID_REDEFINED
	XML_DTD_ID_SUBSET
	XML_DTD_INVALID_CHILD
	XML_DTD_INVALID_DEFAULT
	XML_DTD_LOAD_ERROR
	XML_DTD_MISSING_ATTRIBUTE
	XML_DTD_MIXED_CORRUPT
	XML_DTD_MULTIPLE_ID
	XML_DTD_NO_DOC
	XML_DTD_NO_DTD
	XML_DTD_NO_ELEM_NAME
	XML_DTD_NO_PREFIX
	XML_DTD_NO_ROOT
	XML_DTD_NOTATION_REDEFINED
	XML_DTD_NOTATION_VALUE
	XML_DTD_NOT_EMPTY
	XML_DTD_NOT_PCDATA
	XML_DTD_NOT_STANDALONE
	XML_DTD_ROOT_NAME
	XML_DTD_STANDALONE_WHITE_SPACE
	XML_DTD_UNKNOWN_ATTRIBUTE
	XML_DTD_UNKNOWN_ELEM
	XML_DTD_UNKNOWN_ENTITY
	XML_DTD_UNKNOWN_ID
	XML_DTD_UNKNOWN_NOTATION
	XML_DTD_STANDALONE_DEFAULTED
	XML_DTD_XMLID_VALUE
	XML_DTD_XMLID_TYPE
	XML_HTML_STRUCURE_ERROR = 800
	XML_HTML_UNKNOWN_TAG
	XML_RNGP_ANYNAME_ATTR_ANCESTOR = 1000
	XML_RNGP_ATTR_CONFLICT
	XML_RNGP_ATTRIBUTE_CHILDREN
	XML_RNGP_ATTRIBUTE_CONTENT
	XML_RNGP_ATTRIBUTE_EMPTY
	XML_RNGP_ATTRIBUTE_NOOP
	XML_RNGP_CHOICE_CONTENT
	XML_RNGP_CHOICE_EMPTY
	XML_RNGP_CREATE_FAILURE
	XML_RNGP_DATA_CONTENT
	XML_RNGP_DEF_CHOICE_AND_INTERLEAVE
	XML_RNGP_DEFINE_CREATE_FAILED
	XML_RNGP_DEFINE_EMPTY
	XML_RNGP_DEFINE_MISSING
	XML_RNGP_DEFINE_NAME_MISSING
	XML_RNGP_ELEM_CONTENT_EMPTY
	XML_RNGP_ELEM_CONTENT_ERROR
	XML_RNGP_ELEMENT_EMPTY
	XML_RNGP_ELEMENT_CONTENT
	XML_RNGP_ELEMENT_NAME
	XML_RNGP_ELEMENT_NO_CONTENT
	XML_RNGP_ELEM_TEXT_CONFLICT
	XML_RNGP_EMPTY
	XML_RNGP_EMPTY_CONSTRUCT
	XML_RNGP_EMPTY_CONTENT
	XML_RNGP_EMPTY_NOT_EMPTY
	XML_RNGP_ERROR_TYPE_LIB
	XML_RNGP_EXCEPT_EMPTY
	XML_RNGP_EXCEPT_MISSING
	XML_RNGP_EXCEPT_MULTIPLE
	XML_RNGP_EXCEPT_NO_CONTENT
	XML_RNGP_EXTERNALREF_EMTPY
	XML_RNGP_EXTERNAL_REF_FAILURE
	XML_RNGP_EXTERNALREF_RECURSE
	XML_RNGP_FORBIDDEN_ATTRIBUTE
	XML_RNGP_FOREIGN_ELEMENT
	XML_RNGP_GRAMMAR_CONTENT
	XML_RNGP_GRAMMAR_EMPTY
	XML_RNGP_GRAMMAR_MISSING
	XML_RNGP_GRAMMAR_NO_START
	XML_RNGP_GROUP_ATTR_CONFLICT
	XML_RNGP_HREF_ERROR
	XML_RNGP_INCLUDE_EMPTY
	XML_RNGP_INCLUDE_FAILURE
	XML_RNGP_INCLUDE_RECURSE
	XML_RNGP_INTERLEAVE_ADD
	XML_RNGP_INTERLEAVE_CREATE_FAILED
	XML_RNGP_INTERLEAVE_EMPTY
	XML_RNGP_INTERLEAVE_NO_CONTENT
	XML_RNGP_INVALID_DEFINE_NAME
	XML_RNGP_INVALID_URI
	XML_RNGP_INVALID_VALUE
	XML_RNGP_MISSING_HREF
	XML_RNGP_NAME_MISSING
	XML_RNGP_NEED_COMBINE
	XML_RNGP_NOTALLOWED_NOT_EMPTY
	XML_RNGP_NSNAME_ATTR_ANCESTOR
	XML_RNGP_NSNAME_NO_NS
	XML_RNGP_PARAM_FORBIDDEN
	XML_RNGP_PARAM_NAME_MISSING
	XML_RNGP_PARENTREF_CREATE_FAILED
	XML_RNGP_PARENTREF_NAME_INVALID
	XML_RNGP_PARENTREF_NO_NAME
	XML_RNGP_PARENTREF_NO_PARENT
	XML_RNGP_PARENTREF_NOT_EMPTY
	XML_RNGP_PARSE_ERROR
	XML_RNGP_PAT_ANYNAME_EXCEPT_ANYNAME
	XML_RNGP_PAT_ATTR_ATTR
	XML_RNGP_PAT_ATTR_ELEM
	XML_RNGP_PAT_DATA_EXCEPT_ATTR
	XML_RNGP_PAT_DATA_EXCEPT_ELEM
	XML_RNGP_PAT_DATA_EXCEPT_EMPTY
	XML_RNGP_PAT_DATA_EXCEPT_GROUP
	XML_RNGP_PAT_DATA_EXCEPT_INTERLEAVE
	XML_RNGP_PAT_DATA_EXCEPT_LIST
	XML_RNGP_PAT_DATA_EXCEPT_ONEMORE
	XML_RNGP_PAT_DATA_EXCEPT_REF
	XML_RNGP_PAT_DATA_EXCEPT_TEXT
	XML_RNGP_PAT_LIST_ATTR
	XML_RNGP_PAT_LIST_ELEM
	XML_RNGP_PAT_LIST_INTERLEAVE
	XML_RNGP_PAT_LIST_LIST
	XML_RNGP_PAT_LIST_REF
	XML_RNGP_PAT_LIST_TEXT
	XML_RNGP_PAT_NSNAME_EXCEPT_ANYNAME
	XML_RNGP_PAT_NSNAME_EXCEPT_NSNAME
	XML_RNGP_PAT_ONEMORE_GROUP_ATTR
	XML_RNGP_PAT_ONEMORE_INTERLEAVE_ATTR
	XML_RNGP_PAT_START_ATTR
	XML_RNGP_PAT_START_DATA
	XML_RNGP_PAT_START_EMPTY
	XML_RNGP_PAT_START_GROUP
	XML_RNGP_PAT_START_INTERLEAVE
	XML_RNGP_PAT_START_LIST
	XML_RNGP_PAT_START_ONEMORE
	XML_RNGP_PAT_START_TEXT
	XML_RNGP_PAT_START_VALUE
	XML_RNGP_PREFIX_UNDEFINED
	XML_RNGP_REF_CREATE_FAILED
	XML_RNGP_REF_CYCLE
	XML_RNGP_REF_NAME_INVALID
	XML_RNGP_REF_NO_DEF
	XML_RNGP_REF_NO_NAME
	XML_RNGP_REF_NOT_EMPTY
	XML_RNGP_START_CHOICE_AND_INTERLEAVE
	XML_RNGP_START_CONTENT
	XML_RNGP_START_EMPTY
	XML_RNGP_START_MISSING
	XML_RNGP_TEXT_EXPECTED
	XML_RNGP_TEXT_HAS_CHILD
	XML_RNGP_TYPE_MISSING
	XML_RNGP_TYPE_NOT_FOUND
	XML_RNGP_TYPE_VALUE
	XML_RNGP_UNKNOWN_ATTRIBUTE
	XML_RNGP_UNKNOWN_COMBINE
	XML_RNGP_UNKNOWN_CONSTRUCT
	XML_RNGP_UNKNOWN_TYPE_LIB
	XML_RNGP_URI_FRAGMENT
	XML_RNGP_URI_NOT_ABSOLUTE
	XML_RNGP_VALUE_EMPTY
	XML_RNGP_VALUE_NO_CONTENT
	XML_RNGP_XMLNS_NAME
	XML_RNGP_XML_NS
	XML_XPATH_EXPRESSION_OK = 1200
	XML_XPATH_NUMBER_ERROR
	XML_XPATH_UNFINISHED_LITERAL_ERROR
	XML_XPATH_START_LITERAL_ERROR
	XML_XPATH_VARIABLE_REF_ERROR
	XML_XPATH_UNDEF_VARIABLE_ERROR
	XML_XPATH_INVALID_PREDICATE_ERROR
	XML_XPATH_EXPR_ERROR
	XML_XPATH_UNCLOSED_ERROR
	XML_XPATH_UNKNOWN_FUNC_ERROR
	XML_XPATH_INVALID_OPERAND
	XML_XPATH_INVALID_TYPE
	XML_XPATH_INVALID_ARITY
	XML_XPATH_INVALID_CTXT_SIZE
	XML_XPATH_INVALID_CTXT_POSITION
	XML_XPATH_MEMORY_ERROR
	XML_XPTR_SYNTAX_ERROR
	XML_XPTR_RESOURCE_ERROR
	XML_XPTR_SUB_RESOURCE_ERROR
	XML_XPATH_UNDEF_PREFIX_ERROR
	XML_XPATH_ENCODING_ERROR
	XML_XPATH_INVALID_CHAR_ERROR
	XML_TREE_INVALID_HEX = 1300
	XML_TREE_INVALID_DEC
	XML_TREE_UNTERMINATED_ENTITY
	XML_SAVE_NOT_UTF8 = 1400
	XML_SAVE_CHAR_INVALID
	XML_SAVE_NO_DOCTYPE
	XML_SAVE_UNKNOWN_ENCODING
	XML_REGEXP_COMPILE_ERROR = 1450
	XML_IO_UNKNOWN = 1500
	XML_IO_EACCES
	XML_IO_EAGAIN
	XML_IO_EBADF
	XML_IO_EBADMSG
	XML_IO_EBUSY
	XML_IO_ECANCELED
	XML_IO_ECHILD
	XML_IO_EDEADLK
	XML_IO_EDOM
	XML_IO_EEXIST
	XML_IO_EFAULT
	XML_IO_EFBIG
	XML_IO_EINPROGRESS
	XML_IO_EINTR
	XML_IO_EINVAL
	XML_IO_EIO
	XML_IO_EISDIR
	XML_IO_EMFILE
	XML_IO_EMLINK
	XML_IO_EMSGSIZE
	XML_IO_ENAMETOOLONG
	XML_IO_ENFILE
	XML_IO_ENODEV
	XML_IO_ENOENT
	XML_IO_ENOEXEC
	XML_IO_ENOLCK
	XML_IO_ENOMEM
	XML_IO_ENOSPC
	XML_IO_ENOSYS
	XML_IO_ENOTDIR
	XML_IO_ENOTEMPTY
	XML_IO_ENOTSUP
	XML_IO_ENOTTY
	XML_IO_ENXIO
	XML_IO_EPERM
	XML_IO_EPIPE
	XML_IO_ERANGE
	XML_IO_EROFS
	XML_IO_ESPIPE
	XML_IO_ESRCH
	XML_IO_ETIMEDOUT
	XML_IO_EXDEV
	XML_IO_NETWORK_ATTEMPT
	XML_IO_ENCODER
	XML_IO_FLUSH
	XML_IO_WRITE
	XML_IO_NO_INPUT
	XML_IO_BUFFER_FULL
	XML_IO_LOAD_ERROR
	XML_IO_ENOTSOCK
	XML_IO_EISCONN
	XML_IO_ECONNREFUSED
	XML_IO_ENETUNREACH
	XML_IO_EADDRINUSE
	XML_IO_EALREADY
	XML_IO_EAFNOSUPPORT
	XML_XINCLUDE_RECURSION = 1600
	XML_XINCLUDE_PARSE_VALUE
	XML_XINCLUDE_ENTITY_DEF_MISMATCH
	XML_XINCLUDE_NO_HREF
	XML_XINCLUDE_NO_FALLBACK
	XML_XINCLUDE_HREF_URI
	XML_XINCLUDE_TEXT_FRAGMENT
	XML_XINCLUDE_TEXT_DOCUMENT
	XML_XINCLUDE_INVALID_CHAR
	XML_XINCLUDE_BUILD_FAILED
	XML_XINCLUDE_UNKNOWN_ENCODING
	XML_XINCLUDE_MULTIPLE_ROOT
	XML_XINCLUDE_XPTR_FAILED
	XML_XINCLUDE_XPTR_RESULT
	XML_XINCLUDE_INCLUDE_IN_INCLUDE
	XML_XINCLUDE_FALLBACKS_IN_INCLUDE
	XML_XINCLUDE_FALLBACK_NOT_IN_INCLUDE
	XML_XINCLUDE_DEPRECATED_NS
	XML_XINCLUDE_FRAGMENT_ID
	XML_CATALOG_MISSING_ATTR = 1650
	XML_CATALOG_ENTRY_BROKEN
	XML_CATALOG_PREFER_VALUE
	XML_CATALOG_NOT_CATALOG
	XML_CATALOG_RECURSION
	XML_SCHEMAP_PREFIX_UNDEFINED = 1700
	XML_SCHEMAP_ATTRFORMDEFAULT_VALUE
	XML_SCHEMAP_ATTRGRP_NONAME_NOREF
	XML_SCHEMAP_ATTR_NONAME_NOREF
	XML_SCHEMAP_COMPLEXTYPE_NONAME_NOREF
	XML_SCHEMAP_ELEMFORMDEFAULT_VALUE
	XML_SCHEMAP_ELEM_NONAME_NOREF
	XML_SCHEMAP_EXTENSION_NO_BASE
	XML_SCHEMAP_FACET_NO_VALUE
	XML_SCHEMAP_FAILED_BUILD_IMPORT
	XML_SCHEMAP_GROUP_NONAME_NOREF
	XML_SCHEMAP_IMPORT_NAMESPACE_NOT_URI
	XML_SCHEMAP_IMPORT_REDEFINE_NSNAME
	XML_SCHEMAP_IMPORT_SCHEMA_NOT_URI
	XML_SCHEMAP_INVALID_BOOLEAN
	XML_SCHEMAP_INVALID_ENUM
	XML_SCHEMAP_INVALID_FACET
	XML_SCHEMAP_INVALID_FACET_VALUE
	XML_SCHEMAP_INVALID_MAXOCCURS
	XML_SCHEMAP_INVALID_MINOCCURS
	XML_SCHEMAP_INVALID_REF_AND_SUBTYPE
	XML_SCHEMAP_INVALID_WHITE_SPACE
	XML_SCHEMAP_NOATTR_NOREF
	XML_SCHEMAP_NOTATION_NO_NAME
	XML_SCHEMAP_NOTYPE_NOREF
	XML_SCHEMAP_REF_AND_SUBTYPE
	XML_SCHEMAP_RESTRICTION_NONAME_NOREF
	XML_SCHEMAP_SIMPLETYPE_NONAME
	XML_SCHEMAP_TYPE_AND_SUBTYPE
	XML_SCHEMAP_UNKNOWN_ALL_CHILD
	XML_SCHEMAP_UNKNOWN_ANYATTRIBUTE_CHILD
	XML_SCHEMAP_UNKNOWN_ATTR_CHILD
	XML_SCHEMAP_UNKNOWN_ATTRGRP_CHILD
	XML_SCHEMAP_UNKNOWN_ATTRIBUTE_GROUP
	XML_SCHEMAP_UNKNOWN_BASE_TYPE
	XML_SCHEMAP_UNKNOWN_CHOICE_CHILD
	XML_SCHEMAP_UNKNOWN_COMPLEXCONTENT_CHILD
	XML_SCHEMAP_UNKNOWN_COMPLEXTYPE_CHILD
	XML_SCHEMAP_UNKNOWN_ELEM_CHILD
	XML_SCHEMAP_UNKNOWN_EXTENSION_CHILD
	XML_SCHEMAP_UNKNOWN_FACET_CHILD
	XML_SCHEMAP_UNKNOWN_FACET_TYPE
	XML_SCHEMAP_UNKNOWN_GROUP_CHILD
	XML_SCHEMAP_UNKNOWN_IMPORT_CHILD
	XML_SCHEMAP_UNKNOWN_LIST_CHILD
	XML_SCHEMAP_UNKNOWN_NOTATION_CHILD
	XML_SCHEMAP_UNKNOWN_PROCESSCONTENT_CHILD
	XML_SCHEMAP_UNKNOWN_REF
	XML_SCHEMAP_UNKNOWN_RESTRICTION_CHILD
	XML_SCHEMAP_UNKNOWN_SCHEMAS_CHILD
	XML_SCHEMAP_UNKNOWN_SEQUENCE_CHILD
	XML_SCHEMAP_UNKNOWN_SIMPLECONTENT_CHILD
	XML_SCHEMAP_UNKNOWN_SIMPLETYPE_CHILD
	XML_SCHEMAP_UNKNOWN_TYPE
	XML_SCHEMAP_UNKNOWN_UNION_CHILD
	XML_SCHEMAP_ELEM_DEFAULT_FIXED
	XML_SCHEMAP_REGEXP_INVALID
	XML_SCHEMAP_FAILED_LOAD
	XML_SCHEMAP_NOTHING_TO_PARSE
	XML_SCHEMAP_NOROOT
	XML_SCHEMAP_REDEFINED_GROUP
	XML_SCHEMAP_REDEFINED_TYPE
	XML_SCHEMAP_REDEFINED_ELEMENT
	XML_SCHEMAP_REDEFINED_ATTRGROUP
	XML_SCHEMAP_REDEFINED_ATTR
	XML_SCHEMAP_REDEFINED_NOTATION
	XML_SCHEMAP_FAILED_PARSE
	XML_SCHEMAP_UNKNOWN_PREFIX
	XML_SCHEMAP_DEF_AND_PREFIX
	XML_SCHEMAP_UNKNOWN_INCLUDE_CHILD
	XML_SCHEMAP_INCLUDE_SCHEMA_NOT_URI
	XML_SCHEMAP_INCLUDE_SCHEMA_NO_URI
	XML_SCHEMAP_NOT_SCHEMA
	XML_SCHEMAP_UNKNOWN_MEMBER_TYPE
	XML_SCHEMAP_INVALID_ATTR_USE
	XML_SCHEMAP_RECURSIVE
	XML_SCHEMAP_SUPERNUMEROUS_LIST_ITEM_TYPE
	XML_SCHEMAP_INVALID_ATTR_COMBINATION
	XML_SCHEMAP_INVALID_ATTR_INLINE_COMBINATION
	XML_SCHEMAP_MISSING_SIMPLETYPE_CHILD
	XML_SCHEMAP_INVALID_ATTR_NAME
	XML_SCHEMAP_REF_AND_CONTENT
	XML_SCHEMAP_CT_PROPS_CORRECT_1
	XML_SCHEMAP_CT_PROPS_CORRECT_2
	XML_SCHEMAP_CT_PROPS_CORRECT_3
	XML_SCHEMAP_CT_PROPS_CORRECT_4
	XML_SCHEMAP_CT_PROPS_CORRECT_5
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_1
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_2_1_1
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_2_1_2
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_2_2
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_3
	XML_SCHEMAP_WILDCARD_INVALID_NS_MEMBER
	XML_SCHEMAP_INTERSECTION_NOT_EXPRESSIBLE
	XML_SCHEMAP_UNION_NOT_EXPRESSIBLE
	XML_SCHEMAP_SRC_IMPORT_3_1
	XML_SCHEMAP_SRC_IMPORT_3_2
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_4_1
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_4_2
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_4_3
	XML_SCHEMAP_COS_CT_EXTENDS_1_3
	XML_SCHEMAV_NOROOT = 1801
	XML_SCHEMAV_UNDECLAREDELEM
	XML_SCHEMAV_NOTTOPLEVEL
	XML_SCHEMAV_MISSING
	XML_SCHEMAV_WRONGELEM
	XML_SCHEMAV_NOTYPE
	XML_SCHEMAV_NOROLLBACK
	XML_SCHEMAV_ISABSTRACT
	XML_SCHEMAV_NOTEMPTY
	XML_SCHEMAV_ELEMCONT
	XML_SCHEMAV_HAVEDEFAULT
	XML_SCHEMAV_NOTNILLABLE
	XML_SCHEMAV_EXTRACONTENT
	XML_SCHEMAV_INVALIDATTR
	XML_SCHEMAV_INVALIDELEM
	XML_SCHEMAV_NOTDETERMINIST
	XML_SCHEMAV_CONSTRUCT
	XML_SCHEMAV_INTERNAL
	XML_SCHEMAV_NOTSIMPLE
	XML_SCHEMAV_ATTRUNKNOWN
	XML_SCHEMAV_ATTRINVALID
	XML_SCHEMAV_VALUE
	XML_SCHEMAV_FACET
	XML_SCHEMAV_CVC_DATATYPE_VALID_1_2_1
	XML_SCHEMAV_CVC_DATATYPE_VALID_1_2_2
	XML_SCHEMAV_CVC_DATATYPE_VALID_1_2_3
	XML_SCHEMAV_CVC_TYPE_3_1_1
	XML_SCHEMAV_CVC_TYPE_3_1_2
	XML_SCHEMAV_CVC_FACET_VALID
	XML_SCHEMAV_CVC_LENGTH_VALID
	XML_SCHEMAV_CVC_MINLENGTH_VALID
	XML_SCHEMAV_CVC_MAXLENGTH_VALID
	XML_SCHEMAV_CVC_MININCLUSIVE_VALID
	XML_SCHEMAV_CVC_MAXINCLUSIVE_VALID
	XML_SCHEMAV_CVC_MINEXCLUSIVE_VALID
	XML_SCHEMAV_CVC_MAXEXCLUSIVE_VALID
	XML_SCHEMAV_CVC_TOTALDIGITS_VALID
	XML_SCHEMAV_CVC_FRACTIONDIGITS_VALID
	XML_SCHEMAV_CVC_PATTERN_VALID
	XML_SCHEMAV_CVC_ENUMERATION_VALID
	XML_SCHEMAV_CVC_COMPLEX_TYPE_2_1
	XML_SCHEMAV_CVC_COMPLEX_TYPE_2_2
	XML_SCHEMAV_CVC_COMPLEX_TYPE_2_3
	XML_SCHEMAV_CVC_COMPLEX_TYPE_2_4
	XML_SCHEMAV_CVC_ELT_1
	XML_SCHEMAV_CVC_ELT_2
	XML_SCHEMAV_CVC_ELT_3_1
	XML_SCHEMAV_CVC_ELT_3_2_1
	XML_SCHEMAV_CVC_ELT_3_2_2
	XML_SCHEMAV_CVC_ELT_4_1
	XML_SCHEMAV_CVC_ELT_4_2
	XML_SCHEMAV_CVC_ELT_4_3
	XML_SCHEMAV_CVC_ELT_5_1_1
	XML_SCHEMAV_CVC_ELT_5_1_2
	XML_SCHEMAV_CVC_ELT_5_2_1
	XML_SCHEMAV_CVC_ELT_5_2_2_1
	XML_SCHEMAV_CVC_ELT_5_2_2_2_1
	XML_SCHEMAV_CVC_ELT_5_2_2_2_2
	XML_SCHEMAV_CVC_ELT_6
	XML_SCHEMAV_CVC_ELT_7
	XML_SCHEMAV_CVC_ATTRIBUTE_1
	XML_SCHEMAV_CVC_ATTRIBUTE_2
	XML_SCHEMAV_CVC_ATTRIBUTE_3
	XML_SCHEMAV_CVC_ATTRIBUTE_4
	XML_SCHEMAV_CVC_COMPLEX_TYPE_3_1
	XML_SCHEMAV_CVC_COMPLEX_TYPE_3_2_1
	XML_SCHEMAV_CVC_COMPLEX_TYPE_3_2_2
	XML_SCHEMAV_CVC_COMPLEX_TYPE_4
	XML_SCHEMAV_CVC_COMPLEX_TYPE_5_1
	XML_SCHEMAV_CVC_COMPLEX_TYPE_5_2
	XML_SCHEMAV_ELEMENT_CONTENT
	XML_SCHEMAV_DOCUMENT_ELEMENT_MISSING
	XML_SCHEMAV_CVC_COMPLEX_TYPE_1
	XML_SCHEMAV_CVC_AU
	XML_SCHEMAV_CVC_TYPE_1
	XML_SCHEMAV_CVC_TYPE_2
	XML_XPTR_UNKNOWN_SCHEME = 1900
	XML_XPTR_CHILDSEQ_START
	XML_XPTR_EVAL_FAILED
	XML_XPTR_EXTRA_OBJECTS
	XML_C14N_CREATE_CTXT = 1950
	XML_C14N_REQUIRES_UTF8
	XML_C14N_CREATE_STACK
	XML_C14N_INVALID_NODE
	XML_FTP_PASV_ANSWER = 2000
	XML_FTP_EPSV_ANSWER
	XML_FTP_ACCNT
	XML_HTTP_URL_SYNTAX = 2020
	XML_HTTP_USE_IP
	XML_HTTP_UNKNOWN_HOST
	XML_SCHEMAP_SRC_SIMPLE_TYPE_1 = 3000
	XML_SCHEMAP_SRC_SIMPLE_TYPE_2
	XML_SCHEMAP_SRC_SIMPLE_TYPE_3
	XML_SCHEMAP_SRC_SIMPLE_TYPE_4
	XML_SCHEMAP_SRC_RESOLVE
	XML_SCHEMAP_SRC_RESTRICTION_BASE_OR_SIMPLETYPE
	XML_SCHEMAP_SRC_LIST_ITEMTYPE_OR_SIMPLETYPE
	XML_SCHEMAP_SRC_UNION_MEMBERTYPES_OR_SIMPLETYPES
	XML_SCHEMAP_ST_PROPS_CORRECT_1
	XML_SCHEMAP_ST_PROPS_CORRECT_2
	XML_SCHEMAP_ST_PROPS_CORRECT_3
	XML_SCHEMAP_COS_ST_RESTRICTS_1_1
	XML_SCHEMAP_COS_ST_RESTRICTS_1_2
	XML_SCHEMAP_COS_ST_RESTRICTS_1_3_1
	XML_SCHEMAP_COS_ST_RESTRICTS_1_3_2
	XML_SCHEMAP_COS_ST_RESTRICTS_2_1
	XML_SCHEMAP_COS_ST_RESTRICTS_2_3_1_1
	XML_SCHEMAP_COS_ST_RESTRICTS_2_3_1_2
	XML_SCHEMAP_COS_ST_RESTRICTS_2_3_2_1
	XML_SCHEMAP_COS_ST_RESTRICTS_2_3_2_2
	XML_SCHEMAP_COS_ST_RESTRICTS_2_3_2_3
	XML_SCHEMAP_COS_ST_RESTRICTS_2_3_2_4
	XML_SCHEMAP_COS_ST_RESTRICTS_2_3_2_5
	XML_SCHEMAP_COS_ST_RESTRICTS_3_1
	XML_SCHEMAP_COS_ST_RESTRICTS_3_3_1
	XML_SCHEMAP_COS_ST_RESTRICTS_3_3_1_2
	XML_SCHEMAP_COS_ST_RESTRICTS_3_3_2_2
	XML_SCHEMAP_COS_ST_RESTRICTS_3_3_2_1
	XML_SCHEMAP_COS_ST_RESTRICTS_3_3_2_3
	XML_SCHEMAP_COS_ST_RESTRICTS_3_3_2_4
	XML_SCHEMAP_COS_ST_RESTRICTS_3_3_2_5
	XML_SCHEMAP_COS_ST_DERIVED_OK_2_1
	XML_SCHEMAP_COS_ST_DERIVED_OK_2_2
	XML_SCHEMAP_S4S_ELEM_NOT_ALLOWED
	XML_SCHEMAP_S4S_ELEM_MISSING
	XML_SCHEMAP_S4S_ATTR_NOT_ALLOWED
	XML_SCHEMAP_S4S_ATTR_MISSING
	XML_SCHEMAP_S4S_ATTR_INVALID_VALUE
	XML_SCHEMAP_SRC_ELEMENT_1
	XML_SCHEMAP_SRC_ELEMENT_2_1
	XML_SCHEMAP_SRC_ELEMENT_2_2
	XML_SCHEMAP_SRC_ELEMENT_3
	XML_SCHEMAP_P_PROPS_CORRECT_1
	XML_SCHEMAP_P_PROPS_CORRECT_2_1
	XML_SCHEMAP_P_PROPS_CORRECT_2_2
	XML_SCHEMAP_E_PROPS_CORRECT_2
	XML_SCHEMAP_E_PROPS_CORRECT_3
	XML_SCHEMAP_E_PROPS_CORRECT_4
	XML_SCHEMAP_E_PROPS_CORRECT_5
	XML_SCHEMAP_E_PROPS_CORRECT_6
	XML_SCHEMAP_SRC_INCLUDE
	XML_SCHEMAP_SRC_ATTRIBUTE_1
	XML_SCHEMAP_SRC_ATTRIBUTE_2
	XML_SCHEMAP_SRC_ATTRIBUTE_3_1
	XML_SCHEMAP_SRC_ATTRIBUTE_3_2
	XML_SCHEMAP_SRC_ATTRIBUTE_4
	XML_SCHEMAP_NO_XMLNS
	XML_SCHEMAP_NO_XSI
	XML_SCHEMAP_COS_VALID_DEFAULT_1
	XML_SCHEMAP_COS_VALID_DEFAULT_2_1
	XML_SCHEMAP_COS_VALID_DEFAULT_2_2_1
	XML_SCHEMAP_COS_VALID_DEFAULT_2_2_2
	XML_SCHEMAP_CVC_SIMPLE_TYPE
	XML_SCHEMAP_COS_CT_EXTENDS_1_1
	XML_SCHEMAP_SRC_IMPORT_1_1
	XML_SCHEMAP_SRC_IMPORT_1_2
	XML_SCHEMAP_SRC_IMPORT_2
	XML_SCHEMAP_SRC_IMPORT_2_1
	XML_SCHEMAP_SRC_IMPORT_2_2
	XML_SCHEMAP_INTERNAL
	XML_SCHEMAP_NOT_DETERMINISTIC
	XML_SCHEMAP_SRC_ATTRIBUTE_GROUP_1
	XML_SCHEMAP_SRC_ATTRIBUTE_GROUP_2
	XML_SCHEMAP_SRC_ATTRIBUTE_GROUP_3
	XML_SCHEMAP_MG_PROPS_CORRECT_1
	XML_SCHEMAP_MG_PROPS_CORRECT_2
	XML_SCHEMAP_SRC_CT_1
	XML_SCHEMAP_DERIVATION_OK_RESTRICTION_2_1_3
	XML_SCHEMAP_AU_PROPS_CORRECT_2
	XML_SCHEMAP_A_PROPS_CORRECT_2
	XML_MODULE_OPEN = 4900
	XML_MODULE_CLOSE
	XML_CHECK_FOUND_ELEMENT = 5000
	XML_CHECK_FOUND_ATTRIBUTE
	XML_CHECK_FOUND_TEXT
	XML_CHECK_FOUND_CDATA
	XML_CHECK_FOUND_ENTITYREF
	XML_CHECK_FOUND_ENTITY
	XML_CHECK_FOUND_PI
	XML_CHECK_FOUND_COMMENT
	XML_CHECK_FOUND_DOCTYPE
	XML_CHECK_FOUND_FRAGMENT
	XML_CHECK_FOUND_NOTATION
	XML_CHECK_UNKNOWN_NODE
	XML_CHECK_ENTITY_TYPE
	XML_CHECK_NO_PARENT
	XML_CHECK_NO_DOC
	XML_CHECK_NO_NAME
	XML_CHECK_NO_ELEM
	XML_CHECK_WRONG_DOC
	XML_CHECK_NO_PREV
	XML_CHECK_WRONG_PREV
	XML_CHECK_NO_NEXT
	XML_CHECK_WRONG_NEXT
	XML_CHECK_NOT_DTD
	XML_CHECK_NOT_ATTR
	XML_CHECK_NOT_ATTR_DECL
	XML_CHECK_NOT_ELEM_DECL
	XML_CHECK_NOT_ENTITY_DECL
	XML_CHECK_NOT_NS_DECL
	XML_CHECK_NO_HREF
	XML_CHECK_WRONG_PARENT
	XML_CHECK_NS_SCOPE
	XML_CHECK_NS_ANCESTOR
	XML_CHECK_NOT_UTF8
	XML_CHECK_NO_DICT
	XML_CHECK_NOT_NCNAME
	XML_CHECK_OUTSIDE_DICT
	XML_CHECK_WRONG_NAME
	XML_CHECK_NAME_NOT_NULL
end enum

type xmlGenericErrorFunc as any ptr
type xmlStructuredErrorFunc as any ptr

declare sub xmlSetGenericErrorFunc cdecl alias "xmlSetGenericErrorFunc" (byval ctx as any ptr, byval handler as xmlGenericErrorFunc)
declare sub initGenericErrorDefaultFunc cdecl alias "initGenericErrorDefaultFunc" (byval handler as xmlGenericErrorFunc ptr)
declare sub xmlSetStructuredErrorFunc cdecl alias "xmlSetStructuredErrorFunc" (byval ctx as any ptr, byval handler as xmlStructuredErrorFunc)
declare sub xmlParserError cdecl alias "xmlParserError" (byval ctx as any ptr, byval msg as zstring ptr, ...)
declare sub xmlParserWarning cdecl alias "xmlParserWarning" (byval ctx as any ptr, byval msg as zstring ptr, ...)
declare sub xmlParserValidityError cdecl alias "xmlParserValidityError" (byval ctx as any ptr, byval msg as zstring ptr, ...)
declare sub xmlParserValidityWarning cdecl alias "xmlParserValidityWarning" (byval ctx as any ptr, byval msg as zstring ptr, ...)
declare sub xmlParserPrintFileInfo cdecl alias "xmlParserPrintFileInfo" (byval input as xmlParserInputPtr)
declare sub xmlParserPrintFileContext cdecl alias "xmlParserPrintFileContext" (byval input as xmlParserInputPtr)
declare function xmlGetLastError cdecl alias "xmlGetLastError" () as xmlErrorPtr
declare sub xmlResetLastError cdecl alias "xmlResetLastError" ()
declare function xmlCtxtGetLastError cdecl alias "xmlCtxtGetLastError" (byval ctx as any ptr) as xmlErrorPtr
declare sub xmlCtxtResetLastError cdecl alias "xmlCtxtResetLastError" (byval ctx as any ptr)
declare sub xmlResetError cdecl alias "xmlResetError" (byval err as xmlErrorPtr)
declare function xmlCopyError cdecl alias "xmlCopyError" (byval from as xmlErrorPtr, byval to as xmlErrorPtr) as integer

#endif
