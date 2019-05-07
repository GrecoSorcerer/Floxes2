/*
 | Salvatore Greco
 | 5/6/2019
 | slgreco@buffalo.edu
 | github: https://github.com/GrecoSorcerer/Floxes2
 */
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
    //basically a vector update
    this.x = x; // this boxes x
    this.y = y; // this boxes y
    //the angle of the box
    this.angle = angle;
  }
  void display (  )
  {
    pushMatrix();//start a new local transfrom
    //apply transfromation
    translate(xOffset + x, yOffset + y , 0);
    //rotate to angle 
    rotateY(angle);
    //Draw box of size 25
    box(25);
    //return to the normal global space
    popMatrix();
  }
  
}
