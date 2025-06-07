CLASS zcl_database_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: copy_mard_to_zstock_levels, set_min_stock.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DATABASE_HANDLER IMPLEMENTATION.


  METHOD copy_mard_to_zstock_levels.

    DELETE FROM zstock_levels.
    INSERT zstock_levels FROM (
     SELECT
       m~matnr,
       m~werks,
       m~lgort,
       m~labst,
       a~meins,
       t~maktx
     FROM mard AS m
     INNER JOIN mara AS a ON m~matnr = a~matnr
     INNER JOIN makt AS t ON t~matnr = m~matnr
     WHERE t~spras = @sy-langu
   ).

    IF sy-subrc = 0.
      MESSAGE s001(z_message_agh2402_pr).
    ELSE.
      MESSAGE e002(z_message_agh2402_pr) WITH sy-subrc.
    ENDIF.
  ENDMETHOD.


  METHOD set_min_stock.

    DATA: lt_zstock_levels TYPE STANDARD TABLE OF zstock_levels,
          fs_zstock        TYPE zstock_levels.

    SELECT * FROM zstock_levels INTO TABLE lt_zstock_levels.

    LOOP AT lt_zstock_levels ASSIGNING FIELD-SYMBOL(<fs_zstock>).
      SELECT SINGLE meins FROM mara
        WHERE matnr = @<fs_zstock>-matnr
        INTO @DATA(lv_meins).

      IF lv_meins IS NOT INITIAL.
        <fs_zstock>-meins = lv_meins.
      ELSE.
        <fs_zstock>-meins = 'STK'.
      ENDIF.

      <fs_zstock>-min_stock = 10.
    ENDLOOP.

    MODIFY zstock_levels FROM TABLE lt_zstock_levels.

  ENDMETHOD.
ENDCLASS.
