*&---------------------------------------------------------------------*
*&  Include           ZABAPGIT_OBJECT_STYL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_object_styl DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_object_styl DEFINITION INHERITING FROM lcl_objects_super FINAL.

  PUBLIC SECTION.
    INTERFACES lif_object.
    ALIASES mo_files FOR lif_object~mo_files.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_style,
             header     TYPE itcda,
             paragraphs TYPE STANDARD TABLE OF itcdp WITH DEFAULT KEY,
             strings    TYPE STANDARD TABLE OF itcds WITH DEFAULT KEY,
             tabs       TYPE STANDARD TABLE OF itcdq WITH DEFAULT KEY,
           END OF ty_style.

ENDCLASS.                    "lcl_object_styl DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_object_styl IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_object_styl IMPLEMENTATION.

  METHOD lif_object~has_changed_since.
    rv_changed = abap_true.
  ENDMETHOD.  "lif_object~has_changed_since

  METHOD lif_object~changed_by.

    DATA: ls_style TYPE ty_style,
          lv_name  TYPE itcda-tdstyle.


    lv_name = ms_item-obj_name.

    CALL FUNCTION 'READ_STYLE'
      EXPORTING
        style        = lv_name
      IMPORTING
        style_header = ls_style-header
      TABLES
        paragraphs   = ls_style-paragraphs
        strings      = ls_style-strings
        tabs         = ls_style-tabs.

    rv_user = ls_style-header-tdluser.

  ENDMETHOD.

  METHOD lif_object~get_metadata.
    rs_metadata = get_metadata( ).
    rs_metadata-delete_tadir = abap_true.
  ENDMETHOD.                    "lif_object~get_metadata

  METHOD lif_object~exists.

    DATA: ls_style TYPE ty_style,
          lv_name  TYPE itcda-tdstyle,
          lv_found TYPE abap_bool.


    lv_name = ms_item-obj_name.

    CALL FUNCTION 'READ_STYLE'
      EXPORTING
        style      = lv_name
      IMPORTING
        found      = lv_found
      TABLES
        paragraphs = ls_style-paragraphs
        strings    = ls_style-strings
        tabs       = ls_style-tabs.

    rv_bool = boolc( lv_found = abap_true ).

  ENDMETHOD.                    "lif_object~exists

  METHOD lif_object~jump.

    DATA: ls_bcdata TYPE bdcdata,
          lt_bcdata TYPE STANDARD TABLE OF bdcdata.

    ls_bcdata-program  = 'SAPMSSCS'.
    ls_bcdata-dynpro   = '1100'.
    ls_bcdata-dynbegin = 'X'.
    APPEND ls_bcdata TO lt_bcdata.

    CLEAR ls_bcdata.
    ls_bcdata-fnam     = 'RSSCS-TDSTYLE'.
    ls_bcdata-fval     = ms_item-obj_name.
    APPEND ls_bcdata TO lt_bcdata.

    CLEAR ls_bcdata.
    ls_bcdata-fnam     = 'RSSCS-TDSPRAS'.
    ls_bcdata-fval     = sy-langu.
    APPEND ls_bcdata TO lt_bcdata.

    CLEAR ls_bcdata.
    ls_bcdata-fnam     = 'RSSCS-TDHEADEROB'.
    ls_bcdata-fval     = 'X'.
    APPEND ls_bcdata TO lt_bcdata.

    CLEAR ls_bcdata.
    ls_bcdata-fnam = 'BDC_OKCODE'.
    ls_bcdata-fval = '=SHOW'.
    APPEND ls_bcdata TO lt_bcdata.

    CALL FUNCTION 'ABAP4_CALL_TRANSACTION'
      STARTING NEW TASK 'GIT'
      EXPORTING
        tcode     = 'SE72'
        mode_val  = 'E'
      TABLES
        using_tab = lt_bcdata
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise( 'error from ABAP4_CALL_TRANSACTION, STYL' ).
    ENDIF.

  ENDMETHOD.                    "jump

  METHOD lif_object~delete.

    DATA: lv_style TYPE itcda-tdstyle.


    lv_style = ms_item-obj_name.

    CALL FUNCTION 'DELETE_STYLE'
      EXPORTING
        style    = lv_style
        language = '*'.

  ENDMETHOD.                    "delete

  METHOD lif_object~deserialize.

    DATA: ls_style TYPE ty_style.


    io_xml->read( EXPORTING iv_name = 'STYLE'
                  CHANGING cg_data = ls_style ).

    CALL FUNCTION 'SAVE_STYLE'
      EXPORTING
        style_header = ls_style-header
      TABLES
        paragraphs   = ls_style-paragraphs
        strings      = ls_style-strings
        tabs         = ls_style-tabs.

    tadir_insert( iv_package ).

  ENDMETHOD.                    "deserialize

  METHOD lif_object~serialize.

    DATA: ls_style TYPE ty_style,
          lv_name  TYPE itcda-tdstyle.


    lv_name = ms_item-obj_name.

    CALL FUNCTION 'READ_STYLE'
      EXPORTING
        style        = lv_name
      IMPORTING
        style_header = ls_style-header
      TABLES
        paragraphs   = ls_style-paragraphs
        strings      = ls_style-strings
        tabs         = ls_style-tabs.

    CLEAR: ls_style-header-tdfuser,
           ls_style-header-tdfdate,
           ls_style-header-tdftime,
           ls_style-header-tdfreles,
           ls_style-header-tdluser,
           ls_style-header-tdldate,
           ls_style-header-tdltime,
           ls_style-header-tdlreles.

    io_xml->add( iv_name = 'STYLE'
                 ig_data = ls_style ).

  ENDMETHOD.                    "serialize

  METHOD lif_object~compare_to_remote_version.
    CREATE OBJECT ro_comparison_result TYPE lcl_comparison_null.
  ENDMETHOD.

ENDCLASS.                    "lcl_object_styl IMPLEMENTATION
