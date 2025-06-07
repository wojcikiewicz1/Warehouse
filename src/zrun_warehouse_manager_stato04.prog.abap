*----------------------------------------------------------------------*
***INCLUDE ZRUN_WAREHOUSE_MANAGER_STATO04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0140 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0140 OUTPUT.
  IF alv_grid_2 IS INITIAL.

    CREATE OBJECT alv_container_2
      EXPORTING
        container_name = 'ALV_CONTAINER_2'.

    CREATE OBJECT alv_grid_2
      EXPORTING
        i_parent = alv_container_2.

    SELECT * FROM zstock_log INTO TABLE @gt_stock_log.

    CALL METHOD alv_grid_2->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZSTOCK_LOG'
      CHANGING
        it_outtab        = gt_stock_log
      EXCEPTIONS
        OTHERS           = 1.

    IF sy-subrc <> 0.
      MESSAGE e024(z_message_agh2402_pr).
    ENDIF.

  ENDIF.
ENDMODULE.
