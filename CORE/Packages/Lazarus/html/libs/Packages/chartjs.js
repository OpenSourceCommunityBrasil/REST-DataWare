// REST Dataware HTML Editor package classes
// The exported class is the source of the component implementation HTML.
export class RESTDWChart_Bar {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<canvas id="chartBar" width="600" height="260"></canvas><script>new Chart(document.getElementById("chartBar"),{type:"bar",data:{labels:["A","B","C"],datasets:[{label:"Values",data:[10,20,15]}]}});</script>`;
 }
 static mount(element, options) { if(typeof Chart!=="undefined"){new Chart(element,{type:"bar",data:{labels:["A","B","C"],datasets:[{label:"Values",data:[10,20,15]}]}});} }
}

export class RESTDWChart_Line {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<canvas id="chartLine" width="600" height="260"></canvas><script>new Chart(document.getElementById("chartLine"),{type:"line",data:{labels:["Jan","Feb","Mar"],datasets:[{label:"Series",data:[12,18,14]}]}});</script>`;
 }
 static mount(element, options) { if(typeof Chart!=="undefined"){new Chart(element,{type:"line",data:{labels:["Jan","Feb","Mar"],datasets:[{label:"Series",data:[12,18,14]}]}});} }
}

export class RESTDWChart_Pie {
 static visual = true;
 static placement = 'body';
 static createHTML(options) {
  return `<canvas id="chartPie" width="450" height="250"></canvas><script>new Chart(document.getElementById("chartPie"),{type:"pie",data:{labels:["A","B","C"],datasets:[{data:[40,35,25]}]}});</script>`;
 }
 static mount(element, options) { if(typeof Chart!=="undefined"){new Chart(element,{type:"pie",data:{labels:["A","B","C"],datasets:[{data:[40,35,25]}]}});} }
}
