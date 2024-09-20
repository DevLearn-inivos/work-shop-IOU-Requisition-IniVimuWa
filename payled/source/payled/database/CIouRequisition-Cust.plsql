-----------------------------------------------------------------------------
--
--  Logical unit: CIouRequisition
--  Component:    PAYLED
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  240918  IniVimuWa   
-----------------------------------------------------------------------------

layer Cust;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
-- (+) 240918 InivimuWa (START)
FUNCTION Get_Total_Spent_Amount (cash_ac_ IN VARCHAR2
                                 )RETURN NUMBER 
IS 
   total_spent_amount_ NUMBER;
   
   CURSOR Get_Total_Utilized(cash_ac VARCHAR2)IS 
   SELECT  sum(irl.amount) amount_      
   FROM    c_iou_requisition_line_tab irl
   WHERE   irl.cash_ac = cash_ac_;

BEGIN
   OPEN Get_Total_Utilized(cash_ac_);
   FETCH Get_Total_Utilized INTO total_spent_amount_;
   CLOSE Get_Total_Utilized;
   
   RETURN total_spent_amount_;
END Get_Total_Spent_Amount; 
   

FUNCTION Get_Utilized_Amount(cash_ac_ IN VARCHAR2
                                 )RETURN NUMBER
IS 
   utilized_amount_ NUMBER;
   allocated_amount_ NUMBER;
   
   CURSOR  Get_Allocated_Amount(cash_ac_ VARCHAR2) IS 
   SELECT  irt.c_iou_amount allocated_amount      
   FROM    c_iou_requisition_tab irt
   WHERE   irt.cash_ac = cash_ac_; 

BEGIN
   OPEN Get_Allocated_Amount(cash_ac_);
   FETCH Get_Allocated_Amount INTO allocated_amount_ ;
   CLOSE Get_Allocated_Amount;
   
   utilized_amount_ :=  allocated_amount_ - Get_Total_Spent_Amount(cash_ac_);
   RETURN utilized_amount_ ;
END Get_Utilized_Amount;
  -- (+) 240918 InivimuWa (FINISH)
   
   
   -------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
   
   
   -------------------- LU SPECIFIC PROTECTED METHODS --------------------------
   
   
   -------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
   
   
   -------------------- LU CUST NEW METHODS -------------------------------------
   