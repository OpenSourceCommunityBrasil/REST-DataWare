var TreeSelectFormHTML =  "<div id='jqxwindow2'>"+
        "<div><br></div>"+
        
        "<div>"+
          "<div>Directory Select</div>"+
          "<div id=\"jqxTree\"></div>"+  
          "<div><br></div>"+
          "<div></div>"+
            "<div style='float: none;'>"+
            "<button id=\"OK_btn2\">OK</button>"+  
               "<button id=\"Cancel_btn2\">Cancel</button>"+
            "</div>"+
          "<div><br></div>"+
        "</div>"+                
        
      "</div>";


           
        function InitDirTreeSelectForm()
        {

              $("#TreeSelectForm_div").html( TreeSelectFormHTML );   

    
              function getAllParents(item1)
              {
                if( item1.parentElement != null )      
                     GSelectedDirStr = GSelectedDirStr.replace (/^/,"\\" + item1.label)
                else
                  GSelectedDirStr = item1.label + GSelectedDirStr;
                    var parent1 = $('#jqxTree').jqxTree('getItem', item1.parentElement);
                  if(parent1)
                    {   
                     getAllParents(parent1);
                  }
   
              };

            function ShowTreeItem()
            {   

                var item = $('#jqxTree').jqxTree('getSelectedItem');
                getAllParents( item )
                alert( str );
            };

            
// Create jqxTree
            var tree = $('#jqxTree');
            var TreeSource = null;
            $.ajax({
                async: false,
                url: "directorylisting.htm?C:_dash_",
                success: function (data, status, xhr) {
                    TreeSource = jQuery.parseJSON(data);
                }
            });
            tree.jqxTree({ source: TreeSource,  height: 300, width: 500 });
            tree.on('expand', function (event) {
                var label = tree.jqxTree('getItem', event.args.element).label;
                var $element = $(event.args.element);
                var loader = false;
                var loaderItem = null;
                var children = $element.find('ul:first').children();
                $.each(children, function () {
                    var item = tree.jqxTree('getItem', this);
                    if (item && item.label == 'Loading...') {
                        loaderItem = item;
                        loader = true;
                        return false
                    };
                });
                if (loader) {
                    $.ajax({
                        url: loaderItem.value,
                        success: function (data, status, xhr) {
                            var items = jQuery.parseJSON(data);
                            tree.jqxTree('addTo', items, $element[0]);
                            tree.jqxTree('removeItem', loaderItem.element);
                        }
                    });
                }
            });



           //Directory Select Dialog
        $("#jqxwindow2").jqxWindow({
        height: 420,
        width: 510,
        theme: 'energyblue',
        autoOpen: false,
        isModal: true, draggable: false });


         $('#Cancel_btn2').jqxButton({});
  
               $('#Cancel_btn2').click(function () {

                  $('#jqxwindow2').jqxWindow('close');
               });

            
            $('#OK_btn2').jqxButton({});

            $('#OK_btn2').click(function (){                
                var item = $('#jqxTree').jqxTree('getSelectedItem');
                GSelectedDirStr = ''; 
                getAllParents( item );
                GLeftRightSideInput.jqxInput('val', GSelectedDirStr);
                $('#jqxwindow2').jqxWindow('close');
            });
       }
