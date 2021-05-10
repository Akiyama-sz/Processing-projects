import peasy.*;
import processing.serial.*; //connect with arduino serial port

Serial myPort; 
PeasyCam cam;

Table table;  //create table
float r = 0;  //rotation velocity
float volume = 30; //sound input
color c;
color bg = color(20);  //background color
color coord = color(0,255,188);  //theme green
float[] info = new float[4]; //store data of different countries
boolean bool = true; //control the display of information tile
String country = " ";  
PImage[] img = new PImage[7];  //store a group of country maps

 
void setup() {
  size(1600, 800, P3D);
  cam = new PeasyCam(this, 1500); //set camera
  cam.setMinimumDistance(300);
  cam.setMaximumDistance(1000);
  myPort = new Serial(this, "com3", 9600); //set sensor
  myPort.bufferUntil('\n'); //buffer until meet '\n', then call the event listener
  table = loadTable("noise.csv", "header"); //load data
  img[0] = loadImage("1.png");
  img[1] = loadImage("2.png");
  img[2] = loadImage("3.png");
  img[3] = loadImage("4.png");
  img[4] = loadImage("5.png");
  img[5] = loadImage("6.png");
  img[6] = loadImage("7.png");
}


//---- turn this event into comment if you want to control the panel manually ----
void serialEvent(Serial p) {
  String data = p.readString(); //read current sound dB from sensor 
  volume = float(data);
  if (volume>70)  // in case the volume input is too high
    volume=70;
}
//---- turn this event into comment if you want to control the panel manually ----


void draw() {
  // ----------------- 3d table --------------------
  
  // if not rotate by mouse, the coordinate system will still rotate automatically
  rotateY(radians(r));
  r+=0.03;  
 
  // clear info board if the mouse is not hovering on a specific country
  color currentColor = get(mouseX,mouseY);
  if (currentColor == bg || currentColor == coord){
     country = " ";
  }
 
  // create the 3d coordinates by box
  background(bg);
  pushMatrix();
  stroke(coord);
  strokeWeight(2);
  noFill();
  box(600);  
  fill(255,40,0);
  noStroke();
  popMatrix();
 
  // origin
  pushMatrix();
  translate(300,300,300);
  stroke(coord);
  noFill();
  sphere(3);
  popMatrix();
  
  // draw the grid which represents the breakpoint of high volume noise (45dB)
  for (int i=-300; i<=300; i+=20){
     pushMatrix();
     translate(0,0,0);
     stroke(coord);
     strokeWeight(1);
     line(i, -100, 300, i,-100,-300);
     line(-300,-100,i, 300,-100,i);
     popMatrix();
  }
  
  textSize(17);
  // noise level (Lnight) -> y axis
  pushMatrix();
  fill(coord);
  text("Noise Level (Lnight)", 300,-300,300);
  text("High Noise Level", -445,-100,300);
  popMatrix();
  
  // high noise sensitivity -> x axis
  pushMatrix();
  fill(coord);
  text("High Noise Sensitivity", -420,320,300);
  popMatrix();
  
  // highly annoyed rate -> z axis
  pushMatrix();
  fill(coord);
  text("Highly Annoyed Rate", 310,300,-300);
  popMatrix();
  
  
  for (int i=-2; i<3; i++){
    // mark levels of noise (y axis)
    pushMatrix();
    translate(300,100*i,300);
    stroke(coord);
    noFill();
    sphere(3);
    textSize(17);
    fill(0,255,188);
    text(45-5*(i+1)+" dB", 5, i+1);  // 30-50
 
    popMatrix();
  
    // mark levels of high noise sensitivity (z axis)
    pushMatrix();
    translate(100*i,300,300);
    stroke(coord);
    noFill();
    sphere(3);
    textSize(17);
    fill(0,255,188);
    text(40-5*(i+1)+" %", i+1, 20);  // 25-45
    popMatrix();
  
    // mark levels of highly annoyed rate (x axis)
    pushMatrix();
    translate(300,300,100*i);
    stroke(coord);
    noFill();
    sphere(3);
    textSize(17);
    fill(0,255,188);
    text(40-10*(i+1)+" %", 10, 0); // 10-50
    popMatrix();
  }

  // load table and draw spheres 
  // to represent the hypertension risks of different countries
  for (TableRow row : table.rows()) {
    pushMatrix();
    
    //get information from table
    int id = row.getInt("id");
    float noiseLevel = row.getFloat("noise levels (Lnight)");
    float sensitivity = row.getFloat("high noise sensitivity rate");
    float annoyance = row.getFloat("highly annoyed rate");
    float risk = row.getFloat("hypertension");
    float hypertension = row.getFloat("hypertension");
    
    //locate each sphere
    float xpos = ((sensitivity-25)/20)*(-400)+200;
    float ypos = ((noiseLevel-30)/20)*(-400)+200;
    float zpos = ((annoyance-10)/40)*(-400)+200;
    
    //display current volume on the back of the box by lines  
    for (int i=-300; i<=300; i+=10){
      float x = random(25,35);
      line (i,300,-300,  i,100-(volume-x)*10,-300);
      noFill();
      stroke(coord);
    }
    
    //use different colors to represent the different hypertension risks
    c = color(250,(-noiseLevel+40)*20+150,100);
    
    // if hovering on a specific sphere
    if (currentColor == c){
        //show this country's data
       info[0] = risk;
       info[1] = noiseLevel;
       info[2] = sensitivity;
       info[3] = annoyance;
       country = row.getString("country");
       
       // locate the coordination of this sphere and display it by lines
       fill(coord);
       line(xpos, ypos, zpos, xpos, 300, zpos);
       line(xpos, 300, zpos, xpos, 300, 300);
       line(xpos, 300, zpos, 300, 300, zpos);
       pushMatrix();
       translate(xpos,300,300);
       sphere(3);
       popMatrix();
       pushMatrix();
       translate(300,300,zpos);
       sphere(3);
       popMatrix();
       
       // add maps as textures to the bottom of the box
       // if hovering on a particular country, show the map on the bottom
       beginShape();
       noFill();
       noStroke();
       texture(img[id-1]);
       vertex(-200,300,-200, 0,0);
       vertex(200,300,-200, 300,0);
       vertex(200,300,200, 300,300);
       vertex(-200,300,200, 0,300);
       endShape();
    }
    
    //if current volume is equal to or higher than a specific value
    //then load data which are below or equal to this value 
    //use different scales of spheres to represent the different hypertension risks
     if (volume > noiseLevel){
      translate(xpos, ypos, zpos);
      noFill();
      noStroke();
      fill(c);
      sphere(hypertension);
    }
    popMatrix();
  }
  
  cam.beginHUD();//Stop peasy cam to leave the texts and panel unaffected
 
  //load particular information in 2d
  if(red(currentColor)<250){
     bool=false; // if not hovering on a sphere, display nothing
  }else{ // if hovering on a sphere(country), show related data
     fill(230);
     noStroke();
     rect(mouseX+5,mouseY+5, 300,150);
     fill(20);
     text(country, mouseX+30, mouseY+30);
     text("Hypertension Risk:  "+info[0], mouseX+30, mouseY+55);
     text("Noise Level:  "+info[1], mouseX+30, mouseY+80);
     text("Sensitivity:  "+info[2], mouseX+30, mouseY+105);
     text("Annoyance:  "+info[3], mouseX+30, mouseY+130);
     textSize(23);
     bool=true;
  }
    
    
  // ---------- 2d panel on the right side ----------
  
  //line(1400,300, 1400-100*(cos(volume)),300+100*(sin(volume)));
  
  if (volume <45){
    fill(coord);//if current volume is under 45 dB, circles will be green 
  }else{
    fill(255,0,0);//if current volume is under 45 dB, circles will be red as warnings
  }
  textSize(30);
  text(floor(volume)+"dB",1382,300); //show current volume in number
  
  pushMatrix();
  stroke(coord);
  noFill();
  ellipse(1420,290, 100,100); // draw the first circle
  popMatrix();

  int n = floor(volume/10); // the numbers of circles(rings)
  
  // draw circles(rings) to represent current volume
  for (int i=0; i<=n; i++){
    if (volume<45){
    pushMatrix();
    stroke(0,255,188,70*(n-i));
    strokeWeight(2);
    noFill();
    ellipse(1420,290, 100+i*15,100+i*15); // set the alpha as dynamic so as to display a fade out effect
    popMatrix();
    }else{
    pushMatrix();
    stroke(255,0,0,70*(n-i));
    strokeWeight(2);
    noFill();
    ellipse(1420,290, 100+i*15,100+i*15);
    popMatrix();
    }
  }
  
  // create triangle buttons to let user control current volume manually
  pushMatrix();
  fill(137,255,231);
  noStroke();
  triangle(1395,180, 1420,130, 1445,180);
  popMatrix();
  pushMatrix();
  fill(137,242,255);
  noStroke();
  triangle(1395,400, 1420,450, 1445,400);
  popMatrix();
  
  // texts
  textSize(16); 
  fill(coord);
  text("This pooled analysis based on seven European countries. The findings indicate possible modifier effects of aircraft noise annoyance and noise sensitivity in the relationship between aircraft noise levels and the risk of hypertension.", 50,400, 300,600);
  text("Instructions:", 1280,520);
  text("1. Press 's' to save current page;", 1280,550);
  text("2. Scroll up/down to zoom in/out; ", 1280,580);
  text("3. Drag the box to view more clearly; ", 1280,610);
  text("4. Control the volume manually", 1280,640);
  text("    or by a sound sensor", 1280,670);
  text("    (recommended)", 1280,700);
  text("5. The higher the volume is, the more", 1280,730);
  text("    data will be displayed.", 1280,760);
  
  textSize(12);
  fill(coord);
  text("Source: The role of aircraft noise annoyance and noise sensitivity in the association between aircraft noise levels and hypertension risk: Results of a pooled analysis from seven European countries(2020)", 50,640, 300,730);
  
  PFont font;
  font = createFont("LSANS.TTF",40);
  textFont(font);
  fill(coord);
  text("Hypertension Risk Caused by Aircraft Noise in Different Countries", 50,50, 350,300);
  
  cam.endHUD();
}


//control the volume manually by the triangle buttons
void mouseClicked(){
   // the value should not exceed 54dB or below 24dB
  color got = get(mouseX,mouseY);
  int add = 3;
  int minus = -3;
  if (volume>24 && volume<54){
    if (got == color(137,255,231)){
      volume = volume+add;
    }else if (got == color(137,242,255)){
      volume = volume+minus;
    }
  }else if(volume<=24){
    if (got == color(137,255,231)){
      volume = volume+add;
    }
  }else if(volume>=54){
    if (got == color(137,242,255)){
      volume = volume+minus;
    }
  }
}


//save current frame
void keyPressed(){
  // save, clear and load images by keypresses
  switch (key)
  {
  case's':
  //save picture;
  PImage canvas = get(0,0,  1600,800);
  canvas.save("canvas.jpg");
  break;
  }
}
