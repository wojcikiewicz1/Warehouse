PROCESS BEFORE OUTPUT.
* MODULE STATUS_0120.

PROCESS AFTER INPUT.
  CHAIN.
    FIELD: mard-matnr, mard-labst, mard-werks, mard-lgort, vbak-vbeln,
vbrp-posnr.
    MODULE transfer_fields_delivery.
  ENDCHAIN.
  MODULE user_command_0120.
