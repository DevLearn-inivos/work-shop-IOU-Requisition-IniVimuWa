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

-- (+) 241014 InivimuWa (START)
TYPE C_Site_Rec_ IS RECORD (
   site VARCHAR2(100)
);

TYPE C_User_Id_Rec_ IS RECORD (
   user_id VARCHAR2(100)
); 
-- (+) 241014 InivimuWa (FINISH)

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
      SELECT irt.c_iou_amount allocated_amount      
      FROM c_iou_requisition_tab irt
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
  
  -- (+) 240923 InivimuWa (START)
--FUNCTION Get_Branch_Manager RETURN Branch_Manager_Rec_ 
--IS
--   branch_manager_id_ Branch_Manager_Rec_;
--   
--   CURSOR Get_Branch_Managers IS
--      SELECT t.userid 
--      FROM user_default t 
--      WHERE t.objkey = (SELECT ud.rowkey FROM user_default_cft ud WHERE ud.cf$_c_branch_manager = 'TRUE')--;
--   
--BEGIN
--   OPEN Get_Branch_Managers;
--   FETCH Get_Branch_Managers INTO branch_manager_id_;
--   CLOSE Get_Branch_Managers;
--   
--   RETURN branch_manager_id_;
-- 
--END Get_Branch_Manager;
  -- (+) 240923 InivimuWa (FINISH) 
  
  -- (+) 241014 InivimuWa (START)
FUNCTION Get_Site RETURN C_Site_Rec_ 
IS 
   site_ C_Site_Rec_ ;
   user_id_ VARCHAR2(100);
   
   CURSOR Get_Sites(user_id_ VARCHAR2) IS
   SELECT t.contract 
   FROM user_allowed_site t
   WHERE t.userid= user_id_;
   
   CURSOR Get_User_Id IS
   SELECT v.userid 
   FROM user_default v 
   WHERE v.c_branch_manager='True';
   
BEGIN
   OPEN Get_User_Id ;
      LOOP 
         FETCH Get_User_Id INTO user_id_;
         EXIT WHEN Get_User_Id%NOTFOUND;
            OPEN Get_Sites(user_id_);
            LOOP 
            FETCH Get_Sites INTO site_;
            EXIT WHEN Get_Sites%NOTFOUND;
            CLOSE Get_Sites;
         CLOSE Get_User_Id;
          END LOOP;
      CLOSE Get_Sites; 
   END LOOP;
   CLOSE Get_User_Id; 
   RETURN site_; 
END Get_Site;

  -- (+) 241021 InivimuWa (START)
FUNCTION Get_Iou_Number RETURN NUMBER 
IS 
   current_iou_ NUMBER;
   next_val_ NUMBER;
   
   CURSOR Get_Max_Iou_Number IS 
   SELECT NVL(MAX(t.c_iou_number),0) 
   FROM c_iou_requisition_tab t;
BEGIN
   OPEN Get_Max_Iou_Number ;
   FETCH Get_Max_Iou_Number INTO current_iou_ ;

   next_val_ := current_iou_ + 1;
   CLOSE Get_Max_Iou_Number;
   RETURN next_val_;
END Get_Iou_Number;
   
  -- (+) 241021 InivimuWa (FINISH)
  
  -- (+) 241014 InivimuWa (FINISH)
   -------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
   
   
   -------------------- LU SPECIFIC PROTECTED METHODS --------------------------
   
   
   -------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   CURSOR Get_Max_Iou_Number IS 
   SELECT NVL(MAX(t.c_iou_number),0) 
   FROM c_iou_requisition_tab t;
   
   line_no_ NUMBER;
   
BEGIN
   --Add pre-processing code here
   super(attr_);
   
   OPEN Get_Max_Iou_Number;
   FETCH Get_Max_Iou_Number INTO line_no_;
   CLOSE Get_Max_Iou_Number;
   
   IF line_no_ IS NULL THEN
      line_no_ := 0;
   END IF;  
   line_no_ := line_no_ + 1;
   Client_SYS.Add_To_Attr('C_IOU_NUMBER', line_no_, attr_);
   --Add post-processing code here
END Prepare_Insert___;









   
   -------------------- LU CUST NEW METHODS -------------------------------------
   