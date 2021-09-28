#include <RDWBaseclass.h>
#include <SPI.h>
#include <Ethernet.h>

int buffersize = 80;
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip( 192,168,15,250 );
IPAddress gateway( 192,168,15,1 );
IPAddress subnet( 255,255,255,0 );

EthernetServer server(8082);

void setup()
{
 Serial.begin(9600);
 pinMode(4,OUTPUT);
 digitalWrite(4,HIGH);
 Ethernet.begin(mac, ip, gateway, gateway, subnet);
 delay(2000);
 server.begin();
 Serial.println("Ready");
}

void loop()
{
 EthernetClient client = server.available();
 if(client) {
   boolean currentLineIsBlank = true;
   boolean currentLineIsGet = true;
   int tCount = 0;
   char tBuf[buffersize];
   int r,t;
   char *pch;
   String paramSTR, contextName, eventName, paramsValues = "";
   Serial.println(F("Client request: "));
   while (client.connected()) {
     while(client.available()) {
       char c = client.read();
       if(currentLineIsGet && tCount < (buffersize -1))
       {
         tBuf[tCount] = c;
         tCount++;
         tBuf[tCount] = 0;          
       }
       paramSTR = paramSTR + c;
       if (c == '\n' && currentLineIsBlank) {
         client.write("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n<html><body><H1>TEST</H1>");
         client.write("<form method=GET>T: <input type=text name=t><br>");
         client.write("R: <input type=text name=r><br><input type=submit></form>");
         client.write("</body></html>\r\n\r\n");
         client.stop();
       }
       else if (c == '\n') {
         currentLineIsBlank = true;
         currentLineIsGet = false;
       }
       else if (c != '\r') {
         currentLineIsBlank = false;
       }
     }
    paramSTR = tBuf;
    RDWBaseclass* RDW = new RDWBaseclass(); //Create RDWClass
    RDW->ParseRequest(paramSTR, contextName, eventName, paramsValues);//Parse Request
    delete RDW;//Delete RDWClass
    Serial.println("eventName : " + eventName);
    Serial.println("contextName : " + contextName);
    Serial.println("paramsValues : " + paramsValues);
   }
 }
}
