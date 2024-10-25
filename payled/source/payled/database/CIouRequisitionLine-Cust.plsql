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
-- (+) 240918 InivimuWa (START)
FUNCTION Get_Total_Spent_Amount (c_iou_number_ IN NUMBER 
                                 )RETURN NUMBER 
IS 
   total_spent_amount_ NUMBER;
   
   CURSOR Get_Total_Utilized(c_iou_number_ NUMBER)IS 
   SELECT  sum(irl.amount) amount_      
   FROM    c_iou_requisition_line irl
   WHERE   irl.c_iou_number = c_iou_number_;

BEGIN
   IF c_iou_number_ IS NULL THEN
    total_spent_amount_ := 0;
    RETURN total_spent_amount_; 
   END IF;
   
   OPEN Get_Total_Utilized(c_iou_number_);
   FETCH Get_Total_Utilized INTO total_spent_amount_;
   CLOSE Get_Total_Utilized;
   
   RETURN total_spent_amount_;
END Get_Total_Spent_Amount; 
   
FUNCTION Get_Utilized_Amount(c_iou_number_ IN NUMBER) RETURN NUMBER IS
   utilized_amount_ NUMBER;
   allocated_amount_ NUMBER;

   CURSOR Get_Allocated_Amount(c_iou_number_ NUMBER) IS 
      SELECT irt.float_amount allocated_amount      
      FROM c_iou_requisition irt
      WHERE irt.c_iou_number = c_iou_number_; 

BEGIN
   IF c_iou_number_ IS NULL THEN
       utilized_amount_ := 0;
       RETURN utilized_amount_;     
   END IF;
   OPEN Get_Allocated_Amount(c_iou_number_);
   FETCH Get_Allocated_Amount INTO allocated_amount_;
   CLOSE Get_Allocated_Amount;

   IF allocated_amount_ IS NULL THEN
      allocated_amount_ := 0;
   END IF;

   utilized_amount_ := allocated_amount_ - Get_Total_Spent_Amount(c_iou_number_);

   RETURN utilized_amount_;
END Get_Utilized_Amount;
-- (+) 240918 InivimuWa (FINISH)


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
