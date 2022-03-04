#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
const char* ssid = "XyberXR";
const char* password = "termudjin";
ESP8266WebServer server(8082); // HTTP server on port 80

IPAddress ip(192, 168, 15, 200); // where xx is the desired IP Address
IPAddress gateway(192, 168, 15, 1); // set gateway to match your network
IPAddress subnet(255, 255, 255, 0); // set subnet mask to match your network

void setup() {
 Serial.begin(9600); 
 WiFi.disconnect(); // Disconnect AP

 WiFi.config(ip, gateway, subnet);

 WiFi.mode(WIFI_STA); 
 WiFi.begin(ssid, password); // Connect to WIFI network
// Wait for connection
 while (WiFi.status() != WL_CONNECTED) {
 delay(500);
 Serial.println(".");
 }
 Serial.print("Connected);
 Serial.println(ssid);
 Serial.print("IPess: ");
 Serial.println(WiFi.localIP());
server.on("/", [](){
 server.send(200, "text/plain", "Hello World");
 });
server.begin(); // Start HTTP server
 Serial.println("HTTP server started.");
}
void loop() {
 server.handleClient();
}
