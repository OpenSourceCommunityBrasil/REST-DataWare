// REST Dataware HTML Editor package classes
// The exported class is the source of the component implementation HTML.
export class RESTDWDataTable {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<table id="dashboardTable" class="table table-striped"><thead><tr><th>Name</th><th>Value</th></tr></thead><tbody><tr><td>Item A</td><td>100</td></tr><tr><td>Item B</td><td>200</td></tr></tbody></table><script>new DataTable("#dashboardTable");</script>`;
 }
 static mount(element, options) { if(typeof DataTable!=="undefined"){new DataTable(element);} }
}

export class RESTDWDataTable_CRUD {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-flex gap-2 mb-3"><button class="btn btn-primary">New</button><button class="btn btn-success">Save</button><button class="btn btn-danger">Delete</button></div><table id="crudTable" class="table table-striped table-bordered"><thead><tr><th>ID</th><th>Name</th><th>Status</th></tr></thead><tbody><tr><td>1</td><td>Record</td><td>Active</td></tr></tbody></table><script>new DataTable("#crudTable");</script>`;
 }
 static mount(element, options) { if(typeof DataTable!=="undefined"&&element&&element.nextElementSibling){new DataTable(element.nextElementSibling);} }
}
