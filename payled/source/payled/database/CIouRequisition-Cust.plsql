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
@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   CURSOR Get_Max_Iou_Number IS 
   SELECT NVL(MAX(t.c_iou_number),0) 
   FROM c_iou_requisition_tab t;
   
   
   
   
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
   Client_SYS.Add_To_Attr('C_IOU_NUMBER', line_no_, attr_);
   Client_SYS.Add_To_Attr('STATUS',C_Iou_Requisition_Enum_API.Get_Client_Value(0),attr_);
   

   
END Prepare_Insert___;

@Override 
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT c_iou_requisition_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   CURSOR Get_Site(cash_ac VARCHAR2) IS 
      SELECT DISTINCT(t.c_site) 
      FROM cash_account t 
      WHERE t.institute_id = cash_ac
      AND t.c_site IS NOT NULL;
   
   site_ VARCHAR2(100);
   
BEGIN
   
   newrec_.float_amount := NVL(C_Iou_Requisition_API.Get_Float_Amount(newrec_.cash_ac), 0);
   
   OPEN Get_Site(newrec_.cash_ac);
   FETCH Get_Site INTO site_;
   CLOSE Get_Site;
   
   IF ( newrec_.site != site_) THEN 
      Error_SYS.record_general('', 'You do not have permission');
   END IF;
   
   super(objid_, objversion_, newrec_, attr_);
   
END Insert___;



-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-------------------- LU CUST NEW METHODS -------------------------------------
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

-- (+) 241014 InivimuWa (START)
FUNCTION Get_Site RETURN C_Site_Rec_ 
IS 
   site_ C_Site_Rec_ ;
   
   CURSOR Get_Sites IS
   SELECT t.contract 
   FROM user_allowed_site t
   WHERE t.c_branch_manager='True';
   
   
BEGIN
   OPEN Get_Sites;
LOOP 
   FETCH Get_Sites INTO site_;
   EXIT WHEN Get_Sites%NOTFOUND;
   
END LOOP;
CLOSE Get_Sites; 

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

FUNCTION Get_Float_Amount(cash_ac VARCHAR2) RETURN NUMBER 
IS
   float_amount_ NUMBER;
   
   CURSOR Get_Float_Amount_Cursor(cash_ac_ VARCHAR2) IS
       SELECT SUM(t.c_allocated_iou_amount) 
       FROM cash_account t 
       WHERE t.institute_id = cash_ac_;
   
BEGIN
   OPEN Get_Float_Amount_Cursor(cash_ac);
   FETCH Get_Float_Amount_Cursor INTO float_amount_;
   CLOSE Get_Float_Amount_Cursor;
   
   RETURN NVL(float_amount_, 0); 
END Get_Float_Amount;

-- (+) 241014 InivimuWa (FINISH)