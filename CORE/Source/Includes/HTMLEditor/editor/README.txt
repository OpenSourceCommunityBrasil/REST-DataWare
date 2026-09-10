LazDatasnap Web Designer local libraries

The editor and generated pages never require a CDN.

Folders:
 bootstrap/
 datatables/
 chartjs/
 plugins/

New visual components:
Place a *.dscomponent file in libs/editor/plugins.
Format:
[Component]
Name=My Widget
Category=Custom
HTML=<div class="my-widget">My Widget</div>
CSS=my-widget.css
JS=my-widget.js

The editor scans this folder every time it opens and adds discovered components
to the visual palette. CSS/JS files stay local and can be referenced by the page.
