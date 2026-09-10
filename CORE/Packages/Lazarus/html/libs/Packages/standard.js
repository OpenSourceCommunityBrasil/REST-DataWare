// REST Dataware HTML Editor package classes
// The exported class is the source of the component implementation HTML.
export class RESTDWLabel {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<label class="form-label">Label</label>`;
 }
}

export class RESTDWEdit {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<input type="text" class="form-control" placeholder="Edit">`;
 }
}

export class RESTDWMemo {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<textarea class="form-control" rows="4" placeholder="Memo"></textarea>`;
 }
}

export class RESTDWButton {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<button type="button" class="btn btn-primary">Button</button>`;
 }
}

export class RESTDWCheckBox {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input class="form-check-input" type="checkbox" id="check1"><label class="form-check-label" for="check1">CheckBox</label></div>`;
 }
}

export class RESTDWRadioButton {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="form-check"><input class="form-check-input" type="radio" name="radioGroup" id="radio1"><label class="form-check-label" for="radio1">RadioButton</label></div>`;
 }
}

export class RESTDWComboBox {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<select class="form-select"><option value="">Select...</option><option value="1">Item 1</option><option value="2">Item 2</option></select>`;
 }
}

export class RESTDWListBox {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<select class="form-select" size="5"><option>Item 1</option><option>Item 2</option><option>Item 3</option></select>`;
 }
}

export class RESTDWGrid {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<table class="table table-striped"><thead><tr><th>ID</th><th>Name</th><th>Value</th></tr></thead><tbody><tr><td>1</td><td>Item</td><td>Value</td></tr></tbody></table>`;
 }
}

export class RESTDWImage {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<img class="img-fluid" src="images/sample.png" alt="Image">`;
 }
}

export class RESTDWLink {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<a href="#">Link</a>`;
 }
}

export class RESTDWPanel {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="border rounded p-3">Panel</div>`;
 }
}

export class RESTDWGroupBox {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<fieldset class="border rounded p-3"><legend class="float-none w-auto px-2">GroupBox</legend>Content</fieldset>`;
 }
}

export class RESTDWProgressBar {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<div class="progress"><div class="progress-bar" style="width:50%">50%</div></div>`;
 }
}

export class RESTDWHiddenField {
 static visual = false;
 static placement = 'body';
 static createHTML(options) {
  return `<input type="hidden" name="hiddenField" value="">`;
 }
}
