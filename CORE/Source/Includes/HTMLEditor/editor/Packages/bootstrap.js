// LazDatasnap HTML Editor package classes
// The exported class is the source of the component implementation HTML.
export class DSContainer {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="container p-3">Container</div>`;
 }
}

export class DSContainer_Fluid {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="container-fluid p-3">Container Fluid</div>`;
 }
}

export class DSRow {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col">Column</div></div>`;
 }
}

export class DSColumns_6_6 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-6">Left</div><div class="col-6">Right</div></div>`;
 }
}

export class DSColumns_4_4_4 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-4">One</div><div class="col-4">Two</div><div class="col-4">Three</div></div>`;
 }
}

export class DSColumns_3_9 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-3">Sidebar</div><div class="col-9">Content</div></div>`;
 }
}

export class DSFlex_Row {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-flex gap-2"><div>Item 1</div><div>Item 2</div></div>`;
 }
}

export class DSGrid {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-grid gap-2"><div>Item 1</div><div>Item 2</div></div>`;
 }
}

export class DSHeading_H1 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<h1>Heading H1</h1>`;
 }
}

export class DSHeading_H2 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<h2>Heading H2</h2>`;
 }
}

export class DSHeading_H3 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<h3>Heading H3</h3>`;
 }
}

export class DSParagraph {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<p>Paragraph text</p>`;
 }
}

export class DSSmall_Text {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<small>Small text</small>`;
 }
}

export class DSLead_Text {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<p class="lead">Lead paragraph</p>`;
 }
}

export class DSImage {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<img class="img-fluid rounded" src="images/sample.png" alt="Image">`;
 }
}

export class DSCard {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="card"><div class="card-header">Card</div><div class="card-body">Card body</div></div>`;
 }
}

export class DSCard_With_Footer {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="card"><div class="card-header">Header</div><div class="card-body">Body</div><div class="card-footer">Footer</div></div>`;
 }
}

export class DSList_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="list-group"><li class="list-group-item">Item 1</li><li class="list-group-item">Item 2</li></ul>`;
 }
}

export class DSBadge {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<span class="badge">Badge</span>`;
 }
}

export class DSHorizontal_Rule {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<hr>`;
 }
}

export class DSNavbar {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<nav class="navbar"><a class="navbar-brand" href="#">Dashboard</a><div class="nav"><a class="nav-link" href="#">Home</a><a class="nav-link" href="#">Reports</a></div></nav>`;
 }
}

export class DSNav_Pills {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="nav"><li><a class="nav-link btn btn-primary" href="#">One</a></li><li><a class="nav-link" href="#">Two</a></li></ul>`;
 }
}

export class DSNav_Tabs {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="nav"><li><a class="nav-link" href="#">Tab 1</a></li><li><a class="nav-link" href="#">Tab 2</a></li></ul>`;
 }
}

export class DSBreadcrumb {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ol class="breadcrumb"><li>Home</li><li>/ Dashboard</li></ol>`;
 }
}

export class DSPagination {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<ul class="pagination"><li><a class="page-link" href="#">1</a></li><li><a class="page-link" href="#">2</a></li></ul>`;
 }
}

export class DSText_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Text</label><input class="form-control" type="text"></div>`;
 }
}

export class DSPassword_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Password</label><input class="form-control" type="password"></div>`;
 }
}

export class DSEmail_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">E-mail</label><input class="form-control" type="email"></div>`;
 }
}

export class DSSearch_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Search</label><input class="form-control" type="search"></div>`;
 }
}

export class DSNumber_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Number</label><input class="form-control" type="number" value="0" step="1"></div>`;
 }
}

export class DSDecimal_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Decimal</label><input class="form-control" type="number" value="0.00" step="0.01"></div>`;
 }
}

export class DSMoney_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Value</label><div class="input-group"><span class="input-group-text">R$</span><input class="form-control" type="number" value="0.00" step="0.01"></div></div>`;
 }
}

export class DSPercent_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Percent</label><div class="input-group"><input class="form-control" type="number" value="0" min="0" max="100" step="0.01"><span class="input-group-text">%</span></div></div>`;
 }
}

export class DSDate_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Date</label><input class="form-control" type="date"></div>`;
 }
}

export class DSTime_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Time</label><input class="form-control" type="time"></div>`;
 }
}

export class DSDateTime_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Date / Time</label><input class="form-control" type="datetime-local"></div>`;
 }
}

export class DSMonth_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Month</label><input class="form-control" type="month"></div>`;
 }
}

export class DSWeek_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Week</label><input class="form-control" type="week"></div>`;
 }
}

export class DSColor_Picker {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Color</label><input class="form-control" type="color" value="#0d6efd"></div>`;
 }
}

export class DSTextArea {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Notes</label><textarea class="form-control" rows="4"></textarea></div>`;
 }
}

export class DSSelect {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Select</label><select class="form-select"><option>Option 1</option><option>Option 2</option></select></div>`;
 }
}

export class DSMulti_Select {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Multiple</label><select class="form-select" multiple><option>Option 1</option><option>Option 2</option></select></div>`;
 }
}

export class DSCheckbox {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input type="checkbox" id="check1"><label for="check1">Check</label></div>`;
 }
}

export class DSSwitch {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input type="checkbox" role="switch" id="switch1"><label for="switch1">Switch</label></div>`;
 }
}

export class DSRadio_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input type="radio" name="radio1" id="radio1a" checked><label for="radio1a">Option A</label></div><div class="form-check"><input type="radio" name="radio1" id="radio1b"><label for="radio1b">Option B</label></div>`;
 }
}

export class DSRange {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Range</label><input class="form-range" type="range" min="0" max="100" value="50"></div>`;
 }
}

export class DSFile_Upload {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">File</label><input class="form-control" type="file"></div>`;
 }
}

export class DSInput_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="input-group"><span class="input-group-text">@</span><input class="form-control"></div>`;
 }
}

export class DSReadonly_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Readonly</label><input class="form-control" type="text" value="Readonly" readonly></div>`;
 }
}

export class DSDisabled_Edit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="mb-3"><label class="form-label">Disabled</label><input class="form-control" type="text" value="Disabled" disabled></div>`;
 }
}

export class DSPrimary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary">Primary</button>`;
 }
}

export class DSSecondary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-secondary">Secondary</button>`;
 }
}

export class DSSuccess {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-success">Success</button>`;
 }
}

export class DSDanger {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-danger">Danger</button>`;
 }
}

export class DSWarning {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-warning">Warning</button>`;
 }
}

export class DSInfo {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-info">Info</button>`;
 }
}

export class DSLight {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-light">Light</button>`;
 }
}

export class DSDark {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-dark">Dark</button>`;
 }
}

export class DSLink {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-link">Link</button>`;
 }
}

export class DSOutline_Primary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-outline-primary">Outline Primary</button>`;
 }
}

export class DSSmall_Button {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary btn-sm">Small</button>`;
 }
}

export class DSLarge_Button {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary btn-lg">Large</button>`;
 }
}

export class DSButton_Group {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-flex gap-2"><button class="btn btn-primary">New</button><button class="btn btn-success">Save</button><button class="btn btn-danger">Delete</button></div>`;
 }
}

export class DSCRUD_Toolbar {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="d-flex gap-2"><button class="btn btn-primary">New</button><button class="btn btn-success">Save</button><button class="btn btn-secondary">Edit</button><button class="btn btn-danger">Delete</button><button class="btn btn-warning">Cancel</button></div>`;
 }
}

export class DSAlert_Primary {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="alert alert-primary">Information message</div>`;
 }
}

export class DSAlert_Success {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="alert alert-success">Success message</div>`;
 }
}

export class DSAlert_Danger {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="alert alert-danger">Error message</div>`;
 }
}

export class DSProgress {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="progress"><div class="progress-bar" style="width:65%"></div></div>`;
 }
}

export class DSSpinner {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<span class="spinner-border"></span>`;
 }
}

export class DSAccordion {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="accordion-item"><button class="accordion-button" data-bs-toggle="collapse" data-bs-target="#acc1">Accordion</button><div id="acc1" class="accordion-body collapse show">Content</div></div>`;
 }
}

export class DSCollapse {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary" data-bs-toggle="collapse" data-bs-target="#collapse1">Toggle</button><div id="collapse1" class="collapse"><div class="card card-body">Collapsed content</div></div>`;
 }
}

export class DSDropdown {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="dropdown"><button class="btn btn-secondary">Dropdown</button><div class="dropdown-menu"><a class="nav-link" href="#">Action</a></div></div>`;
 }
}

export class DSModal {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modal1">Open Modal</button><div id="modal1" class="modal"><h3>Modal</h3><p>Modal content</p></div>`;
 }
}

export class DSOffcanvas {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button class="btn btn-primary" data-bs-toggle="offcanvas" data-bs-target="#off1">Open</button><div id="off1" class="offcanvas">Offcanvas content</div>`;
 }
}

export class DSToast {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="toast">Toast notification</div>`;
 }
}

export class DSTable {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<table class="table table-striped"><thead><tr><th>Name</th><th>Value</th></tr></thead><tbody><tr><td>Item</td><td>100</td></tr></tbody></table>`;
 }
}

export class DSBordered_Table {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<table class="table table-bordered"><thead><tr><th>ID</th><th>Name</th></tr></thead><tbody><tr><td>1</td><td>Item</td></tr></tbody></table>`;
 }
}

export class DSKPI_Card {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="card"><div class="card-body"><div class="fw-bold">Revenue</div><h2>R$ 0,00</h2><small>Current month</small></div></div>`;
 }
}

export class DSKPI_Cards_4 {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-3"><div class="card"><div class="card-body"><b>Revenue</b><h2>R$ 125K</h2></div></div></div><div class="col-3"><div class="card"><div class="card-body"><b>Orders</b><h2>1.284</h2></div></div></div><div class="col-3"><div class="card"><div class="card-body"><b>Clients</b><h2>842</h2></div></div></div><div class="col-3"><div class="card"><div class="card-body"><b>Conversion</b><h2>18.4%</h2></div></div></div></div>`;
 }
}

export class DSDashboard_Grid {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="row"><div class="col-3"><div class="card"><div class="card-body">KPI 1</div></div></div><div class="col-3"><div class="card"><div class="card-body">KPI 2</div></div></div><div class="col-6"><canvas id="dashChart"></canvas></div></div>`;
 }
}
