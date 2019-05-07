/*
 | Welcome to the Floxes 2 SRC, this is an extension of the 
 | Flocking simulation listed on the Processing examples page.
 *
 | Salvatore Greco
 | 5/6/2019
 | slgreco@buffalo.edu
 | github: https://github.com/GrecoSorcerer/Floxes2
 */
// The Boid class
float rangeLinesOutter = 63, rangeCohesionDist = 96.5, rangeAlignDist = 80.5, rangeDesiredSeparation = 63, rangeColorAveraging = 63.5f;
boolean drawOutterLines = false;
float maxColorDist = 40;

class Boid {
  // Variables that define each boid in the flocking simulation
  int id;
  float age = 0; // used to respawn boids and keep their color ~fresh~
  float deathAge = random(75, 150);
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r; // Whats this for again?
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  PVector boidColor;
  
  Boid(float x, float y, PVector boidColor) {
    acceleration = new PVector(0, 0, 0);
    this.boidColor = boidColor; 
    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle),sin(angle));

    position = new PVector(x, y, random(0,depth));
    r = 2.0;
    maxspeed = 2;
    maxforce = 0.03;
  }

  void run(ArrayList<Boid> boids) {
    //if(DEBUG) {print("Flocking");}
    flock(boids);
    update();
    borders();
    render(boids);
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  void respawn() {
    //print("A boid has respawned");
    this.age = 0;
    this.deathAge = random(100, 250);
    this.position = new PVector(random(height),random(width),random(depth));
    this.boidColor = new PVector(random(0, 255), random(0, 255), random(0, 255));
    
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep;
    PVector ali;
    PVector coh;
    if (followFlightRules){
      sep = separate(boids);   // Separation
      ali = align(boids);      // Alignment
      coh = cohesion(boids);   // Cohesion
      
    // Arbitrarily weight these forces
      sep.mult(1.5);
      ali.mult(1.0);
      coh.mult(1.0);
    
    // Add the force vectors to acceleration
    //setColor()
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    } else {
      sep = repell(boids);
    }
    PVector locCols = avgColorVec(boids);
    this.age +=0.1;
    //print(this.age);
    if (this.age >= deathAge) {
      this.respawn();
    }
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // Originally defined by {Not me}, but I've updated it to work in 3D space
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  // Originally defined by {Not me}, but I've updated it to work in 3D space, as well as to include a few other aesthetic choices.
  void render(ArrayList<Boid> boids) {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    float connectionrange = rangeLinesOutter;
    // Keep the number of lines each boid can have to a manageable number
    int maxLines = 40;
    
    int lines = 0; // Count of number of lines that have been drawn for a boid. if > 40 don't draw anymore.
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      
      if ((uses3D) && ((d>40 && d<=rangeCohesionDist) || (drawOutterLines) && (d>=rangeDesiredSeparation+50 && d<connectionrange+100)) && lines < maxLines) {
        stroke(this.boidColor.x,this.boidColor.y,this.boidColor.z, 155); //Line color is the average of source boid and destination boid
        strokeWeight(2);
        line(this.position.x,this.position.y,this.position.z,other.position.x,other.position.y,other.position.z); // Draw the lines
        lines++;
      }
    }
   
    
    // Used to change how boids are rendered on the screen.
    if (uses3D) {
      fill(this.boidColor.x, this.boidColor.y, this.boidColor.z,200);
      //stroke(boidColor.x, boidColor.y, boidColor.z);
      pushMatrix();
      //stroke(10);
      //strokeWeight(1);
      noStroke();
      translate(position.x, position.y, (position.z)); 
        
      sphereDetail(6);
      sphere(6);
      
      popMatrix();
    }
    if (!uses3D) {
      fill(200, 100);
      stroke(boidColor.x, boidColor.y, boidColor.z);
      pushMatrix();
      translate(position.x, position.y,0);
      rotate(theta);
      beginShape(TRIANGLES);
      vertex(0, -r*2);
      vertex(-r, r*2);
      vertex(r, r*2);
      endShape();
      popMatrix();
    }
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.z < -r) position.z = depth+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
    if (position.z > depth+r) position.z = -r;
    
  }
  // Separation
  // Method checks for nearby boids and steers away
  // Originally defined by {Not me}, but I've updated it to work in 3D space
  PVector repell (ArrayList<Boid> boids) {
    float desiredseparation = 1000;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d*d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(4*maxforce);
    }
    return steer;
  }
  // Separation
  // Method checks for nearby boids and steers away
  // Originally defined by {Not me}, but I've updated it to work in 3D space
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = rangeDesiredSeparation;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  //Originally defined by {Not me}, but I've updated it to work in 3D space
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = rangeAlignDist;
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0, 0);
    }
  }
  void setBoidColor(PVector newColor) {
    boidColor = newColor;
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  //Originally defined by {Not me}, but I've updated it to work in 3D space
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = rangeCohesionDist;
    PVector sum = new PVector(0, 0, 0);   // Start with empty vector to accumulate all positions

    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0, 0);
    }
  }
  
  /** A function I wrote that takes the list of boids and compares the current to 
    * all boids in the ArrayList, checking if its within it's range. If two boids are within
    * the designated range average their colors and set their color to that.
    */
  PVector avgColorVec(ArrayList<Boid> boids) {
    
    // Set the local colorfov to the globabl variable rangeColorAveraging declared in Floxes2.pde, controlled with the C key
    float colorfov = rangeColorAveraging;
    
    // An arbitary number of local boids a boid will stop at. Maybe this could be defined randomly in boid contstructor.
    float mutationrange=9;
    
    // Processing doesnt let us average two colors like your would a vector, so thats exactly what I used.
    //By using a vector here it simplifies the code needed to average multiple boids colors.
    //We add the active boids color to the avgColorOfLocalBoids PVector so that it takes itself into account.
    PVector avgColorOfLocalBoids = new PVector().add(this.boidColor);
    // Set the count to one, since there is one boid being averaged so far
    int count = 1;
    
    //Here we get each boid element OTHER from the ArrayList of boids
    for (Boid other : boids) {
      //Check the distance between the active boid and the OTHER boid
      float d = PVector.dist(position, other.position);
      // Check the distance between two colors.
      // We use the distance between two colors to check if the colors are sufficently close enough or different enough to be averaged.
      float colordist = PVector.dist(this.boidColor, other.boidColor);
      if (d>0 && d < colorfov) {
        // Compare colorDist oto maxColorDist. maxColor dist is controlled with the X key
        if (colordist < maxColorDist) {
          continue;
        }
        // if the two colors are within range, and the colors have sufficient distance. then it will be added to the PVector avgColorOfLocalBoids
        avgColorOfLocalBoids.add(other.boidColor);
        count++;
      }
    }
    //avgColorOfLocalBoids.normalize();
    avgColorOfLocalBoids.div(count);
    if (count > mutationrange ) {
      //if count is less the mutation range, spice it up and set the aveColorofLocalBoids to a random PVector.
      avgColorOfLocalBoids = new PVector(random(0, 255), random(0, 255), random(0, 255));
    }
    //Here we update the avtive boids color
    setBoidColor(avgColorOfLocalBoids);
    return avgColorOfLocalBoids;
  }
}
