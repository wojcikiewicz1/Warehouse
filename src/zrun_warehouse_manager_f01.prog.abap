*&---------------------------------------------------------------------*
*& Include          ZRUN_WAREHOUSE_MANAGER_F01
*&---------------------------------------------------------------------*

FORM refresh_stock_data.
  SELECT * FROM zstock_levels INTO TABLE gt_stock_levels.

  IF alv_grid IS NOT INITIAL.
    CALL METHOD alv_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZSTOCK_LEVELS'
      CHANGING
        it_outtab        = gt_stock_levels.
  ENDIF.
ENDFORM.

FORM refresh_stock_log.
  SELECT * FROM zstock_log INTO TABLE gt_stock_log.

  IF alv_grid_2 IS NOT INITIAL.
    CALL METHOD alv_grid_2->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZSTOCK_LOG'
      CHANGING
        it_outtab        = gt_stock_log.
  ENDIF.
ENDFORM.

FORM save_stock_data_delivery.
  DATA: ls_stock         TYPE zstock_levels,
        ls_log           TYPE zstock_log,
        lv_existing_log  TYPE zstock_log,
        ls_existing      TYPE zstock_levels,
        lv_delivered_qty TYPE zstock_quantity.

  " --------------------- Input validations ---------------------
  IF mard-matnr IS INITIAL.
    MESSAGE i004(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-labst IS INITIAL.
    MESSAGE i005(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-werks IS INITIAL.
    MESSAGE i006(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-lgort IS INITIAL.
    MESSAGE i007(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-labst IS INITIAL OR mard-labst <= 0.
    MESSAGE i008(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF vbak-vbeln IS INITIAL.
    MESSAGE i009(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF vbrp-posnr IS INITIAL.
    MESSAGE i010(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  " --------------------- Check if this invoice item has already been saved ---------------------
  SELECT SINGLE vbeln
  INTO @lv_existing_log-vbeln
  FROM zstock_log
  WHERE vbeln = @vbak-vbeln
    AND posnr = @vbrp-posnr.

  IF sy-subrc = 0.
    MESSAGE i017(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  "--------------------- Saving to warehouse and log ---------------------
  TRY.
      " --- Preparing data for saving to warehouse ---
      ls_stock-matnr = mard-matnr.
      ls_stock-werks = mard-werks.
      ls_stock-lgort = mard-lgort.
      ls_stock-labst = mard-labst.
      ls_stock-laeda = sy-datum.
      ls_stock-aenam = sy-uname.

      SELECT SINGLE meins FROM mara
         WHERE matnr = @mard-matnr
         INTO @ls_stock-meins.

      SELECT SINGLE maktx FROM makt
        WHERE matnr = @mard-matnr
        INTO @ls_stock-maktx.

      lv_delivered_qty = mard-labst.

      " --- Preparing data for saving to log ---
      CLEAR ls_log.
      ls_log-vbeln    = vbak-vbeln.
      ls_log-posnr    = vbrp-posnr.
      ls_log-matnr    = ls_stock-matnr.
      ls_log-meins    = ls_stock-meins.
      ls_log-werks    = ls_stock-werks.
      ls_log-lgort    = ls_stock-lgort.
      ls_log-quantity = lv_delivered_qty.
      ls_log-type     = 'D'.
      ls_log-laeda    = sy-datum.
      ls_log-aenam    = sy-uname.

      " --- Insert or update zstock_levels ---
      SELECT SINGLE * FROM zstock_levels INTO @ls_existing
        WHERE matnr = @ls_stock-matnr
          AND werks = @ls_stock-werks
          AND lgort = @ls_stock-lgort.

      IF sy-subrc = 0.
        " --- Updating an existing record ---
        ls_stock-labst = ls_stock-labst + ls_existing-labst.
        ls_stock-min_stock = ls_existing-min_stock.
        UPDATE zstock_levels FROM ls_stock.
        IF sy-subrc = 0.
          MESSAGE s011(z_message_agh2402_pr).
          CLEAR: mard-matnr,
                   mard-werks,
                   mard-lgort,
                   mard-labst.
          PERFORM refresh_stock_data.

        ELSE.
          MESSAGE i012(z_message_agh2402_pr).
          RAISE EXCEPTION TYPE cx_sy_no_handler.
        ENDIF.
      ELSE.
        " --- Inserting a new record ---
        ls_stock-min_stock = 10.
        INSERT zstock_levels FROM ls_stock.
        IF sy-subrc = 0.
          MESSAGE s013(z_message_agh2402_pr).
        ELSE.
          MESSAGE i014(z_message_agh2402_pr).
          RAISE EXCEPTION TYPE cx_sy_no_handler.
        ENDIF.
      ENDIF.

      INSERT zstock_log FROM ls_log.

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        MESSAGE i015(z_message_agh2402_pr).
        RAISE EXCEPTION TYPE cx_sy_no_handler.
      ENDIF.

    CATCH cx_sy_no_handler INTO DATA(lx_failure).
      " --- In case of an error, perform a rollback ---
      ROLLBACK WORK.
      MESSAGE i016(z_message_agh2402_pr).
  ENDTRY.

  " --- Clearing fields and refreshing ---
  CLEAR: mard-matnr,
         mard-werks,
         mard-lgort,
         mard-labst,
         vbak-vbeln,
         vbrp-posnr.

  PERFORM refresh_stock_data.
  PERFORM refresh_stock_log.

  gv_save_attempted = abap_false.
ENDFORM.

FORM save_stock_data_consumption.
  DATA: ls_stock         TYPE zstock_levels,
        ls_log           TYPE zstock_log,
        ls_existing      TYPE zstock_levels,
        lv_existing_log  TYPE zstock_log,
        lv_delivered_qty TYPE zstock_quantity.

  " --------------------- Input validations ---------------------
  IF mard-matnr IS INITIAL.
    MESSAGE i004(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-labst IS INITIAL.
    MESSAGE i005(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-werks IS INITIAL.
    MESSAGE i006(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-lgort IS INITIAL.
    MESSAGE i007(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-labst IS INITIAL.
    MESSAGE i008(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF mard-labst <= 0.
    MESSAGE i018(z_message_agh2402_pr).
    gv_save_attempted = abap_false.
    RETURN.
  ENDIF.

  IF rb2 = abap_true.

    IF vbak-vbeln IS INITIAL.
      MESSAGE i009(z_message_agh2402_pr).
      gv_save_attempted = abap_false.
      RETURN.
    ENDIF.

    IF vbrp-posnr IS INITIAL.
      MESSAGE i010(z_message_agh2402_pr).
      gv_save_attempted = abap_false.
      RETURN.
    ENDIF.

  ENDIF.

  " --------------------- Check if this invoice item has already been saved ---------------------
  IF rb2 = abap_true.

    SELECT SINGLE vbeln
      INTO @lv_existing_log-vbeln
      FROM zstock_log
      WHERE vbeln = @vbak-vbeln
        AND posnr = @vbrp-posnr.

    IF sy-subrc = 0.
      MESSAGE i017(z_message_agh2402_pr).
      gv_save_attempted = abap_false.
      RETURN.
    ENDIF.

  ENDIF.

  "--------------------- Saving to warehouse and log ---------------------
  TRY.
      " --- Preparing data for saving to warehouse ---
      ls_stock-matnr = mard-matnr.
      ls_stock-werks = mard-werks.
      ls_stock-lgort = mard-lgort.
      ls_stock-labst = mard-labst.
      ls_stock-laeda = sy-datum.
      ls_stock-aenam = sy-uname.

      " --- Fetching data from tables MARA and MAKT ---
      SELECT SINGLE meins FROM mara
        WHERE matnr = @mard-matnr
        INTO @ls_stock-meins.

      SELECT SINGLE maktx FROM makt
        WHERE matnr = @mard-matnr
        INTO @ls_stock-maktx.

      lv_delivered_qty = mard-labst.

      " --- Preparing data for saving to log ---
      CLEAR ls_log.

      IF rb1 = abap_true.
        ls_log-vbeln = 'N/A'.
        ls_log-posnr = sy-uzeit.
      ELSEIF rb2 = abap_true.
        ls_log-vbeln = vbak-vbeln.
        ls_log-posnr = vbrp-posnr.
      ENDIF.

      ls_log-matnr    = ls_stock-matnr.
      ls_log-meins    = ls_stock-meins.
      ls_log-werks    = ls_stock-werks.
      ls_log-lgort    = ls_stock-lgort.
      ls_log-quantity = lv_delivered_qty.
      ls_log-type     = 'C'.
      ls_log-laeda    = sy-datum.
      ls_log-aenam    = sy-uname.

      " --- Saving to warehouse ---
      SELECT SINGLE * FROM zstock_levels INTO ls_existing
        WHERE matnr = ls_stock-matnr
          AND werks = ls_stock-werks
          AND lgort = ls_stock-lgort.

      IF sy-subrc = 0.
        IF ls_existing-labst < ls_stock-labst.
          MESSAGE i023(z_message_agh2402_pr) WITH ls_existing-labst ls_stock-labst.
          RAISE EXCEPTION TYPE cx_sy_no_handler.
        ENDIF.

        UPDATE zstock_levels
          SET labst = labst - @ls_stock-labst,
              laeda = @sy-datum,
              aenam = @sy-uname
          WHERE matnr = @ls_stock-matnr
            AND werks = @ls_stock-werks
            AND lgort = @ls_stock-lgort.

        IF sy-subrc = 0.
          " --- Logging after successful warehouse save ---
          INSERT zstock_log FROM ls_log.

          IF sy-subrc = 0.
            " --- Sending emails after saving warehouse data ---
            COMMIT WORK.
            MESSAGE s011(z_message_agh2402_pr).

            PERFORM check_and_notify_low_stock  USING ls_stock.

            CLEAR: mard-matnr,
                   mard-werks,
                   mard-lgort,
                   mard-labst.

            PERFORM refresh_stock_data.
          ELSE.
            MESSAGE e015(z_message_agh2402_pr).
            RAISE EXCEPTION TYPE cx_sy_no_handler.
          ENDIF.
        ELSE.
          MESSAGE e020(z_message_agh2402_pr).
          RAISE EXCEPTION TYPE cx_sy_no_handler.
        ENDIF.
      ELSE.
        MESSAGE e021(z_message_agh2402_pr).
        RAISE EXCEPTION TYPE cx_sy_no_handler.
      ENDIF.

    CATCH cx_sy_no_handler INTO DATA(lx_failure).
      ROLLBACK WORK.
      MESSAGE e016(z_message_agh2402_pr).
  ENDTRY.

  " --- Clearing fields and refreshing the screen ---
  CLEAR: mard-matnr,
         mard-werks,
         mard-lgort,
         mard-labst,
         vbak-vbeln,
         vbrp-posnr.

  PERFORM refresh_stock_data.
  PERFORM refresh_stock_log.

  gv_save_attempted = abap_false.
ENDFORM.

FORM check_and_notify_low_stock USING is_stock TYPE zstock_levels.
  DATA: lv_min_stock     TYPE zstock_levels-min_stock,
        lv_current_labst TYPE zstock_levels-labst,
        lv_answer        TYPE c,
        lo_send_request  TYPE REF TO cl_bcs,
        lo_document      TYPE REF TO cl_document_bcs,
        lt_content       TYPE bcsy_text,
        lo_recipient     TYPE REF TO if_recipient_bcs.

  SELECT SINGLE min_stock INTO @lv_min_stock
    FROM zstock_levels
    WHERE matnr = @is_stock-matnr
      AND werks = @is_stock-werks
      AND lgort = @is_stock-lgort.

  SELECT SINGLE labst INTO @lv_current_labst
    FROM zstock_levels
    WHERE matnr = @is_stock-matnr
      AND werks = @is_stock-werks
      AND lgort = @is_stock-lgort.

  CHECK sy-subrc = 0.

  IF lv_current_labst < lv_min_stock.

    APPEND |Attention! The stock level of material { is_stock-matnr } has fallen below the minimum level!| TO lt_content.
    APPEND |Current stock: { is_stock-labst },  threshold: { lv_min_stock }| TO lt_content.

    lo_document = cl_document_bcs=>create_document(
      i_type    = 'RAW'
      i_subject = 'Low stock level'
      i_text    = lt_content
    ).

    SELECT * FROM zstock_notify INTO TABLE @DATA(lt_recipients).

    " --- Create message and request sending ---
    lo_send_request = cl_bcs=>create_persistent( ).
    lo_send_request->set_document( lo_document ).

    LOOP AT lt_recipients INTO DATA(ls_recipient).

      IF ls_recipient-email IS NOT INITIAL.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( ls_recipient-email ).
        lo_send_request->add_recipient( lo_recipient ).
      ENDIF.

    ENDLOOP.

    lo_send_request->send( i_with_error_screen = 'X' ).
    COMMIT WORK.

    " Popup after sending email
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar      = 'Information'
        text_question = 'The low stock notification emails were sent successfully. Would you like to create a PR?'
        text_button_1 = 'Yes'
        text_button_2 = 'No'
      IMPORTING
        answer        = lv_answer.

    IF lv_answer = '1'.
      MESSAGE s019(z_message_agh2402_pr).
      CALL TRANSACTION 'ME51N' AND SKIP FIRST SCREEN.
    ELSE.
      MESSAGE s025(z_message_agh2402_pr).
    ENDIF.

  ENDIF.
ENDFORM.

FORM save_stock_emails.
  IF alv_grid_3 IS BOUND.
    CALL METHOD alv_grid_3->check_changed_data.
  ENDIF.

  LOOP AT gt_stock_notify INTO DATA(ls_row).
    IF ls_row-email IS INITIAL.
      MESSAGE i022(z_message_agh2402_pr).
    ENDIF.
  ENDLOOP.

  MODIFY zstock_notify FROM TABLE gt_stock_notify.

  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE s013(z_message_agh2402_pr).
  ELSE.
    MESSAGE i014(z_message_agh2402_pr).
  ENDIF.
ENDFORM.
