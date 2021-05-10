int sound_sensor = A2; //connect to sound sensor
 
void setup() 
{
  Serial.begin(9600); 
}
 
void loop()
{
  int soundValue = 0;
  
  for (int i = 0; i < 32; i++){
    soundValue += analogRead(sound_sensor);//read the sound sensor in voltages
  } 
 
  soundValue >>= 5; //bitshift
  Serial.println(10*log10(10/6) + 20*log10(soundValue)); //print the value in serial port

  delay(1);
}
