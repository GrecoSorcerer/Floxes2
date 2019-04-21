/*
 | Welcome to the Floxes 2 SRC, this is an extension of the 
 | Flocking simulation listed on the Processing examples page.
 */

// Makes seeing gooder 
import peasy.*;

// A Flock object containing an ArrayList of Boid objects.
Flock flock;

//##################################
//###			Config			 ###
//##################################

// Sets the initial window Size. Also controls size of Floxes boundary.
int depth;
// Change this to set the initial flock size.
int flocksize = 500;
float modifier = 0.5;
// Enable debug outputs to console.
boolean DEBUG = true;
// Change how Floxes renders.
boolean uses3D = false;

float averageAge;

float lastAvAge;

PeasyCam camera;
void setup() {

  size(600, 600, P3D);
  depth = width;

  // A new flock is created here.
  flock = new Flock();

  // Add our PeasyCam view.
  camera = new PeasyCam(this, width/2, height/2, depth/2, 600);

  // Add an initial set of boids into the system
  for (int i = 0; i < flocksize; i++) {
    flock.addBoid(new Boid(random(width), random(height), new PVector(random(0, 255), random(0, 255), random(0, 255))));
  }
}


void draw() {
  surface.setTitle("FS:"+flock.boids.size()+"| avAge" + floor(averageAge) +"| "+frameRate);
  if (uses3D) {
    background(155); 
    camera.lookAt(width/2, height/2, depth/2);
  } else {
    background(50); 
    camera.lookAt(width/2, height/2, 0, depth);
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
}

void keyPressed() {
  char pressed = Character.toLowerCase(key); // Get the lowercase char of pressed key.
  int special = keyCode;

  if (DEBUG) {
    print("\n[DEBUG] KeyPressed ["+pressed+"]");
    print("\n[DEBUG] KeyCode ["+keyCode+"]");
  }

  switch(pressed) {
    case('v'):
    print("\n[CONFIGS] 3D view enabled.");
    uses3D = !uses3D;
    break;
    case('s'):
    rangeDesiredSeparation += modifier;
    print("\n[CONFIGS] Changed separation by " + modifier + ", separation is now " + rangeDesiredSeparation);
    break;
    case('a'):
    rangeAlignDist += modifier;
    print("\n[CONFIGS] Changed alignment by " + modifier + ", alignment is now " + rangeAlignDist);
    break;
    case('d'):
    rangeCohesionDist += modifier;
    print("\n[CONFIGS] Changed cohesion by " + modifier + ", cohesion is now " + rangeCohesionDist);
    break;
    case('l'):
    rangeLinesOutter += modifier;
    print("\n[CONFIGS] Changed rangeLines by " + modifier + ", Separation is now " + rangeLinesOutter);
    break;
    case('q'):
    drawOutterLines = !drawOutterLines;
    print("\n[CONFIGS] Draw outer lines " + drawOutterLines);
    break;
  }
  switch(keyCode) {
    case(UP):
    modifier += 0.5;
    print("\n[CONFIGS] Incriment: " + modifier);
    break;
    case(DOWN):
    modifier -= 0.5;
    print("\n[CONFIGS] Incriment: " + modifier);
    break;
    
    default:
      // Do nothing
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
