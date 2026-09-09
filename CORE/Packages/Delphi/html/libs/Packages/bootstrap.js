// REST Dataware HTML Editor package classes
// The exported class is the source of the component implementation HTML.
export class RESTDWContainer {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="container p-3">Container</div>`;
 }
}

export class RESTDWContainer_Fluid {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="container-fluid p-3">Container Fluid</div>`;
 }
}

export class RESTDWRow {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col">Column</div></div>`;
 }
}

export class RESTDWColumns_6_6 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-6">Left</div><div class="col-6">Right</div></div>`;
 }
}

export class RESTDWColumns_4_4_4 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-4">One</div><div class="col-4">Two</div><div class="col-4">Three</div></div>`;
 }
}

export class RESTDWColumns_3_9 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-3">Sidebar</div><div class="col-9">Content</div></div>`;
 }
}

export class RESTDWFlex_Row {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-flex gap-2"><div>Item 1</div><div>Item 2</div></div>`;
 }
}

export class RESTDWGrid {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-grid gap-2"><div>Item 1</div><div>Item 2</div></div>`;
 }
}

export class RESTDWHeading_H1 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<h1>Heading H1</h1>`;
 }
}

export class RESTDWHeading_H2 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<h2>Heading H2</h2>`;
 }
}

export class RESTDWHeading_H3 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<h3>Heading H3</h3>`;
 }
}

export class RESTDWParagraph {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<p>Paragraph text</p>`;
 }
}

export class RESTDWSmall_Text {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<small>Small text</small>`;
 }
}

export class RESTDWLead_Text {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<p class="lead">Lead paragraph</p>`;
 }
}

export class RESTDWImage {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<img class="img-fluid rounded" src="images/sample.png" alt="Image">`;
 }
}

export class RESTDWCard {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="card"><div class="card-header">Card</div><div class="card-body">Card body</div></div>`;
 }
}

export class RESTDWCard_With_Footer {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="card"><div class="card-header">Header</div><div class="card-body">Body</div><div class="card-footer">Footer</div></div>`;
 }
}

export class RESTDWList_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="list-group"><li class="list-group-item">Item 1</li><li class="list-group-item">Item 2</li></ul>`;
 }
}

export class RESTDWBadge {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<span class="badge">Badge</span>`;
 }
}

export class RESTDWHorizontal_Rule {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<hr>`;
 }
}

export class RESTDWNavbar {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<nav class="navbar"><a class="navbar-brand" href="#">Dashboard</a><div class="nav"><a class="nav-link" href="#">Home</a><a class="nav-link" href="#">Reports</a></div></nav>`;
 }
}

export class RESTDWNav_Pills {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="nav"><li><a class="nav-link btn btn-primary" href="#">One</a></li><li><a class="nav-link" href="#">Two</a></li></ul>`;
 }
}

export class RESTDWNav_Tabs {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="nav"><li><a class="nav-link" href="#">Tab 1</a></li><li><a class="nav-link" href="#">Tab 2</a></li></ul>`;
 }
}

export class RESTDWBreadcrumb {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ol class="breadcrumb"><li>Home</li><li>/ Dashboard</li></ol>`;
 }
}

export class RESTDWPagination {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="pagination"><li><a class="page-link" href="#">1</a></li><li><a class="page-link" href="#">2</a></li></ul>`;
 }
}

export class RESTDWText_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Text</label><input class="form-control" type="text"></div>`;
 }
}

export class RESTDWPassword_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Password</label><input class="form-control" type="password"></div>`;
 }
}

export class RESTDWEmail_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">E-mail</label><input class="form-control" type="email"></div>`;
 }
}

export class RESTDWSearch_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Search</label><input class="form-control" type="search"></div>`;
 }
}

export class RESTDWNumber_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Number</label><input class="form-control" type="number" value="0" step="1"></div>`;
 }
}

export class RESTDWDecimal_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Decimal</label><input class="form-control" type="number" value="0.00" step="0.01"></div>`;
 }
}

export class RESTDWMoney_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Value</label><div class="input-group"><span class="input-group-text">R$</span><input class="form-control" type="number" value="0.00" step="0.01"></div></div>`;
 }
}

export class RESTDWPercent_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Percent</label><div class="input-group"><input class="form-control" type="number" value="0" min="0" max="100" step="0.01"><span class="input-group-text">%</span></div></div>`;
 }
}

export class RESTDWDate_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Date</label><input class="form-control" type="date"></div>`;
 }
}

export class RESTDWTime_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Time</label><input class="form-control" type="time"></div>`;
 }
}

export class RESTDWDateTime_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Date / Time</label><input class="form-control" type="datetime-local"></div>`;
 }
}

export class RESTDWMonth_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Month</label><input class="form-control" type="month"></div>`;
 }
}

export class RESTDWWeek_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Week</label><input class="form-control" type="week"></div>`;
 }
}

export class RESTDWColor_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Color</label><input class="form-control" type="color" value="#0d6efd"></div>`;
 }
}

export class RESTDWTextArea {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Notes</label><textarea class="form-control" rows="4"></textarea></div>`;
 }
}

export class RESTDWSelect {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Select</label><select class="form-select"><option>Option 1</option><option>Option 2</option></select></div>`;
 }
}

export class RESTDWMulti_Select {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Multiple</label><select class="form-select" multiple><option>Option 1</option><option>Option 2</option></select></div>`;
 }
}

export class RESTDWCheckbox {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input type="checkbox" id="check1"><label for="check1">Check</label></div>`;
 }
}

export class RESTDWSwitch {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input type="checkbox" role="switch" id="switch1"><label for="switch1">Switch</label></div>`;
 }
}

export class RESTDWRadio_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input type="radio" name="radio1" id="radio1a" checked><label for="radio1a">Option A</label></div><div class="form-check"><input type="radio" name="radio1" id="radio1b"><label for="radio1b">Option B</label></div>`;
 }
}

export class RESTDWRange {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Range</label><input class="form-range" type="range" min="0" max="100" value="50"></div>`;
 }
}

export class RESTDWFile_Upload {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">File</label><input class="form-control" type="file"></div>`;
 }
}

export class RESTDWInput_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="input-group"><span class="input-group-text">@</span><input class="form-control"></div>`;
 }
}

export class RESTDWReadonly_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Readonly</label><input class="form-control" type="text" value="Readonly" readonly></div>`;
 }
}

export class RESTDWDisabled_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Disabled</label><input class="form-control" type="text" value="Disabled" disabled></div>`;
 }
}

export class RESTDWPrimary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary">Primary</button>`;
 }
}

export class RESTDWSecondary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-secondary">Secondary</button>`;
 }
}

export class RESTDWSuccess {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-success">Success</button>`;
 }
}

export class RESTDWDanger {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-danger">Danger</button>`;
 }
}

export class RESTDWWarning {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-warning">Warning</button>`;
 }
}

export class RESTDWInfo {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-info">Info</button>`;
 }
}

export class RESTDWLight {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-light">Light</button>`;
 }
}

export class RESTDWDark {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-dark">Dark</button>`;
 }
}

export class RESTDWLink {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-link">Link</button>`;
 }
}

export class RESTDWOutline_Primary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-outline-primary">Outline Primary</button>`;
 }
}

export class RESTDWSmall_Button {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary btn-sm">Small</button>`;
 }
}

export class RESTDWLarge_Button {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary btn-lg">Large</button>`;
 }
}

export class RESTDWButton_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-flex gap-2"><button class="btn btn-primary">New</button><button class="btn btn-success">Save</button><button class="btn btn-danger">Delete</button></div>`;
 }
}

export class RESTDWCRUD_Toolbar {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-flex gap-2"><button class="btn btn-primary">New</button><button class="btn btn-success">Save</button><button class="btn btn-secondary">Edit</button><button class="btn btn-danger">Delete</button><button class="btn btn-warning">Cancel</button></div>`;
 }
}

export class RESTDWAlert_Primary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="alert alert-primary">Information message</div>`;
 }
}

export class RESTDWAlert_Success {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="alert alert-success">Success message</div>`;
 }
}

export class RESTDWAlert_Danger {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="alert alert-danger">Error message</div>`;
 }
}

export class RESTDWProgress {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="progress"><div class="progress-bar" style="width:65%"></div></div>`;
 }
}

export class RESTDWSpinner {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<span class="spinner-border"></span>`;
 }
}

export class RESTDWAccordion {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="accordion-item"><button class="accordion-button" data-bs-toggle="collapse" data-bs-target="#acc1">Accordion</button><div id="acc1" class="accordion-body collapse show">Content</div></div>`;
 }
}

export class RESTDWCollapse {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary" data-bs-toggle="collapse" data-bs-target="#collapse1">Toggle</button><div id="collapse1" class="collapse"><div class="card card-body">Collapsed content</div></div>`;
 }
}

export class RESTDWDropdown {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="dropdown"><button class="btn btn-secondary">Dropdown</button><div class="dropdown-menu"><a class="nav-link" href="#">Action</a></div></div>`;
 }
}

export class RESTDWModal {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modal1">Open Modal</button><div id="modal1" class="modal"><h3>Modal</h3><p>Modal content</p></div>`;
 }
}

export class RESTDWOffcanvas {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary" data-bs-toggle="offcanvas" data-bs-target="#off1">Open</button><div id="off1" class="offcanvas">Offcanvas content</div>`;
 }
}

export class RESTDWToast {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="toast">Toast notification</div>`;
 }
}

export class RESTDWTable {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<table class="table table-striped"><thead><tr><th>Name</th><th>Value</th></tr></thead><tbody><tr><td>Item</td><td>100</td></tr></tbody></table>`;
 }
}

export class RESTDWBordered_Table {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<table class="table table-bordered"><thead><tr><th>ID</th><th>Name</th></tr></thead><tbody><tr><td>1</td><td>Item</td></tr></tbody></table>`;
 }
}

export class RESTDWKPI_Card {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="card"><div class="card-body"><div class="fw-bold">Revenue</div><h2>R$ 0,00</h2><small>Current month</small></div></div>`;
 }
}

export class RESTDWKPI_Cards_4 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-3"><div class="card"><div class="card-body"><b>Revenue</b><h2>R$ 125K</h2></div></div></div><div class="col-3"><div class="card"><div class="card-body"><b>Orders</b><h2>1.284</h2></div></div></div><div class="col-3"><div class="card"><div class="card-body"><b>Clients</b><h2>842</h2></div></div></div><div class="col-3"><div class="card"><div class="card-body"><b>Conversion</b><h2>18.4%</h2></div></div></div></div>`;
 }
}

export class RESTDWDashboard_Grid {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-3"><div class="card"><div class="card-body">KPI 1</div></div></div><div class="col-3"><div class="card"><div class="card-body">KPI 2</div></div></div><div class="col-6"><canvas id="dashChart"></canvas></div></div>`;
 }
}
