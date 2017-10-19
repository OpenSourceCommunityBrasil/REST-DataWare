  //globals
  
    var GInternetProtSettingsDialogWidth = 810;  
    var GInternetProtSettingsDialogHeight = 640;
    var GInternetProtSettingsTabControlWidth = GInternetProtSettingsDialogWidth - 50;
    var GInternetProtSettingsTabControlHeight = GInternetProtSettingsDialogHeight - 150;
    var GInternetProtSettingsTabs = null; 
    var GCurrentInternetProtocolSetRegistryList = null; 
    var GSelectedProfileName = "";
    var GLeftOrRight = "";
    var GProtocolName = "";

      
    var InternetProtSettingsTabsHTML_Cloud = 
    '<div id="jqxInternetProtSettingsTabs">'+
                '<ul>'+
                '    <li>Settings</li>'+
                '    <li>Advanced</li>'+
                '    <li>Proxy Settings</li>'+          
                '</ul>'+
                '<div>'+                                                                                                      
                '    <div>Library</div><div id ="jqxLibraryCombo" style="float: left;"></div>'+
                '    <br/><br/>'+
                '    <div>Folder</div><div><input type="text" id="inptInternetFolder"/></div>'+
                '    <br/><br/>'+
                '    <div>Account( opt. )</div><div><input type="password" id="inptAccountOpt"/></div>'+
                '    <br/><br/>'+                                          
                '</div>'+                  
                '<div>'+
                '</div>'+
                '<div>'+                                                           
                '</div>'+
             '</div>';



function OnProtocolComboItem( ProfileName, InternetProtocolSetRegistryList, LeftOrRight, ProtocolName )
{

      GProtocolName = ProtocolName;
     if( GInternetProtSettingsTabs != null)  
      {
         GInternetProtSettingsTabs.jqxTabs( 'destroy' ); 
         GInternetProtSettingsTabs = null;
      }

      /*
      ftpGUIlikeFTP          =1;+
      ftpGUIlikeSFTP         =2;
      ftpGUIlikeWebDAV       =3;+
      ftpGUIlikeAmazonS3     =4;+
      ftpGUIlikeAzure        =5;+
      ftpGUIlikeAmazonGlacier=6;
      ftpGUIlikeGoogleDrive  =7;+
      ftpGUIlikeRSync        =8;+
      ftpGUIlikeHTTP         =9;+
      ftpGUIlikeMTP          =10;
      */ 


    

      if( GetBaseProtocolName( ProtocolName ) == 'FTP' )
      {
          
          $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_FTP );  
          GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });   
          var LibraryComboSource = ['1(default)', '2', '3' ];
          $("#jqxLibraryCombo").jqxComboBox({ source: LibraryComboSource, selectedIndex: 0, width: '100', height: '25px'});

          $("#inptIntProtSetFTP_url").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_FTP_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#cbIntProtSet_FTP_passive_mode").jqxCheckBox({ width: 120, height: 25});                     
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_FTP_login").jqxInput({ width: 350, height: 25 });          
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_FTP_save_user_id").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_FTP_save_password").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_FTP_allow_ipv6").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_FTP_auto_resume_transfer").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_FTP_filename_encoding").jqxCheckBox({ width: 120, height: 25});                     
                              
          var adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];
          
          $("#comboIntProtSet_FTP_adv_Charset").jqxComboBox({ source: adv_CharsetComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#cbIntProtSet_FTP_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_FTP_adv_ascii_transfer_mode").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_FTP_adv_server_supports_moving").jqxCheckBox({ width: 120, height: 25});                     
 
          var adv_FTP_ListingCommandComboSource = ['Automatic', 'LIST(basic listing)', 'LIST-al(includes hidden files)', 'LIST-alR(recursive listing)', 'LS-al(rare)', 'LS-alR(rare)' ];
          $("#comboIntProtSet_FTP_adv_ListingCommand").jqxComboBox({ source: adv_FTP_ListingCommandComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#cbIntProtSet_FTP_adv_verify_file").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_FTP_adv_respect_passive_mode").jqxCheckBox({ width: 120, height: 25});                     
          var adv_FTP_TimestampsForUploadsComboSource = ['Auto-Detect If Settable', 'Force Sending Timestamps'];
          $("#comboIntProtSet_FTP_adv_TimestampsForUploads").jqxComboBox({ source: adv_FTP_TimestampsForUploadsComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#cbIntProtSet_FTP_adv_zone").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_FTP_adv_auto").jqxCheckBox({ width: 120, height: 25});
       //   $("#cbIntProtSet_FTP_adv_UTC").jqxCheckBox({ width: 120, height: 25});
          $("#inptIntProtSet_FTP_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_FTP_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_FTP_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_FTP_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_FTP_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });   

          var FTP_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_FTP_proxy_proxy_type").jqxComboBox({ source: FTP_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_FTP_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_FTP_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_FTP_proxy_login").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_FTP_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_FTP_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    

          $("#rbIntProtSet_FTP_Security_security_none").jqxRadioButton({ groupName: 'IntProtSet_FTP_Security_Mode_Group', rtl: false});                 
          $("#rbIntProtSet_FTP_Security_security_implisit_tsl").jqxRadioButton({ groupName: 'IntProtSet_FTP_Security_Mode_Group', rtl: false});                 
          $("#rbIntProtSet_FTP_Security_security_explisit_tsl").jqxRadioButton({ groupName: 'IntProtSet_FTP_Security_Mode_Group', rtl: false});                 

          $("#rbIntProtSet_FTP_Security_auto").jqxRadioButton({ groupName: 'IntProtSet_FTP_Auth_Cmd_Group', rtl: false});                 
          $("#rbIntProtSet_FTP_Security_TLS").jqxRadioButton({ groupName: 'IntProtSet_FTP_Auth_Cmd_Group', rtl: false});                 
          $("#rbIntProtSet_FTP_Security_SSL").jqxRadioButton({ groupName: 'IntProtSet_FTP_Auth_Cmd_Group', rtl: false});                 
          $("#rbIntProtSet_FTP_Security_TLSC").jqxRadioButton({ groupName: 'IntProtSet_FTP_Auth_Cmd_Group', rtl: false});                     
          $("#rbIntProtSet_FTP_Security_TLSP").jqxRadioButton({ groupName: 'IntProtSet_FTP_Auth_Cmd_Group', rtl: false});                     


          $("#rbIntProtSet_FTP_Security_SSLv2").jqxRadioButton({ groupName: 'IntProtSet_FTP_Version_Group', rtl: false});                     
          $("#rbIntProtSet_FTP_Security_SSLv2_3").jqxRadioButton({ groupName: 'IntProtSet_FTP_Version_Group', rtl: false}); 
          $("#rbIntProtSet_FTP_Security_SSLv3").jqxRadioButton({ groupName: 'IntProtSet_FTP_Version_Group', rtl: false}); 
          $("#rbIntProtSet_FTP_Security_TLSv_1_1_2").jqxRadioButton({ groupName: 'IntProtSet_FTP_Version_Group', rtl: false}); 

          $("#btnIntProtSet_FTP_Security_Advanced_SSH").jqxButton({ template: "info" }); 

          $("#cbIntProtSet_FTP_Security_SSH_username_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_FTP_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_FTP_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});


          var FTP_proxy_security_CertificateComboSource = ['none'];
          $("#comboIntProtSet_FTP_security_Certificate").jqxComboBox({ source: FTP_proxy_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_FTP_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 }); 
          $("#cbIntProtSet_FTP_security_nopassword").jqxCheckBox({ width: 120, height: 25});


          $("#inptIntProtSet_FTP_certificates_certificates").jqxInput({ width: 350, height: 150 });
          $("#inptIntProtSet_FTP_certificates_certname_forreference").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_FTP_certificates_private_keyfile").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_FTP_certificates_public_keyfile").jqxInput({ width: 350, height: 25 });
      }
      else if( GetBaseProtocolName( ProtocolName ) == 'SSH' )
      {
          
          $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_SFTP );  
          GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });   
          var LibraryComboSource = ['1(SFTP)', '2(SCP )', '3(Pure SSH)' ];
          $("#jqxLibraryCombo").jqxComboBox({ source: LibraryComboSource, selectedIndex: 0, width: '100', height: '25px'});

          $("#inptIntProtSetSSH_url").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_SSH_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_SSH_login").jqxInput({ width: 350, height: 25 });          
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });


          $("#cbIntProtSet_SSH_save_user_id").jqxCheckBox({ width: 120, height: 25});          
          $("#cbIntProtSet_SSH_save_password").jqxCheckBox({ width: 120, height: 25});          
          $("#cbIntProtSet_SSH_allow_ipv6").jqxCheckBox({ width: 120, height: 25});          


          $("#cbIntProtSet_SSH_auto_resume_transfer").jqxCheckBox({ width: 120, height: 25});                     

                              
          var adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];
          
          $("#comboIntProtSet_SSH_adv_Charset").jqxComboBox({ source: adv_CharsetComboSource, selectedIndex: 0, width: '250', height: '25px'});

          $("#cbIntProtSet_SSH_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_SSH_adv_recursive_listing").jqxCheckBox({ width: 120, height: 25});                               
          $("#cbIntProtSet_SSH_adv_verify_destination_file").jqxCheckBox({ width: 120, height: 25});                     


          $("#cbIntProtSet_SSH_adv_zone").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_SSH_adv_auto").jqxCheckBox({ width: 120, height: 25});
       
          $("#inptIntProtSet_SSH_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_SSH_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_SSH_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_SSH_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_SSH_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });   

          var SSH_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_SSH_proxy_proxy_type").jqxComboBox({ source: SSH_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_SSH_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_SSH_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_SSH_proxy_user_id").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_SSH_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_SSH_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    


          $("#btnIntProtSet_SSH_Security_Advanced_SSH").jqxButton({ template: "info" }); 

          $("#cbIntProtSet_SSH_Security_SSH_username_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_SSH_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_SSH_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});


          var SSH_proxy_security_CertificateComboSource = ['none'];
          $("#comboIntProtSet_SSH_security_Certificate").jqxComboBox({ source: SSH_proxy_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_SSH_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 }); 
          $("#cbIntProtSet_SSH_security_nopassword").jqxCheckBox({ width: 120, height: 25});


          $("#inptIntProtSet_SSH_certificates_certificates").jqxInput({ width: 350, height: 150 });
          $("#inptIntProtSet_SSH_certificates_certname_forreference").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_SSH_certificates_private_keyfile").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_SSH_certificates_public_keyfile").jqxInput({ width: 350, height: 25 });
      }
      else if( GetBaseProtocolName( ProtocolName ) == 'HTTP' )
      {

          $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_HTTP );  
          GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });   

          $("#inptIntProtSet_HTTP_url").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_HTTP_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });                                
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_HTTP_login").jqxInput({ width: 350, height: 25 });          
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_HTTP_save_user_id").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_HTTP_save_password").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_HTTP_allow_ipv6").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_HTTP_filename_encoding").jqxCheckBox({ width: 120, height: 25});    


          $("#cbIntProtSet_HTTP_HTML_download_and_parse").jqxCheckBox({ width: 120, height: 25});
          $("#inptIntProtSet_HTTP_HTML_parsing_limit").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#cbIntProtSet_HTTP_HTML_enquire_timestamp").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_HTTP_HTML_enquire_precise_info").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_HTTP_HTML_download_default_pages").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_HTTP_HTML_consider_locally_existing_files").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_HTTP_HTML_assume_local_files").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_HTTP_HTML_avoid_re_downloading").jqxCheckBox({ width: 120, height: 25});

          var HTTP_HTML_links_ComboSource = ['Ignore', 'Download', 'Download&Analyze']; 
          $("#jqxLinksAboveCombo").jqxComboBox({ source: HTTP_HTML_links_ComboSource, selectedIndex: 0, width: '100', height: '25px'});
          $("#jqxLinksToOtherDomainsCombo").jqxComboBox({ source: HTTP_HTML_links_ComboSource, selectedIndex: 0, width: '100', height: '25px'});
 

          var HTTP_adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];
          
          $("#comboIntProtSet_HTTP_adv_Charset").jqxComboBox({ source: HTTP_adv_CharsetComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#cbIntProtSet_HTTP_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});    
          
          $("#cbIntProtSet_HTTP_adv_zone").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_HTTP_adv_auto").jqxCheckBox({ width: 120, height: 25});    
        
          $("#inptIntProtSet_HTTP_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
          $("#inptIntProtSet_HTTP_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
                    
          $("#inptIntProtSet_HTTP_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_HTTP_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_HTTP_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });                                         
          
          var FTP_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_HTTP_proxy_proxy_type").jqxComboBox({ source: FTP_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_HTTP_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_HTTP_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_HTTP_proxy_login").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_HTTP_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_HTTP_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    
 


          $("#rbIntProtSet_HTTP_Security_SSLv2").jqxRadioButton({ groupName: 'IntProtSet_HTTP_Version_Group', rtl: false});                     
          $("#rbIntProtSet_HTTP_Security_SSLv2_3").jqxRadioButton({ groupName: 'IntProtSet_HTTP_Version_Group', rtl: false}); 
          $("#rbIntProtSet_HTTP_Security_SSLv3").jqxRadioButton({ groupName: 'IntProtSet_HTTP_Version_Group', rtl: false}); 
          $("#rbIntProtSet_HTTP_Security_TLSv_1_1_2").jqxRadioButton({ groupName: 'IntProtSet_HTTP_Version_Group', rtl: false}); 

          $("#btnIntProtSet_HTTP_Security_Advanced_SSH").jqxButton({ template: "info" }); 

          $("#cbIntProtSet_HTTP_Security_SSH_username_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_HTTP_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_HTTP_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});


          var HTTP_security_CertificateComboSource = ['none'];
          $("#comboIntProtSet_HTTP_security_Certificate").jqxComboBox({ source: HTTP_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_HTTP_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 }); 
          $("#cbIntProtSet_HTTP_security_nopassword").jqxCheckBox({ width: 120, height: 25});

          $("#inptIntProtSet_HTTP_certificates_certificates").jqxInput({ width: 350, height: 150 });
          $("#inptIntProtSet_HTTP_certificates_certname_forreference").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_HTTP_certificates_private_keyfile").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_HTTP_certificates_public_keyfile").jqxInput({ width: 350, height: 25 });


      }
      else if( GetBaseProtocolName( ProtocolName ) == 'Google Drive' ) 
      {
          
          $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_GoogleDrive );  
          
          GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });   
       

        //Library Combo  
          var LibraryComboSource = ['1 MS(SSL)', '2 Open(SSL)'];
          $("#jqxLibraryCombo").jqxComboBox({ source: LibraryComboSource, selectedIndex: 0, width: '100', height: '25px'});
                                

        // Internet Folder
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });    
          
          $("#cbIntProtSet_GDrive_save_optional_accname").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_allow_ipv6").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_GDrive_auto_resume_transfer").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_GDrive_filename_encoding").jqxCheckBox({ width: 120, height: 25});   

           var GDrive_adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];
          
          $("#comboIntProtSet_GDrive_adv_Charset").jqxComboBox({ source: GDrive_adv_CharsetComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#cbIntProtSet_GDrive_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_GDrive_adv_enable_doc_convercion").jqxCheckBox({ width: 120, height: 25});    

          $("#cbIntProtSet_GDrive_adv_zone").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_GDrive_adv_auto").jqxCheckBox({ width: 120, height: 25});    
          
          $("#inptIntProtSet_GDrive_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
          $("#inptIntProtSet_GDrive_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
                    
          $("#inptIntProtSet_GDrive_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_GDrive_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_GDrive_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
           
          var GDrive_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_GDrive_proxy_proxy_type").jqxComboBox({ source: GDrive_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_GDrive_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_GDrive_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_GDrive_proxy_login").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_GDrive_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_GDrive_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    
          
                  
          $("#rbIntProtSet_GDrive_GDocs_xlsx").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatSpreadsheets_Group', rtl: false});                     
          $("#rbIntProtSet_GDrive_GDocs_csv").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatSpreadsheets_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_pdf").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatSpreadsheets_Group', rtl: false}); 
                    


          $("#rbIntProtSet_GDrive_GDocs_dd_docx").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDocs_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_dd_odt").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDocs_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_dd_rtf").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDocs_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_dd_html").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDocs_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_dd_pdf").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDocs_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_dd_txt").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDocs_Group', rtl: false}); 
          

          $("#rbIntProtSet_GDrive_GDocs_dpres_pptx").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldPres_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_dpres_pdf").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldPres_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_dpres_txt").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldPres_Group', rtl: false}); 

           
          $("#rbIntProtSet_GDrive_GDocs_ddraw_jpg").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDraw_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_ddraw_png").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDraw_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_ddraw_pdf").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDraw_Group', rtl: false}); 
          $("#rbIntProtSet_GDrive_GDocs_ddraw_xml").jqxRadioButton({ groupName: 'IntProtSet_GDrive_FormatDownldDraw_Group', rtl: false}); 

          
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_csv").jqxCheckBox({ width: 120, height: 25});  
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_html").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_pdf").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_pptx").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_txt").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_doc").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_ods").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_pps").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_rtf").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_xls").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_docx").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_odt").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_ppt").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_tsv").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_GDrive_GDocs_ftconvert_xlsx").jqxCheckBox({ width: 120, height: 25});   
          

       } 
       else if( GetBaseProtocolName( ProtocolName ) == 'Amazon S3' )
       {          
          
          $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_AmazonS3 );            
          GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });   
       
          $("#inptIntProtSet_AmazonS3_bucket").jqxInput({ width: 350, height: 25 });
          $("#cbIntProtSet_AmazonS3_reduced_redundancy").jqxCheckBox({ width: 120, height: 25});             
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });

          $("#inptIntProtSet_AmazonS3_access_id").jqxInput({ width: 350, height: 25 });                  
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });    
          
          $("#cbIntProtSet_AmazonS3_save_access_id").jqxCheckBox({ width: 120, height: 25});   
          $("#cbIntProtSet_AmazonS3_save_secret_key").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_AmazonS3_allow_ipv6").jqxCheckBox({ width: 120, height: 25});                     
          $("#cbIntProtSet_AmazonS3_filename_encoding").jqxCheckBox({ width: 120, height: 25}); 




         var AmazonS3_adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];
          
          $("#comboIntProtSet_AmazonS3_adv_Charset").jqxComboBox({ source: AmazonS3_adv_CharsetComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#cbIntProtSet_AmazonS3_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_AmazonS3_make_uploaded_files_pub_available").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_AmazonS3_recursive_listing").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_AmazonS3_use_server_side_encryption").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_AmazonS3_adv_zone").jqxCheckBox({ width: 120, height: 25});    
          $("#cbIntProtSet_AmazonS3_adv_auto").jqxCheckBox({ width: 120, height: 25});    

            
          $("#inptIntProtSet_AmazonS3_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
          $("#inptIntProtSet_AmazonS3_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
                    
          $("#inptIntProtSet_AmazonS3_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_AmazonS3_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_AmazonS3_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });                                                



          var AmazonS3_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_AmazonS3_proxy_proxy_type").jqxComboBox({ source: AmazonS3_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_AmazonS3_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_AmazonS3_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_AmazonS3_proxy_login").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_AmazonS3_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_AmazonS3_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    
          


          $("#rbIntProtSet_AmazonS3_Security_SSLv2").jqxRadioButton({ groupName: 'IntProtSet_AmazonS3_Version_Group', rtl: false});                     
          $("#rbIntProtSet_AmazonS3_Security_SSLv2_3").jqxRadioButton({ groupName: 'IntProtSet_AmazonS3_Version_Group', rtl: false}); 
          $("#rbIntProtSet_AmazonS3_Security_SSLv3").jqxRadioButton({ groupName: 'IntProtSet_AmazonS3_Version_Group', rtl: false}); 
          $("#rbIntProtSet_AmazonS3_Security_TLSv_1_1_2").jqxRadioButton({ groupName: 'IntProtSet_AmazonS3_Version_Group', rtl: false}); 

          $("#btnIntProtSet_AmazonS3_Security_Advanced_SSH").jqxButton({ template: "info" }); 

          $("#cbIntProtSet_AmazonS3_Security_SSH_username_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_AmazonS3_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_AmazonS3_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});


          var AmazonS3_security_CertificateComboSource = ['none'];
          $("#comboIntProtSet_AmazonS3_security_Certificate").jqxComboBox({ source: AmazonS3_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_AmazonS3_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 }); 
          $("#cbIntProtSet_AmazonS3_security_nopassword").jqxCheckBox({ width: 120, height: 25});


                    
       }
       else if( GetBaseProtocolName( ProtocolName ) == 'Asure' ) 
       {
        
         $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_Asure );  
         GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });   
     
        // Internet Folder
        
          $("#inptIntProtSet_Asure_container").jqxInput({ width: 350, height: 25 });
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_Asure_account_id").jqxInput({ width: 350, height: 25 });                   
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_Asure_save_user_id").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Asure_save_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Asure_allow_ipv6").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Asure_filename_encoding").jqxCheckBox({ width: 120, height: 25});
                                                  

          var Asure_adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];
          
          $("#comboIntProtSet_Asure_adv_Charset").jqxComboBox({ source: Asure_adv_CharsetComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#cbIntProtSet_Asure_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Asure_adv_recursive_listing").jqxCheckBox({ width: 120, height: 25});
          $("#inptIntProtSet_Asure_adv_cache_control").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#cbIntProtSet_Asure_adv_zone").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Asure_adv_auto").jqxCheckBox({ width: 120, height: 25});
          $("#inptIntProtSet_Asure_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_Asure_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_Asure_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_Asure_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptIntProtSet_Asure_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
                                                            
  
          var Asure_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_Asure_proxy_proxy_type").jqxComboBox({ source: Asure_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_Asure_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_Asure_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_Asure_proxy_login").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_Asure_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_Asure_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    
          


          $("#rbIntProtSet_Asure_Security_SSLv2").jqxRadioButton({ groupName: 'IntProtSet_Asure_Version_Group', rtl: false});                     
          $("#rbIntProtSet_Asure_Security_SSLv2_3").jqxRadioButton({ groupName: 'IntProtSet_Asure_Version_Group', rtl: false}); 
          $("#rbIntProtSet_Asure_Security_SSLv3").jqxRadioButton({ groupName: 'IntProtSet_Asure_Version_Group', rtl: false}); 
          $("#rbIntProtSet_Asure_Security_TLSv_1_1_2").jqxRadioButton({ groupName: 'IntProtSet_Asure_Version_Group', rtl: false}); 

          $("#btnIntProtSet_Asure_Security_Advanced_SSH").jqxButton({ template: "info" }); 

          $("#cbIntProtSet_Asure_Security_SSH_username_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Asure_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Asure_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});


          var Asure_security_CertificateComboSource = ['none'];
          $("#comboIntProtSet_Asure_security_Certificate").jqxComboBox({ source: Asure_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_Asure_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 }); 
          $("#cbIntProtSet_Asure_security_nopassword").jqxCheckBox({ width: 120, height: 25});                    
                                                                                                                          
       }
       else if( GetBaseProtocolName( ProtocolName ) == 'WebDAV' )
       {
          $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_WebDAV );  
          GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });   
     

          var LibraryComboSource = ['1 MS(SSL)', '2 Open(SSL)'];
          $("#jqxLibraryCombo").jqxComboBox({ source: LibraryComboSource, selectedIndex: 0, width: '100', height: '25px'});
          $("#inptIntProtSetWebDAV_url").jqxInput({ width: 350, height: 25 });
          var AuthenticationComboSource = ['Basic', 'Auto'];
          $("#jqxWebDAVAuthenticationCombo").jqxComboBox({ source: AuthenticationComboSource, selectedIndex: 0, width: '100', height: '25px'});
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_WebDAV_login").jqxInput({ width: 350, height: 25 });
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });          
          $("#cbIntProtSet_WebDAV_save_user_id").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_WebDAV_save_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_WebDAV_allow_ipv6").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_WebDAV_filename_encoding").jqxCheckBox({ width: 120, height: 25});
        

          var WebDAV_adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];

          $("#comboIntProtSet_WebDAV_adv_Charset").jqxComboBox({ source: WebDAV_adv_CharsetComboSource, selectedIndex: 0, width: '100', height: '25px'});
          $("#cbIntProtSet_WebDAV_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});

          var WebDAV_adv_strategyComboSource = ['Get All Properties', 'Get Necessary Properties Only', 'PROPFIND without XML body' ];
          $("#comboIntProtSet_WebDAV_adv_strategyCombo").jqxComboBox({ source: WebDAV_adv_strategyComboSource, selectedIndex: 0, width: '100', height: '25px'});
          
          $("#cbIntProtSet_WebDAV_adv_use_displayname").jqxCheckBox({ width: 120, height: 25});
          $("#comboIntProtSet_WebDAV_adv_use_expect_100_continue").jqxCheckBox({ width: 120, height: 25});
             
          var WebDAV_adv_TimestampsComboSource = ['Auto-Detect If Settable', 'WebDrive/GroupDrive', 'CrushFTP', 'OnlineDrive by CM4all', 'vitalEsafe' ];
          $("#comboIntProtSet_WebDAV_adv_TimestampsForUploads").jqxComboBox({ source: WebDAV_adv_TimestampsComboSource, selectedIndex: 0, width: '100', height: '25px'});
          $("#cbIntProtSet_WebDAV_adv_zone").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_WebDAV_adv_auto").jqxCheckBox({ width: 120, height: 25});
     


  
          $("#inptIntProtSet_WebDAV_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
          $("#inptIntProtSet_WebDAV_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
                    

          $("#inptIntProtSet_WebDAV_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_WebDAV_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_WebDAV_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });                                                

          

          var WebDAV_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_WebDAV_proxy_proxy_type").jqxComboBox({ source: WebDAV_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_WebDAV_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_WebDAV_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_WebDAV_proxy_login").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_WebDAV_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_WebDAV_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    
          
 

          $("#rbIntProtSet_WebDAV_Security_SSLv2").jqxRadioButton({ groupName: 'IntProtSet_WebDAV_Version_Group', rtl: false});                     
          $("#rbIntProtSet_WebDAV_Security_SSLv2_3").jqxRadioButton({ groupName: 'IntProtSet_WebDAV_Version_Group', rtl: false}); 
          $("#rbIntProtSet_WebDAV_Security_SSLv3").jqxRadioButton({ groupName: 'IntProtSet_WebDAV_Version_Group', rtl: false}); 
          $("#rbIntProtSet_WebDAV_Security_TLSv_1_1_2").jqxRadioButton({ groupName: 'IntProtSet_WebDAV_Version_Group', rtl: false}); 

          $("#btnIntProtSet_WebDAV_Security_Advanced_SSH").jqxButton({ template: "info" }); 

          $("#cbIntProtSet_WebDAV_Security_SSH_username_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_WebDAV_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_WebDAV_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});

          var WebDAV_security_CertificateComboSource = ['none'];
          $("#comboIntProtSet_WebDAV_security_Certificate").jqxComboBox({ source: WebDAV_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_WebDAV_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 }); 
          $("#cbIntProtSet_WebDAV_security_nopassword").jqxCheckBox({ width: 120, height: 25});                    
        

          $("#inptIntProtSet_WebDAV_certificates_certificates").jqxInput({ width: 350, height: 150 });     
          $("#inptIntProtSet_WebDAV_certificates_certname_forreference").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_WebDAV_certificates_private_keyfile").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_WebDAV_certificates_public_keyfile").jqxInput({ width: 350, height: 25 });
       }
       else if( GetBaseProtocolName( ProtocolName ) == 'RSync' )
       {

                    
          $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_RSync );  
          GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });        
          var LibraryComboSource = ['1 (SSH)', '2 (Direct)'];
          $("#jqxLibraryCombo").jqxComboBox({ source: LibraryComboSource, selectedIndex: 0, width: '100', height: '25px'});

          $("#inptIntProtSet_Rsync_url").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_Rsync_port_number").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
          $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_Rsync_login").jqxInput({ width: 350, height: 25 });
          $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });          
          $("#cbIntProtSet_Rsync_save_user_id").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Rsync_save_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Rsync_allow_ipv6").jqxCheckBox({ width: 120, height: 25});

          var RSync_adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];

          $("#comboIntProtSet_Rsync_adv_Charset").jqxComboBox({ source: RSync_adv_CharsetComboSource, selectedIndex: 0, width: '100', height: '25px'});
          $("#cbIntProtSet_Rsync_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});
  

             
          var Rsync_adv_TimestampsComboSource = ['Auto-Detect If Settable', 'WebDrive/GroupDrive', 'CrushFTP', 'OnlineDrive by CM4all', 'vitalEsafe' ];
          $("#comboIntProtSet_Rsync_adv_TimestampsForUploads").jqxComboBox({ source: Rsync_adv_TimestampsComboSource, selectedIndex: 0, width: '100', height: '25px'});
          $("#cbIntProtSet_Rsync_adv_zone").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Rsync_adv_auto").jqxCheckBox({ width: 120, height: 25});
      


  
          $("#inptIntProtSet_Rsync_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
          $("#inptIntProtSet_Rsync_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });
                    

          $("#inptIntProtSet_Rsync_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_Rsync_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });          
          $("#inptIntProtSet_Rsync_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });                                                




          var Rsync_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
          $("#comboIntProtSet_Rsync_proxy_proxy_type").jqxComboBox({ source: Rsync_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_Rsync_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_Rsync_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 

          $("#inptIntProtSet_Rsync_proxy_login").jqxInput({ width: 350, height: 25 });          
          $("#inptIntProtSet_Rsync_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
          $("#cbIntProtSet_Rsync_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});    
          
 

          
          $("#btnIntProtSet_Rsync_Security_Advanced_SSH").jqxButton({ template: "info" }); 

          $("#cbIntProtSet_Rsync_Security_SSH_username_password").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Rsync_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});
          $("#cbIntProtSet_Rsync_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});

          var Rsync_security_CertificateComboSource = ['none'];
          $("#comboIntProtSet_Rsync_security_Certificate").jqxComboBox({ source: Rsync_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});
          $("#inptIntProtSet_Rsync_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 }); 
          $("#cbIntProtSet_Rsync_security_nopassword").jqxCheckBox({ width: 120, height: 25});                    
        

          $("#inptIntProtSet_Rsync_certificates_certificates").jqxInput({ width: 350, height: 150 });     
          $("#inptIntProtSet_Rsync_certificates_certname_forreference").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_Rsync_certificates_private_keyfile").jqxInput({ width: 350, height: 25 });
          $("#inptIntProtSet_Rsync_certificates_public_keyfile").jqxInput({ width: 350, height: 25 });
          
          

       }
       else if( GetBaseProtocolName( ProtocolName ) == 'Glacier' )
       {

            $("#jqxInternetProtSettingsTabs_div").html( InternetProtSettingsTabsHTML_Glacier );  
            GInternetProtSettingsTabs = $('#jqxInternetProtSettingsTabs').jqxTabs({ width: GInternetProtSettingsTabControlWidth, height: GInternetProtSettingsTabControlHeight });        
                
            $("#inptIntProtSet_Glacier_Vault").jqxInput({ width: 350, height: 25 });
  

            var Glacier_RegionComboSource = ['US East (Northern Virginia)', 'US West (Oregon)', 'US West (Northern California)', 
              'EU (Ireland)', 'Asia Pacific (Tokyo)' ];
            $("#comboIntProtSet_Glacier_Region").jqxComboBox({ source: Glacier_RegionComboSource, selectedIndex: 0, width: '100', height: '25px'});                    
            $("#inptInternetFolder").jqxInput({ width: 350, height: 25 });
            $("#inptAccountOpt").jqxPasswordInput({ width: 350, height: 25 });

            $("#cbIntProtSet_Glacier_save_access_id").jqxCheckBox({ width: 120, height: 25});
            $("#cbIntProtSet_Glacier_save_password").jqxCheckBox({ width: 120, height: 25});
            $("#cbIntProtSet_Glacier_allow_ipv6").jqxCheckBox({ width: 120, height: 25});


            $("#cbIntProtSet_Glacier_filename_encoding").jqxCheckBox({ width: 120, height: 25});                    
            var Glacier_adv_CharsetComboSource = ['Automatic', 'Unicode(UTF-8)', 'Windows ANSI' ];
            $("#comboIntProtSet_Glacier_adv_Charset").jqxComboBox({ source: Glacier_adv_CharsetComboSource, selectedIndex: 0, width: '100', height: '25px'});
            $("#cbIntProtSet_Glacier_adv_replace_characters").jqxCheckBox({ width: 120, height: 25});                    
            $("#cbIntProtSet_Glacier_recursive_listing").jqxCheckBox({ width: 120, height: 25});                                
            $("#cbIntProtSet_Glacier_adv_zone").jqxCheckBox({ width: 120, height: 25});                    
            $("#cbIntProtSet_Glacier_adv_auto").jqxCheckBox({ width: 120, height: 25});                                            
            $("#inptIntProtSet_Glacier_adv_list").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });             
            $("#inptIntProtSet_Glacier_adv_upload_min").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });             
            $("#inptIntProtSet_Glacier_adv_timeout").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });             
            $("#inptIntProtSet_Glacier_adv_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
            $("#inptIntProtSet_Glacier_adv_http_retries").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false });                                                                                   
            var Glacier_proxy_proxy_typeComboSource = ['No Proxy(default)', 'USER user@hostname', 'SITE(with logon)', 'OPEN', 'USER/PASS combined', 'Transparent'];
            $("#comboIntProtSet_Glacier_proxy_proxy_type").jqxComboBox({ source: Glacier_proxy_proxy_typeComboSource, selectedIndex: 0, width: '250', height: '25px'});           
            $("#inptIntProtSet_Glacier_proxy_proxy_host").jqxInput({ width: 350, height: 25 });
            $("#inptIntProtSet_Glacier_proxy_proxy_port").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "10000", spinButtons: false }); 
            $("#inptIntProtSet_Glacier_proxy_login").jqxInput({ width: 350, height: 25 });
            $("#inptIntProtSet_Glacier_proxy_password").jqxPasswordInput({ width: 350, height: 25 });
            $("#cbIntProtSet_Glacier_proxy_send_host_command").jqxCheckBox({ width: 120, height: 25});                    
            $("#rbIntProtSet_Glacier_Security_None").jqxRadioButton({ groupName: 'IntProtSet_Glacier_Security_Mode_Group', rtl: false});                     
            $("#rbIntProtSet_Glacier_Security_TLS").jqxRadioButton({ groupName: 'IntProtSet_Glacier_Security_Mode_Group', rtl: false}); 
            $("#btnIntProtSet_Glacier_Security_Advanced_SSH").jqxButton({ template: "info" }); 
            $("#cbIntProtSet_Glacier_Security_SSH_username_password").jqxCheckBox({ width: 350, height: 25 });
            $("#cbIntProtSet_Glacier_Security_SSH_keyboard").jqxCheckBox({ width: 120, height: 25});                    
            $("#cbIntProtSet_Glacier_Security_SSH_certificate").jqxCheckBox({ width: 120, height: 25});                    
            var Glacier_security_CertificateComboSource = ['none'];
            $("#comboIntProtSet_Glacier_security_Certificate").jqxComboBox({ source: Glacier_security_CertificateComboSource, selectedIndex: 0, width: '250', height: '25px'});            
            $("#inptIntProtSet_Glacier_security_CertificatePassword").jqxPasswordInput({ width: 350, height: 25 });            
            $("#cbIntProtSet_Glacier_security_nopassword").jqxCheckBox({ width: 350, height: 25 });            
        }   

       LoadRegistryListToControls( GCurrentInternetProtocolSetRegistryList, GetBaseProtocolName( ProtocolName ) );                                                                     

        if( GInternetProtSettingsTabs != null)   
        {

            $("#inptInternetFolder").jqxInput( 'val' , GLeftRightSideInput.jqxInput( 'val' ) );
            if( GLeftOrRight == "Left" )
              $("#inptAccountOpt").jqxInput( 'val' , GLeftAccountOpt );            
            else            
              $("#inptAccountOpt").jqxInput( 'val' , GRightAccountOpt );
            
        }


                           

}


function InitProtocolSettingsForm( ProfileName, InternetProtocolSetRegistryList, LeftOrRight, ProtocolName )
{
    GCurrentInternetProtocolSetRegistryList = InternetProtocolSetRegistryList;
    GSelectedProfileName = ProfileName;  
    GLeftOrRight = LeftOrRight;
    GProtocolName = ProtocolName;

    $("#ProtocolSettingsForm_div").html( ProtocolSettingsFormHTML );   
	   ///Internet Protocol SettingsDlg
    $("#jqxwInternetProtSettingsDlg").jqxWindow({ maxWidth: GInternetProtSettingsDialogWidth, maxHeight: GInternetProtSettingsDialogHeight, height: GInternetProtSettingsDialogHeight,  
        width: GInternetProtSettingsDialogWidth,  theme: 'energyblue',  autoOpen: false,  isModal: true,  animationType: 'slide' });



            $('#Cancel_btn3').jqxButton({});
  
            $('#Cancel_btn3').click(function () {

               $('#jqxwInternetProtSettingsDlg').jqxWindow('close');
            });

            
            $('#OK_btn3').jqxButton({});

            $('#OK_btn3').click(function (){                            

               if( GLeftOrRight == "Left" )
               {
                  //in synapp_profile_editor_form                
                  GLeftProtocolName = $("#jqxProtocolCombo").jqxComboBox('val');
                  if( $("#inptInternetFolder").length > 0 )                                       
                     GLeftRightSideInput.jqxInput('val',  $("#inptInternetFolder").jqxInput( 'val' ) );
                    
                  
               }
               else if( GLeftOrRight == "Right" )
               {
                  //in synapp_profile_editor_form                
                  GRightProtocolName = $("#jqxProtocolCombo").jqxComboBox('val');     
                  if( $("#inptInternetFolder").length > 0 )                  
                    GLeftRightSideInput.jqxInput('val',  $("#inptInternetFolder").jqxInput( 'val' ) );
                  
               }

               ControlValuesToRegistryList(GCurrentInternetProtocolSetRegistryList, GetBaseProtocolName( GProtocolName ) );

               
               $('#jqxwInternetProtSettingsDlg').jqxWindow('close');
            });


// Protocols combo

            var ProtocolComboSource = ['FTP', 'SSH', 'WebDAV', 'Amazon S3', 'HTTP', 'Asure', 'RSync', 'Glacier', 'Box', 'Google Drive',
              'DropBox',  'Rackspace', 'OneDrive', 'SugarSync', 'Amazon Cloud Drive', 'MTP', 'Email' ];
            // Create a jqxComboBox
            $("#jqxProtocolCombo").jqxComboBox({ source: ProtocolComboSource, selectedIndex: 0, width: '250', height: '25px'});

           

            $('#jqxProtocolCombo').on('select', function (event) {
                    var args = event.args;
                    if (args != undefined) 
                    {
                        var item = event.args.item;                        
                        
                        if ( ( item != null )  ) 
                        {                           
                           OnProtocolComboItem( GSelectedProfileName, GCurrentInternetProtocolSetRegistryList, GLeftOrRight, item.label );
                        }
                    }
            });



      
      $('#jqxwInternetProtSettingsDlg').on('close', function (event) { 

          
          $('#jqxwInternetProtSettingsDlg').jqxWindow('destroy'); 

      });
      $("#jqxwInternetProtSettingsDlg").jqxWindow('open') 
      $('#jqxwInternetProtSettingsDlg').on('open', function (event) 
      { 
       
          $("#jqxProtocolCombo").jqxComboBox( 'val', GProtocolName );
          //OnProtocolComboItem( GSelectedProfileName, GCurrentInternetProtocolSetRegistryList, GLeftOrRight, GetBaseProtocolName( GProtocolName ) );            

       }); 

}