#include "WiFiEsp.h"
#include <ArduinoJson.h>//Json信息的解析，并通过串口输出
#include <PubSubClient.h>//消息发布的库

#include "DHT.h"
#define DHTTYPE DHT11
#define DHTPIN 2
#define MQ2pin (0)
int buzzerPin = 7;

DHT dht(DHTPIN, DHTTYPE);

//输入WiFi信息
#define WIFI_SSID "whn"
#define WIFI_PASSWD "whn200229"

static WiFiEspClient espClient(Serial3);//通过WiFi模块连接服务器
int status = WL_IDLE_STATUS; //the wifi radio's status
unsigned long lastMsMain = 0;
const char* mqtt_server = "stevenhou.xyz";
const char* mqtt_username = "student";
const char* mqtt_password = "STUDENT";
unsigned long lastMsg = 0;

PubSubClient client(espClient); //定义PunSubClient实例

void wifilnit(const char *ssid, const char *passphrase){ //连接wifi
  if(WiFi.status()!=WL_NO_SHIELD){
    Serial.println("WiFi shield not present");
    //while(true);
  }
  while(status != WL_CONNECTED){
    Serial.print("Attempting to connect to WPA SSID");
    Serial.println(ssid);
    status = WiFi.begin(WIFI_SSID, WIFI_PASSWD);
  }
  Serial.println("You are connected to the network");
}

void reconnect(){
  while(!client.connected()){
    Serial.print("Attempting MQTT connection...");
    if(client.connect("student09",mqtt_username,mqtt_password)){
      Serial.println("connected");
    }else{
      Serial.print("failed,rc=");
      Serial.print(client.state());
      Serial.println("try again in 5 seconds");
      delay(5000);
    }
  }
}

void data_read(){
  Serial.println("====================");
  Serial.println("Sample DHT11...");
  int h = dht.readHumidity();         // 读取湿度传感器的值
  int t = dht.readTemperature();    // 读取温度传感器的值
  int flag = 0;
  int s;
  s = analogRead(MQ2pin);
   
  if(s > 300) //阈值 根据实际情况判断 大于300 还是小于300 ，300也是变量
  {
   Serial.print(" | Smoke detected!  探测到烟雾 ");
  }
  Serial.print(t);Serial.print(" °C,");
  Serial.print(h);Serial.print(" H,");
  Serial.print("烟雾值: ");Serial.print(s);
  if (t > 26.00 || h > 70.00 || s > 300.00 ) {            //温度大于26或湿度大于70时LED灯亮红灯
    int flag = 1;
    digitalWrite(12, HIGH);    //向12号引脚输出高电压
    digitalWrite(11, LOW);     //向11号引脚输出低电压
    int h = dht.readHumidity();            // 重新读取湿度传感器的值
    int t = dht.readTemperature();       // 重新读取温度度传感器的值
    int s = analogRead(MQ2pin);          // 重新读取烟雾值
    Serial.println(F(" 环境异常"));
    digitalWrite(buzzerPin, HIGH);
    char msg[1000];
    sprintf(msg,"{\"temperature\":%d,\"humidity\":%d,\"smoke\":%d,\"environment_status\":%d}",t,h,s,flag);
    client.publish("student09",msg);
  }
  else{     //温度小于26和湿度小于70时LED灯变为绿色
        int flag = 0;
        digitalWrite(11, HIGH);    //向11号引脚输出高电压
        digitalWrite(12, LOW);     //向12号引脚输出低电压
        int h = dht.readHumidity();            // 重新读取湿度传感器的值
        int t = dht.readTemperature();       // 重新读取温度度传感器的值
        int s = analogRead(MQ2pin); 
        Serial.println(F(" 环境正常"));
        digitalWrite(buzzerPin, LOW);
        char msg[1000];
        sprintf(msg,"{\"temperature\":%d,\"humidity\":%d,\"smoke\":%d,\"environment_status\":%d}",t,h,s,flag);
        client.publish("student09",msg);
  }
  return;
}


void setup(){
  Serial.begin(115200);
  Serial3.begin(115200);
  dht.begin();
  Serial.print("SERIAL_RX_BUFFER_SIZE=");
  Serial.println("SERIAL_RX_BUFFER_SIZE");
  WiFi.init(&Serial3);
  wifilnit(WIFI_SSID,WIFI_PASSWD);
  client.setServer(mqtt_server, 1883);
}

void loop(){
  delay(20000);
  if(!client.connected()){
    reconnect();
  }

  client.loop();
  unsigned long now = millis();
  if(now - lastMsg > 10000){
    lastMsg = now;
    data_read();
  }
}

