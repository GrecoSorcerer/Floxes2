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

float averageAge;

float lastAvAge;

PeasyCam camera;
void setup() {

  size(900, 900, P3D);
  depth = width;
  
  Minim minim = new Minim(this);
  
  balalaika = minim.loadFile("audio/BalalaikaLoop2.wav");
  balalaika.setGain(-9);
  
  rawA = minim.loadFile("audio/rawABlka.wav"); // Play this sound when alignment is adjusted
  rawD = minim.loadFile("audio/rawDBlka.wav"); // Play this sound when separation changes
  rawCsm = minim.loadFile("audio/rawCsmBlka.wav"); // Play this sound when cohesion changes
  
  rawBm = minim.loadFile("audio/rawBmBlka.wav"); // Play when modifier > 0 when control key is pressed
  pitchedNote1 = new SoundFile(this, "audio/rawBmBlka.wav"); 
  pitchedNote2 = new SoundFile(this, "audio/rawEBlka.wav"); 
  rawE = minim.loadFile("audio/rawEBlka.wav"); // Play when modifier < 0 when control key is pressed
  rawFsm = minim.loadFile("audio/rawFsmBlka.wav"); // Play when modifier = 0 when control key is pressed
  
  
  
  static1 = minim.loadFile("audio/static1.wav");
  static1.setGain(-4);
  
  birds1 = minim.loadFile("audio/birds1.wav");
  birds1.setGain(5);
  
  running = minim.loadFile("audio/running.wav");
  running.setLoopPoints(0,700);
  running.setGain(7);
  
  breath = minim.loadFile("audio/breath.wav");
  breath.setGain(7);
  
  // A new flock is created here.
  flock = new Flock();

  // Add our PeasyCam view.
  camera = new PeasyCam(this, width/2, height/2, depth/2, 600);

  // Add an initial set of boids into the system
  for (int i = 0; i < flocksize; i++) {
    flock.addBoid(new Boid(random(width), random(height), new PVector(random(0, 255), random(0, 255), random(0, 255))));
  }
  
  birds1.loop();
}


void draw() {
  //pitchedNote.play();
  surface.setTitle("FS:"+flock.boids.size()+"| avAge ~" + floor(averageAge) +"| ~"+floor(frameRate));
  
  if (uses3D) {
    background(#4BBEE3); //Zima Blue
    camera.lookAt(width/2, height/2, depth/2);
  } else {
    background(50); 
    camera.lookAt(width/2, height/2, 0, depth);
  }
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
void mousePressed() {
  if (mouseButton == LEFT) {
    for(Boid boid: flock.boids){
      boid.velocity=boid.velocity.sub(boid.seek(PVector.random3D()));
      boid.update();
    }
    print("pressed");
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
    maxColorDist += modifier;
    print("\n[DEBUG][CONFIGS] Changed color avg range " + modifier + " Color avg range is now" + maxColorDist);
    break;
    case('r'):
    followFlightRules = !followFlightRules;
    print("\n[DEBUG][CONFIGS] Follow Flight Rules " + followFlightRules);
    break;
  }
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
      if((key % 3 == 0) && (key % 5 == 0)) {
        
      }
      else if(key % 5 == 0){
        
      }
      else if (key % 3 == 0){
      
      }
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
