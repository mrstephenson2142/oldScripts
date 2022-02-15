// This script was used to keep track of historical changes month over month in an Excel Web Work Book. 
// A range would be appended to a protected sheet.
// This was integrated with power automate to automatically lock the state of the tracker the last day of the month. 

// Office Script overview - https://docs.microsoft.com/en-us/office/dev/scripts/overview/excel

function main(workbook: ExcelScript.Workbook) {

    //Defined Report Worksheet and Protection Pass
  
    let reportws = workbook.getWorksheet("Report");
  
    let protectkey = "foo"
  
   
  
    // Get Tracker Table Name 
  
    let tracker = workbook.getTables()[0];
  
    //console.log(tracker.getName());
  
   
  
    // Get Report Table
  
    let report = workbook.getTables()[2];
  
    //console.log(report.getName());  
  
   
  
    // Unprotect Report Sheet 
  
    if (reportws.getProtection().getProtected() == true) {
  
      reportws.getProtection().unprotect(protectkey);
  
    }
  
   
  
    // Clear Filters 
  
    tracker.clearFilters();
  
   
  
    // Add Temp Date Column and Fill Values 
  
   
  
    // Set Year 
  
    tracker.getColumnByName("Year")?.delete();
  
    tracker.addColumn(-1, String[""], "Year");
  
    tracker.getColumnByName("Year").getRangeBetweenHeaderAndTotal().setFormula("=Year(Now())");
  
   
  
    // Set Month 
  
   
  
    tracker.getColumnByName("Month")?.delete();
  
    tracker.addColumn(-1, String[""], "Month");
  
    tracker.getColumnByName("Month").getRangeBetweenHeaderAndTotal().setFormula("=Month(Now())");
  
   
  
    tracker.getColumnByName("Quarter")?.delete();
  
    tracker.addColumn(-1, String[""], "Quarter");
  
    tracker.getColumnByName("Quarter").getRangeBetweenHeaderAndTotal().setFormula("=\"Q\"&ROUNDUP(Month(Now())/3,0)");
  
    // Copy data to report 
  
    let data = tracker.getRangeBetweenHeaderAndTotal().getTexts();
  
    report.addRows(-1, data)
  
   
  
    // Delete Tracker Date Columns
  
    tracker.getColumnByName("Year")?.delete();
  
    tracker.getColumnByName("Month")?.delete();
  
    tracker.getColumnByName("Quarter")?.delete();
  
   
  
    //Protect Sheet
  
    if (reportws.getProtection().getProtected() == false) {
  
      reportws.getProtection().protect({}, protectkey)
  
    }
  
   
  
    //Refresh Pivot Table 
  
    
  
      let report_pivot1 = workbook.getPivotTables()[1];
  
      report_pivot1.refresh();
  
   
  
      let report_pivot2 = workbook.getPivotTables()[2];
  
      report_pivot2.refresh();
  
    
  
   
  
  }
  
   
  
   