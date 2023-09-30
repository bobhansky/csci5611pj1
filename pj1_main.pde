import processing.sound.*;

// *********************** Scenes ************************
int Nlines = 12;
Line[] lines = new Line[Nlines];
Line lu = new Line(0, 180, 80, 350);    // left up
Line ld = new Line(80, 350, 0, 500);    // left down
Line ru = new Line(440, 180, 400, 350);    // right up
Line rd = new Line(400, 350, 440, 500);    // right down
Line lowerleft = new Line(140, 400, 190, 500);    // left down
Line lowerright = new Line(340, 400, 290, 500);    // left down

Line pipe = new Line(440, 120, 440, 720); 
Line corner = new Line(440, 0, 480, 50);   

// quad
Line left = new Line(200, 570, 200, 600);
Line up = new Line(200, 570, 250, 570);
Line right = new Line(250, 570, 250, 600);
Line down = new Line(200, 600, 250, 600);

int Nobstacles = 3;

Circle[] obstacles = new Circle[Nobstacles];
Circle c1 = new Circle(100, 200, 35);
Circle c2 = new Circle(220, 150, 50);
Circle c3 = new Circle(340, 200, 35);

// *********************** Scenes ends ************************

int Nballs = 5;
int curN = 0;
Circle balls[] = new Circle[Nballs];
Vec2 vel[] = new Vec2[Nballs];
float mass[] = new float[Nballs];

int NParti = 0;
int maxParticles = 400;
Vec2 velPat [] = new Vec2[maxParticles];
Vec2 posPat [] = new Vec2[maxParticles];
boolean displayParticle = false;
float genRate = 40;

float COR = 0.6;
Vec2 gravity = new Vec2(0,500);

// time
long t1 = 0;
long t2 = 0;

SoundFile file;


void setup(){
    size(480, 720);
    lines[0] = lu;
    lines[1] = ld;
    lines[2] = ru;
    lines[3] = rd;
    lines[4] = lowerleft;
    lines[5] = lowerright;

    lines[6] = pipe;
    lines[7] = corner;

    // quad
    lines[8] = left;
    lines[9] = up;
    lines[10] = right;
    lines[11] = down;

    obstacles[0] = c1;
    obstacles[1] = c2;
    obstacles[2] = c3;

    for(int i = 0; i < Nballs; i++){
      balls[i] = new Circle(450, 680, 15);
      vel[i] = new Vec2(0,-800 - random(400));    // 800 to 1200
      mass[i] = balls[i].radius * balls[i].radius;
    }


  file = new SoundFile(this, "fireworks.mp3");
}


void draw(){
  drawScene();
  drawBalls();
  fill(200, 0, 200);

  rect(200, 570, 50, 30);


  update(1.0/frameRate);

 
}

void drawScene(){
  PImage img = loadImage("bg.jpg");
  background(img); //White background
  stroke(255);
  // draw lines
  for(int i = 0; i<Nlines; i++){
      line(lines[i].p0.x,lines[i].p0.y,lines[i].p1.x, lines[i].p1.y);
  }
  
  fill(255, 0, 0);
  //draw circles
  for(int i = 0; i<Nobstacles; i++){
      circle(obstacles[i].center.x, obstacles[i].center.y, obstacles[i].radius*2);
  }
}


void drawBalls(){
  fill(255, 255, 0);

  for(int i = 0; i < curN; i++){
    circle(balls[i].center.x, balls[i].center.y, balls[i].radius*2);
  }

}

// updates for balls
void update(float dt){
    for(int i = 0; i < curN; i++){
      Vec2 downVel = gravity.times(dt);
      vel[i].add(downVel);

      // update position
      balls[i].center.add(vel[i].times(dt));

      float r = balls[i].radius;
      Vec2 pos = balls[i].center;
      // ********************* test collision ****************
      //     -------------------- with boundary---------------------
      if (balls[i].center.y > height - r){
        balls[i].center.y = height - r;
        vel[i].y *= -COR;

      }
      if (balls[i].center.y < r){
        balls[i].center.y = r;
        vel[i].y *= -COR;

      }
      if (balls[i].center.x > width - r){
        balls[i].center.x = width - r;
        vel[i].x *= -COR;

      }
      if (balls[i].center.x < r){
        balls[i].center.x = r;
        vel[i].x *= -COR;
      }
    //    --------------------- with boundary ends ------------------
    //    --------------------- with obstacles ----------------------
    // with lines
    for(int j = 0; j < Nlines; j++){
      if(CircleInterLine(balls[i], lines[j], 0)){
        Intersection inter = getCircleInterLine(balls[i], lines[j], 0);
        if(inter.hit){
          // calculate the reflection direction
          Vec2 normal = inter.normal;
          // for unknown reason, disable the position correction
          // makes the movement more correct???
          balls[i].center = inter.pos.plus(normal.times(balls[i].radius).times(1.01));
          Vec2 velNormal = normal.times(dot(vel[i],normal));
          vel[i].subtract(velNormal.times(1+COR)); 

          // hit purple quad, activate sound and particle effect
          if(j > 7){
              
              
              file.play();
              displayParticle = true;
          }
        }
      }
    }
    // with sphere
    for(int j = 0; j < Nobstacles; j++){
      if(circleInterCircle(balls[i], obstacles[j])){
        Vec2 normal = (balls[i].center.minus(obstacles[j].center)).normalized();
        balls[i].center = 
          obstacles[j].center.plus(normal.times(balls[i].radius + obstacles[j].radius).times(1.01));
        Vec2 velNormal = normal.times(dot(vel[i],normal));
        vel[i].subtract(velNormal.times(1+COR)); 
      }
    }
    //    --------------------- with obstacles ends ----------------------
    // with other balls
    for(int j = i + 1; j < curN; j++){
      if(curN == 1) break;
      if(circleInterCircle(balls[i], balls[j])){
        // position correction
        Vec2 delta = balls[i].center.minus(balls[j].center);
        float dist = delta.length();
        Vec2 dir = delta.normalized();
        float overlap = 0.5 * (dist - balls[i].radius - balls[j].radius);
        balls[i].center.subtract(dir.times(overlap));
        balls[j].center.add(dir.times(overlap));
        
        // collision update
        float v1 = dot(vel[i], dir);
        float v2 = dot(vel[j], dir);
        float m1 = mass[i];
        float m2 = mass[j];
        float new_v1 = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * COR) / (m1 + m2);
        float new_v2 = (m1 * v1 + m2 * v2 - m1 * (v2 - v1) * COR) / (m1 + m2);
        vel[i] = vel[i].plus(dir.times(new_v1 - v1));
        vel[j] = vel[j].plus(dir.times(new_v2 - v2));
      }
    }
  }    

  // draw particle
  float toGen_float = genRate * dt;
  int toGen = int(toGen_float);
  float fractPart = toGen_float - toGen;
  if (random(1) < fractPart) toGen += 1;


   if((t2 - t1) > 1000000l * 1000l * 10l){  // 10 s
      t1 = 0;
      t2 = 0;
      displayParticle = false;

      // particle initial position sr
      NParti = 0;
  }

   if(displayParticle){
      if(t1 == 0) t1 = System.nanoTime();
      else{
        t2 =  System.nanoTime();
      }

      for (int i = 0; i < toGen; i++){
        if (NParti >= maxParticles) break;
        posPat[NParti] = new Vec2(255,585);
        velPat[NParti] = new Vec2(30 + random(60), -190 - random(10)); 
        NParti += 1;
      }

      Vec2 downVel = gravity.times(dt);
      for(int i = 0; i < NParti; i ++){
        circle(posPat[i].x, posPat[i].y, 2*2);
        posPat[i].add(velPat[i].times(dt));
        velPat[i].add(downVel);
      }
   } 
    
}

void keyPressed(){
  if(key == 's'){
    if(curN < Nballs)
      curN++;
  }
  if(key == 'r'){
    println("Resetting the simulation");
    curN = 0;
    NParti = 0;
    displayParticle = false;

    for(int i = 0; i < Nballs; i++){
      balls[i] = new Circle(450, 680, 15);
      vel[i] = new Vec2(0,-800 - random(800));    // 800 to 1200
      mass[i] = balls[i].radius * balls[i].radius;
    }

    return;
  }
}
