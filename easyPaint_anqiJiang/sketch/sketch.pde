float value=1; // brush width
color currentColor; // brush color
PImage img; // background image

//set four brushes (including eraser)
PImage eraser;
PImage pencil;
PImage mark;
PImage calligraphy;
PImage blank;
boolean x = false; // lock the calligraphy brush if it's not chosen


void setup(){
  size(1200,960);
  
  //load interface images
  img = loadImage("shanshui.jpg");
  background(img);
  eraser = loadImage("eraser.png");
  image(eraser, 710,872);
  pencil = loadImage("pencil.png");
  image(pencil, 800,870);
  mark = loadImage("mark.png");
  image(mark, 885,870);
  calligraphy = loadImage("calligraphy.png");
  image(calligraphy, 980,870);
  
  // set the color palette of traditional Chinese painting
  noStroke();
  fill(255,255,255);
  rect(200,80, 900,700);
  fill(22,124,128);
  circle(100,100,50);
  fill(135,192,205);
  circle(100,160,50);
  fill(183,227,228);
  circle(100,220,50);
  fill(50,182,122);
  circle(100,280,50);
  fill(94,103,97);
  circle(100,340,50);
  
  // instructions for users
  String intro="Press 's' to save current image\nPress 'c' to clear canvas\nPress 'l' to load the last image\nScroll up and down to change brush width";
  textSize(17);
  text(intro, 80,830);
}


void draw() {
  strokeWeight(value); //adapt current brush width
  
  // use a blank image to replace previous texts
  blank = loadImage("blank.png"); 
  image(blank, 490,893);
  
  // show current brush width
  String newWidth= String.valueOf(value);
  text("Brush width:"+" "+newWidth, 490,893, 150,100); 
  textSize(17);
}

void keyPressed(){
  // save, clear and load images by keypresses
  switch (key)
  {
  case's':
  //save picture;
  PImage canvas = get(200,80,  900,700);
  canvas.save("canvas.jpg");
  break;
  
  // clear the canvas by overwriting, cover it with another new white canvas
  case'c': 
  PImage newCanvas = loadImage("newcanvas.png");
  image(newCanvas,  200,80);
  break;
  
  //load the last saved picture
  case'l':
  PImage newPic;
  newPic = loadImage("canvas.jpg");
  image(newPic,  200, 80);
  }
}

void mouseDragged() {
  if(mouseX>=210 && mouseX<=1090 && mouseY>=90 && mouseY<=770){
    line(mouseX,mouseY,pmouseX,pmouseY);
    stroke(currentColor); 
    if (x==true){
       value=value+1;
       if (value == 25){
       value=value-20;
       } // if the calligraphy brush is activated, set value to display the effect
    }else{
    line(-10,-10,-11,-11); // if user keeps dragging mouse outside the canvas, make the lines invisible
    }
  }
}

void mouseClicked(){
  if ((mouseX>=100 && mouseX<=150)&&(mouseY>=50 && mouseY<=340)){
    currentColor=get(mouseX,mouseY); 
    // if click on the palette, get color from screen 
  }else if((mouseX >= 710 && mouseX <=745) && (mouseY >= 870)){
    currentColor=255;
    x=false;
    // if click on eraser, change brush color to white
  }else if((mouseX >= 800 && mouseX <=840) && (mouseY >= 870)){
    value=1;
    strokeCap(ROUND);
    x=false;
    // if click on pencil, change brush size to 1;
  }else if((mouseX >= 885 && mouseX <=943) && (mouseY >= 870)){
    strokeCap(PROJECT);
    x=false;
    // if click on marker, change strokecap to project
  }else if((mouseX >= 980 && mouseX <=1045) && (mouseY >= 870)){
    strokeCap(ROUND);
    x=true; 
    // if click on calligraphy brush, activate it
    }
  } 


void mouseWheel(MouseEvent event) {
  // use mouse wheel to control brush width
  float e = event.getCount();
  if(value>0 && value<25){   // maximum size:25
     if (e==-1.0){   // scroll up -- wider
       value=value+1;
     }else if(e==1.0){   // scroll down -- narrower
       value=value-1;
     }
  }else{
  value=1; // minimum size:1
  }
}
