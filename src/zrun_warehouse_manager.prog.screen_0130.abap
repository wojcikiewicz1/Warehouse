PROCESS BEFORE OUTPUT.
  MODULE status_0130.

PROCESS AFTER INPUT.
  CHAIN.
    FIELD: rb1, rb2, mard-matnr, mard-labst, mard-werks, mard-lgort,
vbak-vbeln,vbrp-posnr.
    MODULE transfer_fields_consumption.
  ENDCHAIN.
  MODULE user_command_0130.
