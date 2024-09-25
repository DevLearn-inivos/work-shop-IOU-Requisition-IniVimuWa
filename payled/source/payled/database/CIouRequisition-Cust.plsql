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
-- (+) 240924 InivimuWa (START)
TYPE Branch_Manager_Rec_ IS RECORD
   (branch_manager VARCHAR2(100)
   );
-- (+) 240924 InivimuWa (FINISH)

  -- (+) 240925 InivimuWa (START)
TYPE C_Status_Rec_ IS RECORD (
   status1  VARCHAR2(100),
   status2  VARCHAR2(100),
   status3  VARCHAR2(100) 
);
  -- (+) 240925 InivimuWa (FINISH)
-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
-- (+) 240918 InivimuWa (START)
FUNCTION Get_Total_Spent_Amount (c_iou_number_ IN NUMBER 
                                 )RETURN NUMBER 
IS 
   total_spent_amount_ NUMBER;
   
   CURSOR Get_Total_Utilized(c_iou_number_ NUMBER)IS 
   SELECT  sum(irl.amount) amount_      
   FROM    c_iou_requisition_line_tab irl
   WHERE   irl.c_iou_number = c_iou_number_;

BEGIN
   OPEN Get_Total_Utilized(c_iou_number_);
   FETCH Get_Total_Utilized INTO total_spent_amount_;
   CLOSE Get_Total_Utilized;
   
   RETURN total_spent_amount_;
END Get_Total_Spent_Amount; 
   

FUNCTION Get_Utilized_Amount(c_iou_number_ IN NUMBER
                                 )RETURN NUMBER
IS 
   utilized_amount_ NUMBER;
   allocated_amount_ NUMBER;
   
   CURSOR  Get_Allocated_Amount(c_iou_number_ NUMBER) IS 
   SELECT  irt.c_iou_amount allocated_amount      
   FROM    c_iou_requisition_tab irt
   WHERE   irt.c_iou_number = c_iou_number_; 

BEGIN
   OPEN Get_Allocated_Amount(c_iou_number_);
   FETCH Get_Allocated_Amount INTO allocated_amount_ ;
   CLOSE Get_Allocated_Amount;
   
   utilized_amount_ :=  allocated_amount_ - Get_Total_Spent_Amount(c_iou_number_);
   RETURN utilized_amount_ ;
END Get_Utilized_Amount;
  -- (+) 240918 InivimuWa (FINISH)
  
  -- (+) 240923 InivimuWa (START)
FUNCTION Get_Branch_Manager RETURN Branch_Manager_Rec_ 
IS
   branch_manager_id_ Branch_Manager_Rec_;
   
   CURSOR Get_Branch_Managers IS
      SELECT t.userid 
      FROM user_default t 
      WHERE t.objkey = (SELECT ud.rowkey FROM user_default_cft ud WHERE ud.cf$_c_branch_manager = 'TRUE');
   
BEGIN
   OPEN Get_Branch_Managers;
   FETCH Get_Branch_Managers INTO branch_manager_id_;
   CLOSE Get_Branch_Managers;
   
   RETURN branch_manager_id_;
 
END Get_Branch_Manager;
  -- (+) 240923 InivimuWa (FINISH) 
   -------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
   
   
   -------------------- LU SPECIFIC PROTECTED METHODS --------------------------
   
   
   -------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
   
   
   -------------------- LU CUST NEW METHODS -------------------------------------
   