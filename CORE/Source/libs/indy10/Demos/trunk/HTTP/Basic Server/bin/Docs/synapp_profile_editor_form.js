

//Globals
 ///////////////////////////NOT USED Variables////////////////////////NEED to unregister them            
              var GLeftLibraryIndex = 0;
              var GRightLibraryIndex = 0;              
//////////////////////////////////////////////////////////////////////

              

              var GProfileSettingsDialogWidth = 1200;  
              var GProfileSettingsDialogHeight = 810;
              var GProfileSettingsTabControlWidth = GProfileSettingsDialogWidth - 50;
              var GProfileSettingsTabControlHeight = 490;
              var GLeftRightSideInput = null; 


              var GSelectedDirStr = "";            

              var GLeftAccountOpt = "";
              var GRightAccountOpt = "";



function deepCopy (arr) {
    var out = [];
    for (var i = 0, len = arr.length; i < len; i++) {
        var item = arr[i];
        var obj = {};
        for (var k in item) {
            obj[k] = item[k];
        }
        out.push(obj);
    }
    return out;
}

              
              var GInternetProtocolSetLEFTRegistryList = new Array();
              var GInternetProtocolSetRIGHTRegistryList = new Array();
              


//
      var GIntProtSetSource =
      {                  
         datatype: "json",                   
         id: 'Name',                           
      };

function InitProtocolSettingsDatasource( IntProtSetSource, ProfileName, LeftOrRight, ProtocolName )
{

             IntProtSetSource.url = "internet_settings_" + ProfileName +"_" + LeftOrRight+ "_" + ProtocolName; 
             if( GetBaseProtocolName( ProtocolName ) == "FTP" )
             {
                IntProtSetSource.datafields = [
                        { name: 'Name', type: 'string' },
                        { name: 'internet_protocol_FTPLibraryComboIndex', map: 'internet_protocol_FTPLibraryComboIndex', type: 'number' },
                        { name: 'internet_protocol_FTP_url', map: 'internet_protocol_FTP_url', type: 'string' },
                        { name: 'internet_protocol_FTP_port', map: 'internet_protocol_FTP_port', type: 'number' },
                        { name: 'internet_protocol_FTP_passive_mode', map: 'internet_protocol_FTP_passive_mode', type: 'boolean' },
                        { name: 'internet_protocol_FTP_InternetFolder', map: 'internet_protocol_FTP_InternetFolder', type: 'string' },
                        { name: 'internet_protocol_FTP_login', map: 'internet_protocol_FTP_login', type: 'string' },
                        { name: 'internet_protocol_FTP_AccountOpt', map: 'internet_protocol_FTP_AccountOpt', type: 'string' },
                        { name: 'internet_protocol_FTP_save_user_id', map: 'internet_protocol_FTP_save_user_id', type: 'boolean' },
                        { name: 'internet_protocol_FTP_save_password', map: 'internet_protocol_FTP_save_password', type: 'boolean' },
                        { name: 'internet_protocol_FTP_allow_ipv6', map: 'internet_protocol_FTP_allow_ipv6', type: 'boolean' },
                        { name: 'internet_protocol_FTP_auto_resume_transfer', map: 'internet_protocol_FTP_auto_resume_transfer', type: 'boolean' },
                        { name: 'internet_protocol_FTP_filename_encoding', map: 'internet_protocol_FTP_filename_encoding', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_CharsetComboIndex', map: 'internet_protocol_FTP_adv_CharsetComboIndex', type: 'number' },
                        { name: 'internet_protocol_FTP_adv_replace_characters', map: 'internet_protocol_FTP_adv_replace_characters', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_ascii_transfer_mode', map: 'internet_protocol_FTP_adv_ascii_transfer_mode', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_server_supports_moving', map: 'internet_protocol_FTP_adv_server_supports_moving', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_ListingCommandComboIndex', map: 'internet_protocol_FTP_adv_ListingCommandComboIndex', type: 'number' },
                        { name: 'internet_protocol_FTP_adv_verify_file', map: 'internet_protocol_FTP_adv_verify_file', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_respect_passive_mode', map: 'internet_protocol_FTP_adv_respect_passive_mode', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_TimestampsForUploadsComboIndex', map: 'internet_protocol_FTP_adv_TimestampsForUploadsComboIndex', type: 'number' },
                        { name: 'internet_protocol_FTP_adv_zone', map: 'internet_protocol_FTP_adv_zone', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_auto', map: 'internet_protocol_FTP_adv_auto', type: 'boolean' },
                        //{ name: 'internet_protocol_FTP_adv_UTC', map: 'internet_protocol_FTP_adv_UTC', type: 'boolean' },
                        { name: 'internet_protocol_FTP_adv_list', map: 'internet_protocol_FTP_adv_list', type: 'float' },
                        { name: 'internet_protocol_FTP_adv_upload_min', map: 'internet_protocol_FTP_adv_upload_min', type: 'float' },
                        { name: 'internet_protocol_FTP_adv_timeout', map: 'internet_protocol_FTP_adv_timeout', type: 'number' },
                        { name: 'internet_protocol_FTP_adv_retries', map: 'internet_protocol_FTP_adv_retries', type: 'number' },
                        { name: 'internet_protocol_FTP_adv_http_retries', map: 'internet_protocol_FTP_adv_http_retries', type: 'number' },
                        { name: 'internet_protocol_FTP_proxy_proxy_type', map: 'internet_protocol_FTP_proxy_proxy_type', type: 'number' },
                        { name: 'internet_protocol_FTP_proxy_proxy_host', map: 'internet_protocol_FTP_proxy_proxy_host', type: 'string' },
                        { name: 'internet_protocol_FTP_proxy_proxy_port', map: 'internet_protocol_FTP_proxy_proxy_port', type: 'number' },
                        { name: 'internet_protocol_FTP_proxy_login', map: 'internet_protocol_FTP_proxy_login', type: 'string' },
                        { name: 'internet_protocol_FTP_proxy_password', map: 'internet_protocol_FTP_proxy_password', type: 'string' },
                        { name: 'internet_protocol_FTP_proxy_send_host_command', map: 'internet_protocol_FTP_proxy_send_host_command', type: 'boolean' },
                        { name: 'internet_protocol_FTP_Security_Mode_Group', map: 'internet_protocol_FTP_Security_Mode_Group', type: 'string' },
                        { name: 'internet_protocol_FTP_Auth_Cmd_Group', map: 'internet_protocol_FTP_Security_Mode_Group', type: 'string' },
                        { name: 'internet_protocol_FTP_Version_Group', map: 'internet_protocol_FTP_Version_Group', type: 'string' },
                        { name: 'internet_protocol_FTP_Security_SSH_username_password', map: 'internet_protocol_FTP_Security_SSH_username_password', type: 'boolean' },
                        { name: 'internet_protocol_FTP_Security_SSH_keyboard', map: 'internet_protocol_FTP_Security_SSH_keyboard', type: 'boolean' },
                        { name: 'internet_protocol_FTP_Security_SSH_certificate', map: 'internet_protocol_FTP_Security_SSH_certificate', type: 'boolean' },
                        { name: 'internet_protocol_FTP_security_CertificateComboIndex', map: 'internet_protocol_FTP_security_CertificateComboIndex', type: 'number' },
                        { name: 'internet_protocol_FTP_security_CertificatePassword', map: 'internet_protocol_FTP_security_CertificatePassword', type: 'string' },
                        { name: 'internet_protocol_FTP_security_nopassword', map: 'internet_protocol_FTP_security_nopassword', type: 'boolean' },
                        { name: 'internet_protocol_FTP_certificates_certificates', map: 'internet_protocol_FTP_certificates_certificates', type: 'string' },
                        { name: 'internet_protocol_FTP_certificates_certname_forreference', map: 'internet_protocol_FTP_certificates_certname_forreference', type: 'string' },
                        { name: 'internet_protocol_FTP_certificates_private_keyfile', map: 'internet_protocol_FTP_certificates_private_keyfile', type: 'string' },
                        { name: 'internet_protocol_FTP_certificates_public_keyfile', map: 'internet_protocol_FTP_certificates_public_keyfile', type: 'string' } 
            
                        ] ;
                }   
                if( GetBaseProtocolName( ProtocolName ) == "SSH" )
                {
                   IntProtSetSource.datafields = [
                        { name: 'Name', type: 'string' },
                        { name: 'internet_protocol_SSH_LibraryComboIndex', map: 'internet_protocol_SSH_LibraryComboIndex', type: 'number' },  
                        { name: 'internet_protocol_SSH_url', map: 'internet_protocol_SSH_url', type: 'string' },
                        { name: 'internet_protocol_SSH_port_number', map: 'internet_protocol_SSH_port_number', type: 'number' },  
                        { name: 'internet_protocol_SSH_InternetFolder', map: 'internet_protocol_SSH_InternetFolder', type: 'string' },
                        { name: 'internet_protocol_SSH_login', map: 'internet_protocol_SSH_login', type: 'string' },
                        { name: 'internet_protocol_SSH_AccountOpt', map: 'internet_protocol_SSH_AccountOpt', type: 'string' },
                        { name: 'internet_protocol_SSH_save_password', map: 'internet_protocol_SSH_save_password', type: 'boolean' },

                        { name: 'internet_protocol_SSH_save_user_id', map: 'internet_protocol_SSH_save_user_id', type: 'boolean' },
                        { name: 'internet_protocol_SSH_allow_ipv6', map: 'internet_protocol_SSH_allow_ipv6', type: 'boolean' },


                        { name: 'internet_protocol_SSH_auto_resume_transfer', map: 'internet_protocol_SSH_auto_resume_transfer', type: 'boolean' },
                        { name: 'internet_protocol_SSH_adv_CharsetComboIndex', map: 'internet_protocol_SSH_adv_CharsetComboIndex', type: 'number' },  
                        { name: 'internet_protocol_SSH_adv_replace_characters', map: 'internet_protocol_SSH_adv_replace_characters', type: 'boolean' },
                        { name: 'internet_protocol_SSH_adv_recursive_listing', map: 'internet_protocol_SSH_adv_recursive_listing', type: 'boolean' },
                        { name: 'internet_protocol_SSH_adv_verify_destination_file', map: 'internet_protocol_SSH_adv_verify_destination_file', type: 'boolean' },
                        { name: 'internet_protocol_SSH_adv_zone', map: 'internet_protocol_SSH_adv_zone', type: 'boolean' },
                        { name: 'internet_protocol_SSH_adv_auto', map: 'internet_protocol_SSH_adv_auto', type: 'boolean' },
                        
                        { name: 'internet_protocol_SSH_adv_list', map: 'internet_protocol_SSH_adv_list', type: 'number' },  
                        { name: 'internet_protocol_SSH_adv_upload_min', map: 'internet_protocol_SSH_adv_upload_min', type: 'number' },  
                        { name: 'internet_protocol_SSH_adv_timeout', map: 'internet_protocol_SSH_adv_timeout', type: 'number' },  
                        { name: 'internet_protocol_SSH_adv_retries', map: 'internet_protocol_SSH_adv_retries', type: 'number' },  
                        { name: 'internet_protocol_SSH_adv_http_retries', map: 'internet_protocol_SSH_adv_http_retries', type: 'number' },  
                        { name: 'internet_protocol_SSH_proxy_proxy_type', map: 'internet_protocol_SSH_proxy_proxy_type', type: 'number' },  
                        { name: 'internet_protocol_SSH_proxy_proxy_host', map: 'internet_protocol_SSH_proxy_proxy_host', type: 'string' },  
                        { name: 'internet_protocol_SSH_proxy_proxy_port', map: 'internet_protocol_SSH_proxy_proxy_port', type: 'number' },  
                        { name: 'internet_protocol_SSH_proxy_user_id', map: 'internet_protocol_SSH_proxy_user_id', type: 'string' },  
                        { name: 'internet_protocol_SSH_proxy_password', map: 'internet_protocol_SSH_proxy_password', type: 'string' },  
                        { name: 'internet_protocol_SSH_proxy_send_host_command', map: 'internet_protocol_SSH_proxy_send_host_command', type: 'boolean' },
                        { name: 'internet_protocol_SSH_Security_SSH_username_password', map: 'internet_protocol_SSH_Security_SSH_username_password', type: 'boolean' },
                        { name: 'internet_protocol_SSH_Security_SSH_keyboard', map: 'internet_protocol_SSH_Security_SSH_keyboard', type: 'boolean' },
                        { name: 'internet_protocol_SSH_Security_SSH_certificate', map: 'internet_protocol_SSH_Security_SSH_certificate', type: 'boolean' },
                        { name: 'internet_protocol_SSH_security_CertificateComboIndex', map: 'internet_protocol_SSH_security_CertificateComboIndex', type: 'number' },  
                        { name: 'internet_protocol_SSH_security_CertificatePassword', map: 'internet_protocol_SSH_security_CertificatePassword', type: 'string' },  
                        { name: 'internet_protocol_SSH_security_nopassword', map: 'internet_protocol_SSH_security_nopassword', type: 'boolean' },
                        { name: 'internet_protocol_SSH_certificates_certificates', map: 'internet_protocol_SSH_certificates_certificates', type: 'string' },  
                        { name: 'internet_protocol_SSH_certificates_certname_forreference', map: 'internet_protocol_SSH_certificates_certname_forreference', type: 'string' },  
                        { name: 'internet_protocol_SSH_certificates_private_keyfile', map: 'internet_protocol_SSH_certificates_private_keyfile', type: 'string' },  
                        { name: 'internet_protocol_SSH_certificates_public_keyfile', map: 'internet_protocol_SSH_certificates_public_keyfile', type: 'string' }
                        ]
                }              
                else if( GetBaseProtocolName( ProtocolName ) == 'Google Drive'  )
                {

                    IntProtSetSource.datafields = [
                        { name: 'Name', type: 'string' },
                        { name: 'internet_protocol_GDrive_LibraryComboIndex', map: 'internet_protocol_GDrive_LibraryComboIndex', type: 'number' },   
                        { name: 'internet_protocol_GDrive_InternetFolder', map: 'internet_protocol_GDrive_InternetFolder', type: 'string' },                                             
                        { name: 'internet_protocol_GDrive_AccountOpt', map: 'internet_protocol_GDrive_AccountOpt', type: 'string' },                                             
                        { name: 'internet_protocol_GDrive_save_optional_accname', map: 'internet_protocol_GDrive_save_optional_accname', type: 'boolean' },                                             
                        { name: 'internet_protocol_GDrive_allow_ipv6', map: 'internet_protocol_GDrive_allow_ipv6', type: 'boolean' },                                             
                        { name: 'internet_protocol_GDrive_auto_resume_transfer', map: 'internet_protocol_GDrive_auto_resume_transfer', type: 'boolean' },                                             
                        { name: 'internet_protocol_GDrive_filename_encoding', map: 'internet_protocol_GDrive_filename_encoding', type: 'boolean' },                                             
                        { name: 'internet_protocol_GDrive_adv_Charset', map: 'internet_protocol_GDrive_adv_Charset', type: 'number' },                                             
                        { name: 'internet_protocol_GDrive_adv_replace_characters', map: 'internet_protocol_GDrive_adv_replace_characters', type: 'boolean' },                                             
                        { name: 'internet_protocol_GDrive_adv_enable_doc_convercion', map: 'internet_protocol_GDrive_adv_enable_doc_convercion', type: 'boolean' },                                                               
                        { name: 'internet_protocol_GDrive_adv_zone', map: 'internet_protocol_GDrive_adv_zone', type: 'boolean' },                                                               
                        { name: 'internet_protocol_GDrive_adv_auto', map: 'internet_protocol_GDrive_adv_auto', type: 'boolean' },                                                                                                                                                      
                        { name: 'internet_protocol_GDrive_adv_list', map: 'internet_protocol_GDrive_adv_list', type: 'number' },                                                               
                        { name: 'internet_protocol_GDrive_adv_upload_min', map: 'internet_protocol_GDrive_adv_upload_min', type: 'number' },                                                               
                        { name: 'internet_protocol_GDrive_adv_timeout', map: 'internet_protocol_GDrive_adv_timeout', type: 'number' },                                                               
                        { name: 'internet_protocol_GDrive_adv_retries', map: 'internet_protocol_GDrive_adv_retries', type: 'number' },                                                               
                        { name: 'internet_protocol_GDrive_adv_http_retries', map: 'internet_protocol_GDrive_adv_http_retries', type: 'number' },                                                               
                        { name: 'internet_protocol_GDrive_proxy_proxy_type', map: 'internet_protocol_GDrive_proxy_proxy_type', type: 'number' },                                                               
                        { name: 'internet_protocol_GDrive_proxy_proxy_host', map: 'internet_protocol_GDrive_proxy_proxy_host', type: 'string' },                                                               
                        { name: 'internet_protocol_GDrive_proxy_proxy_port', map: 'internet_protocol_GDrive_proxy_proxy_port', type: 'number' },                                                               
                        { name: 'internet_protocol_GDrive_proxy_login', map: 'internet_protocol_GDrive_proxy_login', type: 'string' },                                                               
                        { name: 'internet_protocol_GDrive_proxy_password', map: 'internet_protocol_GDrive_proxy_password', type: 'string' },                                                               
                        { name: 'internet_protocol_GDrive_proxy_send_host_command', map: 'internet_protocol_GDrive_proxy_send_host_command', type: 'boolean' },                                                               
                        { name: 'internet_protocol_GDrive_FormatSpreadsheets_Group', map: 'internet_protocol_GDrive_FormatSpreadsheets_Group', type: 'string' },                                                               
                        { name: 'internet_protocol_GDrive_FormatDownldDocs_Group', map: 'internet_protocol_GDrive_FormatDownldDocs_Group', type: 'string' },                                                               
                        { name: 'internet_protocol_GDrive_FormatDownldPres_Group', map: 'internet_protocol_GDrive_FormatDownldPres_Group', type: 'string' }, 
                        { name: 'internet_protocol_GDrive_FormatDownldDraw_Group', map: 'internet_protocol_GDrive_FormatDownldDraw_Group', type: 'string' },                                                               
                        
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_csv', map: 'internet_protocol_GDrive_GDocs_ftconvert_csv', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_html', map: 'internet_protocol_GDrive_GDocs_ftconvert_html', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_pdf', map: 'internet_protocol_GDrive_GDocs_ftconvert_pdf', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_pptx', map: 'internet_protocol_GDrive_GDocs_ftconvert_pptx', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_txt', map: 'internet_protocol_GDrive_GDocs_ftconvert_txt', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_doc', map: 'internet_protocol_GDrive_GDocs_ftconvert_doc', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_ods', map: 'internet_protocol_GDrive_GDocs_ftconvert_ods', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_pps', map: 'internet_protocol_GDrive_GDocs_ftconvert_pps', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_rtf', map: 'internet_protocol_GDrive_GDocs_ftconvert_rtf', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_xls', map: 'internet_protocol_GDrive_GDocs_ftconvert_xls', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_docx', map: 'internet_protocol_GDrive_GDocs_ftconvert_docx', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_odt', map: 'internet_protocol_GDrive_GDocs_ftconvert_odt', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_ppt', map: 'internet_protocol_GDrive_GDocs_ftconvert_ppt', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_tsv', map: 'internet_protocol_GDrive_GDocs_ftconvert_tsv', type: 'boolean' },                                                                                                                                                                                                                                                                                                    
                        { name: 'internet_protocol_GDrive_GDocs_ftconvert_xlsx', map: 'internet_protocol_GDrive_GDocs_ftconvert_xlsx', type: 'boolean' }                                                                                                                                                                                                                                                                                                                                                                
                    ]
                }
                else if( GetBaseProtocolName( ProtocolName ) == 'HTTP' )
                {

                    IntProtSetSource.datafields = [
                        { name: 'Name', type: 'string' },
                        { name: 'internet_protocol_HTTP_url', map: 'internet_protocol_HTTP_url', type: 'string' }, 
                        { name: 'internet_protocol_HTTP_port', map: 'internet_protocol_HTTP_port', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_InternetFolder', map: 'internet_protocol_HTTP_InternetFolder', type: 'string' }, 
                        { name: 'internet_protocol_HTTP_login', map: 'internet_protocol_HTTP_login', type: 'string' }, 
                        { name: 'internet_protocol_HTTP_AccountOpt', map: 'internet_protocol_HTTP_AccountOpt', type: 'string' }, 
                        { name: 'internet_protocol_HTTP_save_user_id', map: 'internet_protocol_HTTP_save_user_id', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                               
                        { name: 'internet_protocol_HTTP_save_password', map: 'internet_protocol_HTTP_save_password', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_allow_ipv6', map: 'internet_protocol_HTTP_allow_ipv6', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_auto_resume_transfer', map: 'internet_protocol_HTTP_auto_resume_transfer', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_download_and_parse', map: 'internet_protocol_HTTP_HTML_download_and_parse', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_parsing_limit', map: 'internet_protocol_HTTP_HTML_parsing_limit', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_HTML_enquire_timestamp', map: 'internet_protocol_HTTP_HTML_enquire_timestamp', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_enquire_precise_info', map: 'internet_protocol_HTTP_HTML_enquire_precise_info', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_download_default_pages', map: 'internet_protocol_HTTP_HTML_download_default_pages', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_consider_locally_existing_files', map: 'internet_protocol_HTTP_HTML_consider_locally_existing_files', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_assume_local_files', map: 'internet_protocol_HTTP_HTML_assume_local_files', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_avoid_re_downloading', map: 'internet_protocol_HTTP_HTML_avoid_re_downloading', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_HTML_LinksAboveComboIndex', map: 'internet_protocol_HTTP_HTML_LinksAboveComboIndex', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_HTML_LinksToOtherDomainsComboIndex', map: 'internet_protocol_HTTP_HTML_LinksToOtherDomainsComboIndex', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_adv_CharsetIndex', map: 'internet_protocol_HTTP_adv_CharsetIndex', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_adv_replace_characters', map: 'internet_protocol_HTTP_adv_replace_characters', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_adv_zone', map: 'internet_protocol_HTTP_adv_zone', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
                        { name: 'internet_protocol_HTTP_adv_auto', map: 'internet_protocol_HTTP_adv_auto', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                        { name: 'internet_protocol_HTTP_adv_list', map: 'internet_protocol_HTTP_adv_list', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_adv_upload_min', map: 'internet_protocol_HTTP_adv_upload_min', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_adv_timeout', map: 'internet_protocol_HTTP_adv_timeout', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_adv_retries', map: 'internet_protocol_HTTP_adv_retries', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_adv_http_retries', map: 'internet_protocol_HTTP_adv_http_retries', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_HTTP_proxy_proxy_typeComboIndex', map: 'internet_protocol_HTTP_HTTP_proxy_proxy_typeComboIndex', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_proxy_proxy_host', map: 'internet_protocol_HTTP_proxy_proxy_host', type: 'string' }, 
                        { name: 'internet_protocol_HTTP_proxy_proxy_port', map: 'internet_protocol_HTTP_proxy_proxy_port', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_proxy_login', map: 'internet_protocol_HTTP_proxy_login', type: 'string' }, 
                        { name: 'internet_protocol_HTTP_proxy_password', map: 'internet_protocol_HTTP_proxy_password', type: 'string' }, 
                        { name: 'internet_protocol_HTTP_proxy_send_host_command', map: 'internet_protocol_HTTP_proxy_send_host_command', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_Version_Group', map: 'internet_protocol_HTTP_Version_Group', type: 'string' },              
                        { name: 'internet_protocol_HTTP_Security_SSH_username_password', map: 'internet_protocol_HTTP_Security_SSH_username_password', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_Security_SSH_keyboard', map: 'internet_protocol_HTTP_Security_SSH_keyboard', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_Security_SSH_certificate', map: 'internet_protocol_HTTP_Security_SSH_certificate', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_security_CertificateIndex', map: 'internet_protocol_HTTP_security_CertificateIndex', type: 'number' }, 
                        { name: 'internet_protocol_HTTP_security_CertificatePassword', map: 'internet_protocol_HTTP_security_CertificatePassword', type: 'string' },              
                        { name: 'internet_protocol_HTTP_security_nopassword', map: 'internet_protocol_HTTP_security_nopassword', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_HTTP_certificates_certificates', map: 'internet_protocol_HTTP_certificates_certificates', type: 'string' },              
                        { name: 'internet_protocol_HTTP_certificates_certname_forreference', map: 'internet_protocol_HTTP_certificates_certname_forreference', type: 'string' },              
                        { name: 'internet_protocol_HTTP_certificates_private_keyfile', map: 'internet_protocol_HTTP_certificates_private_keyfile', type: 'string' },              
                        { name: 'internet_protocol_HTTP_certificates_public_keyfile', map: 'internet_protocol_HTTP_certificates_public_keyfile', type: 'string' }
                      ]              
              
                  } 
                  else if( GetBaseProtocolName( ProtocolName ) == 'Amazon S3' )
                  {

                    IntProtSetSource.datafields = [
                        { name: 'Name', type: 'string' },
                        { name: 'internet_protocol_AmazonS3_bucket', map: 'internet_protocol_AmazonS3_bucket', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_reduced_redundancy', map: 'internet_protocol_AmazonS3_reduced_redundancy', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_InternetFolder', map: 'internet_protocol_AmazonS3_InternetFolder', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_access_id', map: 'internet_protocol_AmazonS3_access_id', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_AccountOpt', map: 'internet_protocol_AmazonS3_AccountOpt', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_save_access_id', map: 'internet_protocol_AmazonS3_save_access_id', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_save_secret_key', map: 'internet_protocol_AmazonS3_save_secret_key', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_allow_ipv6', map: 'internet_protocol_AmazonS3_allow_ipv6', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_filename_encoding', map: 'internet_protocol_AmazonS3_filename_encoding', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_adv_CharsetIndex', map: 'internet_protocol_AmazonS3_adv_CharsetIndex', type: 'number' }, 
                        { name: 'internet_protocol_AmazonS3_adv_replace_characters', map: 'internet_protocol_AmazonS3_adv_replace_characters', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_make_uploaded_files_pub_available', map: 'internet_protocol_AmazonS3_make_uploaded_files_pub_available', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_recursive_listing', map: 'internet_protocol_AmazonS3_recursive_listing', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_use_server_side_encryption', map: 'internet_protocol_AmazonS3_use_server_side_encryption', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_adv_zone', map: 'internet_protocol_AmazonS3_adv_zone', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_adv_auto', map: 'internet_protocol_AmazonS3_adv_auto', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_adv_list', map: 'internet_protocol_AmazonS3_adv_list', type: 'number' }, 
                        { name: 'internet_protocol_AmazonS3_adv_upload_min', map: 'internet_protocol_AmazonS3_adv_upload_min', type: 'number' }, 
                        { name: 'internet_protocol_AmazonS3_adv_timeout', map: 'internet_protocol_AmazonS3_adv_timeout', type: 'number' }, 
                        { name: 'internet_protocol_AmazonS3_adv_retries', map: 'internet_protocol_AmazonS3_adv_retries', type: 'number' }, 
                        { name: 'internet_protocol_AmazonS3_adv_http_retries', map: 'internet_protocol_AmazonS3_adv_http_retries', type: 'number' }, 
                        { name: 'internet_protocol_AmazonS3_proxy_proxy_typeIndex', map: 'internet_protocol_AmazonS3_proxy_proxy_typeIndex', type: 'number' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_proxy_proxy_host', map: 'internet_protocol_AmazonS3_proxy_proxy_host', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_proxy_proxy_port', map: 'internet_protocol_AmazonS3_proxy_proxy_port', type: 'number' }, 
                        { name: 'internet_protocol_AmazonS3_proxy_login', map: 'internet_protocol_AmazonS3_proxy_login', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_proxy_password', map: 'internet_protocol_AmazonS3_proxy_password', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_proxy_send_host_command', map: 'internet_protocol_AmazonS3_proxy_send_host_command', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'IntProtSet_AmazonS3_Version_Group', map: 'IntProtSet_AmazonS3_Version_Group', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_Security_SSH_username_password', map: 'internet_protocol_AmazonS3_Security_SSH_username_password', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_Security_SSH_keyboard', map: 'internet_protocol_AmazonS3_Security_SSH_keyboard', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_Security_SSH_certificate', map: 'internet_protocol_AmazonS3_Security_SSH_certificate', type: 'boolean' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_Security_CertificateIndex', map: 'internet_protocol_AmazonS3_Security_CertificateIndex', type: 'number' },                                                                                                                                                                                                                                                                                                                                                                
                        { name: 'internet_protocol_AmazonS3_security_CertificatePassword', map: 'internet_protocol_AmazonS3_security_CertificatePassword', type: 'string' },  
                        { name: 'internet_protocol_AmazonS3_security_nopassword', map: 'internet_protocol_AmazonS3_security_nopassword', type: 'boolean' }                                                                                                                                                                                                                                                                                                                                                                
                       ] 
                              
                 }
                 else if( GetBaseProtocolName( ProtocolName ) == 'Asure' )
                 {
                    IntProtSetSource.datafields = [
                      { name: 'Name', type: 'string' },
                      { name: 'internet_protocol_Asure_container', map: 'internet_protocol_Asure_container', type: 'string' },  
                      { name: 'internet_protocol_Asure_InternetFolder', map: 'internet_protocol_Asure_InternetFolder', type: 'string' },  
                      { name: 'internet_protocol_Asure_account_id', map: 'internet_protocol_Asure_account_id', type: 'string' },  
                      { name: 'internet_protocol_Asure_AccountOpt', map: 'internet_protocol_Asure_AccountOpt', type: 'string' },  
                      { name: 'internet_protocol_Asure_save_user_id', map: 'internet_protocol_Asure_save_user_id', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_save_password', map: 'internet_protocol_Asure_save_password', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_allow_ipv6', map: 'internet_protocol_Asure_allow_ipv6', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_filename_encoding', map: 'internet_protocol_Asure_filename_encoding', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_adv_CharsetIndex', map: 'internet_protocol_Asure_adv_CharsetIndex', type: 'number' },  
                      { name: 'internet_protocol_Asure_adv_replace_characters', map: 'internet_protocol_Asure_adv_replace_characters', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_adv_recursive_listing', map: 'internet_protocol_Asure_adv_recursive_listing', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_adv_cache_control', map: 'internet_protocol_Asure_adv_cache_control', type: 'number' },  
                      { name: 'internet_protocol_Asure_adv_zone', map: 'internet_protocol_Asure_adv_zone', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_adv_auto', map: 'internet_protocol_Asure_adv_auto', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_adv_list', map: 'internet_protocol_Asure_adv_list', type: 'number' },  
                      { name: 'internet_protocol_Asure_adv_upload_min', map: 'internet_protocol_Asure_adv_upload_min', type: 'number' },  
                      { name: 'internet_protocol_Asure_adv_timeout', map: 'internet_protocol_Asure_adv_timeout', type: 'number' },  
                      { name: 'internet_protocol_Asure_adv_retries', map: 'internet_protocol_Asure_adv_retries', type: 'number' },  
                      { name: 'internet_protocol_Asure_adv_http_retries', map: 'internet_protocol_Asure_adv_http_retries', type: 'number' },  
                      { name: 'internet_protocol_Asure_proxy_proxy_typeIndex', map: 'internet_protocol_Asure_proxy_proxy_typeIndex', type: 'number' },  
                      { name: 'internet_protocol_Asure_proxy_proxy_host', map: 'internet_protocol_Asure_proxy_proxy_host', type: 'string' },  
                      { name: 'internet_protocol_Asure_proxy_proxy_port', map: 'internet_protocol_Asure_proxy_proxy_port', type: 'number' },  
                      { name: 'internet_protocol_Asure_proxy_login', map: 'internet_protocol_Asure_proxy_login', type: 'string' },  
                      { name: 'internet_protocol_Asure_proxy_password', map: 'internet_protocol_Asure_proxy_password', type: 'string' },  
                      { name: 'internet_protocol_Asure_proxy_send_host_command', map: 'internet_protocol_Asure_proxy_send_host_command', type: 'boolean' },  
                      { name: 'IntProtSet_Asure_Version_Group', map: 'IntProtSet_Asure_Version_Group', type: 'string' },  
                      { name: 'internet_protocol_Asure_Security_SSH_username_password', map: 'internet_protocol_Asure_Security_SSH_username_password', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_Security_SSH_keyboard', map: 'internet_protocol_Asure_Security_SSH_keyboard', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_Security_SSH_certificate', map: 'internet_protocol_Asure_Security_SSH_certificate', type: 'boolean' },  
                      { name: 'internet_protocol_Asure_security_CertificateIndex', map: 'internet_protocol_Asure_security_CertificateIndex', type: 'number' },  
                      { name: 'internet_protocol_Asure_security_CertificatePassword', map: 'internet_protocol_Asure_security_CertificatePassword', type: 'string' },  
                      { name: 'internet_protocol_Asure_security_nopassword', map: 'internet_protocol_Asure_security_nopassword', type: 'boolean' }
                    ]                       
                }
                else if( GetBaseProtocolName( ProtocolName ) == 'WebDAV' )
                { 
                    IntProtSetSource.datafields = [
                      { name: 'Name', type: 'string' },
                      { name: 'internet_protocol_WebDAV_LibraryComboIndex', map: 'internet_protocol_WebDAV_LibraryComboIndex', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_url', map: 'internet_protocol_WebDAV_url', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_AuthenticationComboIndex', map: 'internet_protocol_WebDAV_AuthenticationComboIndex', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_InternetFolder', map: 'internet_protocol_WebDAV_InternetFolder', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_login', map: 'internet_protocol_WebDAV_login', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_AccountOpt', map: 'internet_protocol_WebDAV_AccountOpt', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_save_user_id', map: 'internet_protocol_WebDAV_save_user_id', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_save_password', map: 'internet_protocol_WebDAV_save_password', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_allow_ipv6', map: 'internet_protocol_WebDAV_allow_ipv6', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_filename_encoding', map: 'internet_protocol_WebDAV_filename_encoding', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_adv_CharsetComboIndex', map: 'internet_protocol_WebDAV_adv_CharsetComboIndex', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_adv_replace_characters', map: 'internet_protocol_WebDAV_adv_replace_characters', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_adv_strategyCombo', map: 'internet_protocol_WebDAV_adv_strategyCombo', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_adv_use_displayname', map: 'internet_protocol_WebDAV_adv_use_displayname', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_adv_use_expect_100_continue', map: 'internet_protocol_WebDAV_adv_use_expect_100_continue', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_adv_TimestampsForUploads', map: 'internet_protocol_WebDAV_adv_TimestampsForUploads', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_adv_zone', map: 'internet_protocol_WebDAV_adv_zone', type: 'boolean' },  
                      { name: 'internet_protocol_WebDAV_adv_auto', map: 'internet_protocol_WebDAV_adv_auto', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_adv_list', map: 'internet_protocol_WebDAV_adv_list', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_adv_upload_min', map: 'internet_protocol_WebDAV_adv_upload_min', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_adv_timeout', map: 'internet_protocol_WebDAV_adv_timeout', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_adv_retries', map: 'internet_protocol_WebDAV_adv_retries', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_adv_http_retries', map: 'internet_protocol_WebDAV_adv_http_retries', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_proxy_proxy_type', map: 'internet_protocol_WebDAV_proxy_proxy_type', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_proxy_proxy_host', map: 'internet_protocol_WebDAV_proxy_proxy_host', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_proxy_proxy_port', map: 'internet_protocol_WebDAV_proxy_proxy_port', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_proxy_login', map: 'internet_protocol_WebDAV_proxy_login', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_proxy_password', map: 'internet_protocol_WebDAV_proxy_password', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_proxy_send_host_command', map: 'internet_protocol_WebDAV_proxy_send_host_command', type: 'boolean' },
                      { name: 'IntProtSet_WebDAV_Version_Group', map: 'IntProtSet_WebDAV_Version_Group', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_Security_SSH_username_password', map: 'internet_protocol_WebDAV_Security_SSH_username_password', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_Security_SSH_keyboard', map: 'internet_protocol_WebDAV_Security_SSH_keyboard', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_Security_SSH_certificate', map: 'internet_protocol_WebDAV_Security_SSH_certificate', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_security_CertificateComboIndex', map: 'internet_protocol_WebDAV_security_CertificateComboIndex', type: 'number' },  
                      { name: 'internet_protocol_WebDAV_security_CertificatePassword', map: 'internet_protocol_WebDAV_security_CertificatePassword', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_security_nopassword', map: 'internet_protocol_WebDAV_security_nopassword', type: 'boolean' },
                      { name: 'internet_protocol_WebDAV_certificates_certificates', map: 'internet_protocol_WebDAV_certificates_certificates', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_certificates_certname_forreference', map: 'internet_protocol_WebDAV_certificates_certname_forreference', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_certificates_private_keyfile', map: 'internet_protocol_WebDAV_certificates_private_keyfile', type: 'string' },  
                      { name: 'internet_protocol_WebDAV_certificates_public_keyfile', map: 'internet_protocol_WebDAV_certificates_public_keyfile', type: 'string' }  
         
                      ]              

                }                       
                else if( GetBaseProtocolName( ProtocolName ) == 'RSync' )
                { 
                    IntProtSetSource.datafields = [
                      { name: 'Name', type: 'string' },
                      { name: 'internet_protocol_RSync_LibraryComboIndex', map: 'internet_protocol_RSync_LibraryComboIndex', type: 'number' },  
                      { name: 'internet_protocol_Rsync_url', map: 'internet_protocol_Rsync_url', type: 'string' },  
                      { name: 'internet_protocol_Rsync_port_number', map: 'internet_protocol_Rsync_port_number', type: 'number' },  
                      { name: 'internet_protocol_Rsync_InternetFolder', map: 'internet_protocol_Rsync_InternetFolder', type: 'string' },  
                      { name: 'internet_protocol_Rsync_login', map: 'internet_protocol_Rsync_login', type: 'string' },  
                      { name: 'internet_protocol_Rsync_AccountOpt', map: 'internet_protocol_Rsync_AccountOpt', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_save_user_id', map: 'internet_protocol_Rsync_save_user_id', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_save_password', map: 'internet_protocol_Rsync_save_password', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_allow_ipv6', map: 'internet_protocol_Rsync_allow_ipv6', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_adv_CharsetComboIndex', map: 'internet_protocol_Rsync_adv_CharsetComboIndex', type: 'number' },  
                      { name: 'internet_protocol_Rsync_adv_replace_characters', map: 'internet_protocol_Rsync_adv_replace_characters', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_adv_TimestampsForUploadsComboIndex', map: 'internet_protocol_Rsync_adv_TimestampsForUploadsComboIndex', type: 'number' },  
                      { name: 'internet_protocol_Rsync_adv_zone', map: 'internet_protocol_Rsync_adv_zone', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_adv_auto', map: 'internet_protocol_Rsync_adv_auto', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_adv_list', map: 'internet_protocol_Rsync_adv_list', type: 'number' },  
                      { name: 'internet_protocol_Rsync_adv_upload_min', map: 'internet_protocol_Rsync_adv_upload_min', type: 'number' },  
                      { name: 'internet_protocol_Rsync_adv_timeout', map: 'internet_protocol_Rsync_adv_timeout', type: 'number' },  
                      { name: 'internet_protocol_Rsync_adv_retries', map: 'internet_protocol_Rsync_adv_retries', type: 'number' },  
                      { name: 'internet_protocol_Rsync_adv_http_retries', map: 'internet_protocol_Rsync_adv_http_retries', type: 'number' },  
                      { name: 'internet_protocol_Rsync_proxy_proxy_typeComboIndex', map: 'internet_protocol_Rsync_proxy_proxy_typeComboIndex', type: 'number' },  
                      { name: 'internet_protocol_Rsync_proxy_proxy_host', map: 'internet_protocol_Rsync_proxy_proxy_host', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_proxy_proxy_port', map: 'internet_protocol_Rsync_proxy_proxy_port', type: 'number' },  
                      { name: 'internet_protocol_Rsync_proxy_login', map: 'internet_protocol_Rsync_proxy_login', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_proxy_password', map: 'internet_protocol_Rsync_proxy_password', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_proxy_send_host_command', map: 'internet_protocol_Rsync_proxy_send_host_command', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_Security_SSH_username_password', map: 'internet_protocol_Rsync_Security_SSH_username_password', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_Security_SSH_keyboard', map: 'internet_protocol_Rsync_Security_SSH_keyboard', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_Security_SSH_certificate', map: 'internet_protocol_Rsync_Security_SSH_certificate', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_security_CertificateIndex', map: 'internet_protocol_Rsync_security_CertificateIndex', type: 'number' },  
                      { name: 'internet_protocol_Rsync_security_CertificatePassword', map: 'internet_protocol_Rsync_security_CertificatePassword', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_security_nopassword', map: 'internet_protocol_Rsync_security_nopassword', type: 'boolean' },  
                      { name: 'internet_protocol_Rsync_proxy_login', map: 'internet_protocol_Rsync_proxy_login', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_certificates_certificates', map: 'internet_protocol_Rsync_certificates_certificates', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_certificates_certname_forreference', map: 'internet_protocol_Rsync_certificates_certname_forreference', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_certificates_private_keyfile', map: 'internet_protocol_Rsync_certificates_private_keyfile', type: 'string' },                          
                      { name: 'internet_protocol_Rsync_certificates_public_keyfile', map: 'internet_protocol_Rsync_certificates_public_keyfile', type: 'string' }                          
                      
                    ]
                }                              
                else if( GetBaseProtocolName( ProtocolName ) == 'Glacier' )
                { 
                    IntProtSetSource.datafields = [
                      { name: 'Name', type: 'string' },
                      { name: 'internet_protocol_Glacier_Vault', map: 'internet_protocol_Glacier_Vault', type: 'string' },                          
                      { name: 'internet_protocol_Glacier_RegionComboIndex', map: 'internet_protocol_Glacier_RegionComboIndex', type: 'number' },  
                      { name: 'internet_protocol_Glacier_InternetFolder', map: 'internet_protocol_Glacier_InternetFolder', type: 'string' },                                                
                      { name: 'internet_protocol_Glacier_AccountOpt', map: 'internet_protocol_Glacier_AccountOpt', type: 'string' }, 

                      { name: 'internet_protocol_Glacier_save_access_id', map: 'internet_protocol_Glacier_save_access_id', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_save_password', map: 'internet_protocol_Glacier_save_password', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_allow_ipv6', map: 'internet_protocol_Glacier_allow_ipv6', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_filename_encoding', map: 'internet_protocol_Glacier_filename_encoding', type: 'boolean' },  
                        

                      { name: 'internet_protocol_Glacier_adv_CharsetComboIndex', map: 'internet_protocol_Glacier_adv_CharsetComboIndex', type: 'number' },  
                      { name: 'internet_protocol_Glacier_adv_replace_characters', map: 'internet_protocol_Glacier_adv_replace_characters', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_recursive_listing', map: 'internet_protocol_Glacier_recursive_listing', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_adv_zone', map: 'internet_protocol_Glacier_adv_zone', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_adv_auto', map: 'internet_protocol_Glacier_adv_auto', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_adv_list', map: 'internet_protocol_Glacier_adv_list', type: 'number' },  
                      { name: 'internet_protocol_Glacier_adv_upload_min', map: 'internet_protocol_Glacier_adv_upload_min', type: 'number' },              
                      { name: 'internet_protocol_Glacier_adv_timeout', map: 'internet_protocol_Glacier_adv_timeout', type: 'number' }, 
                      { name: 'internet_protocol_Glacier_adv_retries', map: 'internet_protocol_Glacier_adv_retries', type: 'number' }, 
                      { name: 'internet_protocol_Glacier_adv_http_retries', map: 'internet_protocol_Glacier_adv_http_retries', type: 'number' }, 
                      { name: 'internet_protocol_Glacier_proxy_proxy_typeComboIndex', map: 'internet_protocol_Glacier_proxy_proxy_typeComboIndex', type: 'number' }, 
                      { name: 'internet_protocol_Glacier_proxy_proxy_host', map: 'internet_protocol_Glacier_proxy_proxy_host', type: 'string' },                          
                      { name: 'internet_protocol_Glacier_proxy_proxy_port', map: 'internet_protocol_Glacier_proxy_proxy_port', type: 'number' }, 
                      { name: 'internet_protocol_Glacier_proxy_login', map: 'internet_protocol_Glacier_proxy_login', type: 'string' },                          
                      { name: 'internet_protocol_Glacier_proxy_password', map: 'internet_protocol_Glacier_proxy_password', type: 'string' },                          
                      { name: 'internet_protocol_Glacier_proxy_send_host_command', map: 'internet_protocol_Glacier_proxy_send_host_command', type: 'boolean' },  
                      { name: 'IntProtSet_Glacier_Security_Mode_Group', map: 'IntProtSet_Glacier_Security_Mode_Group', type: 'string' },                          
                      { name: 'internet_protocol_Glacier_Security_SSH_username_password', map: 'internet_protocol_Glacier_Security_SSH_username_password', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_Security_SSH_keyboard', map: 'internet_protocol_Glacier_Security_SSH_keyboard', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_Security_SSH_certificate', map: 'internet_protocol_Glacier_Security_SSH_certificate', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_security_Certificate', map: 'internet_protocol_Glacier_security_Certificate', type: 'boolean' },  
                      { name: 'internet_protocol_Glacier_security_CertificatePassword', map: 'internet_protocol_Glacier_security_CertificatePassword', type: 'string' },                          
                      { name: 'internet_protocol_Glacier_security_nopassword', map: 'internet_protocol_Glacier_security_nopassword', type: 'boolean' }
                    ]
                }                                                                            

                     
                                 
             
}

function DoInternetSettingsDialogLeft( ProfileName, ProtocolName )
{
    if( ProtocolName == undefined )               
       ProtocolName = "FTP";
    
    if( GInternetProtocolSetLEFTRegistryList.length == 0 ) 
    {
        GInternetProtocolSetLEFTRegistryList = deepCopy( GInternetProtocolSetRegistryList );  //GInternetProtocolSetRegistryList.slice();//                                        
        InitProtocolSettingsDatasource( GIntProtSetSource, ProfileName, "Left", ProtocolName ); 

        var IntProtSetDataAdapter = new $.jqx.dataAdapter(GIntProtSetSource, 
                       
        { loadComplete: function () 
            {
              // get data records.
              
              if( IntProtSetDataAdapter.records.length == 1)
              {
                var record = IntProtSetDataAdapter.records[0];
                
                LoadRecordToRegistryList(record, GInternetProtocolSetLEFTRegistryList, GetBaseProtocolName( ProtocolName ) );
                InitProtocolSettingsForm( ProfileName, GInternetProtocolSetLEFTRegistryList, "Left", ProtocolName );                          
              }
                                   
            } 
            , 
            loadError: function (jqXHR, status, error) { alert(error) } 
         }); 
                             
         IntProtSetDataAdapter.dataBind();
     }
     else
       InitProtocolSettingsForm( ProfileName, GInternetProtocolSetLEFTRegistryList, "Left", ProtocolName );
}

function DoInternetSettingsDialogRight( ProfileName, ProtocolName )
{
    if( ProtocolName == undefined )               
       ProtocolName = "FTP";
    
    if( GInternetProtocolSetRIGHTRegistryList.length == 0 ) 
    {
        GInternetProtocolSetRIGHTRegistryList = deepCopy( GInternetProtocolSetRegistryList );  //GInternetProtocolSetRegistryList.slice();//                                        
        InitProtocolSettingsDatasource( GIntProtSetSource, ProfileName, "Right", ProtocolName ); 

        var IntProtSetDataAdapter = new $.jqx.dataAdapter(GIntProtSetSource, 
                       
        { loadComplete: function () 
            {
              // get data records.
              
              if( IntProtSetDataAdapter.records.length == 1)
              {
                var record = IntProtSetDataAdapter.records[0];
                
                LoadRecordToRegistryList(record, GInternetProtocolSetRIGHTRegistryList, GetBaseProtocolName( ProtocolName ) );
                InitProtocolSettingsForm( ProfileName, GInternetProtocolSetRIGHTRegistryList, "Right", ProtocolName );                          
              }
                                   
            } 
            , 
            loadError: function (jqXHR, status, error) { alert(error) } 
         }); 
                             
         IntProtSetDataAdapter.dataBind();
     }
     else
       InitProtocolSettingsForm( ProfileName, GInternetProtocolSetRIGHTRegistryList, "Right", ProtocolName );
}


function InitProfileEditorForm( ProfileName )
{
              GSelectedProfileName = ProfileName;                
              GInternetProtocolSetLEFTRegistryList = [];
              GInternetProtocolSetRIGHTRegistryList = [];

              $("#ProfileEditorForm_div").html( ProfileEditorFormHTML );   


//Profile settings Dialog  
              $('#jqxProfileEditorForm').jqxWindow({ maxWidth: GProfileSettingsDialogWidth,  width: GProfileSettingsDialogWidth, maxHeight: GProfileSettingsDialogHeight, height: GProfileSettingsDialogHeight, autoOpen: false, isModal: true,  theme: 'energyblue',
    animationType: 'slide' });
              
              


            // Create jqxButton widgets.
               

                $("#NoneMode").jqxRadioButton({ groupName: 'IncludeSubfoldersWidget', rtl: false});//

                $("#AllMode").jqxRadioButton({ groupName: 'IncludeSubfoldersWidget', rtl: false});

                $("#SelectedMode").jqxRadioButton( { groupName: 'IncludeSubfoldersWidget', rtl: false});

               


              //  $("#SyncOperationModeWidget").jqxButtonGroup({mode:'radio', width : "600"});
                
                $("#Standard_Copying_Mode").jqxRadioButton({ groupName: 'SyncOperationModeWidget', rtl: false});

                $("#SmartTracking_Mode").jqxRadioButton( { groupName: 'SyncOperationModeWidget', rtl: false} );

                $("#Exact_Mirror_Mode").jqxRadioButton( { groupName: 'SyncOperationModeWidget', rtl: false} );

                $("#Move_Files_Mode").jqxRadioButton( { groupName: 'SyncOperationModeWidget', rtl: false} );

               

 
            $("#infoButton1").jqxButton({ template: "info" }); 
            $('#infoButton1').click(function () {
               InitDirTreeSelectForm();
               GLeftRightSideInput = $("#inptLeftHandSide"); 
               $('#jqxwindow2').on('close', function (event) { $('#jqxwindow2').jqxWindow('destroy'); });               
               $("#jqxwindow2").jqxWindow('open') 
            }); 



            $("#infoButton2").jqxButton({ template: "info" }); 
            $('#infoButton2').click(function () {
               InitDirTreeSelectForm();              
               GLeftRightSideInput = $("#inptRightHandSide"); 
               $('#jqxwindow2').on('close', function (event) { $('#jqxwindow2').jqxWindow('destroy'); });               
               $("#jqxwindow2").jqxWindow('open') 
            }); 


            $("#intrntBtnLeft").jqxButton({ template: "info" }); 
            $('#intrntBtnLeft').click(function () 
            {
               GLeftRightSideInput = $("#inptLeftHandSide");
               DoInternetSettingsDialogLeft( GSelectedProfileName, GLeftProtocolName );                                                                          
            });

            $("#intrntBtnRight").jqxButton({ template: "info" }); 
            $('#intrntBtnRight').click(function () 
            {                                        
               GLeftRightSideInput = $("#inptRightHandSide");              
               DoInternetSettingsDialogRight( GSelectedProfileName, GRightProtocolName );                                                                         
            });



            $("#jqxLeftToRightCb").jqxCheckBox({ width: 120, height: 25});
            $("#jqxRightToLeftCb").jqxCheckBox({ width: 120, height: 25});


         


///Tab Control
                

                var initWidgets = function (tab) 
                {
                    switch (tab) {
                    case 0:
                        $('#jqxTabsShedule').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight }); 
                        break;
                    case 1:
                        $('#jqxTabsAccessAndRetries').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});    
                        break;
                    case 2:    
                        $('#jqxTabsComparison').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});
                        break;
                    case 3:    
                       $('#jqxTabsFiles').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});
                       break;
                    case 6:   
                       $('#jqxTabsMasksAndFilters').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});
                       break;
                    case 7:   
                      $('#jqxTabsSafety').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});
                      break;
                    case 8:  
                      $('#jqxTabsSpecial').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});
                      break;
                    case 9:
                      $('#jqxTabsVersioning').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});
                      break;
                    case 10:   
                      $('#jqxTabsZip').jqxTabs({ width: GProfileSettingsTabControlWidth - 10, height: GProfileSettingsTabControlHeight});
                      break;
                    }
                }
            $('#jqxTabs').jqxTabs({ width: GProfileSettingsTabControlWidth,   initTabContent: initWidgets });








//Tab Shedule/Shedule
            $("#jqxSheduleThisProfileCb").jqxCheckBox({ width: 120, height: 25});
            $("#jqxSpecifyNextRunCb").jqxCheckBox({ width: 120, height: 25});
            $("#jqxIntervalSpecificationCb").jqxCheckBox({ width: 120, height: 25});


            //$("#RunModeRadiogroupWidget").jqxButtonGroup({mode:'radio', width: "400"});
            $("#Run_Every_Day_Radio_Mode").jqxRadioButton({ groupName: 'RunModeRadiogroupWidget', rtl: false});
            $("#Repeat_after_Radio_Mode").jqxRadioButton({ groupName: 'RunModeRadiogroupWidget', rtl: false});
            $("#Repeat_monthly_Radio_Mode").jqxRadioButton({ groupName: 'RunModeRadiogroupWidget', rtl: false});
            $("#Run_only_Once_Radio_Mode").jqxRadioButton({ groupName: 'RunModeRadiogroupWidget', rtl: false});
                        
            


           $("#jqxRun_Every_Day_Time_Input").jqxDateTimeInput({ width: '100px', height: '25px', formatString: 'T', showCalendarButton: false});
           $("#inptScheduleDays").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "31", spinButtons: true }); 
           $("#inptScheduleHours").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "24", spinButtons: true });
           $("#inptScheduleMinutes").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "60", spinButtons: true });
           $("#inptScheduleSec").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "60", spinButtons: true });

           //Tab Shedule/More
           $("#jqxSheduleRunUponWinLoginCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSheduleRunUponShutdownAndLogOutCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSheduleRunMissedDaylyJobCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSheduleAddRandomDelayUpToCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSheduleWarnIfProfileNotRunForCb").jqxCheckBox({ width: 120, height: 25});
           
           $("#jqxAddRandomDelay_Time_Input").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "60", spinButtons: true }); 
           
            $("#jqxWarnIfProfileNotRunFor_Time_Input").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "31", spinButtons: true }); 


          // Tab Shedule/Weekdays
          $("#jqxMondayCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxTuesdayCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxWednesdayCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxThursdayCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFridayCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSaturdayCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSundayCb").jqxCheckBox({ width: 120, height: 25});



          //Tab Shedule Monitoring/Realtime
          $("#jqxRealTimeSynchronizationCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxRealContinuousSyncCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxRealProfileAsSoonAsDriveAvailableCb").jqxCheckBox({ width: 120, height: 25});


          //Tab AccessAndRetries/File Access
          
          
          //$("#VolumeShadowingRadiogroupWidget").jqxButtonGroup({mode:'radio', height: "100", width: "450"});
          $("#Do_not_Use_Radio_Mode").jqxRadioButton({ groupName: 'VolumeShadowingRadiogroupWidget', rtl: false});  
          $("#Use_to_copy_locked_files_Radio_Mode").jqxRadioButton({ groupName: 'VolumeShadowingRadiogroupWidget', rtl: false});  
          $("#Use_for_all_files_Radio_Mode").jqxRadioButton({ groupName: 'VolumeShadowingRadiogroupWidget', rtl: false});  
          $("#Use_for_all_Create_Radio_Mode").jqxRadioButton({ groupName: 'VolumeShadowingRadiogroupWidget', rtl: false});  

          $("#jqxFADatabaseSafeCopyCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFATakeAdminOwnershipCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFAVerifyOpeningPriorCopyCb").jqxCheckBox({ width: 120, height: 25});
                                    



          //Tab AccessAndRetries/Wait and Retry
          $("#jqxWRWaitForFileAccessCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxWRWaitIfTransferProblemCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxWRBuildingFileListCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxWRBuildingFileListCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxWRRunningTheProfileCb").jqxCheckBox({ width: 120, height: 25});
          
          $("#inptWRWaitUpToMin").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "60", spinButtons: true });
         

         
          //$("#WRReRunRadiogroupWidget").jqxButtonGroup({mode:'radio', width: "580px" });
          $("#Re_Run_Once_Radio_Mode").jqxRadioButton({ groupName: 'WRReRunRadiogroupWidget', rtl: false});
          $("#Re_Run_Until_Success_Radio_Mode").jqxRadioButton({ groupName: 'WRReRunRadiogroupWidget', rtl: false});
          $("#Max_Re_Runs_Radio_Mode").jqxRadioButton({ groupName: 'WRReRunRadiogroupWidget', rtl: false}); 
          $("#inptWRMaxReRuns").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0",  spinButtons: true });
          $("#inptWRRetryAfter").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0",  max: "60", spinButtons: true });
          $("#jqxWRAvoidRerunDueToLockedCb").jqxCheckBox({ width: 120, height: 25});
          

          //Tab Comparison Comparison
          $("#jqxComparIgnoreSmallTimeDiffCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparIgnoreExactHourTimeDiffCb").jqxCheckBox({ width: 120, height: 25});
          $("#inptComparIgnoreSec").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0",  max: "60", spinButtons: true });
          $("#inptComparIgnoreHours").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0",  max: "24", spinButtons: true });
          $("#jqxComparIgnoreSecondsCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparIgnoreTimestampAlltogetherCb").jqxCheckBox({ width: 120, height: 25});
                    
          //$("#ComparWhenSizeIsDiffentRadiogroupWidget").jqxButtonGroup({mode:'radio', width: "280"});
          $("#Ask_Radio_Mode").jqxRadioButton({ groupName: 'ComparWhenSizeIsDiffentRadiogroupWidget', rtl: false});
          $("#Copy_Left_To_Right_Radio_Mode").jqxRadioButton({ groupName: 'ComparWhenSizeIsDiffentRadiogroupWidget', rtl: false});
          $("#Copy_Right_To_Left_Radio_Mode").jqxRadioButton({ groupName: 'ComparWhenSizeIsDiffentRadiogroupWidget', rtl: false}); 
          $("#Copy_Larger_Files_Radio_Mode").jqxRadioButton({ groupName: 'ComparWhenSizeIsDiffentRadiogroupWidget', rtl: false}); 

          //Tab Comparison More
          $("#jqxComparMoreAlwaysCopyFilesCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreBinaryComparisonCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreBinaryLeftSideCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreBinaryRightSideCb").jqxCheckBox({ width: 120, height: 25});


          $("#jqxComparMoreFileAttributeComparisonCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreCaseSencivityCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreVerifySyncStatisticsCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreFolderAttributeComparisonCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreFolderTimestampComparisonCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreDetectHardLinksCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxComparMoreEnforceHardLinksCb").jqxCheckBox({ width: 120, height: 25});
                                 
          //Tab Files Files
          $("#jqxFilesDetectMovedFilesCb").jqxCheckBox({ width: 120, height: 25});
          
          //$("#FilesDetectMovedFilesRadiogroupWidget").jqxButtonGroup({mode:'radio', width:"150"});
          $("#Files_Left_Radio_Mode").jqxRadioButton({ groupName: 'FilesDetectMovedFilesRadiogroupWidget', rtl: false});
          $("#Files_Right_Radio_Mode").jqxRadioButton({ groupName: 'FilesDetectMovedFilesRadiogroupWidget', rtl: false});

          $("#jqxFilesDetectRenamedFilesCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesVerifyCopiedFilesCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesReCopyOnceCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesAutomaticallyResumeCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesProtectFromBeingReplacedCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesDoNotScanDestinationCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesBypassFilesBufferingCb").jqxCheckBox({ width: 120, height: 25});
          $("#inptFilesNumberToCopyInparallel").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0",  max: "3", spinButtons: true });
                                              
          //Tab Files Deletions
          $("#jqxFilesDeletions_OverritenFiles").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesDeletions_DeletedFiles").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesDeletions_MoveFilesToSFolder").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesDeletions_DeleteOlderVersionsPermamently").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesDeletions_DoubleCheckNonExistence").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesDeletions_NeverDelete").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesDeletions_DeleteBeforeCopying").jqxCheckBox({ width: 120, height: 25});           

          //Tab Files More
          $("#jqxFilesMore_UseWindowsApi").jqxCheckBox({ width: 120, height: 25});
          $("#jqxFilesMore_SpeedLimit").jqxCheckBox({ width: 120, height: 25});
    
          //$("#inptFilesMore_SpeedLimit").jqxNumberInput({ width: 150, height: 25, inputMode: 'simple', spinButtons: false });
          
          
          $("#jqxFilesMore_NeverReplace").jqxCheckBox({ width: 120, height: 25});              
          $("#jqxFilesMore_AlwaysAppend").jqxCheckBox({ width: 120, height: 25});                            
          $("#jqxFilesMore_AlwaysConsider").jqxCheckBox({ width: 120, height: 25});                                          
          $("#jqxFilesMore_CheckDestinationFile").jqxCheckBox({ width: 120, height: 25});                                                        
          $("#jqxFilesMore_AndCompareFileDetails").jqxCheckBox({ width: 120, height: 25});                                                                      
          $("#jqxFilesMore_CopiedFilesSysTime").jqxCheckBox({ width: 120, height: 25});                                                                      
          $("#jqxFilesMore_PreserveLastAccessOnSource").jqxCheckBox({ width: 120, height: 25});                                                                      
          $("#jqxFilesMore_CopyOnlyFilesPerRun").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#inptFilesMore_FilesPerRun").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", spinButtons: true }); 
          $("#jqxFilesMore_IgnoreGlobalSpeedLimit").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#jqxFilesMore_DontAddAnyFiles").jqxCheckBox({ width: 120, height: 25});                                                                                    
           
          //Tab Folders
          $("#jqxFolders_CreateEmptyFolders").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#jqxFolders_RemoveEmptiedFolders").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#jqxFolders_OnRightSideCreateFolderEachTime").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#jqxFolders_IncludeTimeOfDay").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#jqxFolders_FlatRightSide").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#jqxFolders_CopyLatestFileIfExists").jqxCheckBox({ width: 120, height: 25});                                                                                    
          $("#jqxFolders_EnsureFolderTimestamps").jqxCheckBox({ width: 120, height: 25});                                                                                        
          $("#jqxFolders_UseIntermediateLocation").jqxCheckBox({ width: 120, height: 25});                                                                                            
              
          //Tab Job


          $("#jqxJob_ExecuteCommand").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_OverrideEmailSettings").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_RunAsUser").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_NetworkConnections").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_VerifyRightSideVolume").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_UseExternalCopyingTool").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_ShowCheckboxesInPreview").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_CheckFreeSpaceBeforeCopying").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_IgnoreInternetConnectivityCheck").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_WhenRunViaSheduler").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_WhenRunManuallyUnattended").jqxCheckBox({ width: 120, height: 25});
          $("#jqxJob_WhenRunManuallyAttended").jqxCheckBox({ width: 120, height: 25});
          
          //Tab Masks and Filters  
            
          $("#jqxMasks_SpecFolderMasksCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxMasks_RestrictionsCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxMasks_IncludeBackupFilesCb").jqxCheckBox({ width: 120, height: 25});

          $("#jqxMasks_UseGlobalExclAlsoCb").jqxCheckBox({ width: 120, height: 25});

          //$("#ExclucionFilesWidget").jqxButtonGroup({mode:'radio'});
          $("#Masks_DontCopy_Radio_Mode").jqxRadioButton({ groupName: 'ExclucionFilesWidget', rtl: false});
          $("#Masks_IgnoreTotaly_Radio_Mode").jqxRadioButton({ groupName: 'ExclucionFilesWidget', rtl: false});

          $("#jqxMasks_ProcessHiddenFilesCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxMasks_SearchHiddenFoldersCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxMasks_ProcessReparcePointsCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxMasks_FollowJunctionPointsFilesCb").jqxCheckBox({ width: 120, height: 25});                     
          $("#jqxMasks_FollowJunctionPointsFoldersCb").jqxCheckBox({ width: 120, height: 25});                     
          $("#jqxMasks_CopyOtherReparcePointsCb").jqxCheckBox({ width: 120, height: 25});                     
          $("#jqxMasks_CopyFilesWithArchiveFlagCb").jqxCheckBox({ width: 120, height: 25});                     
 
          $("#jqxMasks_FileSizesWithinCb").jqxCheckBox({ width: 120, height: 25});                     
          //$("#jqxInptMasks_FileSizesMin").jqxNumberInput({ width: 150, height: 25, inputMode: 'simple', spinButtons: false });
          //$("#jqxInptMasks_FileSizesMax").jqxNumberInput({ width: 150, height: 25, inputMode: 'simple', spinButtons: false });

                 
          $("#jqxMasks_FileDatesWithinCb").jqxCheckBox({ width: 120, height: 25});                     
          $("#jqxInptDateMasks_FileMinDate").jqxDateTimeInput({ width: '150px', height: '25px', formatString: 'dd.MM.yyyy', showCalendarButton: true});
          $("#jqxInptDateMasks_FileMaxDate").jqxDateTimeInput({ width: '150px', height: '25px', formatString: 'dd.MM.yyyy', showCalendarButton: true});
           
           
           $("#jqxMasks_FileAgeCb").jqxCheckBox({ width: 120, height: 25});


            var FileAgeComboSource = ['less that', 'over'];
           $("#jqxMasks_FileAgeCombo").jqxComboBox({ source: FileAgeComboSource, selectedIndex: 0, width: '150', height: '25px'});                     
           
           $("#inptMasks_FileAgeDays").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "31", spinButtons: true }); 
           $("#inptMasks_FileAgeHours").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "24", spinButtons: true });
           $("#inptMasks_FileAgeMinutes").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "60", spinButtons: true });
           $("#inptMasks_FileAgeSec").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max: "60", spinButtons: true }); 

            

          //$("#Masks_FilterByWidget").jqxButtonGroup({mode:'radio'});
          $("#Masks_LastModification_Radio_Mode").jqxRadioButton({ groupName: 'Masks_FilterByWidget', rtl: false});
          $("#Masks_Creation_Radio_Mode").jqxRadioButton({ groupName: 'Masks_FilterByWidget', rtl: false});


          //$("#Masks_ApplyToWidget").jqxButtonGroup({mode:'radio', width: "500"});
          $("#Masks_ApplyToFiles_Radio_Mode").jqxRadioButton({ groupName: 'Masks_ApplyToWidget', rtl: false});
          $("#Masks_ApplyToFolders_Radio_Mode").jqxRadioButton({ groupName: 'Masks_ApplyToWidget', rtl: false});
          $("#Masks_ApplyToBoth_Radio_Mode").jqxRadioButton({ groupName: 'Masks_ApplyToWidget', rtl: false});

                       
          $("#jqxMasks_TargetDataRestoreCb").jqxCheckBox({ width: 120, height: 25});
          
          $("#jqxInptDateMasks_TargetDateRestoreDate").jqxDateTimeInput({ width: '150px', height: '25px', formatString: 'dd.MM.yyyy', showCalendarButton: true});
          $("#jqxInptDateMasks_TargetDateRestoreTime").jqxDateTimeInput({ width: '150px', height: '25px', formatString: 'T', showCalendarButton: false});
          
          
          //Tab  Safety
          $("#jqxSafety_WarnIfMovingFiles").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSafety_WarnBeforeOverridingReadOnly").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSafety_WarnBeforeOverridingLarger").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSafety_WarnBeforeOverridingNewer").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSafety_WarnBeforeDeleting").jqxCheckBox({ width: 120, height: 25});
          
          //Tab Safety Special 
          $("#jqxSafetySpecial_WarnIfDeletingFilesMoreThan").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSafetySpecial_WarnIfDeletingAllFilesInAnySubfolder").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSafetySpecial_WarnIfDeletingMoreThanInAnySubfolder").jqxCheckBox({ width: 120, height: 25});
          

           $("#inptSafetySpecial_WarnIfDeletingFilesMoreThan").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", spinButtons: true });
           $("#inptSafetySpecial_WarnIfDeletingMoreThanInAnySubfolder").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", spinButtons: true });                             
           //Tab Safety Unattended Mode  

           $("#jqxSafetyUnattended_OvewriteReadOnly").jqxCheckBox({ width: 120, height: 25});
                            
           $("#jqxSafetyUnattended_OvewriteLarge").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSafetyUnattended_NewerFilesCanBeOvewriten").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSafetyUnattended_FileDeletionAllowed").jqxCheckBox({ width: 120, height: 25});
                            
           $("#inptSafetyUnattended_FileDeletionAllowed").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", max:"100", spinButtons: true });
           
           $("#jqxSafetyUnattended_EnableSpecialSafetyCheck").jqxCheckBox({ width: 220, height: 25});
           

                       //Tab Special SpecialFeatures
           $("#jqxSpecialSpFeatr_CacheDestinationFileListCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSpecialSpFeatr_ProcessSecurityCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSpecialSpFeatr_UseParcialFileUpdatingCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSpecialSpFeatr_RightSideRemoteServiceCb").jqxCheckBox({ width: 120, height: 25}); 
           $("#jqxSpecialSpFeatr_FastModeCb").jqxCheckBox({ width: 120, height: 25});                           
           $("#jqxSpecialSpFeatr_UseCacheDatabaseForSourceCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSpecialSpFeatr_LeftSideUsesRemoteServiceCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSpecialSpFeatr_RightSideUsesRemoteServiceCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSpecialSpFeatr_UseDifferentFoldersCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxSpecialSpFeatr_IfDestinationMachineModifiersCb").jqxCheckBox({ width: 120, height: 25});
        //   $("#inptSpecialSpFeatr_SetTargetVolumeLabel").jqxInput({ width: 50, height: 25 });

          //Tab Special Database

          $("#jqxSpDb_OpenDatabaseReadOnlyCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxSpecialDatabase_FastModeCb").jqxCheckBox({ width: 120, height: 25});
         // $("#inptSpecialDatabase_DatabaseNameToUse").jqxInput({ width: 50, height: 25 });
         // $("#inptSpecialDatabase_Left").jqxInput({ width: 50, height: 25 });
         // $("#inptSpecialDatabase_Right").jqxInput({ width: 50, height: 25 });        







           //Tab Vesioning Versioning
           $("#jqxVersVers_KeepOlderVersionsWhenReplacing").jqxCheckBox({ width: 120, height: 25});
           $("#inptVersVers_PerFile").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", spinButtons: false });        
           $("#jqxVersVers_OnlyOnRightHandSide").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersVers_MoveIntoFolder").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersVers_AsSubfolerInEachFolderCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersVers_RecreateTreeBelowCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersVers_FileNameEncodingCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersVers_DontRenameNewestOlderVersionCb").jqxCheckBox({ width: 120, height: 25});


          //$("#VersVers_RenamingOlderVersionsWidget").jqxButtonGroup({mode:'radio', width: "350"});
          $("#VersVers_Add_Prefix_Mode").jqxRadioButton({ groupName: 'VersVers_RenamingOlderVersionsWidget', rtl: false});
          $("#VersVers_Add_Timestamp_Mode").jqxRadioButton({ groupName: 'VersVers_RenamingOlderVersionsWidget', rtl: false});


           //Tab Vesioning Synthetic Backups
          $("#jqxVersSynth_UseSynthBackupsCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxVersSynth_UseCheckPointsCb").jqxCheckBox({ width: 120, height: 25});
            

           var CreateCheckpointComboSource = [ 'Day', 'Week', 'Month', 'Quarter', 'Year' ];
           $("#jqxVersSynth_CreateCheckpointCombo").jqxComboBox({ source: CreateCheckpointComboSource, selectedIndex: 0, width: '100', height: '25px'});                     
      
           var CheckpointsRelativeComboSource = [ 'The initial file version',  'The previous higher checkpoint(week/month/quarter)', 'The previous higher checkpoint(maximum distance month)', 
             'The previous higher checkpoint(maximum distance week)', 'The closest preseeding checkpoint' ];
           $("#jqxVersSynth_CheckpointsRelativeCombo").jqxComboBox({ source: CheckpointsRelativeComboSource, selectedIndex: 0, width: '550', height: '25px'});                     

           $("#jqxVersSynth_BuildAllIncrementalCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersSynth_RemoveUnneededCb").jqxCheckBox({ width: 120, height: 25});
           $("#inptVersSynth_RemoveUnneeded").jqxFormattedInput({ width: 50, height: 25, radix: "decimal", value: "0", min: "0", spinButtons: false });  

            var RemoveUnneededComboSource = [ 'Keep all checkpoints', 'Thin out checkpoints dynamically','Remove all unneeded checkpoints' ];
           $("#jqxVersSynth_RemoveUnneededCombo").jqxComboBox({ source: RemoveUnneededComboSource, selectedIndex: 0, width: '350', height: '25px'});                     
           
           $("#jqxVersSynth_IfAllBlocksCb").jqxCheckBox({ width: 120, height: 25});
             
           //Tab Vesioning More
           $("#jqxVersMore_DoNotDecodeLeftHandCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersMore_DoNotDecodeRightHandCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersMore_CleanUpIdenticalCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersMore_RemoveParenthesizedCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersMore_RemoveVesioningTagsCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersMore_CleanUpAllOlderVersionsCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxVersMore_FilesBackupV4Cb").jqxCheckBox({ width: 120, height: 25});
                                                                                
           //Tab Zipping/Zipping
           $("#jqxZipping_ZipEachFileCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxZipping_USeZipPackagesCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxZipping_ZipDirectlyToDestinationCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxZipping_UnzipAllfilesCb").jqxCheckBox({ width: 120, height: 25});
           $("#jqxZipping_LimitZipFileSizeCb").jqxCheckBox({ width: 120, height: 25});


           //$("#Zipping_CompressionLevelWidget").jqxButtonGroup({mode:'radio', width: "350"});
           $("#Zipping_None_Mode").jqxRadioButton({ groupName: 'Zipping_CompressionLevelWidget', rtl: false});
           $("#Zipping_Fastest_Mode").jqxRadioButton({ groupName: 'Zipping_CompressionLevelWidget', rtl: false});
           $("#Zipping_Normal_Mode").jqxRadioButton({ groupName: 'Zipping_CompressionLevelWidget', rtl: false});
           $("#Zipping_Maximum_Mode").jqxRadioButton({ groupName: 'Zipping_CompressionLevelWidget', rtl: false});

           //Tab Zipping/Encryption
          $("#jqxZippingEncrypt_EncryptFilesCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxZippingEncrypt_DecryptFilesCb").jqxCheckBox({ width: 120, height: 25});
          $("#jqxZippingEncrypt_Password").jqxPasswordInput({ width: 400, height: 25, showStrength: true, showStrengthPosition: "right" });
          $("#jqxZippingEncrypt_Confirm").jqxPasswordInput({ width: 400, height: 25, showStrength: true, showStrengthPosition: "right" });
                              
           var ZippingEncryptComboSource = [ 'ZIP-Compatible AES (256 bit)', 'ZIP-Compatible AES (192 bit)', 'ZIP-Compatible AES (128 bit)', 'Classic ZIP Password' ];
           $("#jqxZippingEncrypt_Combo").jqxComboBox({ source: ZippingEncryptComboSource, selectedIndex: 0, width: '350', height: '25px'});   

           //Tab Information
            $("#btnInformation_ShowProfileDetails").jqxButton({ template: "info" }); 
            $('#btnInformation_ShowProfileDetails').click(function () {
              
            }); 

            $("#btnInformation_ShowLogFiles").jqxButton({ template: "info" }); 
            $('#btnInformation_ShowLogFiles').click(function () {
              
            });
           










///////////////////////////////////////////////Bottom form buttons


            $('#Cancel_btn').jqxButton({});
  
               $('#Cancel_btn').click(function () {

                  $('#jqxProfileEditorForm').jqxWindow('close');
               });

            
            $('#OK_btn').jqxButton();

            $('#OK_btn').click(function () 
            {
                var CurrentProfile = $("#inptProfileName").jqxInput('val');    
                
                if( GLeftProtocolName != undefined )
                   PostRegistryListSettings( GInternetProtocolSetLEFTRegistryList,  CurrentProfile, "internet_settings_LEFT_" + GLeftProtocolName ).done(
                  function( data ) 
                  {
                    if( data == 'Edited' )
                    {  

                      
                    }
                  } );                    
                if( GRightProtocolName != undefined ) 
                   PostRegistryListSettings( GInternetProtocolSetRIGHTRegistryList,  CurrentProfile, "internet_settings_RIGHT_" + GRightProtocolName ).done(
                  function( data ) 
                  {
                    if( data == 'Edited' )
                    {  

                      
                    }
                  } );                     

                ControlValuesToRegistryList( GProfileEditorRegistryList, "" );
                PostRegistryListSettings( GProfileEditorRegistryList,  CurrentProfile, "synapp_profile_editor_form", "" ).done(
                  function( data ) 
                  {
                    if( data == 'Edited' )
                    {  
                                                                                                                           
                       var selectedrowindex = $('#jqxgrid').jqxGrid('getselectedrowindex');
                       var rowscount = $("#jqxgrid").jqxGrid('getdatainformation').rowscount;
                       if (selectedrowindex >= 0 && selectedrowindex < rowscount) 
                       {
                           var id = $("#jqxgrid").jqxGrid('getrowid', selectedrowindex);   
                           var datarow = GridDataAdapter.records[selectedrowindex];
                           datarow.LPath = $("#inptLeftHandSide").jqxInput('val');
                           datarow.RPath = $("#inptRightHandSide").jqxInput('val');

                           var commit = $("#jqxgrid").jqxGrid('updaterow', id, datarow);
                           $("#jqxgrid").jqxGrid('ensurerowvisible', selectedrowindex);
              
                       }    
                    
                       //alert( "Profile settings are saved" );
                       $('#jqxProfileEditorForm').jqxWindow('close');
                       
                    }
                    else if( data == 'Inserted' )
                    {
                       
                       var datarow = {};
                       datarow["Name"] = $("#inptProfileName").jqxInput('val');
                       datarow["LPath"] = $("#inptLeftHandSide").jqxInput('val');
                       datarow["RPath"] = $("#inptRightHandSide").jqxInput('val');
                       var commit = $("#jqxgrid").jqxGrid('addrow', null, datarow );
                       alert( "New Profile created" );
                       $('#jqxProfileEditorForm').jqxWindow('close');
                       
                    }  
                    else
                    {
                       alert( "Error: " + data + ". please try again" );
                    }    

                  });

                            
            
                });
                


            $('#jqxProfileEditorForm').on('close', function (event) 
                                      { 
                                        $('#jqxTabs').jqxTabs('destroy'); 
                                        $('#jqxProfileEditorForm').jqxWindow('destroy'); 
                                        
                                      });                        
            $('#jqxProfileEditorForm').jqxWindow('open');    



           //if( record == null ) 
            //  return;


      

};
    

function PostRegistryListSettings( PRegistryList, ProfileName, formname )
{
  
  //dynamically getting control values                                              
  var PostArray = "ProfileName=" + ProfileName;
  PostArray = PostArray + "|FormName=" + formname;                                                        
  for (index = 0; index < PRegistryList.length; index++) 
  {     
      var RegistryItem = PRegistryList[index];
      PostArray = PostArray + "|" + RegistryItem.fieldname + "=" + RegistryItem.value;                             
  };  
  return  $.post( "post_profilesettings.php",  PostArray  );                                                            

}



