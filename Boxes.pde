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
