#include <SoftwareSerial.h>
//#include <Servo.h>



SoftwareSerial bluetooth(10, 11); // RX, TX
int BluetoothData;
int groc = 5;
int verd = 6; 
int blau = 7; 
//Servo myservo;

void setup() 
{
  Serial.begin(9600);
  bluetooth.begin(9600);
  pinMode(5,OUTPUT);
  //pinMode(led,OUTPUT);
  //myservo.attach(9);
  //myservo.write(0);  // ajusta el servo al punto medio

}

void loop()
{
  if (bluetooth.available()){
    BluetoothData=bluetooth.read();
    if(BluetoothData=='1'){
      Serial.println("Plastic");
      digitalWrite(groc, HIGH);
      delay(500);
      digitalWrite(groc, LOW);
    }
    else if(BluetoothData=='2'){
      Serial.println("Paper");
      digitalWrite(blau, HIGH);
      delay(500);
      digitalWrite(blau, LOW);
    }
    else if(BluetoothData=='3'){
      Serial.println("Vidre");
      digitalWrite(verd, HIGH);
      delay(500);
      digitalWrite(verd, LOW);
    }
  }
  
  
  /*
   if (bluetooth.available())
   {
     BluetoothData=bluetooth.read();
     Serial.print(bluetooth.read());
     if(BluetoothData=='1')
       {  
         //digitalWrite(led,1);
         //bluetooth.println("ON");
         //myservo.write(180);  // ajusta el servo al punto medio
         //delay(5000);
         //myservo.write(0);
         digitalWrite(groc, HIGH);
         delay(500);
         digitalWrite(groc, LOW);
       } 

     else if(BluetoothData=='2')
       {  
         //digitalWrite(led,0);
         //bluetooth.println("OFF");
         myservo.write(90);  // ajusta el servo al punto medio
         digitalWrite(verd, HIGH);
         delay(500);
         digitalWrite(verd, LOW);
       }           
     
    }
      delay(100);*/
}
