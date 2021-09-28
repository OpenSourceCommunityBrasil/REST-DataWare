#include <Arduino.h>
#include <RDWBaseclass.h>


void RDWBaseclass::ParseRequest(String &paramSTR, String &contextName, String &eventName, String &paramsValues)
{
    String tempString = "";
    int i = 0;
    contextName, eventName, paramsValues = "";
    int a = paramSTR.length();
    bool params = false;
    bool paramsTag = false;
    while (a > i) {
       if ((paramSTR[i] == ' ') || 
           (paramSTR[i] == '/') || 
           (paramSTR[i] == '?') ||
           (a-1 == i))
       {
        if ((paramSTR[i] == '/') && (!params)){
        params = true;
        }
        else if ((paramSTR[i] == '?') && (params)){
        paramsTag = true;
        }
        if ((paramSTR[i] == ' ') && (paramsTag)){
         paramsValues = tempString; 
         paramsTag = false;
        } 
        if ((paramSTR[i] == '/') ||
            (paramSTR[i] == '?') ||
            (paramSTR[i] == ' ') ||
            (a-1 == i)){
         if ((paramSTR[i] == ' ') && (params)) {
          if ((paramSTR[i] != '?') &&
              (paramsValues == "")){
           if (eventName == ""){
            eventName = tempString;
           }
           else if (contextName == ""){
            contextName = eventName;
            eventName = tempString;
           }
          }
          tempString = "";
          break;
         }
         else if ((tempString == "GET")    ||
             (tempString == "POST")   ||
             (tempString == "PUT")    ||
             (tempString == "DELETE") ||
             (tempString == "PATCH")){
           tempString = "";   
          }
         else if (paramsValues == ""){
          if (eventName == ""){
           eventName = tempString;
          }
          else if (contextName == ""){
           contextName = eventName;
           eventName = tempString;
          }
         }
        }
        tempString = "";
       }
       else {
        tempString = tempString + paramSTR[i];
       }
     i++;
    }   
}