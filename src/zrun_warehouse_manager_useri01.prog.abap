*----------------------------------------------------------------------*
***INCLUDE ZRUN_WAREHOUSE_MANAGER_USERI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       Handle user command for main screen (0100)
*----------------------------------------------------------------------*

MODULE user_command_0100 INPUT.

  DATA: lv_ok_code TYPE sy-ucomm.

  lv_ok_code = ok_code.
  CLEAR ok_code.

  CASE lv_ok_code.

    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      gv_save_attempted = abap_false.
      LEAVE PROGRAM.
    WHEN 'TAB1' OR 'TAB2' OR 'TAB3' OR 'TAB4' OR 'TAB5'.
    ts-activetab = lv_ok_code.
    CLEAR: mard-matnr, mard-labst, mard-werks, mard-lgort, vbak-vbeln, vbrp-posnr.
    WHEN 'REFRESH'.
      PERFORM refresh_stock_data.
    WHEN 'REFRESH_140'.
      PERFORM refresh_stock_log.
    WHEN 'RECEIVE'.
      gv_save_attempted = abap_true.
      PERFORM save_stock_data_delivery.
    WHEN 'ISSUE'.
      gv_save_attempted = abap_true.
      PERFORM save_stock_data_consumption.
    WHEN 'SAVE'.
      PERFORM save_stock_emails.
  ENDCASE.
ENDMODULE.
