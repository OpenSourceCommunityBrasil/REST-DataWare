            var MainFormHTML = "<input type=\"button\" value=\"Test\" id=\"Test_btn\" />"+
            "<input type=\"button\" value=\"Test\" id=\"Test_btn1\" />"+
    "<div id=\"jqxgrid\"> </div>"; 




// prepare the data
              var GridSource =
              {
                  datatype: "xml",
                  datafields: [
                      { name: 'Name', type: 'string' },
                      { name: 'LPath', map: 'LPath', type: 'string' },  
                      { name: 'RPath', map: 'RPath', type: 'string' },
                      { name: 'Progress', type: 'string' } ],
                        addrow: function (rowid, rowdata, position, commit) {
                        // synchronize with the server - send insert command
                        // call commit with parameter true if the synchronization with the server is successful 
                        //and with parameter false if the synchronization failed.
                        // you can pass additional argument to the commit callback which represents the new ID if it is generated from a DB.
                          commit(true);
                        },

                        deleterow: function (rowid, commit) 
                        {
                          // synchronize with the server - send delete command
                          // call commit with parameter true if the synchronization with the server is successful 
                          //and with parameter false if the synchronization failed.

                          $.post( "post_deleteprofile.php", { ProfileName : rowid } ).done(function( data ) 
                          {
                             if( data == 'OK' )
                             {  
                                commit(true);
                             }  
                          }); 


                        },
                  root: "Profiles",
                  record: "Profile",
                  id: 'Name',
                  url: "profiles.xml"
              };


       
            var GridDataAdapter = new $.jqx.dataAdapter( GridSource, 
            {
                downloadComplete: function (data, status, xhr) { },
                loadComplete: function (data) { },
                loadError: function (xhr, status, error) { alert(error);  }
            });




      

              var ProfileSource =
              {                  
                  datafields: [
                      { name: 'Name', type: 'string' },
                      { name: 'LPath', map: 'LPath', type: 'string' },  
                      { name: 'RPath', map: 'RPath', type: 'string' },
                      { name: 'Progress', type: 'string' },

                      { name: 'LTR', map: 'LTR', type: 'boolean' },  
                      { name: 'RTL', map: 'RTL', type: 'boolean' },  
                      { name: 'RightFTPSettings', map : 'Internet>RightFTPSettings' },  
                      { name: 'IncludeSubfoldersWidget', map: 'IncludeSubfoldersWidget', type: 'string' },  
                      { name: 'SyncOperationModeWidget', map: 'SyncOperationModeWidget', type: 'string' },  


            
            

                      
                      { name: 'LeftProtocolName', type: 'string' },
                      { name: 'RightProtocolName', type: 'string' },
                      
                       
                       
                       
                      

                                              //Tab Shedule/Shedule

                      { name: 'SheduleThisProfile', map: 'SheduleThisProfile', type: 'boolean' },

                      { name: 'SpecifyNextRun', map: 'SpecifyNextRun', type: 'boolean' },

                      { name: 'IntervalSpecification', map: 'IntervalSpecification', type: 'boolean' },

                      { name: 'RunModeRadiogroupWidget', map: 'RunModeRadiogroupWidget' },

            
                      { name: 'Run_Every_Day_Time_Input', map: 'Run_Every_Day_Time_Input', type: 'date' },
                      { name: 'ScheduleDays', map: 'ScheduleDays', type: 'number' },
                      { name: 'ScheduleHours', map: 'ScheduleHours', type: 'number' },
                      { name: 'ScheduleMinutes', map: 'ScheduleMinutes', type: 'number' },
                      { name: 'ScheduleSec', map: 'ScheduleSec', type: 'number' },
                      
           //Tab Shedule/More

                      { name: 'SheduleRunUponWinLogin', map: 'SheduleRunUponWinLogin', type: 'boolean' },

                      { name: 'SheduleRunUponShutdownAndLogOut', map: 'SheduleRunUponShutdownAndLogOut', type: 'boolean' },

                      { name: 'SheduleRunMissedDaylyJob', map: 'SheduleRunMissedDaylyJob', type: 'boolean' },

                      { name: 'SheduleAddRandomDelayUpTo', map: 'SheduleAddRandomDelayUpTo', type: 'boolean' },

                      { name: 'SheduleWarnIfProfileNotRunFor', map: 'SheduleWarnIfProfileNotRunFor', type: 'boolean' },

                      { name: 'AddRandomDelay_Time_Input', map: 'AddRandomDelay_Time_Input', type: 'number' },

                      { name: 'WarnIfProfileNotRunFor_Time_Input', map: 'WarnIfProfileNotRunFor_Time_Input', type: 'number' },



          // Tab Shedule/Weekdays

                      { name: 'Monday', map: 'Monday', type: 'boolean' },

                      { name: 'Tuesday', map: 'Tuesday', type: 'boolean' },

                      { name: 'Wednesday', map: 'Wednesday', type: 'boolean' },
                      { name: 'Thursday', map: 'Thursday', type: 'boolean' },
                      { name: 'Friday', map: 'Friday', type: 'boolean' },
                      { name: 'Saturday', map: 'Saturday', type: 'boolean' },
                      { name: 'Sunday', map: 'Sunday', type: 'boolean' },
                  

                    //Tab Shedule Monitoring/Realtime

                      { name: 'RealTimeSynchronization', map: 'RealTimeSynchronization', type: 'boolean' },
                      { name: 'RealContinuousSync', map: 'RealContinuousSync', type: 'boolean' },
                      { name: 'RealProfileAsSoonAsDriveAvailable', map: 'RealProfileAsSoonAsDriveAvailable', type: 'boolean' },
                    
                    

                                //Tab AccessAndRetries/File Access
                                
                        { name: 'VolumeShadowingRadiogroupWidget', map: 'VolumeShadowingRadiogroupWidget' },


                        { name: 'FADatabaseSafeCopy', map: 'FADatabaseSafeCopy', type: 'boolean' },
                        { name: 'FATakeAdminOwnership', map: 'FATakeAdminOwnership', type: 'boolean' },
                        { name: 'FATakeAdminOwnership', map: 'FATakeAdminOwnership', type: 'boolean' },
                        { name: 'FAVerifyOpeningPriorCopy', map: 'FAVerifyOpeningPriorCopy', type: 'boolean' },
                                                        

                                //Tab AccessAndRetries/Wait and Retry
                        { name: 'WRWaitForFileAccess', map: 'WRWaitForFileAccess', type: 'boolean' },
                        { name: 'WRWaitIfTransferProblem', map: 'WRWaitIfTransferProblem', type: 'boolean' },
                        { name: 'WRBuildingFileList', map: 'WRBuildingFileList', type: 'boolean' },
                        { name: 'WRRunningTheProfile', map: 'WRRunningTheProfile', type: 'boolean' },


                      { name: 'WRWaitUpToMin', map: 'WRWaitUpToMin', type: 'number' },
                                
                               


                      { name: 'WRReRunRadiogroupWidget', map: 'WRReRunRadiogroupWidget' },

                      { name: 'WRMaxReRuns', map: 'WRMaxReRuns', type: 'number' },
                      { name: 'WRRetryAfter', map: 'WRRetryAfter', type: 'number' },
                      { name: 'WRAvoidRerunDueToLocked', map: 'WRAvoidRerunDueToLocked', type: 'boolean' },

                                //Tab Comparison Comparison
                      { name: 'ComparIgnoreSmallTimeDiff', map: 'ComparIgnoreSmallTimeDiff', type: 'boolean' },
                      { name: 'ComparIgnoreExactHourTimeDiff', map: 'ComparIgnoreExactHourTimeDiff', type: 'boolean' },

                      { name: 'ComparIgnoreSec', map: 'ComparIgnoreSec', type: 'number' },
                      { name: 'ComparIgnoreHours', map: 'ComparIgnoreHours', type: 'number' },

                      { name: 'ComparIgnoreSeconds', map: 'ComparIgnoreSeconds', type: 'boolean' },
                      { name: 'ComparIgnoreTimestampAlltogether', map: 'ComparIgnoreTimestampAlltogether', type: 'boolean' },

                                

                      { name: 'ComparWhenSizeIsDiffentRadiogroupWidget', map: 'ComparWhenSizeIsDiffentRadiogroupWidget' },

                                //Tab Comparison More

                      { name: 'ComparMoreAlwaysCopyFiles', map: 'ComparMoreAlwaysCopyFiles', type: 'boolean' },
                      { name: 'ComparMoreBinaryComparison', map: 'ComparMoreBinaryComparison', type: 'boolean' },
                      { name: 'ComparMoreBinaryLeftSide', map: 'ComparMoreBinaryLeftSide', type: 'boolean' },
                      { name: 'ComparMoreBinaryRightSide', map: 'ComparMoreBinaryRightSide', type: 'boolean' },

                      { name: 'ComparMoreFileAttributeComparison', map: 'ComparMoreFileAttributeComparison', type: 'boolean' },
                      { name: 'ComparMoreCaseSencivity', map: 'ComparMoreCaseSencivity', type: 'boolean' },
                      { name: 'ComparMoreVerifySyncStatistics', map: 'ComparMoreVerifySyncStatistics', type: 'boolean' },
                      { name: 'ComparMoreFolderAttributeComparison', map: 'ComparMoreFolderAttributeComparison', type: 'boolean' },
                      { name: 'ComparMoreFolderTimestampComparison', map: 'ComparMoreFolderTimestampComparison', type: 'boolean' },
                      { name: 'ComparMoreDetectHardLinks', map: 'ComparMoreDetectHardLinks', type: 'boolean' },
                      { name: 'ComparMoreEnforceHardLinks', map: 'ComparMoreEnforceHardLinks', type: 'boolean' },
                                                       
                                //Tab Files Files
                      { name: 'FilesDetectMovedFiles', map: 'FilesDetectMovedFiles', type: 'boolean' },
                                
                      { name: 'FilesDetectMovedFilesRadiogroupWidget', map: 'FilesDetectMovedFilesRadiogroupWidget' },


                      { name: 'FilesDetectRenamedFiles', map: 'FilesDetectRenamedFiles', type: 'boolean' },
                      { name: 'FilesVerifyCopiedFiles', map: 'FilesVerifyCopiedFiles', type: 'boolean' },
                      { name: 'FilesReCopyOnce', map: 'FilesReCopyOnce', type: 'boolean' },
                      { name: 'FilesAutomaticallyResume', map: 'FilesAutomaticallyResume', type: 'boolean' },
                      { name: 'FilesProtectFromBeingReplaced', map: 'FilesProtectFromBeingReplaced', type: 'boolean' },
                      { name: 'FilesDoNotScanDestination', map: 'FilesDoNotScanDestination', type: 'boolean' },
                      { name: 'FilesBypassFilesBuffering', map: 'FilesBypassFilesBuffering', type: 'boolean' },

                      { name: 'FilesNumberToCopyInparallel', map: 'FilesNumberToCopyInparallel', type: 'number' },


                                                                    
                                //Tab Files Deletions
                      { name: 'FilesDeletions_OverritenFiles', map: 'FilesDeletions_OverritenFiles', type: 'boolean' },
                      { name: 'FilesDeletions_DeletedFiles', map: 'FilesDeletions_DeletedFiles', type: 'boolean' },
                      { name: 'FilesDeletions_MoveFilesToSFolder', map: 'FilesDeletions_MoveFilesToSFolder', type: 'boolean' },
                      { name: 'FilesDeletions_DeleteOlderVersionsPermamently', map: 'FilesDeletions_DeleteOlderVersionsPermamently', type: 'boolean' },
                      { name: 'FilesDeletions_DoubleCheckNonExistence', map: 'FilesDeletions_DoubleCheckNonExistence', type: 'boolean' },
                      { name: 'FilesDeletions_NeverDelete', map: 'FilesDeletions_NeverDelete', type: 'boolean' },
                      { name: 'FilesDeletions_DeleteBeforeCopying', map: 'FilesDeletions_DeleteBeforeCopying', type: 'boolean' },


                                //Tab Files More
                      { name: 'FilesMore_UseWindowsApi', map: 'FilesMore_UseWindowsApi', type: 'boolean' },
                      { name: 'FilesMore_UseSpeedLimit', map: 'FilesMore_UseSpeedLimit', type: 'boolean' },

                      { name: 'FilesMore_SpeedLimit', map: 'FilesMore_SpeedLimit', type: 'float' },
                          
                                
                      { name: 'FilesMore_NeverReplace', map: 'FilesMore_NeverReplace', type: 'boolean' },
                      { name: 'FilesMore_AlwaysAppend', map: 'FilesMore_AlwaysAppend', type: 'boolean' },
                      { name: 'FilesMore_AlwaysConsider', map: 'FilesMore_AlwaysConsider', type: 'boolean' },
                      { name: 'FilesMore_CheckDestinationFile', map: 'FilesMore_CheckDestinationFile', type: 'boolean' },
                      { name: 'FilesMore_AndCompareFileDetails', map: 'FilesMore_AndCompareFileDetails', type: 'boolean' },
                      { name: 'FilesMore_CopiedFilesSysTime', map: 'FilesMore_CopiedFilesSysTime', type: 'boolean' },
                      { name: 'FilesMore_PreserveLastAccessOnSource', map: 'FilesMore_PreserveLastAccessOnSource', type: 'boolean' },
                      { name: 'FilesMore_CopyOnlyFilesPerRun', map: 'FilesMore_CopyOnlyFilesPerRun', type: 'boolean' },
                                

                      { name: 'FilesMore_FilesPerRun', map: 'FilesMore_FilesPerRun', type: 'decimal' },

                      { name: 'FilesMore_IgnoreGlobalSpeedLimit', map: 'FilesMore_IgnoreGlobalSpeedLimit', type: 'boolean' },
                      { name: 'FilesMore_DontAddAnyFiles', map: 'FilesMore_DontAddAnyFiles', type: 'boolean' },
                                 
                                //Tab Folders
                      { name: 'Folders_CreateEmptyFolders', map: 'Folders_CreateEmptyFolders', type: 'boolean' },
                      { name: 'Folders_RemoveEmptiedFolders', map: 'Folders_RemoveEmptiedFolders', type: 'boolean' },
                      { name: 'Folders_OnRightSideCreateFolderEachTime', map: 'Folders_OnRightSideCreateFolderEachTime', type: 'boolean' },
                      { name: 'Folders_IncludeTimeOfDay', map: 'Folders_IncludeTimeOfDay', type: 'boolean' },
                      { name: 'Folders_FlatRightSide', map: 'Folders_FlatRightSide', type: 'boolean' },
                      { name: 'Folders_CopyLatestFileIfExists', map: 'Folders_CopyLatestFileIfExists', type: 'boolean' },
                      { name: 'Folders_EnsureFolderTimestamps', map: 'Folders_EnsureFolderTimestamps', type: 'boolean' },
                      { name: 'Folders_UseIntermediateLocation', map: 'Folders_UseIntermediateLocation', type: 'boolean' },

                                    
                                //Tab Job

                      { name: 'Job_ExecuteCommand', map: 'Job_ExecuteCommand', type: 'boolean' },
                      { name: 'Job_OverrideEmailSettings', map: 'Job_OverrideEmailSettings', type: 'boolean' },
                      { name: 'Job_RunAsUser', map: 'Job_RunAsUser', type: 'boolean' },
                      { name: 'Job_NetworkConnections', map: 'Job_NetworkConnections', type: 'boolean' },
                      { name: 'Job_VerifyRightSideVolume', map: 'Job_VerifyRightSideVolume', type: 'boolean' },
                      { name: 'Job_UseExternalCopyingTool', map: 'Job_UseExternalCopyingTool', type: 'boolean' },
                      { name: 'Job_ShowCheckboxesInPreview', map: 'Job_ShowCheckboxesInPreview', type: 'boolean' },
                      { name: 'Job_CheckFreeSpaceBeforeCopying', map: 'Job_CheckFreeSpaceBeforeCopying', type: 'boolean' },
                      { name: 'Job_IgnoreInternetConnectivityCheck', map: 'Job_IgnoreInternetConnectivityCheck', type: 'boolean' },
                      { name: 'Job_WhenRunViaSheduler', map: 'Job_WhenRunViaSheduler', type: 'boolean' },
                      { name: 'Job_WhenRunManuallyUnattended', map: 'Job_WhenRunManuallyUnattended', type: 'boolean' },
                      { name: 'Job_WhenRunManuallyAttended', map: 'Job_WhenRunManuallyAttended', type: 'boolean' },

                                            
                                  
                                //Tab  Safety
                      { name: 'Safety_WarnIfMovingFiles', map: 'Safety_WarnIfMovingFiles', type: 'boolean' },
                      { name: 'Safety_WarnBeforeOverridingReadOnly', map: 'Safety_WarnBeforeOverridingReadOnly', type: 'boolean' },
                      { name: 'Safety_WarnBeforeOverridingLarger', map: 'Safety_WarnBeforeOverridingLarger', type: 'boolean' },
                      { name: 'Safety_WarnBeforeOverridingNewer', map: 'Safety_WarnBeforeOverridingNewer', type: 'boolean' },
                      { name: 'Safety_WarnBeforeDeleting', map: 'Safety_WarnBeforeDeleting', type: 'boolean' },

                                                  
                                //Tab Safety Special 
                      { name: 'SafetySpecial_WarnIfDeletingFilesMoreThan', map: 'SafetySpecial_WarnIfDeletingFilesMoreThan', type: 'boolean' },        
                      { name: 'SafetySpecial_WarnIfDeletingAllFilesInAnySubfolder', map: 'SafetySpecial_WarnIfDeletingAllFilesInAnySubfolder', type: 'boolean' },
                      { name: 'SafetySpecial_WarnIfDeletingMoreThanInAnySubfolder', map: 'SafetySpecial_WarnIfDeletingMoreThanInAnySubfolder', type: 'boolean' },

                      { name: 'SafetySpecial_WarnIfDeletingFilesMoreThanVal', map: 'SafetySpecial_WarnIfDeletingFilesMoreThanVal', type: 'boolean' },        
                      { name: 'SafetySpecial_WarnIfDeletingMoreThanInAnySubfolderVal', map: 'SafetySpecial_WarnIfDeletingMoreThanInAnySubfolderVal', type: 'boolean' },
                                


                                 //Tab Safety Unattended Mode  

                      { name: 'SafetyUnattended_OvewriteReadOnly', map: 'SafetyUnattended_OvewriteReadOnly', type: 'boolean' },
                      { name: 'SafetyUnattended_OvewriteLarge', map: 'SafetyUnattended_OvewriteLarge', type: 'boolean' },
                      { name: 'SafetyUnattended_NewerFilesCanBeOvewriten', map: 'SafetyUnattended_NewerFilesCanBeOvewriten', type: 'boolean' },
                      { name: 'SafetyUnattended_FileDeletionAllowed', map: 'SafetyUnattended_FileDeletionAllowed', type: 'boolean' },
                      { name: 'SafetyUnattended_EnableSpecialSafetyCheck', map: 'SafetyUnattended_EnableSpecialSafetyCheck', type: 'boolean' },
                                                  
                                                  
                      { name: 'SafetyUnattended_FileDeletionAllowed', map: 'SafetyUnattended_FileDeletionAllowed', type: 'number' },

                                           

                                             //Tab Special SpecialFeatures
                      { name: 'SpecialSpFeatr_CacheDestinationFileList', map: 'SpecialSpFeatr_CacheDestinationFileList', type: 'boolean' },
                      { name: 'SpecialSpFeatr_ProcessSecurity', map: 'SpecialSpFeatr_ProcessSecurity', type: 'boolean' },
                      { name: 'SpecialSpFeatr_UseParcialFileUpdating', map: 'SpecialSpFeatr_UseParcialFileUpdating', type: 'boolean' },
                      { name: 'SpecialSpFeatr_RightSideRemoteService', map: 'SpecialSpFeatr_RightSideRemoteService', type: 'boolean' },
                      { name: 'SpecialSpFeatr_FastMode', map: 'SpecialSpFeatr_FastMode', type: 'boolean' },
                      { name: 'SpecialSpFeatr_UseCacheDatabaseForSource', map: 'SpecialSpFeatr_UseCacheDatabaseForSource', type: 'boolean' },
                      { name: 'SpecialSpFeatr_LeftSideUsesRemoteService', map: 'SpecialSpFeatr_LeftSideUsesRemoteService', type: 'boolean' },
                      { name: 'SpecialSpFeatr_RightSideUsesRemoteService', map: 'SpecialSpFeatr_RightSideUsesRemoteService', type: 'boolean' },
                      { name: 'SpecialSpFeatr_UseDifferentFolders', map: 'SpecialSpFeatr_UseDifferentFolders', type: 'boolean' },
                      { name: 'SpecialSpFeatr_IfDestinationMachineModifiers', map: 'SpecialSpFeatr_IfDestinationMachineModifiers', type: 'boolean' },
                      { name: 'SpecialSpFeatr_SetTargetVolumeLabel', map: 'SpecialSpFeatr_SetTargetVolumeLabel' },


                                //Tab Special Database

                      { name: 'SpDb_OpenDatabaseReadOnly', map: 'SpDb_OpenDatabaseReadOnly', type: 'boolean' },
                      { name: 'SpecialDatabase_FastMode', map: 'SpecialDatabase_FastMode', type: 'boolean' },
                      { name: 'SpecialDatabase_DatabaseNameToUse', map: 'SpecialDatabase_DatabaseNameToUse' },
                      { name: 'SpecialDatabase_Left', map: 'SpecialDatabase_Left', type: 'string' },
                      { name: 'SpecialDatabase_Right', map: 'SpecialDatabase_Right', type: 'string' },







                                 //Tab Vesioning Versioning
                      { name: 'VersVers_KeepOlderVersionsWhenReplacing', map: 'VersVers_KeepOlderVersionsWhenReplacing', type: 'boolean' },

                      { name: 'VersVers_PerFile', map: 'VersVers_PerFile', type: 'number' },
                      //internet settings dlg
                      { name: 'LeftAccountOpt', map: 'LeftAccountOpt', type: 'string' },
                      { name: 'RightAccountOpt', map: 'RightAccountOpt', type: 'string' },

                      //Tab Masks and Filters
                      { name: 'Masks_InclusionMasks', map: 'Masks_InclusionMasks', type: 'string' },
                      { name: 'Masks_ExclusionMasks', map: 'Masks_ExclusionMasks', type: 'string' },
                      { name: 'Masks_SpecFolderMasks', map: 'Masks_SpecFolderMasks', type: 'boolean' },
                      { name: 'Masks_Restrictions', map: 'Masks_Restrictions', type: 'boolean' },
                      { name: 'Masks_IncludeBackupFiles', map: 'Masks_IncludeBackupFiles', type: 'boolean' },
                      { name: 'Masks_UseGlobalExclAlso', map: 'Masks_UseGlobalExclAlso', type: 'boolean' },
                      { name: 'ExclucionFilesWidget', map: 'ExclucionFilesWidget', type: 'string' },

                      { name: 'Masks_ProcessHiddenFiles', map: 'Masks_ProcessHiddenFiles', type: 'boolean' },
                      { name: 'Masks_SearchHiddenFolders', map: 'Masks_SearchHiddenFolders', type: 'boolean' },
                      { name: 'Masks_ProcessReparcePoints', map: 'Masks_ProcessReparcePoints', type: 'boolean' },
                      { name: 'Masks_FollowJunctionPointsFiles', map: 'Masks_FollowJunctionPointsFiles', type: 'boolean' },
                      { name: 'Masks_FollowJunctionPointsFolders', map: 'Masks_FollowJunctionPointsFolders', type: 'boolean' },
                      { name: 'Masks_CopyOtherReparcePoints', map: 'Masks_CopyOtherReparcePoints', type: 'boolean' },
                      { name: 'Masks_CopyFilesWithArchiveFlag', map: 'Masks_CopyFilesWithArchiveFlag', type: 'boolean' },
                      { name: 'Masks_FileSizesWithin', map: 'Masks_FileSizesWithin', type: 'boolean' },
                      { name: 'Masks_FileSizesMin', map: 'Masks_FileSizesMin', type: 'string' },
                      { name: 'Masks_FileSizesMax', map: 'Masks_FileSizesMax', type: 'string' },
                      { name: 'Masks_FileDatesWithin', map: 'Masks_FileDatesWithin', type: 'boolean' },
                      { name: 'Masks_FileMinDate', map: 'Masks_FileMinDate', type: 'string' },
                      { name: 'Masks_FileMaxDate', map: 'Masks_FileMaxDate', type: 'string' },
                      { name: 'Masks_FileAge', map: 'Masks_FileAge', type: 'boolean' },
                      { name: 'Masks_FileAgeComboIndex', map: 'Masks_FileAgeComboIndex', type: 'number' },
                      { name: 'Masks_FileAgeDays', map: 'Masks_FileAgeDays', type: 'number' },
                      { name: 'Masks_FileAgeHours', map: 'Masks_FileAgeHours', type: 'number' },
                      { name: 'Masks_FileAgeMinutes', map: 'Masks_FileAgeMinutes', type: 'number' },
                      { name: 'Masks_FileAgeSec', map: 'Masks_FileAgeSec', type: 'number' },
                      { name: 'Masks_FilterByWidget', map: 'Masks_FilterByWidget', type: 'string' },
                      { name: 'Masks_ApplyToWidget', map: 'Masks_ApplyToWidget', type: 'string' },
                      { name: 'Masks_TargetDataRestore', map: 'Masks_TargetDataRestore', type: 'boolean' },

                      { name: 'Masks_TargetDateRestoreDate', map: 'Masks_TargetDateRestoreDate', type: 'string' },
                      { name: 'Masks_TargetDateRestoreTime', map: 'Masks_TargetDateRestoreTime', type: 'string' },
                      { name: 'VersVers_MoveIntoFolderInpt', map: 'VersVers_MoveIntoFolderInpt', type: 'string' },
                      { name: 'VersVers_MoveIntoFolder', map: 'VersVers_MoveIntoFolder', type: 'boolean' },
                      { name: 'VersVers_OnlyOnRightHandSide', map: 'VersVers_OnlyOnRightHandSide', type: 'boolean' },
                      { name: 'VersVers_AsSubfolerInEachFolder', map: 'VersVers_AsSubfolerInEachFolder', type: 'boolean' },
                      { name: 'VersVers_RecreateTreeBelow', map: 'VersVers_RecreateTreeBelow', type: 'boolean' },
                      { name: 'VersVers_FileNameEncoding', map: 'VersVers_FileNameEncoding', type: 'boolean' },
                      { name: 'VersVers_DontRenameNewestOlderVersion', map: 'VersVers_DontRenameNewestOlderVersion', type: 'boolean' },
                      { name: 'VersVers_RenamingOlderVersions', map: 'VersVers_RenamingOlderVersions', type: 'string' },

                      { name: 'VersSynth_UseSynthBackups', map: 'VersSynth_UseSynthBackups', type: 'boolean' },
                      { name: 'VersSynth_UseCheckPoints', map: 'VersSynth_UseCheckPoints', type: 'boolean' },
                      { name: 'VersSynth_CreateCheckpointComboIndex', map: 'VersSynth_CreateCheckpointComboIndex', type: 'number' },
                      { name: 'VersSynth_CheckpointsRelativeComboIndex', map: 'VersSynth_CheckpointsRelativeComboIndex', type: 'number' },
                      { name: 'VersSynth_BuildAllIncremental', map: 'VersSynth_BuildAllIncremental', type: 'boolean' },
                      { name: 'VersSynth_RemoveUnneededCb', map: 'VersSynth_RemoveUnneededCb', type: 'boolean' },
                      { name: 'VersSynth_RemoveUnneeded', map: 'VersSynth_RemoveUnneeded', type: 'number' },
                      { name: 'VersSynth_RemoveUnneededComboIndex', map: 'VersSynth_RemoveUnneededComboIndex', type: 'number' },
                      { name: 'VersSynth_IfAllBlocksCb', map: 'VersSynth_IfAllBlocksCb', type: 'boolean' },

                      { name: 'VersMore_DoNotDecodeLeftHandCb', map: 'VersMore_DoNotDecodeLeftHandCb', type: 'boolean' },
                      { name: 'VersMore_DoNotDecodeRightHandCb', map: 'VersMore_DoNotDecodeRightHandCb', type: 'boolean' },
                      { name: 'VersMore_CleanUpIdenticalCb', map: 'VersMore_CleanUpIdenticalCb', type: 'boolean' },
                      { name: 'VersMore_RemoveParenthesizedCb', map: 'VersMore_RemoveParenthesizedCb', type: 'boolean' },
                      { name: 'VersMore_RemoveVesioningTagsCb', map: 'VersMore_RemoveVesioningTagsCb', type: 'boolean' },
                      { name: 'VersMore_CleanUpAllOlderVersionsCb', map: 'VersMore_CleanUpAllOlderVersionsCb', type: 'boolean' },
                      { name: 'VersMore_FilesBackupV4Cb', map: 'VersMore_FilesBackupV4Cb', type: 'boolean' },

                      { name: 'Zipping_LimitInpt', map: 'Zipping_LimitInpt', type: 'string' },
                      { name: 'Zipping_ZipEachFile', map: 'Zipping_ZipEachFile', type: 'boolean' },
                      { name: 'Zipping_USeZipPackages', map: 'Zipping_USeZipPackages', type: 'boolean' },
                      { name: 'Zipping_ZipDirectlyToDestination', map: 'Zipping_ZipDirectlyToDestination', type: 'boolean' },
                      { name: 'Zipping_UnzipAllfiles', map: 'Zipping_UnzipAllfiles', type: 'boolean' },
                      { name: 'Zipping_LimitZipFileSize', map: 'Zipping_LimitZipFileSize', type: 'boolean' },
                      { name: 'Zipping_CompressionLevelWidget', map: 'Zipping_CompressionLevelWidget', type: 'string' },
                      { name: 'ZippingEncrypt_EncryptFiles', map: 'ZippingEncrypt_EncryptFiles', type: 'boolean' },
                      { name: 'ZippingEncrypt_DecryptFiles', map: 'ZippingEncrypt_DecryptFiles', type: 'boolean' },
                      { name: 'ZippingEncrypt_Password', map: 'ZippingEncrypt_Password', type: 'string' },
                      { name: 'ZippingEncrypt_Confirm', map: 'ZippingEncrypt_Confirm', type: 'string' },
                      { name: 'ZippingEncrypt_ComboIndex', map: 'ZippingEncrypt_ComboIndex', type: 'number' }


                      ] ,
                  datatype: "json",                                     
                  id: 'Name'
                  
              };
     
      
             
function RefreshMainGrid()
{
    var scrolling = $("#jqxgrid").jqxGrid("scrolling");
    $("#jqxgrid").jqxGrid('updatebounddata', 'cells');
}             

function InitMainForm()
{


              
////////////////////////////////////////////////////////////////////////////////// 
           
          

            $("#MainForm_div").html( MainFormHTML );   
             // initialize jqxGrid

      
            $("#jqxgrid").jqxGrid(
            {
                    width: 1000,                
                    rowsheight : 50,                   
                    source: GridDataAdapter,
                    pageable: true,
                    autoheight: true,
                    //scrollmode: 'deferred',
                    //sortable: true,
                    //altrows: true,
                    //enabletooltips: true,
                    //editable: false,
                    //selectionmode: 'singlerow',
                    showtoolbar: true,
                    

                    


                    rendertoolbar: function (toolbar) {
                    var me = this;
                    var container = $("<div style='margin: 5px;'></div>");
                    toolbar.append(container);
                    container.append('<input id="addrowbutton" type="button" value="Add New Profile" />');                    
                    container.append('<input style="margin-left: 5px;" id="deleterowbutton" type="button" value="Delete Profile" />');
                    container.append('<input style="margin-left: 5px;" id="updaterowbutton" type="button" value="Edit Profile" />');
                    container.append('<input style="margin-left: 5px;" id="run_selected_profile_button" type="button" value="Run Selected Profile" />');
                    container.append('<input style="margin-left: 5px;" id="stop_selected_profile_button" type="button" value="Stop Selected Profile" />');
                    $("#addrowbutton").jqxButton();                    
                    $("#deleterowbutton").jqxButton();
                    $("#updaterowbutton").jqxButton();
                    $("#run_selected_profile_button").jqxButton();
                    $("#run_selected_profile_button").on('click', function () 
                    {
                        alert( "Run" ); 
                    });
                    
                    $("#stop_selected_profile_button").jqxButton();
                    

                    $("#stop_selected_profile_button").on('click', function () 
                    {
                       alert( "Stop" ); 
                    });
                    // update row.
                    $("#updaterowbutton").on('click', function () 
                    { 
                         
                                                  
                         var selectedRow = $('#jqxgrid').jqxGrid('getselectedrowindex');
                         if( selectedRow == -1 ) return;
                         
                         
                         var SelectedProfile = $('#jqxgrid').jqxGrid('getrowdata', selectedRow ).Name;
                         
                         
                         ProfileSource.url = "single_profile_" + SelectedProfile; 
                         
                         
                         var ProfileDataAdapter = new $.jqx.dataAdapter(ProfileSource, 
                         
                        { loadComplete: function () 
                            {
                              // get data records.
                              var records = ProfileDataAdapter.records;
                              var length = records.length;
                              for (var i = 0; i < length; i++) 
                              {
                                 var record = records[i];
                                 if( SelectedProfile == record.Name )
                                 {                                       
                                    InitProfileEditorForm( SelectedProfile);   
                                    // dynamicaly assigning controls       
                                    LoadRecordToRegistryList(record, GProfileEditorRegistryList, "");
                                    LoadRegistryListToControls( GProfileEditorRegistryList, "" );
                                      return;
                                 }          
                              }                     
                            } 
                            , 
                            loadError: function (jqXHR, status, error) { alert(error) } 
                         }); 
                

                         ProfileDataAdapter.dataBind();
                        


                    });
                    // create new row.
                    $("#addrowbutton").on('click', function () 
                    {
                        InitProfileEditorForm( null ); 
                        var dataAdapter = new $.jqx.dataAdapter(ProfileSource, {} );
                        //$('#jqxProfileEditorForm').on('close', function (event) { $('#jqxProfileEditorForm').jqxWindow('destroy'); });
                        $('#jqxProfileEditorForm').jqxWindow('open');
                        dataAdapter.dataBind();

                    });                    
                    // delete row.
                    $("#deleterowbutton").on('click', function () {
                        var selectedrowindex = $("#jqxgrid").jqxGrid('getselectedrowindex');
                        var rowscount = $("#jqxgrid").jqxGrid('getdatainformation').rowscount;
                        if (selectedrowindex >= 0 && selectedrowindex < rowscount) {
                          if (confirm('Are you sure ?'))     
                          {     
                            var id = $("#jqxgrid").jqxGrid('getrowid', selectedrowindex);
                            var commit = $("#jqxgrid").jqxGrid('deleterow', id);
                          }
                        }
                    });
                  },  
                columns: [
                  { text: 'Profile Name', datafield: 'Name', width: 350 },
                  { text: 'Left Hand', datafield: 'LPath', width: 200 },
                  { text: 'Right Hand', datafield: 'RPath', width: 200 },               
                  { text: 'Progress', datafield: 'Progress', width: 200 }

                ]
            });
                        
            GridDataAdapter.dataBind();

      $('#Test_btn1').jqxButton({});
      
      $('#Test_btn').jqxButton({});
      
      $('#Test_btn').click(function () 
      {
        $('#Test_btn1').jqxButton({disabled : true});    
         
                
                 

       });


       var refreshInterval = setInterval(function () {
                                                   
           var scrolling = $("#jqxgrid").jqxGrid('scrolling');
           if( scrolling.vertical == false )
           {
            // $("#jqxgrid").jqxGrid('updatebounddata');
           }
       }, 2000);


}//end InitMainForm


      


       
