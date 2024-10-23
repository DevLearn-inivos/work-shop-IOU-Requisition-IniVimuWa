-----------------------------------------------------------------------------
--
--  Logical unit: CIouRequisitionLine
--  Component:    PAYLED
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Cust;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@Override 
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   CURSOR Get_Max_Iou_Number IS 
   SELECT NVL(MAX(t.line_item_no),0) 
   FROM c_iou_requisition_line_tab t;
   
   line_no_ NUMBER;
BEGIN

   super(attr_);
       OPEN Get_Max_Iou_Number;
   FETCH Get_Max_Iou_Number INTO line_no_;
   CLOSE Get_Max_Iou_Number;
   
   IF line_no_ IS NULL THEN
      line_no_ := 0;
   END IF;  
   line_no_ := line_no_ + 1;
   Client_SYS.Add_To_Attr('LINE_ITEM_NO', line_no_, attr_);
  
END Prepare_Insert___;




-------------------- LU CUST NEW METHODS -------------------------------------
