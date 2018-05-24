HW	HW_ID	HWCat_ID	Description	
HWCat	HWCat_ID	Description		
JobHW	Job_ID	UnitType_ID	HW_ID	Count
Unit	Unit_ID	UnitType_ID	Floor_id	Description
UnitType	UnitType_ID	Description		
 
$PropertyName = (dir | Get-Member -membertype NoteProperty).name -join ','

$TableName = $Row.P1 # HW	
$Row  (P2...P26)     # HW_ID,HWCat_ID,Description
$PropertyName = ($Row | 
Get-Member -Property P[2-9],P[1-9][0-9] -membertype *Property*).name 

HW_ID,HWCat_ID,Description
$CreateTable = @" 
CREATE TABLE $tableName (
  column1 datatype,
  column2 datatype,
  column3 datatype,
);
"@

misc tab
misc column on draw sched

PartsList PartsList_ID Quantity Item_Category                  Description        Item_Number Unit_Price Extended_Price