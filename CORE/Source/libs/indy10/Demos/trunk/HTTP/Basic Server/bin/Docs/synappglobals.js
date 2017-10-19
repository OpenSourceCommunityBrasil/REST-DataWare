

var ProfileEditorFormHTML = '';  
var ProtocolSettingsFormHTML = '';
var InternetProtSettingsTabsHTML_FTP = ""; 
var InternetProtSettingsTabsHTML_SFTP = "";
var InternetProtSettingsTabsHTML_GoogleDrive = "";
var InternetProtSettingsTabsHTML_HTTP = "";
var InternetProtSettingsTabsHTML_AmazonS3 = "";
var InternetProtSettingsTabsHTML_Asure = "";
var InternetProtSettingsTabsHTML_WebDAV = "";
var InternetProtSettingsTabsHTML_RSync = "";
var InternetProtSettingsTabsHTML_Glacier = "";
var GFuncInitProfileEditorForm = null;

var GSelectedProfileName = "";
var GLeftProtocolName = "";
var GRightProtocolName = ""; 


  

function GetBaseProtocolName( ProtocolName )
{
   if( ProtocolName == 'FTP' )
     return 'FTP'; 
   if( ProtocolName == 'SSH')
     return 'SSH';  
   if( ProtocolName == 'Amazon S3' )
     return 'Amazon S3';    
   else if( ProtocolName == 'HTTP' )  
     return 'HTTP';  
   else if( ( ProtocolName == 'Google Drive' ) || ( ProtocolName == 'OneDrive' ) || ( ProtocolName == 'Amazon Cloud Drive' ) || ( ProtocolName == 'DropBox' )
        || ( ProtocolName == 'Box' ) )
     return 'Google Drive';     
   else if( ( ProtocolName == 'Asure' ) || ( ProtocolName == 'SugarSync' ) || ( ProtocolName == 'Rackspace' ) )  
     return 'Asure';
   else if( ProtocolName == 'WebDAV' )
     return 'WebDAV';
   else if( ProtocolName == 'RSync' )
     return 'RSync';
   else if( ProtocolName == 'Glacier' )
     return 'Glacier';
}

 function GetCheckedRadiobuttonName( radiobutton1, radiobutton2, radiobutton3, radiobutton4, radiobutton5, radiobutton6 )
            {
               if( radiobutton1 !== null && radiobutton1.jqxRadioButton( 'checked')  )
                 return radiobutton1.attr("id"); 
               else if( radiobutton2 !== null && radiobutton2.jqxRadioButton( 'checked') )
                 return radiobutton2.attr("id"); 
               else if( radiobutton3 !== null && radiobutton3.jqxRadioButton( 'checked') )
                 return radiobutton3.attr("id"); 
               else if( radiobutton4 !== null && radiobutton4.jqxRadioButton( 'checked') )
                 return radiobutton4.attr("id"); 
               else if( radiobutton5 !== null && radiobutton5.jqxRadioButton( 'checked') )
                 return radiobutton5.attr("id"); 
               else if( radiobutton6 !== null && radiobutton6.jqxRadioButton( 'checked') )
                 return radiobutton6.attr("id"); 
            }

            function SetRadioGroupChecked( checked_id, radiobutton1, radiobutton2, radiobutton3, radiobutton4, radiobutton5, radiobutton6 )
            {
               
               if( ( radiobutton1 !== null ) && ( radiobutton1.attr("id") == checked_id ) )
                 radiobutton1.jqxRadioButton('check');
               else if( ( radiobutton2 !== null ) && ( radiobutton2.attr("id") == checked_id ) )
                 radiobutton2.jqxRadioButton('check');
               else if( ( radiobutton3 !== null ) && ( radiobutton3.attr("id") == checked_id ) )
                 radiobutton3.jqxRadioButton('check');
               else if( ( radiobutton4 !== null ) && ( radiobutton4.attr("id") == checked_id ) )
                 radiobutton4.jqxRadioButton('check');
               else if( ( radiobutton5 !== null ) && ( radiobutton5.attr("id") == checked_id ) )
                 radiobutton5.jqxRadioButton('check');
              else if( ( radiobutton6 !== null ) && ( radiobutton6.attr("id") == checked_id ) )
                 radiobutton6.jqxRadioButton('check');

            }



function LoadRecordToRegistryList(record, RegistryList, ControlAppGroup)
{
     try
       {


            for (index = 0; index < RegistryList.length; index++) 
            {

                var RegistryItem = RegistryList[index];
                if( RegistryItem.ControlAppGroup == ControlAppGroup)
                {                                        
                  if( record[ RegistryItem.fieldname ] == null )
                  {
                      RegistryItem.value = RegistryItem.default;
                  }   
                  else
                  {
                    if( RegistryItem.controltype == "jqxCheckBox" )
                    {
                                          
                       RegistryItem.value = "false";
                       if( record[ RegistryItem.fieldname ] != "" )
                       {
                          RegistryItem.value = record[ RegistryItem.fieldname ];                                           
                       }   
                       
                    }
                    else  if( RegistryItem.controltype == "jqxInput" )
                    {  
                       RegistryItem.value = record[ RegistryItem.fieldname ];                                                              
                    }
                    else  if( RegistryItem.controltype == "jqxPasswordInput" )
                    {   
                       RegistryItem.value = record[ RegistryItem.fieldname ];                                                             
                    }                  
                    else if( RegistryItem.controltype == "jqxDateTimeInput" )
                    {
                       RegistryItem.value = new Date();
                       RegistryItem.value = record[ RegistryItem.fieldname ];                                                                     
                    }
                    else if( RegistryItem.controltype == "jqxNumberInput" )         
                    {
                       RegistryItem.value = record[ RegistryItem.fieldname ];                                                                     
                    }   
                    else  if( RegistryItem.controltype == "jqxFormattedInput" )
                    {
                       RegistryItem.value = record[ RegistryItem.fieldname ];                                                                     
                    }   
                    else if( RegistryItem.controltype == "ButtonGroup" )
                    {
                       RegistryItem.value = record[ RegistryItem.fieldname ];                                                                     
                    }
                    else if( RegistryItem.controltype == "variable" )
                    {                        
                       if( ( RegistryItem.type == 'decimal' ) && ( record[ RegistryItem.fieldname ] == '' ) )
                          RegistryItem.value = 0
                       else                            
                        RegistryItem.value = record[ RegistryItem.fieldname ];
                    }  
                    else if( RegistryItem.controltype == "jqxComboBox" )
                    {
                        RegistryItem.value = 0;
                        if( record[ RegistryItem.fieldname ] != "" )
                          RegistryItem.value = record[ RegistryItem.fieldname ];
                    };
                 }   
               }
                              
                
            };

      }
      catch(err) 
      {
          document.getElementById("error_message").innerHTML = err.message + '  :LoadRecordToRegistryList';
      }  
}


function LoadRegistryListToControls( RegistryList, ControlAppGroup )
{
     try
       {

            for (index = 0; index < RegistryList.length; index++) 
            {
                var RegistryItem = RegistryList[index];
                if( RegistryItem.ControlAppGroup == ControlAppGroup)
                {
                  if( RegistryItem.controltype == "jqxCheckBox" )
                  {
                                        
                     if( RegistryItem.value == null )                   
                        RegistryItem.value = "false";
                     $("#" + RegistryItem.controlname).jqxCheckBox( 'val', RegistryItem.value );
                     
                  }
                  else  if( RegistryItem.controltype == "jqxInput" )
                  {   
                     
                     $("#" + RegistryItem.controlname).jqxInput({ width : RegistryItem.width, height : RegistryItem.height });                  
                     $("#" + RegistryItem.controlname).jqxInput('val', RegistryItem.value);
                     
                  }
                  else  if( RegistryItem.controltype == "jqxPasswordInput" )
                  {                      
                     $("#" + RegistryItem.controlname).jqxPasswordInput('val',  RegistryItem.value );                                       
                  }                
                  else if( RegistryItem.controltype == "jqxDateTimeInput" )
                  {                
                     $("#" + RegistryItem.controlname).jqxDateTimeInput('setDate', RegistryItem.value );
                  }
                  else  if( RegistryItem.controltype == "jqxNumberInput" )         
                  {
                     $("#" + RegistryItem.controlname).jqxNumberInput({ width : RegistryItem.width, height : RegistryItem.height, inputMode: 'simple' });
                     $("#" + RegistryItem.controlname).jqxNumberInput('val', RegistryItem.value);                   
                  }   
                  else  if( RegistryItem.controltype == "jqxFormattedInput" )
                  {
                     $("#" + RegistryItem.controlname).val( RegistryItem.value );                  
                  }   
                  else if( RegistryItem.controltype == "ButtonGroup" )
                  {
                     RegistryItem.setfunc( RegistryItem.value );                                       
                  }
                  else if( RegistryItem.controltype == "variable" )
                  {                   
                     this[RegistryItem.controlname] = RegistryItem.value;                   
                  }  
                  else if( RegistryItem.controltype == "jqxComboBox" )
                  {                  
                    if( RegistryItem.value == null )
                      RegistryItem.value = 0;
                    $("#" + RegistryItem.controlname).jqxComboBox( {selectedIndex: RegistryItem.value } );                  
                  };                              
                }  
            };

      }
      catch(err) 
      {
          document.getElementById("error_message").innerHTML = err.message + '  LoadRegistryListToControls';
      }

}

function ControlValuesToRegistryList(RegistryList, ControlAppGroup)
{
     try
       {

            for (index = 0; index < RegistryList.length; index++) 
            {     
                var RegistryItem = RegistryList[index];                
                if( RegistryItem.ControlAppGroup == ControlAppGroup)
                {
                  if( RegistryItem.controltype == "jqxCheckBox" )
                  {
                      RegistryItem.value = $("#" + RegistryItem.controlname).val();                  
                  }
                  else if( RegistryItem.controltype == "jqxInput" )
                  {
                     RegistryItem.value = $("#" + RegistryItem.controlname).jqxInput('val');                  
                  }
                  else if( RegistryItem.controltype == "jqxPasswordInput" )
                  {
                     RegistryItem.value = $("#" + RegistryItem.controlname).jqxPasswordInput('val');                  
                  }      
                  else if( RegistryItem.controltype == "jqxDateTimeInput" )
                  {
                     RegistryItem.value = $("#" + RegistryItem.controlname).jqxDateTimeInput( 'getText' );                   
                  }
                  else  if( RegistryItem.controltype == "jqxFormattedInput" )        
                  {
                     RegistryItem.value = $("#" + RegistryItem.controlname).jqxFormattedInput('value')                   
                  }
                  else  if( RegistryItem.controltype == "jqxNumberInput" )         
                  {                    
                     RegistryItem.value = $("#" + RegistryItem.controlname).jqxNumberInput('val');                    
                  }
                  else if( RegistryItem.controltype == "ButtonGroup" )
                  {
                     RegistryItem.value = RegistryItem.getfunc();                   
                  } 
                  else if( RegistryItem.controltype == "variable" )
                  {
                     RegistryItem.value = this[RegistryItem.controlname];                   
                  }  
                  else if( RegistryItem.controltype == "jqxComboBox" )
                  {                   
                     RegistryItem.value = $("#" + RegistryItem.controlname).jqxComboBox('getSelectedIndex');                    
                  }
                }    
           }         

      }
      catch(err) 
      {
          document.getElementById("error_message").innerHTML = err.message + '  ControlValuesToRegistryList';
      }

}



              

            var cellsrenderer = function (row, columnfield, value, defaulthtml, columnproperties, rowdata) {
                if (value < 20) {
                    return '<span style="margin: 4px; float: ' + columnproperties.cellsalign + '; color: #ff0000;">' + value + '</span>';
                }
                else {
                    return '<span style="margin: 4px; float: ' + columnproperties.cellsalign + '; color: #008000;">' + value + '</span>';
                }
            };




var GProfileEditorRegistryList = new Array();




   GProfileEditorRegistryList[0] = {fieldname:"LTR", type:"boolean", controlname:"jqxLeftToRightCb", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[1] = {fieldname:"RTL", type:"boolean", controlname:"jqxRightToLeftCb", controltype:"jqxCheckBox" , default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[2] = {fieldname:"SheduleThisProfile", type:"boolean", controlname:"jqxSheduleThisProfileCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""};
   GProfileEditorRegistryList[3] = {fieldname:"SpecifyNextRun", type:"boolean", controlname:"jqxSpecifyNextRunCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[4] = {fieldname:"IntervalSpecification", type:"boolean", controlname:"jqxIntervalSpecificationCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[5] = {fieldname:"SheduleRunUponWinLogin", type:"boolean", controlname:"jqxSheduleRunUponWinLoginCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[6] = {fieldname:"SheduleRunUponShutdownAndLogOut", type:"boolean", controlname:"jqxSheduleRunUponShutdownAndLogOutCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[7] = {fieldname:"SheduleRunMissedDaylyJob", type:"boolean", controlname:"jqxSheduleRunMissedDaylyJobCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[8] = {fieldname:"SheduleAddRandomDelayUpTo", type:"boolean", controlname:"jqxSheduleAddRandomDelayUpToCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[9] = {fieldname:"SheduleWarnIfProfileNotRunFor", type:"boolean", controlname:"jqxSheduleWarnIfProfileNotRunForCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[10] = {fieldname:"Monday", type:"boolean", controlname:"jqxMondayCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[11] = {fieldname:"Tuesday", type:"boolean", controlname:"jqxTuesdayCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[12] = {fieldname:"Wednesday", type:"boolean", controlname:"jqxWednesdayCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[13] = {fieldname:"Thursday", type:"boolean", controlname:"jqxThursdayCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[14] = {fieldname:"Friday", type:"boolean", controlname:"jqxFridayCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[15] = {fieldname:"Saturday", type:"boolean", controlname:"jqxSaturdayCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[16] = {fieldname:"Sunday", type:"boolean", controlname:"jqxSundayCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[17] = {fieldname:"RealTimeSynchronization", type:"boolean", controlname:"jqxRealTimeSynchronizationCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[18] = {fieldname:"RealContinuousSync", type:"boolean", controlname:"jqxRealContinuousSyncCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[19] = {fieldname:"RealProfileAsSoonAsDriveAvailable", type:"boolean", controlname:"jqxRealProfileAsSoonAsDriveAvailableCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[20] = {fieldname:"FADatabaseSafeCopy", type:"boolean", controlname:"jqxFADatabaseSafeCopyCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[21] = {fieldname:"FATakeAdminOwnership", type:"boolean", controlname:"jqxFATakeAdminOwnershipCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[22] = {fieldname:"FAVerifyOpeningPriorCopy", type:"boolean", controlname:"jqxFAVerifyOpeningPriorCopyCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[23] = {fieldname:"WRWaitForFileAccess", type:"boolean", controlname:"jqxWRWaitForFileAccessCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[24] = {fieldname:"WRWaitIfTransferProblem", type:"boolean", controlname:"jqxWRWaitIfTransferProblemCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[25] = {fieldname:"WRBuildingFileList", type:"boolean", controlname:"jqxWRBuildingFileListCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[26] = {fieldname:"WRRunningTheProfile", type:"boolean", controlname:"jqxWRRunningTheProfileCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   //Tab Comparison Comparison
   GProfileEditorRegistryList[27] = {fieldname:"ComparIgnoreSmallTimeDiff", type:"boolean", controlname:"jqxComparIgnoreSmallTimeDiffCb", controltype:"jqxCheckBox", default:"true" , value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[28] = {fieldname:"ComparIgnoreExactHourTimeDiff", type:"boolean", controlname:"jqxComparIgnoreExactHourTimeDiffCb", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[29] = {fieldname:"ComparIgnoreSeconds", type:"boolean", controlname:"jqxComparIgnoreSecondsCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[30] = {fieldname:"ComparIgnoreTimestampAlltogether", type:"boolean", controlname:"jqxComparIgnoreTimestampAlltogetherCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
          //Tab Comparison More
   GProfileEditorRegistryList[31] = {fieldname:"ComparMoreAlwaysCopyFiles", type:"boolean", controlname:"jqxComparMoreAlwaysCopyFilesCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[32] = {fieldname:"ComparMoreBinaryComparison", type:"boolean", controlname:"jqxComparMoreBinaryComparisonCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[33] = {fieldname:"ComparMoreBinaryLeftSide", type:"boolean", controlname:"jqxComparMoreBinaryLeftSideCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[34] = {fieldname:"ComparMoreBinaryRightSide", type:"boolean", controlname:"jqxComparMoreBinaryRightSideCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[35] = {fieldname:"ComparMoreFileAttributeComparison", type:"boolean", controlname:"jqxComparMoreFileAttributeComparisonCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[36] = {fieldname:"ComparMoreCaseSencivity", type:"boolean", controlname:"jqxComparMoreCaseSencivityCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[37] = {fieldname:"ComparMoreVerifySyncStatistics", type:"boolean", controlname:"jqxComparMoreVerifySyncStatisticsCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[38] = {fieldname:"ComparMoreFolderAttributeComparison", type:"boolean", controlname:"jqxComparMoreFolderAttributeComparisonCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[39] = {fieldname:"ComparMoreFolderTimestampComparison", type:"boolean", controlname:"jqxComparMoreFolderTimestampComparisonCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[40] = {fieldname:"ComparMoreDetectHardLinks", type:"boolean", controlname:"jqxComparMoreDetectHardLinksCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[41] = {fieldname:"ComparMoreEnforceHardLinks", type:"boolean", controlname:"jqxComparMoreEnforceHardLinksCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
//Tab Files Files
   GProfileEditorRegistryList[42] = {fieldname:"FilesDetectMovedFiles", type:"boolean", controlname:"jqxFilesDetectMovedFilesCb", controltype:"jqxCheckBox", default:"true", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[43] = {fieldname:"FilesDetectRenamedFiles", type:"boolean", controlname:"jqxFilesDetectRenamedFilesCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[44] = {fieldname:"FilesVerifyCopiedFiles", type:"boolean", controlname:"jqxFilesVerifyCopiedFilesCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[45] = {fieldname:"FilesReCopyOnce", type:"boolean", controlname:"jqxFilesReCopyOnceCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[46] = {fieldname:"FilesAutomaticallyResume", type:"boolean", controlname:"jqxFilesAutomaticallyResumeCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[47] = {fieldname:"FilesProtectFromBeingReplaced", type:"boolean", controlname:"jqxFilesProtectFromBeingReplacedCb", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[48] = {fieldname:"FilesDoNotScanDestination", type:"boolean", controlname:"jqxFilesDoNotScanDestinationCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[49] = {fieldname:"FilesBypassFilesBuffering", type:"boolean", controlname:"jqxFilesBypassFilesBufferingCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
  //Tab Files Deletions
   GProfileEditorRegistryList[50] = {fieldname:"FilesDeletions_OverritenFiles", type:"boolean", controlname:"jqxFilesDeletions_OverritenFiles", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[51] = {fieldname:"FilesDeletions_DeletedFiles", type:"boolean", controlname:"jqxFilesDeletions_DeletedFiles", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[52] = {fieldname:"FilesDeletions_MoveFilesToSFolder", type:"boolean", controlname:"jqxFilesDeletions_MoveFilesToSFolder", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[53] = {fieldname:"FilesDeletions_DeleteOlderVersionsPermamently", type:"boolean", controlname:"jqxFilesDeletions_DeleteOlderVersionsPermamently", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[54] = {fieldname:"FilesDeletions_DoubleCheckNonExistence", type:"boolean", controlname:"jqxFilesDeletions_DoubleCheckNonExistence", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[55] = {fieldname:"FilesDeletions_NeverDelete", type:"boolean", controlname:"jqxFilesDeletions_NeverDelete", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[56] = {fieldname:"FilesDeletions_DeleteBeforeCopying", type:"boolean", controlname:"jqxFilesDeletions_DeleteBeforeCopying", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   //Tab Files More
   GProfileEditorRegistryList[57] = {fieldname:"FilesMore_UseWindowsApi", type:"boolean", controlname:"jqxFilesMore_UseWindowsApi", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[58] = {fieldname:"FilesMore_UseSpeedLimit", type:"boolean", controlname:"jqxFilesMore_SpeedLimit", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""};    
   GProfileEditorRegistryList[59] = {fieldname:"FilesMore_NeverReplace", type:"boolean", controlname:"jqxFilesMore_NeverReplace", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[60] = {fieldname:"FilesMore_AlwaysAppend", type:"boolean", controlname:"jqxFilesMore_AlwaysAppend", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[61] = {fieldname:"FilesMore_AlwaysConsider", type:"boolean", controlname:"jqxFilesMore_AlwaysConsider", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[62] = {fieldname:"FilesMore_CheckDestinationFile", type:"boolean", controlname:"jqxFilesMore_CheckDestinationFile", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[63] = {fieldname:"FilesMore_AndCompareFileDetails", type:"boolean", controlname:"jqxFilesMore_AndCompareFileDetails", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[64] = {fieldname:"FilesMore_CopiedFilesSysTime", type:"boolean", controlname:"jqxFilesMore_CopiedFilesSysTime", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[65] = {fieldname:"FilesMore_PreserveLastAccessOnSource", type:"boolean", controlname:"jqxFilesMore_PreserveLastAccessOnSource", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[66] = {fieldname:"FilesMore_CopyOnlyFilesPerRun", type:"boolean", controlname:"jqxFilesMore_CopyOnlyFilesPerRun", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[67] = {fieldname:"FilesMore_IgnoreGlobalSpeedLimit", type:"boolean", controlname:"jqxFilesMore_IgnoreGlobalSpeedLimit", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[68] = {fieldname:"FilesMore_DontAddAnyFiles", type:"boolean", controlname:"jqxFilesMore_DontAddAnyFiles", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""};                        
//Tab Folders
   GProfileEditorRegistryList[69] = {fieldname:"Folders_CreateEmptyFolders", type:"boolean", controlname:"jqxFolders_CreateEmptyFolders", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[70] = {fieldname:"Folders_RemoveEmptiedFolders", type:"boolean", controlname:"jqxFolders_RemoveEmptiedFolders", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[71] = {fieldname:"Folders_OnRightSideCreateFolderEachTime", type:"boolean", controlname:"jqxFolders_OnRightSideCreateFolderEachTime", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[72] = {fieldname:"Folders_IncludeTimeOfDay", type:"boolean", controlname:"jqxFolders_IncludeTimeOfDay", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[73] = {fieldname:"Folders_FlatRightSide", type:"boolean", controlname:"jqxFolders_FlatRightSide", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[74] = {fieldname:"Folders_CopyLatestFileIfExists", type:"boolean", controlname:"jqxFolders_CopyLatestFileIfExists", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[75] = {fieldname:"Folders_EnsureFolderTimestamps", type:"boolean", controlname:"jqxFolders_EnsureFolderTimestamps", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[76] = {fieldname:"Folders_UseIntermediateLocation", type:"boolean", controlname:"jqxFolders_UseIntermediateLocation", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
           //Tab Job
   GProfileEditorRegistryList[77] = {fieldname:"Job_ExecuteCommand", type:"boolean", controlname:"jqxJob_ExecuteCommand", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[78] = {fieldname:"Job_OverrideEmailSettings", type:"boolean", controlname:"jqxJob_OverrideEmailSettings", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[79] = {fieldname:"Job_RunAsUser", type:"boolean", controlname:"jqxJob_RunAsUser", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[80] = {fieldname:"Job_NetworkConnections", type:"boolean", controlname:"jqxJob_NetworkConnections", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[81] = {fieldname:"Job_VerifyRightSideVolume", type:"boolean", controlname:"jqxJob_VerifyRightSideVolume", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[82] = {fieldname:"Job_UseExternalCopyingTool", type:"boolean", controlname:"jqxJob_UseExternalCopyingTool", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[83] = {fieldname:"Job_ShowCheckboxesInPreview", type:"boolean", controlname:"jqxJob_ShowCheckboxesInPreview", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[84] = {fieldname:"Job_CheckFreeSpaceBeforeCopying", type:"boolean", controlname:"jqxJob_CheckFreeSpaceBeforeCopying", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[85] = {fieldname:"Job_IgnoreInternetConnectivityCheck", type:"boolean", controlname:"jqxJob_IgnoreInternetConnectivityCheck", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[86] = {fieldname:"Job_WhenRunViaSheduler", type:"boolean", controlname:"jqxJob_WhenRunViaSheduler", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[87] = {fieldname:"Job_WhenRunManuallyUnattended", type:"boolean", controlname:"jqxJob_WhenRunManuallyUnattended", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[88] = {fieldname:"Job_WhenRunManuallyAttended", type:"boolean", controlname:"jqxJob_WhenRunManuallyAttended", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
        //Tab  Safety
   GProfileEditorRegistryList[89] = {fieldname:"Safety_WarnIfMovingFiles", type:"boolean", controlname:"jqxSafety_WarnIfMovingFiles", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[90] = {fieldname:"Safety_WarnBeforeOverridingReadOnly", type:"boolean", controlname:"jqxSafety_WarnBeforeOverridingReadOnly", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[91] = {fieldname:"Safety_WarnBeforeOverridingLarger", type:"boolean", controlname:"jqxSafety_WarnBeforeOverridingLarger", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[92] = {fieldname:"Safety_WarnBeforeOverridingNewer", type:"boolean", controlname:"jqxSafety_WarnBeforeOverridingNewer", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[93] = {fieldname:"Safety_WarnBeforeDeleting", type:"boolean", controlname:"jqxSafety_WarnBeforeDeleting", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
       //Tab Safety Special 
   GProfileEditorRegistryList[94] = {fieldname:"SafetySpecial_WarnIfDeletingFilesMoreThan", type:"boolean", controlname:"jqxSafetySpecial_WarnIfDeletingFilesMoreThan", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[95] = {fieldname:"SafetySpecial_WarnIfDeletingAllFilesInAnySubfolder", type:"boolean", controlname:"jqxSafetySpecial_WarnIfDeletingAllFilesInAnySubfolder", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[96] = {fieldname:"SafetySpecial_WarnIfDeletingMoreThanInAnySubfolder", type:"boolean", controlname:"jqxSafetySpecial_WarnIfDeletingMoreThanInAnySubfolder", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
    //Tab Safety Unattended Mode  
   GProfileEditorRegistryList[97] = {fieldname:"SafetyUnattended_OvewriteReadOnly", type:"boolean", controlname:"jqxSafetyUnattended_OvewriteReadOnly", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[98] = {fieldname:"SafetyUnattended_OvewriteLarge", type:"boolean", controlname:"jqxSafetyUnattended_OvewriteLarge", controltype:"jqxCheckBox", default:"true", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[99] = {fieldname:"SafetyUnattended_NewerFilesCanBeOvewriten", type:"boolean", controlname:"jqxSafetyUnattended_NewerFilesCanBeOvewriten", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[100] = {fieldname:"SafetyUnattended_FileDeletionAllowed", type:"boolean", controlname:"jqxSafetyUnattended_FileDeletionAllowed", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[101] = {fieldname:"SafetyUnattended_EnableSpecialSafetyCheck", type:"boolean", controlname:"jqxSafetyUnattended_EnableSpecialSafetyCheck", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: "" }; 
   //Tab Special SpecialFeatures
   GProfileEditorRegistryList[102] = {fieldname:"SpecialSpFeatr_CacheDestinationFileList", type:"boolean", controlname:"jqxSpecialSpFeatr_CacheDestinationFileListCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[103] = {fieldname:"SpecialSpFeatr_ProcessSecurity", type:"boolean", controlname:"jqxSpecialSpFeatr_ProcessSecurityCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[104] = {fieldname:"SpecialSpFeatr_UseParcialFileUpdating", type:"boolean", controlname:"jqxSpecialSpFeatr_UseParcialFileUpdatingCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[105] = {fieldname:"SpecialSpFeatr_RightSideRemoteService", type:"boolean", controlname:"jqxSpecialSpFeatr_RightSideRemoteServiceCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[106] = {fieldname:"SpecialSpFeatr_FastMode", type:"boolean", controlname:"jqxSpecialSpFeatr_FastModeCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[107] = {fieldname:"SpecialSpFeatr_UseCacheDatabaseForSource", type:"boolean", controlname:"jqxSpecialSpFeatr_UseCacheDatabaseForSourceCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[108] = {fieldname:"SpecialSpFeatr_LeftSideUsesRemoteService", type:"boolean", controlname:"jqxSpecialSpFeatr_LeftSideUsesRemoteServiceCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[109] = {fieldname:"SpecialSpFeatr_RightSideUsesRemoteService", type:"boolean", controlname:"jqxSpecialSpFeatr_RightSideUsesRemoteServiceCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[110] = {fieldname:"SpecialSpFeatr_UseDifferentFolders", type:"boolean", controlname:"jqxSpecialSpFeatr_UseDifferentFoldersCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[111] = {fieldname:"SpecialSpFeatr_IfDestinationMachineModifiers", type:"boolean", controlname:"jqxSpecialSpFeatr_IfDestinationMachineModifiersCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
             //Tab Special Database
   GProfileEditorRegistryList[112] = {fieldname:"SpDb_OpenDatabaseReadOnly", type:"boolean", controlname:"jqxSpDb_OpenDatabaseReadOnlyCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[113] = {fieldname:"SpecialDatabase_FastMode", type:"boolean", controlname:"jqxSpecialDatabase_FastModeCb", controltype:"jqxCheckBox", default:"false", value: null, ControlAppGroup: ""}; 
   
   
//ProfileEditor form
   GProfileEditorRegistryList[114] = {fieldname:"Name", type:"string", controlname:"inptProfileName", controltype:"jqxInput", default: "",  width: 600, height: 25, value: null, ControlAppGroup: "" }; 
   GProfileEditorRegistryList[115] = {fieldname:"LPath", type:"string", controlname:"inptLeftHandSide", controltype:"jqxInput", default: "",  width: 200, height: 25, value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[116] = {fieldname:"RPath", type:"string", controlname:"inptRightHandSide", controltype:"jqxInput", default: "", width: 200, height: 25, value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[117] = {fieldname:"Run_Every_Day_Time_Input", type:"date", controlname:"jqxRun_Every_Day_Time_Input", controltype:"jqxDateTimeInput", value: null, ControlAppGroup: ""}; 
   
//Tab Shedule/Shedule
   GProfileEditorRegistryList[118] = {fieldname:"ScheduleDays", type:"number", controlname:"inptScheduleDays", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[119] = {fieldname:"ScheduleHours", type:"number", controlname:"inptScheduleHours", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[120] = {fieldname:"ScheduleMinutes", type:"number", controlname:"inptScheduleMinutes", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[121] = {fieldname:"ScheduleSec", type:"number", controlname:"inptScheduleSec", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
   
//Tab Shedule/More
   GProfileEditorRegistryList[122] = {fieldname:"AddRandomDelay_Time_Input", type:"number", controlname:"jqxAddRandomDelay_Time_Input", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[123] = {fieldname:"WarnIfProfileNotRunFor_Time_Input", type:"number", controlname:"jqxWarnIfProfileNotRunFor_Time_Input", controltype:"jqxFormattedInput", default: "0" , value: null, ControlAppGroup: ""}; 
//Tab AccessAndRetries/Wait and Retry
   GProfileEditorRegistryList[124] = {fieldname:"WRWaitUpToMin", type:"decimal", controlname:"inptWRWaitUpToMin", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
                     
//Tab Comparison Comparison
   GProfileEditorRegistryList[125] = {fieldname:"ComparIgnoreSec", type:"decimal", controlname:"inptComparIgnoreSec", controltype:"jqxFormattedInput", default: "2" , value: null, ControlAppGroup: ""}; 
   GProfileEditorRegistryList[126] = {fieldname:"ComparIgnoreHours", type:"decimal", controlname:"inptComparIgnoreHours", controltype:"jqxFormattedInput", default: "1" , value: null, ControlAppGroup: ""};  

 //Tab Files Files
   GProfileEditorRegistryList[127] = {fieldname:"FilesNumberToCopyInparallel", type:"decimal", controlname:"inptFilesNumberToCopyInparallel", controltype:"jqxFormattedInput", default: "3", value: null, ControlAppGroup: ""};            


//Tab Files More
   GProfileEditorRegistryList[128] = {fieldname:"FilesMore_SpeedLimit", type:"float", controlname:"inptFilesMore_SpeedLimit", controltype:"jqxNumberInput", default: "1",  width: 50, height: 25, value: null, ControlAppGroup: ""};            

   GProfileEditorRegistryList[129] = {fieldname:"FilesMore_FilesPerRun", type:"decimal", controlname:"inptFilesMore_FilesPerRun", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""};            
          
//Tab Safety Special 
   GProfileEditorRegistryList[130] = {fieldname:"SafetySpecial_WarnIfDeletingFilesMoreThanVal", type:"decimal", controlname:"inptSafetySpecial_WarnIfDeletingFilesMoreThan", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[131] = {fieldname:"SafetySpecial_WarnIfDeletingMoreThanInAnySubfolderVal", type:"decimal", controlname:"inptSafetySpecial_WarnIfDeletingMoreThanInAnySubfolder", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""};            
          
 //Tab Safety Unattended Mode  
   GProfileEditorRegistryList[132] = {fieldname:"SafetyUnattended_FileDeletionAllowed", type:"decimal", controlname:"inptSafetyUnattended_FileDeletionAllowed", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""};            
           
 //Tab Vesioning Versioning
   GProfileEditorRegistryList[133] = {fieldname:"VersVers_KeepOlderVersionsWhenReplacing", type:"string", controlname:"jqxVersVers_KeepOlderVersionsWhenReplacing", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[134] = {fieldname:"VersVers_PerFile", type:"decimal", controlname:"inptVersVers_PerFile", controltype:"jqxFormattedInput", default: "2", value: null, ControlAppGroup: ""};            
                
  
 //Tab Special SpecialFeatures
   
   GProfileEditorRegistryList[135] = {fieldname:"SpecialSpFeatr_SetTargetVolumeLabel", type:"string", controlname:"inptSpecialSpFeatr_SetTargetVolumeLabel", controltype:"jqxInput", default: "", width: 150, height: 25, value: null, ControlAppGroup: ""};            

  //Tab Special Database
   GProfileEditorRegistryList[136] = {fieldname:"SpecialDatabase_DatabaseNameToUse", type:"string", controlname:"inptSpecialDatabase_DatabaseNameToUse", controltype:"jqxInput", default: "", width: 150, height: 25, value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[137] = {fieldname:"SpecialDatabase_Left", type:"string", controlname:"inptSpecialDatabase_Left", controltype:"jqxInput", default: "",  width: 150, height: 25, value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[138] = {fieldname:"SpecialDatabase_Right", type:"string", controlname:"inptSpecialDatabase_Right", controltype:"jqxInput", default: "",  width: 150, height: 25, value: null, ControlAppGroup: ""};            

   GProfileEditorRegistryList[139] = {fieldname:"IncludeSubfoldersWidget", type:"string", controlname:"IncludeSubfoldersWidget", controltype:"ButtonGroup", default: "AllMode", value: null, ControlAppGroup: "", 
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#NoneMode"), $("#AllMode"), $("#SelectedMode"), null, null, null );

   }, setfunc: function( option )
   {
       SetRadioGroupChecked( option, $("#NoneMode"), $("#AllMode"), $("#SelectedMode"), null, null, null ); 
   }};



   GProfileEditorRegistryList[140] = {fieldname:"SyncOperationModeWidget", type:"string", controlname:"SyncOperationModeWidget", controltype:"ButtonGroup", default: "Standard_Copying_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Standard_Copying_Mode"), $("#SmartTracking_Mode"), $("#Exact_Mirror_Mode"), $("#Move_Files_Mode"), null, null );

   }, setfunc: function( option )
   {
       SetRadioGroupChecked( option, $("#Standard_Copying_Mode"), $("#SmartTracking_Mode"), $("#Exact_Mirror_Mode"), $("#Move_Files_Mode"), null, null ); 
   }};


    //Tab Shedule/Shedule
      
   GProfileEditorRegistryList[141] = {fieldname:"RunModeRadiogroupWidget", type:"string", controlname:"RunModeRadiogroupWidget", controltype:"ButtonGroup", default: "Run_only_Once_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Run_Every_Day_Radio_Mode"), $("#Repeat_after_Radio_Mode"), $("#Repeat_monthly_Radio_Mode"), $("#Run_only_Once_Radio_Mode"), null, null );

   }, setfunc: function( option )
   {
       SetRadioGroupChecked( option,  $("#Run_Every_Day_Radio_Mode"), $("#Repeat_after_Radio_Mode"), $("#Repeat_monthly_Radio_Mode"), $("#Run_only_Once_Radio_Mode"), null, null ); 
   }};

            
          //Tab AccessAndRetries/File Access

   GProfileEditorRegistryList[142] = {fieldname:"VolumeShadowingRadiogroupWidget", type:"string", controlname:"VolumeShadowingRadiogroupWidget", controltype:"ButtonGroup", default: "Use_to_copy_locked_files_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Do_not_Use_Radio_Mode"), $("#Use_to_copy_locked_files_Radio_Mode"), $("#Use_for_all_files_Radio_Mode"), $("#Use_for_all_Create_Radio_Mode"), null, null );

   }, setfunc: function( option )
   {
       SetRadioGroupChecked( option,  $("#Do_not_Use_Radio_Mode"), $("#Use_to_copy_locked_files_Radio_Mode"), $("#Use_for_all_files_Radio_Mode"), $("#Use_for_all_Create_Radio_Mode"), null, null ); 
   }};

//Tab AccessAndRetries/Wait and Retry
          
   GProfileEditorRegistryList[143] = {fieldname:"WRReRunRadiogroupWidget", type:"string", controlname:"WRReRunRadiogroupWidget", controltype:"ButtonGroup", default: "Re_Run_Once_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Re_Run_Once_Radio_Mode"), $("#Re_Run_Until_Success_Radio_Mode"), $("#Max_Re_Runs_Radio_Mode"), null, null, null );

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,  $("#Re_Run_Once_Radio_Mode"), $("#Re_Run_Until_Success_Radio_Mode"), $("#Max_Re_Runs_Radio_Mode"), null, null, null ); 

   }};

//Tab Comparison Comparison
          
   GProfileEditorRegistryList[144] = {fieldname:"ComparWhenSizeIsDiffentRadiogroupWidget", type:"string", controlname:"ComparWhenSizeIsDiffentRadiogroupWidget", controltype:"ButtonGroup", default: "Ask_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Ask_Radio_Mode"), $("#Copy_Left_To_Right_Radio_Mode"), $("#Copy_Right_To_Left_Radio_Mode"), $("#Copy_Larger_Files_Radio_Mode"), null, null );

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,  $("#Ask_Radio_Mode"), $("#Copy_Left_To_Right_Radio_Mode"), $("#Copy_Right_To_Left_Radio_Mode"), $("#Copy_Larger_Files_Radio_Mode"), null, null ); 


   }};

//Tab Files Files
          
   GProfileEditorRegistryList[145] = {fieldname:"FilesDetectMovedFilesRadiogroupWidget", type:"string", controlname:"FilesDetectMovedFilesRadiogroupWidget", controltype:"ButtonGroup", default: "Files_Right_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Files_Left_Radio_Mode"), $("#Files_Right_Radio_Mode"), null, null, null, null );

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,  $("#Files_Left_Radio_Mode"), $("#Files_Right_Radio_Mode"), null, null, null, null ); 

   }};

                  
   GProfileEditorRegistryList[146] = {fieldname:"LeftProtocolName", type:"string", controlname:"GLeftProtocolName", controltype:"variable", value: null, ControlAppGroup: "" };            
   GProfileEditorRegistryList[147] = {fieldname:"RightProtocolName", type:"string", controlname:"GRightProtocolName", controltype:"variable", value: null, ControlAppGroup: "" };            

   GProfileEditorRegistryList[148] = {fieldname:"LeftLibraryIndex", type:"decimal", controlname:"GLeftLibraryIndex", controltype:"variable", value: null, ControlAppGroup: "" };            
   GProfileEditorRegistryList[149] = {fieldname:"RightLibraryIndex", type:"decimal", controlname:"GRightLibraryIndex", controltype:"variable", value: null, ControlAppGroup: "" };            
   GProfileEditorRegistryList[150] = {fieldname:"LeftAccountOpt", type:"string", controlname:"GLeftAccountOpt", controltype:"variable", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[151] = {fieldname:"RightAccountOpt", type:"string", controlname:"GRightAccountOpt", controltype:"variable", value: null, ControlAppGroup: ""};            

   //Tab Masks
   
   GProfileEditorRegistryList[152] = {fieldname:"Masks_InclusionMasks", type:"string", controlname:"inptInclusionMasks", controltype:"jqxInput", default: "",  width: 350, height: 150, value: null, ControlAppGroup: ""};            

   GProfileEditorRegistryList[153] = {fieldname:"Masks_SpecFolderMasks", type:"boolean", controlname:"jqxMasks_SpecFolderMasksCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[154] = {fieldname:"Masks_Restrictions", type:"boolean", controlname:"jqxMasks_RestrictionsCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[155] = {fieldname:"Masks_IncludeBackupFiles", type:"boolean", controlname:"jqxMasks_IncludeBackupFilesCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            

      
   GProfileEditorRegistryList[156] = {fieldname:"Masks_ExclusionMasks", type:"string", controlname:"inptExclusionMasks", controltype:"jqxInput", default: "",  width: 350, height: 150 , value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[157] = {fieldname:"Masks_UseGlobalExclAlso", type:"boolean", controlname:"jqxMasks_UseGlobalExclAlsoCb", controltype:"jqxCheckBox", default: "false" , value: null, ControlAppGroup: ""};            

   
   GProfileEditorRegistryList[158] = {fieldname:"ExclucionFilesWidget", type:"string", controlname:"ExclucionFilesWidget", controltype:"ButtonGroup", default: "Masks_DontCopy_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Masks_DontCopy_Radio_Mode"), $("#Masks_IgnoreTotaly_Radio_Mode"), null, null, null, null );

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,  $("#Masks_DontCopy_Radio_Mode"), $("#Masks_IgnoreTotaly_Radio_Mode"), null, null, null, null ); 

   }};

  GProfileEditorRegistryList[159] = {fieldname:"Masks_ProcessHiddenFiles", type:"boolean", controlname:"jqxMasks_ProcessHiddenFilesCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[160] = {fieldname:"Masks_SearchHiddenFolders", type:"boolean", controlname:"jqxMasks_SearchHiddenFoldersCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[161] = {fieldname:"Masks_ProcessReparcePoints", type:"boolean", controlname:"jqxMasks_ProcessReparcePointsCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[162] = {fieldname:"Masks_FollowJunctionPointsFiles", type:"boolean", controlname:"jqxMasks_FollowJunctionPointsFilesCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[163] = {fieldname:"Masks_FollowJunctionPointsFolders", type:"boolean", controlname:"jqxMasks_FollowJunctionPointsFoldersCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[164] = {fieldname:"Masks_CopyOtherReparcePoints", type:"boolean", controlname:"jqxMasks_CopyOtherReparcePointsCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[165] = {fieldname:"Masks_CopyFilesWithArchiveFlag", type:"boolean", controlname:"jqxMasks_CopyFilesWithArchiveFlagCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
              
  GProfileEditorRegistryList[166] = {fieldname:"Masks_FileSizesWithin", type:"boolean", controlname:"jqxMasks_FileSizesWithinCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[167] = {fieldname:"Masks_FileSizesMin", type:"boolean", controlname:"jqxInptMasks_FileSizesMin", controltype:"jqxNumberInput", default: "0",  width: 50, height: 25, value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[168] = {fieldname:"Masks_FileSizesMax", type:"boolean", controlname:"jqxInptMasks_FileSizesMax", controltype:"jqxNumberInput", default: "0",  width: 50, height: 25, value: null, ControlAppGroup: ""};            
  
  GProfileEditorRegistryList[169] = {fieldname:"Masks_FileDatesWithin", type:"boolean", controlname:"jqxMasks_FileDatesWithinCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[170] = {fieldname:"Masks_FileMinDate", type:"date", controlname:"jqxInptDateMasks_FileMinDate", controltype:"jqxDateTimeInput", value: null, ControlAppGroup: ""}; 
  GProfileEditorRegistryList[171] = {fieldname:"Masks_FileMaxDate", type:"date", controlname:"jqxInptDateMasks_FileMaxDate", controltype:"jqxDateTimeInput", value: null, ControlAppGroup: ""}; 

  GProfileEditorRegistryList[172] = {fieldname:"Masks_FileAge", type:"boolean", controlname:"jqxMasks_FileAgeCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
     
  GProfileEditorRegistryList[173] = {fieldname:"Masks_FileAgeComboIndex", type:"number", controlname:"jqxMasks_FileAgeCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: ""};            
  
  GProfileEditorRegistryList[174] = {fieldname:"Masks_FileAgeDays", type:"number", controlname:"inptMasks_FileAgeDays", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
  GProfileEditorRegistryList[175] = {fieldname:"Masks_FileAgeHours", type:"number", controlname:"inptMasks_FileAgeHours", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
  GProfileEditorRegistryList[176] = {fieldname:"Masks_FileAgeMinutes", type:"number", controlname:"inptMasks_FileAgeMinutes", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
  GProfileEditorRegistryList[177] = {fieldname:"Masks_FileAgeSec", type:"number", controlname:"inptMasks_FileAgeSec", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""}; 
   


   GProfileEditorRegistryList[178] = {fieldname:"Masks_FilterByWidget", type:"string", controlname:"Masks_FilterByWidget", controltype:"ButtonGroup", default: "Masks_LastModification_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Masks_LastModification_Radio_Mode"), $("#Masks_Creation_Radio_Mode"), null, null, null, null );

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,  $("#Masks_LastModification_Radio_Mode"), $("#Masks_Creation_Radio_Mode"), null, null, null, null ); 

   }};


   GProfileEditorRegistryList[179] = {fieldname:"Masks_ApplyToWidget", type:"string", controlname:"Masks_ApplyToWidget", controltype:"ButtonGroup", default: "Masks_ApplyToFiles_Radio_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Masks_ApplyToFiles_Radio_Mode"),  $("#Masks_ApplyToFolders_Radio_Mode"), $("#Masks_ApplyToBoth_Radio_Mode"), null, null, null ); 

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,   $("#Masks_ApplyToFiles_Radio_Mode"),  $("#Masks_ApplyToFolders_Radio_Mode"), $("#Masks_ApplyToBoth_Radio_Mode"), null, null, null ); 

   }};

  GProfileEditorRegistryList[180] = {fieldname:"Masks_TargetDataRestore", type:"boolean", controlname:"jqxMasks_TargetDataRestoreCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[181] = {fieldname:"Masks_TargetDateRestoreDate", type:"date", controlname:"jqxInptDateMasks_TargetDateRestoreDate", controltype:"jqxDateTimeInput", value: null, ControlAppGroup: ""}; 
  GProfileEditorRegistryList[182] = {fieldname:"Masks_TargetDateRestoreTime", type:"date", controlname:"jqxInptDateMasks_TargetDateRestoreTime", controltype:"jqxDateTimeInput", value: null, ControlAppGroup: ""}; 
  
  GProfileEditorRegistryList[183] = {fieldname:"WRAvoidRerunDueToLocked", type:"boolean", controlname:"jqxWRAvoidRerunDueToLockedCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  
  GProfileEditorRegistryList[184] = {fieldname:"WRMaxReRuns", type:"decimal", controlname:"inptWRMaxReRuns", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""};
  GProfileEditorRegistryList[185] = {fieldname:"WRRetryAfter", type:"decimal", controlname:"inptWRRetryAfter", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""};
       
  GProfileEditorRegistryList[186] = {fieldname:"VersVers_MoveIntoFolderInpt", type:"string", controlname:"inptMoveIntoFolder", controltype:"jqxInput", default: "Older",  width: 120, height: 25, value: null, ControlAppGroup: ""};


  GProfileEditorRegistryList[187] = {fieldname:"VersVers_OnlyOnRightHandSide", type:"boolean", controlname:"jqxVersVers_OnlyOnRightHandSide", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[188] = {fieldname:"VersVers_MoveIntoFolder", type:"boolean", controlname:"jqxVersVers_MoveIntoFolder", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[189] = {fieldname:"VersVers_AsSubfolerInEachFolder", type:"boolean", controlname:"jqxVersVers_AsSubfolerInEachFolderCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[190] = {fieldname:"VersVers_RecreateTreeBelow", type:"boolean", controlname:"jqxVersVers_RecreateTreeBelowCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[191] = {fieldname:"VersVers_FileNameEncoding", type:"boolean", controlname:"jqxVersVers_FileNameEncodingCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
  GProfileEditorRegistryList[192] = {fieldname:"VersVers_DontRenameNewestOlderVersion", type:"boolean", controlname:"jqxVersVers_DontRenameNewestOlderVersionCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
    
  GProfileEditorRegistryList[193] = {fieldname:"VersVers_RenamingOlderVersions", type:"string", controlname:"VersVers_RenamingOlderVersionsWidget", controltype:"ButtonGroup", default: "VersVers_Add_Prefix_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#VersVers_Add_Prefix_Mode"),  $("#VersVers_Add_Timestamp_Mode"), null, null, null, null ); 

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,   $("#VersVers_Add_Prefix_Mode"),  $("#VersVers_Add_Timestamp_Mode"), null, null, null, null ); 

   }}; 



   GProfileEditorRegistryList[194] = {fieldname:"VersSynth_UseSynthBackups", type:"boolean", controlname:"jqxVersSynth_UseSynthBackupsCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[195] = {fieldname:"VersSynth_UseCheckPoints", type:"boolean", controlname:"jqxVersSynth_UseCheckPointsCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[196] = {fieldname:"VersSynth_CreateCheckpointComboIndex", type:"number", controlname:"jqxVersSynth_CreateCheckpointCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: ""};      
   GProfileEditorRegistryList[197] = {fieldname:"VersSynth_CheckpointsRelativeComboIndex", type:"number", controlname:"jqxVersSynth_CheckpointsRelativeCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: ""};      
   GProfileEditorRegistryList[198] = {fieldname:"VersSynth_BuildAllIncremental", type:"boolean", controlname:"jqxVersSynth_BuildAllIncrementalCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[199] = {fieldname:"VersSynth_RemoveUnneededCb", type:"boolean", controlname:"jqxVersSynth_RemoveUnneededCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[200] = {fieldname:"VersSynth_RemoveUnneeded", type:"decimal", controlname:"inptVersSynth_RemoveUnneeded", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: ""};
   GProfileEditorRegistryList[201] = {fieldname:"VersSynth_RemoveUnneededComboIndex", type:"number", controlname:"jqxVersSynth_RemoveUnneededCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: ""};         
   GProfileEditorRegistryList[202] = {fieldname:"VersSynth_IfAllBlocksCb", type:"boolean", controlname:"jqxVersSynth_IfAllBlocksCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   
    
   GProfileEditorRegistryList[203] = {fieldname:"VersMore_DoNotDecodeLeftHandCb", type:"boolean", controlname:"jqxVersMore_DoNotDecodeLeftHandCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[204] = {fieldname:"VersMore_DoNotDecodeRightHandCb", type:"boolean", controlname:"jqxVersMore_DoNotDecodeRightHandCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[205] = {fieldname:"VersMore_CleanUpIdenticalCb", type:"boolean", controlname:"jqxVersMore_CleanUpIdenticalCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[206] = {fieldname:"VersMore_RemoveParenthesizedCb", type:"boolean", controlname:"jqxVersMore_RemoveParenthesizedCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[207] = {fieldname:"VersMore_RemoveVesioningTagsCb", type:"boolean", controlname:"jqxVersMore_RemoveVesioningTagsCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[208] = {fieldname:"VersMore_CleanUpAllOlderVersionsCb", type:"boolean", controlname:"jqxVersMore_CleanUpAllOlderVersionsCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[209] = {fieldname:"VersMore_FilesBackupV4Cb", type:"boolean", controlname:"jqxVersMore_FilesBackupV4Cb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
                
                    
   GProfileEditorRegistryList[210] = {fieldname:"Zipping_LimitInpt", type:"string", controlname:"inptZipping_Limit", controltype:"jqxInput", default: "",  width: 50, height: 25, value: null, ControlAppGroup: ""};
   GProfileEditorRegistryList[211] = {fieldname:"Zipping_ZipEachFile", type:"boolean", controlname:"jqxZipping_ZipEachFileCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[212] = {fieldname:"Zipping_USeZipPackages", type:"boolean", controlname:"jqxZipping_USeZipPackagesCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[213] = {fieldname:"Zipping_ZipDirectlyToDestination", type:"boolean", controlname:"jqxZipping_ZipDirectlyToDestinationCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[214] = {fieldname:"Zipping_UnzipAllfiles", type:"boolean", controlname:"jqxZipping_UnzipAllfilesCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[215] = {fieldname:"Zipping_LimitZipFileSize", type:"boolean", controlname:"jqxZipping_LimitZipFileSizeCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[216] = {fieldname:"Zipping_CompressionLevelWidget", type:"string", controlname:"Zipping_CompressionLevelWidget", controltype:"ButtonGroup", default: "Zipping_None_Mode", value: null, ControlAppGroup: "",
   getfunc: function()
   {
      return GetCheckedRadiobuttonName( $("#Zipping_None_Mode"),  $("#Zipping_Fastest_Mode"), $("#Zipping_Normal_Mode"), $("#Zipping_Maximum_Mode"), null, null ); 

   }, setfunc: function( option )
   {
        SetRadioGroupChecked( option,   $("#Zipping_None_Mode"),  $("#Zipping_Fastest_Mode"), $("#Zipping_Normal_Mode"), $("#Zipping_Maximum_Mode"), null, null ); 

   }}; 
 
   GProfileEditorRegistryList[217] = {fieldname:"ZippingEncrypt_EncryptFiles", type:"boolean", controlname:"jqxZippingEncrypt_EncryptFilesCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[218] = {fieldname:"ZippingEncrypt_DecryptFiles", type:"boolean", controlname:"jqxZippingEncrypt_DecryptFilesCb", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
   GProfileEditorRegistryList[219] = {fieldname:"ZippingEncrypt_Password", type:"string", controlname:"jqxZippingEncrypt_Password", controltype:"jqxPasswordInput", default: "0", value: null, ControlAppGroup: ""};
   GProfileEditorRegistryList[220] = {fieldname:"ZippingEncrypt_Confirm", type:"string", controlname:"jqxZippingEncrypt_Confirm", controltype:"jqxPasswordInput", default: "0", value: null, ControlAppGroup: ""};
   GProfileEditorRegistryList[221] = {fieldname:"ZippingEncrypt_ComboIndex", type:"number", controlname:"jqxZippingEncrypt_Combo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: ""}; 


              
          






var GInternetProtocolSetRegistryList =  new Array();

        //internet_protocol_settings
           
             GInternetProtocolSetRegistryList[0] = {fieldname:"internet_protocol_FTPLibraryComboIndex", type:"number", controlname:"jqxLibraryCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "FTP"}; 
             GInternetProtocolSetRegistryList[1] = {fieldname:"internet_protocol_FTP_url", type:"string", controlname:"inptIntProtSetFTP_url", controltype:"jqxInput", default: "",  width: 350, height: 25, value: "", ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[2] = {fieldname:"internet_protocol_FTP_port", type:"decimal", controlname:"inptIntProtSet_FTP_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[3] = {fieldname:"internet_protocol_FTP_passive_mode", type:"boolean", controlname:"cbIntProtSet_FTP_passive_mode", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[4] = {fieldname:"internet_protocol_FTP_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[5] = {fieldname:"internet_protocol_FTP_login", type:"string", controlname:"inptIntProtSet_FTP_login", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[6] = {fieldname:"internet_protocol_FTP_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[7] = {fieldname:"internet_protocol_FTP_save_user_id", type:"boolean", controlname:"cbIntProtSet_FTP_save_user_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[8] = {fieldname:"internet_protocol_FTP_save_password", type:"boolean", controlname:"cbIntProtSet_FTP_save_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[9] = {fieldname:"internet_protocol_FTP_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_FTP_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[10] = {fieldname:"internet_protocol_FTP_auto_resume_transfer", type:"boolean", controlname:"cbIntProtSet_FTP_auto_resume_transfer", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[11] = {fieldname:"internet_protocol_FTP_filename_encoding", type:"boolean", controlname:"cbIntProtSet_FTP_filename_encoding", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[12] = {fieldname:"internet_protocol_FTP_adv_CharsetComboIndex", type:"number", controlname:"comboIntProtSet_FTP_adv_Charset", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "FTP"}; 
             GInternetProtocolSetRegistryList[13] = {fieldname:"internet_protocol_FTP_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_FTP_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[14] = {fieldname:"internet_protocol_FTP_adv_ascii_transfer_mode", type:"boolean", controlname:"cbIntProtSet_FTP_adv_ascii_transfer_mode", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[15] = {fieldname:"internet_protocol_FTP_adv_server_supports_moving", type:"boolean", controlname:"cbIntProtSet_FTP_adv_server_supports_moving", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[16] = {fieldname:"internet_protocol_FTP_adv_ListingCommandComboIndex", type:"number", controlname:"comboIntProtSet_FTP_adv_ListingCommand", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "FTP"}; 
             GInternetProtocolSetRegistryList[17] = {fieldname:"internet_protocol_FTP_adv_verify_file", type:"boolean", controlname:"cbIntProtSet_FTP_adv_verify_file", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[18] = {fieldname:"internet_protocol_FTP_adv_respect_passive_mode", type:"boolean", controlname:"cbIntProtSet_FTP_adv_respect_passive_mode", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[19] = {fieldname:"internet_protocol_FTP_adv_TimestampsForUploadsComboIndex", type:"number", controlname:"comboIntProtSet_FTP_adv_TimestampsForUploads", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "FTP"}; 
             GInternetProtocolSetRegistryList[20] = {fieldname:"internet_protocol_FTP_adv_zone", type:"boolean", controlname:"cbIntProtSet_FTP_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[21] = {fieldname:"internet_protocol_FTP_adv_auto", type:"boolean", controlname:"cbIntProtSet_FTP_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[22] = {fieldname:"", type:"boolean", controlname:"", controltype:"", default: "false", value: null, ControlAppGroup: ""};//void            
             GInternetProtocolSetRegistryList[23] = {fieldname:"internet_protocol_FTP_adv_list", type:"decimal", controlname:"inptIntProtSet_FTP_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[24] = {fieldname:"internet_protocol_FTP_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_FTP_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[25] = {fieldname:"internet_protocol_FTP_adv_timeout", type:"decimal", controlname:"inptIntProtSet_FTP_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[26] = {fieldname:"internet_protocol_FTP_adv_retries", type:"decimal", controlname:"inptIntProtSet_FTP_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[27] = {fieldname:"internet_protocol_FTP_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_FTP_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[28] = {fieldname:"internet_protocol_FTP_proxy_proxy_type", type:"number", controlname:"comboIntProtSet_FTP_proxy_proxy_type", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "FTP"}; 
             GInternetProtocolSetRegistryList[29] = {fieldname:"internet_protocol_FTP_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_FTP_proxy_proxy_host", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[30] = {fieldname:"internet_protocol_FTP_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_FTP_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[31] = {fieldname:"internet_protocol_FTP_proxy_login", type:"string", controlname:"inptIntProtSet_FTP_proxy_login", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[32] = {fieldname:"internet_protocol_FTP_proxy_password", type:"string", controlname:"inptIntProtSet_FTP_proxy_password", controltype:"jqxPasswordInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[33] = {fieldname:"internet_protocol_FTP_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_FTP_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
                                                         
             GInternetProtocolSetRegistryList[34] = {fieldname:"internet_protocol_FTP_Security_Mode_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_FTP_Security_security_none", value: null, ControlAppGroup: "FTP",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_FTP_Security_security_none"),  $("#rbIntProtSet_FTP_Security_security_implisit_tsl"), $("#rbIntProtSet_FTP_Security_security_explisit_tsl"), null, null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option,   $("#rbIntProtSet_FTP_Security_security_none"),  $("#rbIntProtSet_FTP_Security_security_implisit_tsl"), $("#rbIntProtSet_FTP_Security_security_explisit_tsl"), null, null, null ); 

             }}; 

             GInternetProtocolSetRegistryList[35] = {fieldname:"internet_protocol_FTP_Auth_Cmd_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_FTP_Security_auto", value: null, ControlAppGroup: "FTP",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_FTP_Security_auto"),  $("#rbIntProtSet_FTP_Security_TLS"), $("#rbIntProtSet_FTP_Security_SSL"), $("#rbIntProtSet_FTP_Security_TLSC"), $("#rbIntProtSet_FTP_Security_TLSP"), null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option,   $("#rbIntProtSet_FTP_Security_auto"),  $("#rbIntProtSet_FTP_Security_TLS"), $("#rbIntProtSet_FTP_Security_SSL"), $("#rbIntProtSet_FTP_Security_TLSC"), $("#rbIntProtSet_FTP_Security_TLSP"), null ); 

             }}; 
                    
             GInternetProtocolSetRegistryList[36] = {fieldname:"internet_protocol_FTP_Version_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_FTP_Security_TLSv_1_1_2", value: null, ControlAppGroup: "FTP",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_FTP_Security_SSLv2"),  $("#rbIntProtSet_FTP_Security_SSLv2_3"), $("#rbIntProtSet_FTP_Security_SSLv3"), $("#rbIntProtSet_FTP_Security_TLSv_1_1_2"), null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option,   $("#rbIntProtSet_FTP_Security_SSLv2"),  $("#rbIntProtSet_FTP_Security_SSLv2_3"), $("#rbIntProtSet_FTP_Security_SSLv3"), $("#rbIntProtSet_FTP_Security_TLSv_1_1_2"), null, null ); 

             }}; 
               
             GInternetProtocolSetRegistryList[37] = {fieldname:"internet_protocol_FTP_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_FTP_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[38] = {fieldname:"internet_protocol_FTP_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_FTP_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[39] = {fieldname:"internet_protocol_FTP_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_FTP_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[40] = {fieldname:"internet_protocol_FTP_security_CertificateComboIndex", type:"number", controlname:"comboIntProtSet_FTP_security_Certificate", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "FTP"}; 
             GInternetProtocolSetRegistryList[41] = {fieldname:"internet_protocol_FTP_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_FTP_security_CertificatePassword", controltype:"jqxPasswordInput", default: "0", value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[42] = {fieldname:"internet_protocol_FTP_security_nopassword", type:"boolean", controlname:"cbIntProtSet_FTP_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "FTP"};            
             GInternetProtocolSetRegistryList[43] = {fieldname:"internet_protocol_FTP_certificates_certificates", type:"string", controlname:"inptIntProtSet_FTP_certificates_certificates", controltype:"jqxInput", default: "",  width: 350, height: 150, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[44] = {fieldname:"internet_protocol_FTP_certificates_certname_forreference", type:"string", controlname:"inptIntProtSet_FTP_certificates_certname_forreference", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[45] = {fieldname:"internet_protocol_FTP_certificates_private_keyfile", type:"string", controlname:"inptIntProtSet_FTP_certificates_private_keyfile", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};
             GInternetProtocolSetRegistryList[46] = {fieldname:"internet_protocol_FTP_certificates_public_keyfile", type:"string", controlname:"inptIntProtSet_FTP_certificates_public_keyfile", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "FTP"};


             ///GDrive


             GInternetProtocolSetRegistryList[47] = {fieldname:"internet_protocol_GDrive_LibraryComboIndex", type:"number", controlname:"jqxLibraryCombo", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[48] = {fieldname:"internet_protocol_GDrive_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[49] = {fieldname:"internet_protocol_GDrive_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[50] = {fieldname:"internet_protocol_GDrive_save_optional_accname", type:"boolean", controlname:"cbIntProtSet_GDrive_save_optional_accname", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[51] = {fieldname:"internet_protocol_GDrive_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_GDrive_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[52] = {fieldname:"internet_protocol_GDrive_auto_resume_transfer", type:"boolean", controlname:"cbIntProtSet_GDrive_auto_resume_transfer", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[53] = {fieldname:"internet_protocol_GDrive_filename_encoding", type:"boolean", controlname:"cbIntProtSet_GDrive_filename_encoding", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[54] = {fieldname:"internet_protocol_GDrive_adv_Charset", type:"number", controlname:"comboIntProtSet_GDrive_adv_Charset", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[55] = {fieldname:"internet_protocol_GDrive_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_GDrive_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[56] = {fieldname:"internet_protocol_GDrive_adv_enable_doc_convercion", type:"boolean", controlname:"cbIntProtSet_GDrive_adv_enable_doc_convercion", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[57] = {fieldname:"internet_protocol_GDrive_adv_zone", type:"boolean", controlname:"cbIntProtSet_GDrive_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[58] = {fieldname:"internet_protocol_GDrive_adv_auto", type:"boolean", controlname:"cbIntProtSet_GDrive_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[59] = {fieldname:"", type:"boolean", controlname:"", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""}; //void           
             GInternetProtocolSetRegistryList[60] = {fieldname:"internet_protocol_GDrive_adv_list", type:"number", controlname:"inptIntProtSet_GDrive_adv_list", controltype:"jqxFormattedInput", default: 0, value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[61] = {fieldname:"internet_protocol_GDrive_adv_upload_min", type:"number", controlname:"inptIntProtSet_GDrive_adv_upload_min", controltype:"jqxFormattedInput", default: 0, value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[62] = {fieldname:"internet_protocol_GDrive_adv_timeout", type:"number", controlname:"inptIntProtSet_GDrive_adv_timeout", controltype:"jqxFormattedInput", default: 0, value: null, ControlAppGroup: "Google Drive"};                                                                                                                                             
             GInternetProtocolSetRegistryList[63] = {fieldname:"internet_protocol_GDrive_adv_retries", type:"number", controlname:"inptIntProtSet_GDrive_adv_retries", controltype:"jqxFormattedInput", default: 0, value: null, ControlAppGroup: "Google Drive"};                                                                                                                                             
             GInternetProtocolSetRegistryList[64] = {fieldname:"internet_protocol_GDrive_adv_http_retries", type:"number", controlname:"inptIntProtSet_GDrive_adv_http_retries", controltype:"jqxFormattedInput", default: 0, value: null, ControlAppGroup: "Google Drive"};                                                                                                                                             
             GInternetProtocolSetRegistryList[65] = {fieldname:"internet_protocol_GDrive_proxy_proxy_type", type:"number", controlname:"comboIntProtSet_GDrive_proxy_proxy_type", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[66] = {fieldname:"internet_protocol_GDrive_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_GDrive_proxy_proxy_host", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[67] = {fieldname:"internet_protocol_GDrive_proxy_proxy_port", type:"number", controlname:"inptIntProtSet_GDrive_proxy_proxy_port", controltype:"jqxFormattedInput", default: 0, value: null, ControlAppGroup: "Google Drive"};                                                                                                                                             
             GInternetProtocolSetRegistryList[68] = {fieldname:"internet_protocol_GDrive_proxy_login", type:"string", controlname:"inptIntProtSet_GDrive_proxy_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[69] = {fieldname:"internet_protocol_GDrive_proxy_password", type:"string", controlname:"inptIntProtSet_GDrive_proxy_password", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Google Drive"}; 
             GInternetProtocolSetRegistryList[70] = {fieldname:"internet_protocol_GDrive_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_GDrive_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
                  
             GInternetProtocolSetRegistryList[71] = {fieldname:"internet_protocol_GDrive_FormatSpreadsheets_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_GDrive_GDocs_xlsx", value: null, ControlAppGroup: "Google Drive",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_GDrive_GDocs_xlsx"),  $("#rbIntProtSet_GDrive_GDocs_csv"), $("#rbIntProtSet_GDrive_GDocs_pdf"), null, null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_GDrive_GDocs_xlsx"),  $("#rbIntProtSet_GDrive_GDocs_csv"), $("#rbIntProtSet_GDrive_GDocs_pdf"), null, null, null ); 

             }};                                                                          
                                                                                 
                   
             GInternetProtocolSetRegistryList[72] = {fieldname:"internet_protocol_GDrive_FormatDownldDocs_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_GDrive_GDocs_dd_docx", value: null, ControlAppGroup: "Google Drive",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_GDrive_GDocs_dd_docx"),  $("#rbIntProtSet_GDrive_GDocs_dd_odt"), $("#rbIntProtSet_GDrive_GDocs_dd_rtf"), $("#rbIntProtSet_GDrive_GDocs_dd_html"), $("#rbIntProtSet_GDrive_GDocs_dd_pdf"),  $("#rbIntProtSet_GDrive_GDocs_dd_txt") ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_GDrive_GDocs_dd_docx"),  $("#rbIntProtSet_GDrive_GDocs_dd_odt"), $("#rbIntProtSet_GDrive_GDocs_dd_rtf"), $("#rbIntProtSet_GDrive_GDocs_dd_html"), $("#rbIntProtSet_GDrive_GDocs_dd_pdf"),  $("#rbIntProtSet_GDrive_GDocs_dd_txt") ); 

             }};                                                                          
                                                                                                                                       
             GInternetProtocolSetRegistryList[73] = {fieldname:"internet_protocol_GDrive_FormatDownldPres_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_GDrive_GDocs_dpres_pptx", value: null, ControlAppGroup: "Google Drive",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_GDrive_GDocs_dpres_pptx"),  $("#rbIntProtSet_GDrive_GDocs_dpres_pdf"), $("#rbIntProtSet_GDrive_GDocs_dpres_txt"), null, null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_GDrive_GDocs_dpres_pptx"),  $("#rbIntProtSet_GDrive_GDocs_dpres_pdf"), $("#rbIntProtSet_GDrive_GDocs_dpres_txt"), null, null, null ); 

             }};                                                                          



                                             //out of order. but added later.    
             GInternetProtocolSetRegistryList[350] = {fieldname:"internet_protocol_GDrive_FormatDownldDraw_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_GDrive_GDocs_ddraw_jpg", value: null, ControlAppGroup: "Google Drive",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_GDrive_GDocs_ddraw_jpg"),  $("#rbIntProtSet_GDrive_GDocs_ddraw_png"), $("#rbIntProtSet_GDrive_GDocs_ddraw_pdf"), $("#rbIntProtSet_GDrive_GDocs_ddraw_xml"), null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_GDrive_GDocs_ddraw_jpg"),  $("#rbIntProtSet_GDrive_GDocs_ddraw_png"), $("#rbIntProtSet_GDrive_GDocs_ddraw_pdf"), $("#rbIntProtSet_GDrive_GDocs_ddraw_xml"), null, null); 

             }};                                                                          




             GInternetProtocolSetRegistryList[74] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_csv", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_csv", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[75] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_html", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_html", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[76] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_pdf", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_pdf", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[77] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_pptx", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_pptx", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[78] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_txt", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_txt", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[79] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_doc", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_doc", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[80] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_ods", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_ods", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[81] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_pps", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_pps", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[82] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_rtf", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_rtf", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[83] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_xls", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_xls", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[84] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_docx", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_docx", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[85] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_odt", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_odt", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[86] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_ppt", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_ppt", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[87] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_tsv", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_tsv", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
             GInternetProtocolSetRegistryList[88] = {fieldname:"internet_protocol_GDrive_GDocs_ftconvert_xlsx", type:"boolean", controlname:"cbIntProtSet_GDrive_GDocs_ftconvert_xlsx", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Google Drive"};            
                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                           
             GInternetProtocolSetRegistryList[89] = {fieldname:"internet_protocol_HTTP_url", type:"string", controlname:"inptIntProtSet_HTTP_url", controltype:"jqxInput", default: "",  width: 350, height: 25, value: "", ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[90] = {fieldname:"internet_protocol_HTTP_port", type:"decimal", controlname:"inptIntProtSet_HTTP_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[91] = {fieldname:"internet_protocol_HTTP_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[92] = {fieldname:"internet_protocol_HTTP_login", type:"string", controlname:"inptIntProtSet_HTTP_login", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[93] = {fieldname:"internet_protocol_HTTP_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[94] = {fieldname:"internet_protocol_HTTP_save_user_id", type:"boolean", controlname:"cbIntProtSet_HTTP_save_user_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[95] = {fieldname:"internet_protocol_HTTP_save_password", type:"boolean", controlname:"cbIntProtSet_HTTP_save_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[96] = {fieldname:"internet_protocol_HTTP_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_HTTP_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[97] = {fieldname:"internet_protocol_HTTP_auto_resume_transfer", type:"boolean", controlname:"cbIntProtSet_HTTP_filename_encoding", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[98] = {fieldname:"internet_protocol_HTTP_HTML_download_and_parse", type:"boolean", controlname:"cbIntProtSet_HTTP_HTML_download_and_parse", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[99] = {fieldname:"internet_protocol_HTTP_HTML_parsing_limit", type:"decimal", controlname:"inptIntProtSet_HTTP_HTML_parsing_limit", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[100] = {fieldname:"internet_protocol_HTTP_HTML_enquire_timestamp", type:"boolean", controlname:"cbIntProtSet_HTTP_HTML_enquire_timestamp", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[101] = {fieldname:"internet_protocol_HTTP_HTML_enquire_precise_info", type:"boolean", controlname:"cbIntProtSet_HTTP_HTML_enquire_precise_info", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[102] = {fieldname:"internet_protocol_HTTP_HTML_download_default_pages", type:"boolean", controlname:"cbIntProtSet_HTTP_HTML_download_default_pages", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[103] = {fieldname:"internet_protocol_HTTP_HTML_consider_locally_existing_files", type:"boolean", controlname:"cbIntProtSet_HTTP_HTML_consider_locally_existing_files", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[104] = {fieldname:"internet_protocol_HTTP_HTML_assume_local_files", type:"boolean", controlname:"cbIntProtSet_HTTP_HTML_assume_local_files", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[105] = {fieldname:"internet_protocol_HTTP_HTML_avoid_re_downloading", type:"boolean", controlname:"cbIntProtSet_HTTP_HTML_avoid_re_downloading", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[106] = {fieldname:"internet_protocol_HTTP_HTML_LinksAboveComboIndex", type:"number", controlname:"jqxLinksAboveCombo", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "HTTP"}; 
             GInternetProtocolSetRegistryList[107] = {fieldname:"internet_protocol_HTTP_HTML_LinksToOtherDomainsComboIndex", type:"number", controlname:"jqxLinksToOtherDomainsCombo", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "HTTP"}; 
             GInternetProtocolSetRegistryList[108] = {fieldname:"internet_protocol_HTTP_adv_CharsetIndex", type:"number", controlname:"comboIntProtSet_HTTP_adv_Charset", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "HTTP"}; 
             GInternetProtocolSetRegistryList[109] = {fieldname:"internet_protocol_HTTP_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_HTTP_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[110] = {fieldname:"internet_protocol_HTTP_adv_zone", type:"boolean", controlname:"cbIntProtSet_HTTP_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[111] = {fieldname:"internet_protocol_HTTP_adv_auto", type:"boolean", controlname:"cbIntProtSet_HTTP_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[112] = {fieldname:"", type:"boolean", controlname:"", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""}; //void           
             GInternetProtocolSetRegistryList[113] = {fieldname:"internet_protocol_HTTP_adv_list", type:"decimal", controlname:"inptIntProtSet_HTTP_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[114] = {fieldname:"internet_protocol_HTTP_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_HTTP_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[115] = {fieldname:"internet_protocol_HTTP_adv_timeout", type:"decimal", controlname:"inptIntProtSet_HTTP_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[116] = {fieldname:"internet_protocol_HTTP_adv_retries", type:"decimal", controlname:"inptIntProtSet_HTTP_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[117] = {fieldname:"internet_protocol_HTTP_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_HTTP_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[118] = {fieldname:"internet_protocol_HTTP_HTTP_proxy_proxy_typeComboIndex", type:"number", controlname:"comboIntProtSet_HTTP_proxy_proxy_type", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "HTTP"}; 
             GInternetProtocolSetRegistryList[119] = {fieldname:"internet_protocol_HTTP_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_HTTP_proxy_proxy_host", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[120] = {fieldname:"internet_protocol_HTTP_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_HTTP_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[121] = {fieldname:"internet_protocol_HTTP_proxy_login", type:"string", controlname:"inptIntProtSet_HTTP_proxy_login", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[122] = {fieldname:"internet_protocol_HTTP_proxy_password", type:"string", controlname:"inptIntProtSet_HTTP_proxy_password", controltype:"jqxPasswordInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[123] = {fieldname:"internet_protocol_HTTP_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_HTTP_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
                             
                              
             GInternetProtocolSetRegistryList[124] = {fieldname:"internet_protocol_HTTP_Version_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_HTTP_Security_SSLv2", value: null, ControlAppGroup: "HTTP",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_HTTP_Security_SSLv2"),  $("#rbIntProtSet_HTTP_Security_SSLv2_3"), $("#rbIntProtSet_HTTP_Security_SSLv3"), $("#rbIntProtSet_HTTP_Security_TLSv_1_1_2"), null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_HTTP_Security_SSLv2"),  $("#rbIntProtSet_HTTP_Security_SSLv2_3"), $("#rbIntProtSet_HTTP_Security_SSLv3"), $("#rbIntProtSet_HTTP_Security_TLSv_1_1_2"), null, null ); 

             }};             
          
             GInternetProtocolSetRegistryList[125] = {fieldname:"internet_protocol_HTTP_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_HTTP_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[126] = {fieldname:"internet_protocol_HTTP_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_HTTP_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[127] = {fieldname:"internet_protocol_HTTP_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_HTTP_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[128] = {fieldname:"internet_protocol_HTTP_security_CertificateIndex", type:"number", controlname:"comboIntProtSet_HTTP_security_Certificate", controltype:"jqxComboBox", default: "false", value: null, ControlAppGroup: "HTTP"}; 
             GInternetProtocolSetRegistryList[129] = {fieldname:"internet_protocol_HTTP_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_HTTP_security_CertificatePassword", controltype:"jqxPasswordInput", default: "0", value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[130] = {fieldname:"internet_protocol_HTTP_security_nopassword", type:"boolean", controlname:"cbIntProtSet_HTTP_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "HTTP"};            
             GInternetProtocolSetRegistryList[131] = {fieldname:"internet_protocol_HTTP_certificates_certificates", type:"string", controlname:"inptIntProtSet_HTTP_certificates_certificates", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[132] = {fieldname:"internet_protocol_HTTP_certificates_certname_forreference", type:"string", controlname:"inptIntProtSet_HTTP_certificates_certname_forreference", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[133] = {fieldname:"internet_protocol_HTTP_certificates_private_keyfile", type:"string", controlname:"inptIntProtSet_HTTP_certificates_private_keyfile", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
             GInternetProtocolSetRegistryList[134] = {fieldname:"internet_protocol_HTTP_certificates_public_keyfile", type:"string", controlname:"inptIntProtSet_HTTP_certificates_public_keyfile", controltype:"jqxInput", default: "",  width: 350, height: 25, value: null, ControlAppGroup: "HTTP"};
                                                                  
             //Amazon S3


             GInternetProtocolSetRegistryList[135] = {fieldname:"internet_protocol_AmazonS3_bucket", type:"string", controlname:"inptIntProtSet_AmazonS3_bucket", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[136] = {fieldname:"internet_protocol_AmazonS3_reduced_redundancy", type:"boolean", controlname:"cbIntProtSet_AmazonS3_reduced_redundancy", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[137] = {fieldname:"internet_protocol_AmazonS3_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[138] = {fieldname:"internet_protocol_AmazonS3_access_id", type:"string", controlname:"inptIntProtSet_AmazonS3_access_id", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Amazon S3"};           
             GInternetProtocolSetRegistryList[139] = {fieldname:"internet_protocol_AmazonS3_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[140] = {fieldname:"internet_protocol_AmazonS3_save_access_id", type:"boolean", controlname:"cbIntProtSet_AmazonS3_save_access_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[141] = {fieldname:"internet_protocol_AmazonS3_save_secret_key", type:"boolean", controlname:"cbIntProtSet_AmazonS3_save_secret_key", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[142] = {fieldname:"internet_protocol_AmazonS3_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_AmazonS3_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[143] = {fieldname:"internet_protocol_AmazonS3_filename_encoding", type:"boolean", controlname:"cbIntProtSet_AmazonS3_filename_encoding", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};                                            
             GInternetProtocolSetRegistryList[144] = {fieldname:"internet_protocol_AmazonS3_adv_CharsetIndex", type:"number", controlname:"comboIntProtSet_AmazonS3_adv_Charset", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[145] = {fieldname:"internet_protocol_AmazonS3_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_AmazonS3_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[146] = {fieldname:"internet_protocol_AmazonS3_make_uploaded_files_pub_available", type:"boolean", controlname:"cbIntProtSet_AmazonS3_make_uploaded_files_pub_available", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[147] = {fieldname:"internet_protocol_AmazonS3_recursive_listing", type:"boolean", controlname:"cbIntProtSet_AmazonS3_recursive_listing", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[148] = {fieldname:"internet_protocol_AmazonS3_use_server_side_encryption", type:"boolean", controlname:"cbIntProtSet_AmazonS3_use_server_side_encryption", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[149] = {fieldname:"internet_protocol_AmazonS3_adv_zone", type:"boolean", controlname:"cbIntProtSet_AmazonS3_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[150] = {fieldname:"internet_protocol_AmazonS3_adv_auto", type:"boolean", controlname:"cbIntProtSet_AmazonS3_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
             GInternetProtocolSetRegistryList[151] = {fieldname:"internet_protocol_AmazonS3_adv_list", type:"decimal", controlname:"inptIntProtSet_AmazonS3_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Amazon S3"};
             GInternetProtocolSetRegistryList[152] = {fieldname:"internet_protocol_AmazonS3_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_AmazonS3_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Amazon S3"};
             GInternetProtocolSetRegistryList[153] = {fieldname:"internet_protocol_AmazonS3_adv_timeout", type:"decimal", controlname:"inptIntProtSet_AmazonS3_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Amazon S3"};
             GInternetProtocolSetRegistryList[154] = {fieldname:"internet_protocol_AmazonS3_adv_retries", type:"decimal", controlname:"inptIntProtSet_AmazonS3_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Amazon S3"};
             GInternetProtocolSetRegistryList[155] = {fieldname:"internet_protocol_AmazonS3_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_AmazonS3_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Amazon S3"};
             GInternetProtocolSetRegistryList[156] = {fieldname:"internet_protocol_AmazonS3_proxy_proxy_typeIndex", type:"number", controlname:"comboIntProtSet_AmazonS3_proxy_proxy_type", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[157] = {fieldname:"internet_protocol_AmazonS3_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_AmazonS3_proxy_proxy_host", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[158] = {fieldname:"internet_protocol_AmazonS3_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_AmazonS3_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Amazon S3"};
             GInternetProtocolSetRegistryList[159] = {fieldname:"internet_protocol_AmazonS3_proxy_login", type:"string", controlname:"inptIntProtSet_AmazonS3_proxy_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[160] = {fieldname:"internet_protocol_AmazonS3_proxy_password", type:"string", controlname:"inptIntProtSet_AmazonS3_proxy_password", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Amazon S3"}; 
             GInternetProtocolSetRegistryList[161] = {fieldname:"internet_protocol_AmazonS3_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_AmazonS3_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
                                                                            
          
             GInternetProtocolSetRegistryList[162] = {fieldname:"IntProtSet_AmazonS3_Version_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_AmazonS3_Security_SSLv2", value: null, ControlAppGroup: "Amazon S3",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_AmazonS3_Security_SSLv2"), $("#rbIntProtSet_AmazonS3_Security_SSLv2_3"), $("#rbIntProtSet_AmazonS3_Security_SSLv3"), $("#rbIntProtSet_AmazonS3_Security_TLSv_1_1_2"), null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_AmazonS3_Security_SSLv2"), $("#rbIntProtSet_AmazonS3_Security_SSLv2_3"), $("#rbIntProtSet_AmazonS3_Security_SSLv3"), $("#rbIntProtSet_AmazonS3_Security_TLSv_1_1_2"), null, null ); 
             }};                     
            
             
            GInternetProtocolSetRegistryList[163] = {fieldname:"internet_protocol_AmazonS3_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_AmazonS3_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
            GInternetProtocolSetRegistryList[164] = {fieldname:"internet_protocol_AmazonS3_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_AmazonS3_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
            GInternetProtocolSetRegistryList[165] = {fieldname:"internet_protocol_AmazonS3_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_AmazonS3_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
            GInternetProtocolSetRegistryList[166] = {fieldname:"internet_protocol_AmazonS3_Security_CertificateIndex", type:"number", controlname:"comboIntProtSet_AmazonS3_security_Certificate", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Amazon S3"}; 
            GInternetProtocolSetRegistryList[167] = {fieldname:"internet_protocol_AmazonS3_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_AmazonS3_security_CertificatePassword", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Amazon S3"}; 
            GInternetProtocolSetRegistryList[168] = {fieldname:"internet_protocol_AmazonS3_security_nopassword", type:"boolean", controlname:"cbIntProtSet_AmazonS3_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Amazon S3"};            
                   


            GInternetProtocolSetRegistryList[169] = {fieldname:"internet_protocol_Asure_container", type:"string", controlname:"inptIntProtSet_Asure_container", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[170] = {fieldname:"internet_protocol_Asure_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[171] = {fieldname:"internet_protocol_Asure_account_id", type:"string", controlname:"inptIntProtSet_Asure_account_id", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[172] = {fieldname:"internet_protocol_Asure_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            
            GInternetProtocolSetRegistryList[173] = {fieldname:"internet_protocol_Asure_save_user_id", type:"boolean", controlname:"cbIntProtSet_Asure_save_user_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[174] = {fieldname:"internet_protocol_Asure_save_password", type:"boolean", controlname:"cbIntProtSet_Asure_save_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[175] = {fieldname:"internet_protocol_Asure_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_Asure_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[176] = {fieldname:"internet_protocol_Asure_filename_encoding", type:"boolean", controlname:"cbIntProtSet_Asure_filename_encoding", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[177] = {fieldname:"internet_protocol_Asure_adv_CharsetIndex", type:"number", controlname:"comboIntProtSet_Asure_adv_Charset", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Asure"}; 

            GInternetProtocolSetRegistryList[178] = {fieldname:"internet_protocol_Asure_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_Asure_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[179] = {fieldname:"internet_protocol_Asure_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_Asure_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[180] = {fieldname:"internet_protocol_Asure_adv_recursive_listing", type:"boolean", controlname:"cbIntProtSet_Asure_adv_recursive_listing", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[181] = {fieldname:"internet_protocol_Asure_adv_cache_control", type:"decimal", controlname:"inptIntProtSet_Asure_adv_cache_control", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Asure"};
            GInternetProtocolSetRegistryList[182] = {fieldname:"internet_protocol_Asure_adv_zone", type:"boolean", controlname:"cbIntProtSet_Asure_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[183] = {fieldname:"internet_protocol_Asure_adv_UTC", type:"boolean", controlname:"cbIntProtSet_Asure_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[184] = {fieldname:"internet_protocol_Asure_adv_list", type:"decimal", controlname:"inptIntProtSet_Asure_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Asure"};
            GInternetProtocolSetRegistryList[185] = {fieldname:"internet_protocol_Asure_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_Asure_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Asure"};
            GInternetProtocolSetRegistryList[186] = {fieldname:"internet_protocol_Asure_adv_timeout", type:"decimal", controlname:"inptIntProtSet_Asure_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Asure"};
            GInternetProtocolSetRegistryList[187] = {fieldname:"internet_protocol_Asure_adv_retries", type:"decimal", controlname:"inptIntProtSet_Asure_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Asure"};
            GInternetProtocolSetRegistryList[188] = {fieldname:"internet_protocol_Asure_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_Asure_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Asure"};
            GInternetProtocolSetRegistryList[189] = {fieldname:"internet_protocol_Asure_proxy_proxy_typeIndex", type:"number", controlname:"comboIntProtSet_Asure_proxy_proxy_type", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[190] = {fieldname:"internet_protocol_Asure_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_Asure_proxy_proxy_host", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[191] = {fieldname:"internet_protocol_Asure_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_Asure_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Asure"};
            GInternetProtocolSetRegistryList[192] = {fieldname:"internet_protocol_Asure_proxy_login", type:"string", controlname:"inptIntProtSet_Asure_proxy_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[193] = {fieldname:"internet_protocol_Asure_proxy_password", type:"string", controlname:"inptIntProtSet_Asure_proxy_password", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[194] = {fieldname:"internet_protocol_Asure_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_Asure_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
                                                                 
            GInternetProtocolSetRegistryList[195] = {fieldname:"IntProtSet_Asure_Version_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_Asure_Security_SSLv2", value: null, ControlAppGroup: "Asure",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_Asure_Security_SSLv2"), $("#rbIntProtSet_Asure_Security_SSLv2_3"), $("#rbIntProtSet_Asure_Security_SSLv3"), $("#rbIntProtSet_Asure_Security_TLSv_1_1_2"), null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_Asure_Security_SSLv2"), $("#rbIntProtSet_Asure_Security_SSLv2_3"), $("#rbIntProtSet_Asure_Security_SSLv3"), $("#rbIntProtSet_Asure_Security_TLSv_1_1_2"), null, null ); 
             }}; 
                                                                                   
            GInternetProtocolSetRegistryList[196] = {fieldname:"internet_protocol_Asure_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_Asure_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[197] = {fieldname:"internet_protocol_Asure_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_Asure_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[198] = {fieldname:"internet_protocol_Asure_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_Asure_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            GInternetProtocolSetRegistryList[199] = {fieldname:"internet_protocol_Asure_security_CertificateIndex", type:"number", controlname:"comboIntProtSet_Asure_security_Certificate", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[200] = {fieldname:"internet_protocol_Asure_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_Asure_security_CertificatePassword", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Asure"}; 
            GInternetProtocolSetRegistryList[201] = {fieldname:"internet_protocol_Asure_security_nopassword", type:"boolean", controlname:"cbIntProtSet_Asure_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Asure"};            
            
                                                                                                                                                                                                                                                                                                    
	      
            GInternetProtocolSetRegistryList[202] = {fieldname:"internet_protocol_WebDAV_LibraryComboIndex", type:"number", controlname:"jqxLibraryCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[203] = {fieldname:"internet_protocol_WebDAV_url", type:"string", controlname:"inptIntProtSetWebDAV_url", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[204] = {fieldname:"internet_protocol_WebDAV_AuthenticationComboIndex", type:"number", controlname:"jqxWebDAVAuthenticationCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[205] = {fieldname:"internet_protocol_WebDAV_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[206] = {fieldname:"internet_protocol_WebDAV_login", type:"string", controlname:"inptIntProtSet_WebDAV_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[207] = {fieldname:"internet_protocol_WebDAV_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[208] = {fieldname:"internet_protocol_WebDAV_save_user_id", type:"boolean", controlname:"cbIntProtSet_WebDAV_save_user_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[209] = {fieldname:"internet_protocol_WebDAV_save_password", type:"boolean", controlname:"cbIntProtSet_WebDAV_save_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[210] = {fieldname:"internet_protocol_WebDAV_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_WebDAV_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[211] = {fieldname:"internet_protocol_WebDAV_filename_encoding", type:"boolean", controlname:"cbIntProtSet_WebDAV_filename_encoding", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[212] = {fieldname:"internet_protocol_WebDAV_adv_CharsetComboIndex", type:"number", controlname:"comboIntProtSet_WebDAV_adv_Charset", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[213] = {fieldname:"internet_protocol_WebDAV_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_WebDAV_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[214] = {fieldname:"internet_protocol_WebDAV_adv_strategyCombo", type:"number", controlname:"comboIntProtSet_WebDAV_adv_strategyCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[215] = {fieldname:"internet_protocol_WebDAV_adv_use_displayname", type:"boolean", controlname:"cbIntProtSet_WebDAV_adv_use_displayname", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[216] = {fieldname:"internet_protocol_WebDAV_adv_use_expect_100_continue", type:"boolean", controlname:"comboIntProtSet_WebDAV_adv_use_expect_100_continue", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[217] = {fieldname:"internet_protocol_WebDAV_adv_TimestampsForUploads", type:"number", controlname:"comboIntProtSet_WebDAV_adv_TimestampsForUploads", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[218] = {fieldname:"internet_protocol_WebDAV_adv_zone", type:"boolean", controlname:"cbIntProtSet_WebDAV_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[219] = {fieldname:"internet_protocol_WebDAV_adv_auto", type:"boolean", controlname:"cbIntProtSet_WebDAV_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[220] = {fieldname:"", type:"", controlname:"", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
            GInternetProtocolSetRegistryList[221] = {fieldname:"internet_protocol_WebDAV_adv_list", type:"decimal", controlname:"inptIntProtSet_WebDAV_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "WebDAV"};
            GInternetProtocolSetRegistryList[222] = {fieldname:"internet_protocol_WebDAV_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_WebDAV_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "WebDAV"};
            GInternetProtocolSetRegistryList[223] = {fieldname:"internet_protocol_WebDAV_adv_timeout", type:"decimal", controlname:"inptIntProtSet_WebDAV_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "WebDAV"};
            GInternetProtocolSetRegistryList[224] = {fieldname:"internet_protocol_WebDAV_adv_retries", type:"decimal", controlname:"inptIntProtSet_WebDAV_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "WebDAV"};
            GInternetProtocolSetRegistryList[225] = {fieldname:"internet_protocol_WebDAV_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_WebDAV_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "WebDAV"};
            GInternetProtocolSetRegistryList[226] = {fieldname:"internet_protocol_WebDAV_proxy_proxy_type", type:"boolean", controlname:"comboIntProtSet_WebDAV_proxy_proxy_type", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[227] = {fieldname:"internet_protocol_WebDAV_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_WebDAV_proxy_proxy_host", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[228] = {fieldname:"internet_protocol_WebDAV_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_WebDAV_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "WebDAV"};
            GInternetProtocolSetRegistryList[229] = {fieldname:"internet_protocol_WebDAV_proxy_login", type:"string", controlname:"inptIntProtSet_WebDAV_proxy_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[230] = {fieldname:"internet_protocol_WebDAV_proxy_password", type:"string", controlname:"inptIntProtSet_WebDAV_proxy_password", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[231] = {fieldname:"internet_protocol_WebDAV_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_WebDAV_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
                                       
          
          
             GInternetProtocolSetRegistryList[232] = {fieldname:"IntProtSet_WebDAV_Version_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_WebDAV_Security_SSLv2", value: null, ControlAppGroup: "WebDAV",
             getfunc: function()
             {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_WebDAV_Security_SSLv2"), $("#rbIntProtSet_WebDAV_Security_SSLv2_3"), $("#rbIntProtSet_WebDAV_Security_SSLv3"), $("#rbIntProtSet_WebDAV_Security_TLSv_1_1_2"), null, null ); 

             }, setfunc: function( option )
             {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_WebDAV_Security_SSLv2"), $("#rbIntProtSet_WebDAV_Security_SSLv2_3"), $("#rbIntProtSet_WebDAV_Security_SSLv3"), $("#rbIntProtSet_WebDAV_Security_TLSv_1_1_2"), null, null ); 
             }}; 

            GInternetProtocolSetRegistryList[232] = {fieldname:"internet_protocol_WebDAV_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_WebDAV_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[233] = {fieldname:"internet_protocol_WebDAV_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_WebDAV_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[234] = {fieldname:"internet_protocol_WebDAV_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_WebDAV_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[235] = {fieldname:"internet_protocol_WebDAV_security_CertificateComboIndex", type:"number", controlname:"comboIntProtSet_WebDAV_security_Certificate", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[236] = {fieldname:"internet_protocol_WebDAV_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_WebDAV_security_CertificatePassword", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[237] = {fieldname:"internet_protocol_WebDAV_security_nopassword", type:"boolean", controlname:"cbIntProtSet_WebDAV_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "WebDAV"};            
            GInternetProtocolSetRegistryList[238] = {fieldname:"internet_protocol_WebDAV_certificates_certificates", type:"string", controlname:"inptIntProtSet_WebDAV_certificates_certificates", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[239] = {fieldname:"internet_protocol_WebDAV_certificates_certname_forreference", type:"string", controlname:"inptIntProtSet_WebDAV_certificates_certname_forreference", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[240] = {fieldname:"internet_protocol_WebDAV_certificates_private_keyfile", type:"string", controlname:"inptIntProtSet_WebDAV_certificates_private_keyfile", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
            GInternetProtocolSetRegistryList[241] = {fieldname:"internet_protocol_WebDAV_certificates_public_keyfile", type:"string", controlname:"inptIntProtSet_WebDAV_certificates_public_keyfile", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "WebDAV"}; 
                                       
 


            GInternetProtocolSetRegistryList[242] = {fieldname:"internet_protocol_RSync_LibraryComboIndex", type:"number", controlname:"jqxLibraryCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[243] = {fieldname:"internet_protocol_Rsync_url", type:"string", controlname:"inptIntProtSet_Rsync_url", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[244] = {fieldname:"internet_protocol_Rsync_port_number", type:"decimal", controlname:"inptIntProtSet_Rsync_port_number", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "RSync"};
            GInternetProtocolSetRegistryList[245] = {fieldname:"internet_protocol_Rsync_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[246] = {fieldname:"internet_protocol_Rsync_login", type:"string", controlname:"inptIntProtSet_Rsync_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[247] = {fieldname:"internet_protocol_Rsync_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[248] = {fieldname:"internet_protocol_Rsync_save_user_id", type:"boolean", controlname:"cbIntProtSet_Rsync_save_user_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[249] = {fieldname:"internet_protocol_Rsync_save_password", type:"boolean", controlname:"cbIntProtSet_Rsync_save_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[250] = {fieldname:"internet_protocol_Rsync_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_Rsync_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[251] = {fieldname:"internet_protocol_Rsync_adv_CharsetComboIndex", type:"number", controlname:"comboIntProtSet_Rsync_adv_Charset", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[252] = {fieldname:"internet_protocol_Rsync_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_Rsync_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[253] = {fieldname:"internet_protocol_Rsync_adv_TimestampsForUploadsComboIndex", type:"number", controlname:"comboIntProtSet_Rsync_adv_TimestampsForUploads", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[254] = {fieldname:"internet_protocol_Rsync_adv_zone", type:"boolean", controlname:"cbIntProtSet_Rsync_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[255] = {fieldname:"internet_protocol_Rsync_adv_auto", type:"boolean", controlname:"cbIntProtSet_Rsync_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[256] = {fieldname:"", type:"boolean", controlname:"", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
            GInternetProtocolSetRegistryList[257] = {fieldname:"internet_protocol_Rsync_adv_list", type:"decimal", controlname:"inptIntProtSet_Rsync_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "RSync"};
            GInternetProtocolSetRegistryList[258] = {fieldname:"internet_protocol_Rsync_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_Rsync_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "RSync"};
            GInternetProtocolSetRegistryList[259] = {fieldname:"internet_protocol_Rsync_adv_timeout", type:"decimal", controlname:"inptIntProtSet_Rsync_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "RSync"};
            GInternetProtocolSetRegistryList[260] = {fieldname:"internet_protocol_Rsync_adv_retries", type:"decimal", controlname:"inptIntProtSet_Rsync_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "RSync"};
            GInternetProtocolSetRegistryList[261] = {fieldname:"internet_protocol_Rsync_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_Rsync_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "RSync"};
            GInternetProtocolSetRegistryList[262] = {fieldname:"internet_protocol_Rsync_proxy_proxy_typeComboIndex", type:"number", controlname:"comboIntProtSet_Rsync_proxy_proxy_type", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[263] = {fieldname:"internet_protocol_Rsync_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_Rsync_proxy_proxy_host", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[264] = {fieldname:"internet_protocol_Rsync_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_Rsync_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "RSync"};
            GInternetProtocolSetRegistryList[265] = {fieldname:"internet_protocol_Rsync_proxy_login", type:"string", controlname:"inptIntProtSet_Rsync_proxy_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[266] = {fieldname:"internet_protocol_Rsync_proxy_password", type:"string", controlname:"inptIntProtSet_Rsync_proxy_password", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[267] = {fieldname:"internet_protocol_Rsync_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_Rsync_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
                                                                                      
            GInternetProtocolSetRegistryList[268] = {fieldname:"internet_protocol_Rsync_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_Rsync_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[269] = {fieldname:"internet_protocol_Rsync_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_Rsync_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[270] = {fieldname:"internet_protocol_Rsync_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_Rsync_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[271] = {fieldname:"internet_protocol_Rsync_security_CertificateIndex", type:"number", controlname:"comboIntProtSet_Rsync_security_Certificate", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[272] = {fieldname:"internet_protocol_Rsync_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_Rsync_security_CertificatePassword", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[273] = {fieldname:"internet_protocol_Rsync_security_nopassword", type:"boolean", controlname:"cbIntProtSet_Rsync_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "RSync"};            
            GInternetProtocolSetRegistryList[274] = {fieldname:"internet_protocol_Rsync_proxy_login", type:"string", controlname:"inptIntProtSet_Rsync_proxy_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[275] = {fieldname:"internet_protocol_Rsync_certificates_certificates", type:"string", controlname:"inptIntProtSet_Rsync_certificates_certificates", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[276] = {fieldname:"internet_protocol_Rsync_certificates_certname_forreference", type:"string", controlname:"inptIntProtSet_Rsync_certificates_certname_forreference", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[277] = {fieldname:"internet_protocol_Rsync_certificates_private_keyfile", type:"string", controlname:"inptIntProtSet_Rsync_certificates_private_keyfile", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
            GInternetProtocolSetRegistryList[278] = {fieldname:"internet_protocol_Rsync_certificates_public_keyfile", type:"string", controlname:"inptIntProtSet_Rsync_certificates_public_keyfile", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "RSync"}; 
                                              

            GInternetProtocolSetRegistryList[279] = {fieldname:"internet_protocol_SSH_LibraryComboIndex", type:"number", controlname:"jqxLibraryCombo", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[280] = {fieldname:"internet_protocol_SSH_url", type:"string", controlname:"inptIntProtSetSSH_url", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[281] = {fieldname:"internet_protocol_SSH_port_number", type:"decimal", controlname:"inptIntProtSet_SSH_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "SSH"};
            GInternetProtocolSetRegistryList[282] = {fieldname:"internet_protocol_SSH_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[283] = {fieldname:"internet_protocol_SSH_login", type:"string", controlname:"inptIntProtSet_SSH_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[284] = {fieldname:"internet_protocol_SSH_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[285] = {fieldname:"internet_protocol_SSH_save_password", type:"boolean", controlname:"cbIntProtSet_SSH_save_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            

            //skeeped
            GInternetProtocolSetRegistryList[348] = {fieldname:"internet_protocol_SSH_save_user_id", type:"boolean", controlname:"cbIntProtSet_SSH_save_user_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[349] = {fieldname:"internet_protocol_SSH_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_SSH_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            




            GInternetProtocolSetRegistryList[286] = {fieldname:"internet_protocol_SSH_auto_resume_transfer", type:"boolean", controlname:"cbIntProtSet_SSH_auto_resume_transfer", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[287] = {fieldname:"internet_protocol_SSH_adv_CharsetComboIndex", type:"number", controlname:"comboIntProtSet_SSH_adv_Charset", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[288] = {fieldname:"internet_protocol_SSH_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_SSH_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[289] = {fieldname:"internet_protocol_SSH_adv_recursive_listing", type:"boolean", controlname:"cbIntProtSet_SSH_adv_recursive_listing", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[290] = {fieldname:"internet_protocol_SSH_adv_verify_destination_file", type:"boolean", controlname:"cbIntProtSet_SSH_adv_verify_destination_file", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[291] = {fieldname:"internet_protocol_SSH_adv_zone", type:"boolean", controlname:"cbIntProtSet_SSH_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[292] = {fieldname:"internet_protocol_SSH_adv_auto", type:"boolean", controlname:"cbIntProtSet_SSH_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[293] = {fieldname: "", type:"boolean", controlname:"", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: ""};            
            GInternetProtocolSetRegistryList[294] = {fieldname:"internet_protocol_SSH_adv_list", type:"decimal", controlname:"inptIntProtSet_SSH_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "SSH"};
            GInternetProtocolSetRegistryList[295] = {fieldname:"internet_protocol_SSH_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_SSH_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "SSH"};
            GInternetProtocolSetRegistryList[296] = {fieldname:"internet_protocol_SSH_adv_timeout", type:"decimal", controlname:"inptIntProtSet_SSH_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "SSH"};
            GInternetProtocolSetRegistryList[297] = {fieldname:"internet_protocol_SSH_adv_retries", type:"decimal", controlname:"inptIntProtSet_SSH_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "SSH"};
            GInternetProtocolSetRegistryList[298] = {fieldname:"internet_protocol_SSH_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_SSH_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "SSH"};
            GInternetProtocolSetRegistryList[299] = {fieldname:"internet_protocol_SSH_proxy_proxy_type", type:"number", controlname:"comboIntProtSet_SSH_proxy_proxy_type", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "SSH"};             
            GInternetProtocolSetRegistryList[300] = {fieldname:"internet_protocol_SSH_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_SSH_proxy_proxy_host", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[301] = {fieldname:"internet_protocol_SSH_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_SSH_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "SSH"};
            GInternetProtocolSetRegistryList[302] = {fieldname:"internet_protocol_SSH_proxy_user_id", type:"string", controlname:"inptIntProtSet_SSH_proxy_user_id", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[303] = {fieldname:"internet_protocol_SSH_proxy_password", type:"string", controlname:"inptIntProtSet_SSH_proxy_password", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[304] = {fieldname:"internet_protocol_SSH_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_SSH_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[305] = {fieldname:"internet_protocol_SSH_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_SSH_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};                                       
            GInternetProtocolSetRegistryList[306] = {fieldname:"internet_protocol_SSH_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_SSH_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[307] = {fieldname:"internet_protocol_SSH_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_SSH_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[310] = {fieldname:"internet_protocol_SSH_security_CertificateComboIndex", type:"number", controlname:"comboIntProtSet_SSH_security_Certificate", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[311] = {fieldname:"internet_protocol_SSH_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_SSH_security_CertificatePassword", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[312] = {fieldname:"internet_protocol_SSH_security_nopassword", type:"boolean", controlname:"cbIntProtSet_SSH_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "SSH"};            
            GInternetProtocolSetRegistryList[313] = {fieldname:"internet_protocol_SSH_certificates_certificates", type:"string", controlname:"inptIntProtSet_SSH_certificates_certificates", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[314] = {fieldname:"internet_protocol_SSH_certificates_certname_forreference", type:"string", controlname:"inptIntProtSet_SSH_certificates_certname_forreference", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[315] = {fieldname:"internet_protocol_SSH_certificates_private_keyfile", type:"string", controlname:"inptIntProtSet_SSH_certificates_private_keyfile", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            GInternetProtocolSetRegistryList[316] = {fieldname:"internet_protocol_SSH_certificates_public_keyfile", type:"string", controlname:"inptIntProtSet_SSH_certificates_public_keyfile", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "SSH"}; 
            

                                                                                                                                  
                                                                                                                              
            GInternetProtocolSetRegistryList[317] = {fieldname:"internet_protocol_Glacier_Vault", type:"string", controlname:"inptIntProtSet_Glacier_Vault", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[318] = {fieldname:"internet_protocol_Glacier_RegionComboIndex", type:"number", controlname:"comboIntProtSet_Glacier_Region", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[319] = {fieldname:"internet_protocol_Glacier_InternetFolder", type:"string", controlname:"inptInternetFolder", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[320] = {fieldname:"internet_protocol_Glacier_AccountOpt", type:"string", controlname:"inptAccountOpt", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Glacier"}; 


            GInternetProtocolSetRegistryList[321] = {fieldname:"internet_protocol_Glacier_save_access_id", type:"boolean", controlname:"cbIntProtSet_Glacier_save_access_id", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            GInternetProtocolSetRegistryList[322] = {fieldname:"internet_protocol_Glacier_save_password", type:"boolean", controlname:"cbIntProtSet_Glacier_save_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            GInternetProtocolSetRegistryList[323] = {fieldname:"internet_protocol_Glacier_allow_ipv6", type:"boolean", controlname:"cbIntProtSet_Glacier_allow_ipv6", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            GInternetProtocolSetRegistryList[324] = {fieldname:"internet_protocol_Glacier_filename_encoding", type:"boolean", controlname:"cbIntProtSet_Glacier_filename_encoding", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            
            
            
            GInternetProtocolSetRegistryList[325] = {fieldname:"internet_protocol_Glacier_adv_CharsetComboIndex", type:"number", controlname:"comboIntProtSet_Glacier_adv_Charset", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[326] = {fieldname:"internet_protocol_Glacier_adv_replace_characters", type:"boolean", controlname:"cbIntProtSet_Glacier_adv_replace_characters", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            GInternetProtocolSetRegistryList[327] = {fieldname:"internet_protocol_Glacier_recursive_listing", type:"boolean", controlname:"cbIntProtSet_Glacier_recursive_listing", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            GInternetProtocolSetRegistryList[328] = {fieldname:"internet_protocol_Glacier_adv_zone", type:"boolean", controlname:"cbIntProtSet_Glacier_adv_zone", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            GInternetProtocolSetRegistryList[329] = {fieldname:"internet_protocol_Glacier_adv_auto", type:"boolean", controlname:"cbIntProtSet_Glacier_adv_auto", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};            
            GInternetProtocolSetRegistryList[330] = {fieldname:"internet_protocol_Glacier_adv_list", type:"decimal", controlname:"inptIntProtSet_Glacier_adv_list", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Glacier"};
            GInternetProtocolSetRegistryList[331] = {fieldname:"internet_protocol_Glacier_adv_upload_min", type:"decimal", controlname:"inptIntProtSet_Glacier_adv_upload_min", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Glacier"};
            GInternetProtocolSetRegistryList[332] = {fieldname:"internet_protocol_Glacier_adv_timeout", type:"decimal", controlname:"inptIntProtSet_Glacier_adv_timeout", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Glacier"};
            GInternetProtocolSetRegistryList[333] = {fieldname:"internet_protocol_Glacier_adv_retries", type:"decimal", controlname:"inptIntProtSet_Glacier_adv_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Glacier"};
            GInternetProtocolSetRegistryList[334] = {fieldname:"internet_protocol_Glacier_adv_http_retries", type:"decimal", controlname:"inptIntProtSet_Glacier_adv_http_retries", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Glacier"};
            GInternetProtocolSetRegistryList[335] = {fieldname:"internet_protocol_Glacier_proxy_proxy_typeComboIndex", type:"number", controlname:"comboIntProtSet_Glacier_proxy_proxy_type", controltype:"jqxComboBox", default: "0", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[336] = {fieldname:"internet_protocol_Glacier_proxy_proxy_host", type:"string", controlname:"inptIntProtSet_Glacier_proxy_proxy_host", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[337] = {fieldname:"internet_protocol_Glacier_proxy_proxy_port", type:"decimal", controlname:"inptIntProtSet_Glacier_proxy_proxy_port", controltype:"jqxFormattedInput", default: "0", value: null, ControlAppGroup: "Glacier"};
            GInternetProtocolSetRegistryList[338] = {fieldname:"internet_protocol_Glacier_proxy_login", type:"string", controlname:"inptIntProtSet_Glacier_proxy_login", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[339] = {fieldname:"internet_protocol_Glacier_proxy_password", type:"string", controlname:"inptIntProtSet_Glacier_proxy_password", controltype:"jqxPasswordInput", default: "", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[340] = {fieldname:"internet_protocol_Glacier_proxy_send_host_command", type:"boolean", controlname:"cbIntProtSet_Glacier_proxy_send_host_command", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};                                    
            GInternetProtocolSetRegistryList[341] = {fieldname:"IntProtSet_Glacier_Security_Mode_Group", type:"string", controlname:"", controltype:"ButtonGroup", default: "rbIntProtSet_Glacier_Security_None", value: null, ControlAppGroup: "Glacier",
            getfunc: function()
            {
                return GetCheckedRadiobuttonName( $("#rbIntProtSet_Glacier_Security_None"), $("#rbIntProtSet_Glacier_Security_TLS"), null, null, null, null ); 
            }, setfunc: function( option )
            {
                  SetRadioGroupChecked( option, $("#rbIntProtSet_Glacier_Security_None"), $("#rbIntProtSet_Glacier_Security_TLS"), null, null, null, null ); 
            }}; 

            GInternetProtocolSetRegistryList[342] = {fieldname:"internet_protocol_Glacier_Security_SSH_username_password", type:"boolean", controlname:"cbIntProtSet_Glacier_Security_SSH_username_password", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};                                    
            GInternetProtocolSetRegistryList[343] = {fieldname:"internet_protocol_Glacier_Security_SSH_keyboard", type:"boolean", controlname:"cbIntProtSet_Glacier_Security_SSH_keyboard", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};                                    
            GInternetProtocolSetRegistryList[344] = {fieldname:"internet_protocol_Glacier_Security_SSH_certificate", type:"boolean", controlname:"cbIntProtSet_Glacier_Security_SSH_certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};                                    
            GInternetProtocolSetRegistryList[345] = {fieldname:"internet_protocol_Glacier_security_Certificate", type:"boolean", controlname:"comboIntProtSet_Glacier_security_Certificate", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};                                    
            GInternetProtocolSetRegistryList[346] = {fieldname:"internet_protocol_Glacier_security_CertificatePassword", type:"string", controlname:"inptIntProtSet_Glacier_security_CertificatePassword", controltype:"jqxInput", default: "", value: null, ControlAppGroup: "Glacier"}; 
            GInternetProtocolSetRegistryList[347] = {fieldname:"internet_protocol_Glacier_security_nopassword", type:"boolean", controlname:"cbIntProtSet_Glacier_security_nopassword", controltype:"jqxCheckBox", default: "false", value: null, ControlAppGroup: "Glacier"};                                    
             
             /// next id is 351!!!!        
                    
                    
                    
                    
                    
                    


/*
function LoadRecordToControls( record, RegistryList )
{
       try
       {

            for (index = 0; index < RegistryList.length; index++) 
            {
                var RegistryItem = RegistryList[index];
                if( RegistryItem.controltype == "jqxCheckBox" )
                {
                   
                   var Rec = "";
                   if( record != null )
                   {
                      var Val = false;
                      if( record[ RegistryItem.fieldname ] == "" )
                         Val = false
                      else
                         Val = record[ RegistryItem.fieldname ];
                   }
                   else
                   {
                      Val = RegistryItem.default;

                   }
                   
                   $("#" + RegistryItem.controlname).jqxCheckBox( 'val', Val );
                   
                }
                else  if( RegistryItem.controltype == "jqxInput" )
                {   
                   
                   $("#" + RegistryItem.controlname).jqxInput({ width : RegistryItem.width, height : RegistryItem.height });                  
                   if( record != null )                                  
                      $("#" + RegistryItem.controlname).jqxInput('val', record[ RegistryItem.fieldname ]);
                   else   
                    $("#" + RegistryItem.controlname).val( RegistryItem.default);
                    
                }
                else  if( RegistryItem.controltype == "jqxPasswordInput" )
                {   
                   
                   if( record != null )                                  
                      $("#" + RegistryItem.controlname).jqxPasswordInput('val', record[ RegistryItem.fieldname ]);
                   else   
                    $("#" + RegistryItem.controlname).val( RegistryItem.default);
                    
                }
                
                else if( RegistryItem.controltype == "jqxDateTimeInput" )
                {
                   if( record != null )
                   {
                      var ValDate = new Date();
                      ValDate = record[ RegistryItem.fieldname ]; 
                      $("#" + RegistryItem.controlname).jqxDateTimeInput('setDate', ValDate );
                   }   
                   
                }
                else  if( RegistryItem.controltype == "jqxNumberInput" )         
                {
                   $("#" + RegistryItem.controlname).jqxNumberInput({ width : RegistryItem.width, height : RegistryItem.height, inputMode: 'simple' });
                   if( record != null )                   
                      $("#" + RegistryItem.controlname).jqxNumberInput('val', record[ RegistryItem.fieldname ] );
                   else
                     $("#" + RegistryItem.controlname).val( RegistryItem.default);
                }   
                else  if( RegistryItem.controltype == "jqxFormattedInput" )
                {
                   if( record != null )                   
                      $("#" + RegistryItem.controlname).val( record[ RegistryItem.fieldname ]);
                   else   
                    $("#" + RegistryItem.controlname).val( RegistryItem.default);
                }   
                else if( RegistryItem.controltype == "ButtonGroup" )
                {
                   RegistryItem.setfunc( RegistryItem.default );                    
                   if( record != null )                   
                     RegistryItem.setfunc( record[ RegistryItem.fieldname ] );                                                              
                }
                else if( RegistryItem.controltype == "variable" )
                {
                   if( record != null )
                   {                  
                      this[RegistryItem.controlname] =  record[ RegistryItem.fieldname ];
                      if( ( RegistryItem.type == 'decimal' ) && ( this[RegistryItem.controlname] == '' ) )
                        this[RegistryItem.controlname] = 0; 
                   }   
                }  
                else if( RegistryItem.controltype == "jqxComboBox" )
                {
                   if( record != null )
                   {
                      $("#" + RegistryItem.controlname).jqxComboBox( {selectedIndex: record[ RegistryItem.fieldname ] } );
                   }
                };

                              
                 $('#LastRun').html('test');     
            };

      }
      catch(err) 
      {
          document.getElementById("error_message").innerHTML = err.message;
      }

}
*/           