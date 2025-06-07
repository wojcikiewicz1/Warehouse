*----------------------------------------------------------------------*
***INCLUDE ZRUN_WAREHOUSE_MANAGER_STATO06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0150 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

MODULE status_0150 OUTPUT.
  IF alv_grid_3 IS INITIAL.

    CREATE OBJECT alv_container_3
      EXPORTING
        container_name = 'ALV_CONTAINER_3'.

    CREATE OBJECT alv_grid_3
      EXPORTING
        i_parent = alv_container_3.

    DATA(lt_fieldcatalog) = VALUE lvc_t_fcat( ( fieldname = 'EMAIL' coltext = 'E-Mail Address' col_pos = 1 edit = 'X' ) ).

    SELECT * FROM zstock_notify INTO TABLE @gt_stock_notify.

    CALL METHOD alv_grid_3->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZSTOCK_NOTIFY'
      CHANGING
        it_outtab        = gt_stock_notify
        it_fieldcatalog  = lt_fieldcatalog
      EXCEPTIONS
        OTHERS           = 1.

    IF sy-subrc <> 0.
      MESSAGE e024(z_message_agh2402_pr).
    ENDIF.

  ENDIF.
ENDMODULE.
