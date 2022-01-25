(function () {

  'use strict';

angular.module("AppRestDw",[]);
angular.module("AppRestDw",[]).controller("EmployeeCtrl", function ($scope, $http, $httpParamSerializer) {

  $scope.employee = {
    EMP_NO: 0
  };
  $scope.showForm = false;

  $scope.showHideForm = function(show){
    $scope.showForm = show;
  };

  $scope.deleteEmployee = function(id){
    var postData = {
      ObjectType: "toParam", 
      Direction: "odIN", 
      Encoded: "true", 
      ValueType: "ovString", 
      delete: btoa(id)
    }

    $scope.msg = null;
    $http({
      method: "POST",
      url: "http://localhost:8082/employee",
      data: $httpParamSerializer(postData),
      headers: {
        "Authorization" : "Basic dGVzdHNlcnZlcjp0ZXN0c2VydmVy",
        "Content-Type" : "application/x-www-form-urlencoded"
      }
    }).then(function (result){
	  if (result.data.PARAMS) {
        $scope.msg = result.data.RESULT[0].RESULT;
      }
      else {
        loadEmployees();
      }
    }, function (error){
      $scope.msg = error;
    });
  };  

  $scope.saveEmployee = function(){

    var postData = { 
      ObjectType: "toParam", 
      Direction: "odIN", 
      Encoded: "true", 
      ValueType: "ovString", 
      set: btoa(JSON.stringify($scope.employee))
    }

    $scope.msg = null;

    $http({
      method: "POST",
      url: "http://localhost:8082/employee",
      data: $httpParamSerializer(postData),
      headers: {
        "Authorization" : "Basic dGVzdHNlcnZlcjp0ZXN0c2VydmVy",
        "Content-Type" : "application/x-www-form-urlencoded"
      }
    }).then(function (result){
      if (result.data.PARAMS) {
        $scope.msg = result.data.RESULT[0].RESULT;
      }
      else {      
        $scope.showForm = false;
        loadEmployees();
      }
    }, function (error){
      $scope.msg = error;
    });
  };  

  $scope.loadEmployeeById = function(id){

    var postData = {
      ObjectType: "toParam", 
      Direction: "odIN", 
      Encoded: "true", 
      ValueType: "ovString", 
      get: btoa(id)
    }

    $scope.msg = null;

    $http({
      method: "POST",
      url: "http://localhost:8082/employee",
      data: $httpParamSerializer(postData),
      headers: {
        "Authorization" : "Basic dGVzdHNlcnZlcjp0ZXN0c2VydmVy",
        "Content-Type" : "application/x-www-form-urlencoded"
      }
    }).then(function (result){
      if (result.data.PARAMS) {
        $scope.msg = result.data.RESULT[0].RESULT;
     }
      else {      
        $scope.employee = result.data[0];
        $scope.showForm = true;
      }
    }, function (error){
      $scope.msg = error;
    });
  };  
  
  var loadEmployees = function(){
    $scope.msg = null;

    $http({
      method: "GET",
      url: "http://localhost:8082/employee",
      headers: {
        "Authorization" : "Basic dGVzdHNlcnZlcjp0ZXN0c2VydmVy"
      }
    }).then(function (result){
      if (result.data.PARAMS) {
        $scope.msg = result.data.RESULT[0].RESULT;
      }
      else {      
        $scope.employees = result.data;
      }
    }, function (error){
      $scope.msg = error;
    });
  };  

  loadEmployees();
});
})();