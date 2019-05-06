/*
 | Welcome to the Floxes 2 SRC, this is an extension of the 
 | Flocking simulation listed on the Processing examples page.
 */
// TODO: A way to see controls and get feedback on changes
// TODO: mainmenu, more sounds
// TODO: clean up code and comments
// Audio stuff
import ddf.minim.*;
import processing.sound.*;
import java.util.*;
Minim minim;

AudioPlayer birds1;
AudioPlayer balalaika, running, breath, rawA, rawBm, rawCsm, rawD, rawE, rawFsm, rawE7; // Balalaika sounds
AudioPlayer static1;
SoundFile pitchedNote1;
SoundFile pitchedNote2;
AudioInput input; 

// Makes seeing gooder 
import peasy.*;

// A Flock object containing an ArrayList of Boid objects.
Flock flock;

//##################################
//###		    	Config		      	 ###
//##################################

boolean menu = true;
Boxes[][] boxes;
float angle,distance2Center_m;
int boxCount=3;



// Sets the initial window Size. Also controls size of Floxes boundary.
int depth;

// Change this to set the initial flock size.
int flocksize = 700;

// A Value used to adjust Flox parameters.
float modifier = 0.5;

// Enable debug outputs to console.
boolean DEBUG = true;

// Change how Floxes renders.
boolean uses3D = true;

// Press keys to play the Balalaika.
boolean balalaikaMode = false;

// Causes Floxes to fly away from one another.
boolean followFlightRules = true;

//Used for debug calculations. See header
float averageAge;

//Used for debug calculations. See heard
float lastAvAge;

// Camera Object used to check out the various angles the simulation can be viewed from
PeasyCam camera;

void setup() {
  // The size we use for the window, with 3D rendering enabled
  size(900, 900, P3D);
  // The space is essentially supposed to be a Cube, so set the depth to be equal to one of the edges
  depth = width;
  
  // Dont fill the cube
  noFill();
  
  // create boxes object for menu
  boxes= new Boxes[boxCount][boxCount];
  
  // add box to the cluster of boxes
  for (int i = 0;  i < boxCount; i+=1) 
  {
    for (int j = 0;  j < boxCount; j+=1)
    {
      
      boxes[i][j] = new Boxes(mouseX, mouseY,42*(-1+i),42*(-1+j));
      
    }
  }  
  /**
    * This section brings in all the sounds the project uses.
    */
  Minim minim = new Minim(this);
  
  balalaika = minim.loadFile("audio/BalalaikaLoop2.wav");
  // Setting the volume of the sound
  balalaika.setGain(-9);
  
  rawA = minim.loadFile("audio/rawABlka.wav"); // Play this sound when alignment is adjusted
  rawD = minim.loadFile("audio/rawDBlka.wav"); // Play this sound when separation changes
  rawCsm = minim.loadFile("audio/rawCsmBlka.wav"); // Play this sound when cohesion changes
  
  rawBm = minim.loadFile("audio/rawBmBlka.wav"); // Play when modifier > 0 when control key is pressed
  
  // We use a differnt sound library here so we can set the the pitch of this sound later to better understand the scale of variable
  pitchedNote1 = new SoundFile(this, "audio/rawBmBlka.wav"); 
  pitchedNote2 = new SoundFile(this, "audio/rawEBlka.wav"); 
  
  rawE = minim.loadFile("audio/rawEBlka.wav"); // Play when modifier < 0 when control key is pressed
  rawFsm = minim.loadFile("audio/rawFsmBlka.wav"); // Play when modifier = 0 when control key is pressed
  
  
  
  static1 = minim.loadFile("audio/static1.wav");
  // Setting the volume of the sound
  static1.setGain(-4);
  
  birds1 = minim.loadFile("audio/birds1.wav");
  // Setting the volume of the sound
  birds1.setGain(5);
  
  running = minim.loadFile("audio/running.wav");
  running.setLoopPoints(0,700);
  // Setting the volume of the sound
  running.setGain(4);
  
  breath = minim.loadFile("audio/breath.wav");
  // Setting the volume of the sound
  breath.setGain(7);
  /**
    * End of sounds to be brought in
    */
  // A new flock is created here.
  flock = new Flock();

  // Add our PeasyCam view.
  camera = new PeasyCam(this, width/2, height/2, depth/2, 600);

  // Add an initial set of boids into the system
  for (int i = 0; i < flocksize; i++) {
    flock.addBoid(new Boid(random(width), random(height), new PVector(random(0, 255), random(0, 255), random(0, 255))));
  }

}

// An early snippet from a sketch I wrote to understand 3D position, its used as a menu now.
void drawMenu() {
  
  distance2Center_m = dist(width/2, height/2,mouseX,mouseY);
  background (100);
  angle += .01;
  
  ellipseMode(CENTER);

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

void drawFloxes() {
  
  surface.setTitle("FS:"+flock.boids.size()+"| avAge ~" + floor(averageAge) +"| ~"+floor(frameRate));
  
  // Set camera sates based on render mode
  if (uses3D) {
    background(#4BBEE3); //Zima Blue
    camera.lookAt(width/2, height/2, depth/2);
  } else {
    background(50); 
    camera.lookAt(width/2, height/2, 0, depth);
  }
  
  // Used to return the boids to a flocking state once mouse in no longer pressed
  if (!mousePressed){
    balalaika.rewind();
    balalaika.pause();
    running.rewind();
    running.pause();
    followFlightRules = true;
  }
  
  //Calculate average age of Boids
  float agetotal = 0;
  for(Boid boid: flock.boids) {
    agetotal += boid.age;
  }
  averageAge = (agetotal/flock.boids.size());
  
  // Switching between render modes
  if (uses3D) {
    // Sets lighting on Boids
    lights();
    smooth();
    ambientLight(150,150,150,width/2,height/2,depth/2);
    pushMatrix();
    noFill();
    strokeWeight(2);
    stroke(255);
    translate(width/2, height/2, depth/2);
    box(width);
    popMatrix();
  }

  flock.run();

  strokeWeight(1);
  //pitchedNote.stop(); 
}

void draw() {
  if (menu) {
    drawMenu();
    camera.lookAt(width/2, height/2, 0, depth);
    if(mousePressed && (dist(mouseX,mouseY, width/2, height/2) <= 40)){
      menu = !menu;
      static1.play();
      static1.rewind();
      birds1.loop();
    }
  } 
  else {
    drawFloxes();
  }
}

// Disrupt the simulation if the viewer changes the orientation of the camera.'
// Boids stop flocking if Left Mouse is pressed
void mousePressed() {
  if (mouseButton == LEFT) {
    for(Boid boid: flock.boids){
      boid.velocity=boid.velocity.sub(boid.seek(PVector.random3D()));
      boid.update();
    }
    balalaika.loop();
    running.loop();
    followFlightRules = false;
  }
}

void timedBoolFlip(int milis, boolean var) {
  //TODO implement this
}

void keyPressed() {
  char pressed = Character.toLowerCase(key); // Get the lowercase char of pressed key.
  int special = keyCode;

  if (DEBUG) {
    print("\n[DEBUG][Input] KeyPressed ["+pressed+"]");
    print("\n[DEBUG][Input] KeyCode ["+keyCode+"]");
  }
  // When a key on this list is pressed, trigger the associated effect. If the key isn't mapped the default will trigger.
  switch(pressed) {
    case('v'):
    print("\n[DEBUG][CONFIGS] 3D view enabled.");
    uses3D = !uses3D;
    break;
    case('s'):
    rangeDesiredSeparation += modifier;
    print("\n[DEBUG][CONFIGS] Changed separation by " + modifier + ", separation is now " + rangeDesiredSeparation);
    rawD.play();
    rawD.rewind();
    timedBoolFlip(500, followFlightRules);
    break;
    case('a'):
    rangeAlignDist += modifier;
    print("\n[DEBUG][CONFIGS] Changed alignment by " + modifier + ", alignment is now " + rangeAlignDist);
    rawA.play();
    rawA.rewind();
    timedBoolFlip(500, followFlightRules);
    break;
    case('d'):
    rangeCohesionDist += modifier;
    print("\n[DEBUG][CONFIGS] Changed cohesion by " + modifier + ", cohesion is now " + rangeCohesionDist);
    rawCsm.play();
    rawCsm.rewind();
    timedBoolFlip(500, followFlightRules);
    break;
    case('l'):
    rangeLinesOutter += modifier;
    print("\n[DEBUG][CONFIGS] Changed rangeLines by " + modifier + ", Separation is now " + rangeLinesOutter);
    break;
    case('q'):
    drawOutterLines = !drawOutterLines;
    static1.play();
    static1.rewind();
    print("\n[DEBUG][CONFIGS] Draw outer lines " + drawOutterLines);
    break;
    case('c'):
    rangeColorAveraging += modifier;
    print("\n[DEBUG][CONFIGS] Changed color avg range " + modifier + " Color avg range is now" + rangeColorAveraging);
    break;
    case('x'):
    //rangeColorAveraging += modifier;
    rawFsm.play();
    rawFsm.rewind();
    maxColorDist += modifier;
    print("\n[DEBUG][CONFIGS] Changed color avg range " + modifier + " Color avg range is now" + maxColorDist);
    break;
    
    // This Case has been depricated.
    //case('r'):
    //followFlightRules = !followFlightRules;
    //print("\n[DEBUG][CONFIGS] Follow Flight Rules " + followFlightRules);
    //break;
    // Using a modified implementation of fizzbuzz, play a sound
    default:
    if((keyCode % 3 <= 1) && (keyCode % 5 <= 1)) {
        rawCsm.play();
        rawE.play();
        rawCsm.rewind();
        rawE.rewind();
      }
      else if(keyCode % 5 <= 1){
        rawCsm.play();
        rawCsm.rewind();
      }
      else if (keyCode % 3 <= 1){
        rawCsm.play();
        rawCsm.rewind();
      }
      break;
  }
  //Used to adjust the modifier value when changing flocking parameters.
  switch(keyCode) {
    case(UP):
    modifier += 0.5;
    if (modifier > 0){
      pitchedNote1.play(modifier/2);
    }
    else if (modifier < 0) {
      pitchedNote2.play(1/(-modifier));
      print(1/(-modifier));
    }
    
    print("\n[CONFIGS] Incriment: " + modifier);
    break;
    case(DOWN):
    modifier -= 0.5;
    if (modifier > 0){
      pitchedNote1.play(modifier/2);
    }
    else if (modifier < 0) {
      pitchedNote2.play(1/(-modifier));
      print(1/(-modifier));
    }
    print("\n[CONFIGS] Incriment: " + modifier);
    break;
    case(17):
    modifier *= -1;
    if (modifier>0){
      rawBm.play();
      rawBm.rewind();
    } 
    else if (modifier < 0) {
      rawE.play();
      rawE.rewind();
    } 
    else {
      rawFsm.play();
      rawFsm.rewind();
    }
    print("\n[CONFIGS] Flipped sign: " + modifier);
    break;
    
    default:
      // Do nothing
      break;
  }
}


// The Flock (a list of Boid objects)
class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
}
