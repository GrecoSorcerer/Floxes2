//http://answers.opencv.org/question/93161/how-to-count-faces-in-the-video/ // To try and count faces to make a model classroom maybe?
//lookup buttons
//start screens
/*
class Boxes
{
  float x,y,z,angle;
  int xOffset, yOffset;
  Boxes (float x, float y, int xOffset, int yOffset)
  {
    this.x = x;
    this.y = y;
    this.xOffset = xOffset;
    this.yOffset = yOffset;
  }
  void update (float x, float y,float angle)
  {
    this.x = x;
    this.y = y;
    this.angle = angle;
  }
  void display (  )
  {
    pushMatrix();
    translate(xOffset + x, yOffset + y , 0);
    rotateY(angle);
    box(25);
    popMatrix();
  }
  
}

class Cluster
{
  
}
//End class defs

Boxes[][] boxes;
float angle,distance2Center_m;
int boxCount=3;

void setup (  )
{
  size (1024,480,P3D);
  background (100);
  noFill();
  boxes= new Boxes[boxCount][boxCount];
  noLoop();
  for (int i = 0;  i < boxCount; i+=1) 
  {
    for (int j = 0;  j < boxCount; j+=1)
    {
      
      boxes[i][j] = new Boxes(mouseX, mouseY,42*(-1+i),42*(-1+j));
      print(boxes[i][j].x," ",boxes[i][j].y);
    }
  }  
}

void draw (  )
{
  distance2Center_m = dist(width/2, height/2,mouseX,mouseY);
  print("=======\n",width/2, height/2,"\n");
  print(mouseX,mouseY,"\n");
  print(distance2Center_m,"\n");
  background (100);
  angle += .01;
  
  
  ellipseMode(CENTER);
*/
  /* Larger Outer circle
     Group other interestin gthings to appear in here, with scaling sizes
  */
  /*
  fill (150,150);
  noStroke ();
  ellipse (width/2, height/2, 1*distance2Center_m+(pow(distance2Center_m,1.5)/10), 1*distance2Center_m+(pow(distance2Center_m,1.5))/10);
  
  
  fill (255);
  ellipse (width/2, height/2, 1*distance2Center_m+40, 1*distance2Center_m+40);
  
  noFill ();
  stroke (0,240,0);
  for (int i = 0; i < boxCount;  i+=1)
  {
    for (Boxes box : boxes[i]) 
    {
      box.update(mouseX,mouseY,angle);
      box.display();
    }
  }
}

void mousePressed() {

  loop();

}



void mouseReleased() {

  noLoop();

}
*/
