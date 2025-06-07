*----------------------------------------------------------------------*
***INCLUDE ZRUN_WAREHOUSE_MANAGER_STATO02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

MODULE status_0110 OUTPUT.

  SELECT COUNT(*) INTO @DATA(lv_entries) FROM zstock_levels.

  IF lv_entries = 0.
    zcl_database_handler=>copy_mard_to_zstock_levels( ).
    zcl_database_handler=>set_min_stock( ).
  ENDIF.

  IF alv_grid IS INITIAL.

    CREATE OBJECT alv_container
      EXPORTING
        container_name = 'ALV_CONTAINER'.

    CREATE OBJECT alv_grid
      EXPORTING
        i_parent = alv_container.

    SELECT * FROM zstock_levels INTO TABLE @gt_stock_levels.

    CALL METHOD alv_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZSTOCK_LEVELS'
      CHANGING
        it_outtab        = gt_stock_levels
      EXCEPTIONS
        OTHERS           = 1.

    IF sy-subrc <> 0.
      MESSAGE e024(z_message_agh2402_pr).
    ENDIF.

  ENDIF.
ENDMODULE.
