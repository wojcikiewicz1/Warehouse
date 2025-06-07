*----------------------------------------------------------------------*
***INCLUDE ZRUN_WAREHOUSE_MANAGER_STATO05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0130 OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'GB1'.
      IF rb1 = abap_true.
        screen-invisible = 1.
        screen-active = 0.
      ELSEIF rb2 = abap_true.
        screen-invisible = 0.
        screen-active = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.
