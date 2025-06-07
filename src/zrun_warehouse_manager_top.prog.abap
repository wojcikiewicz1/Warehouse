*&---------------------------------------------------------------------*
*& Include ZRUN_WAREHOUSE_MANAGER_TOP               - Module Pool      ZRUN_WAREHOUSE_MANAGER
*&---------------------------------------------------------------------*
PROGRAM zrun_warehouse_manager.

CONTROLS ts TYPE TABSTRIP.

TABLES: mara, mard, vbak, vbrp.

DATA: ok_code           TYPE sy-ucomm,
      rb1               TYPE abap_bool,
      rb2               TYPE abap_bool,
      gt_stock_levels   TYPE TABLE OF zstock_levels,
      alv_container     TYPE REF TO cl_gui_custom_container,
      alv_grid          TYPE REF TO cl_gui_alv_grid,
      gt_stock_log      TYPE TABLE OF zstock_log,
      alv_container_2   TYPE REF TO cl_gui_custom_container,
      alv_grid_2        TYPE REF TO cl_gui_alv_grid,
      go_alv_table      TYPE REF TO cl_salv_table,
      gv_save_attempted TYPE abap_bool VALUE abap_false,
      gt_stock_notify   TYPE TABLE OF zstock_notify,
      alv_container_3   TYPE REF TO cl_gui_custom_container,
      alv_grid_3        TYPE REF TO cl_gui_alv_grid.
