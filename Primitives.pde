// primitive library 
// include collision detection algorithm
import java.util.*;

float clamp(float v, float min, float max){
  if(v <= min) return min;
  if(v >= max) return max;

  return v;
}

int circ = 0;


class Intersection{
  public Vec2 pos;
  public Vec2 normal;
  public boolean hit = false;
}

class Circle{
  public Vec2 center;
  public float radius;
  public int ID;
  
  public Circle(float x, float y, float r){
    center = new Vec2(x,y);
    radius = r;
  }
}


class Line{
  public Vec2 p0;
  public Vec2 p1;
  public int ID;
  
  public Line(float x0, float y0, float x1, float y1){
    p0 = new Vec2(x0, y0);
    p1 = new Vec2(x1, y1);
  }

  public Line(Vec2 p00, Vec2 p11){
    p0 = new Vec2(p00.x, p00.y);
    p1 = new Vec2(p11.x, p11.y);
  }
  
}

// center_x center_y width height
class Box{
  public Vec2 center;
  public float width;
  public float height;
  public int ID;

  public Box(float x, float y, float wid, float h){
    center = new Vec2(x,y);
    width = wid;
    height = h;
  }
}

// test if two points are on the same side of a line
boolean sameSide (Line l, Vec2 p1, Vec2 p2){
  Vec2 line = l.p1.minus(l.p0);
  float cp1 = cross(line, p1.minus(l.p1) );
  float cp2 = cross(line, p2.minus(l.p1) );
  return cp1*cp2 >=0;
}


boolean lineInterLine(Line l1, Line l2){
  if (sameSide(l1, l2.p0, l2.p1)) return false;
  if (sameSide(l2, l1.p0, l1.p1)) return false;
  return true;
}

boolean circleInterCircle(Circle c1, Circle c2){
  return c1.center.minus(c2.center).lengthSqr() <= (c1.radius+c2.radius) * (c1.radius+c2.radius);
}

boolean BoxInterBox(Box b1, Box b2){
  Vec2 cb1 = b1.center;
  Vec2 cb2 = b2.center;

  float xdiff = abs(cb1.x - cb2.x);
  float ydiff = abs(cb1.y - cb2.y);

  float widthhalf1 = b1.width*0.5;
  float heighthalf1 = b1.height*0.5;

  float widthhalf2 = b2.width*0.5;
  float heighthalf2 = b2.height*0.5;

  return ((xdiff <= widthhalf1 + widthhalf2) && (ydiff <= heighthalf1 + heighthalf2));
}

// for numerical simulation only: set strokeWidth to 0
boolean CircleInterLine(Circle cir, Line l, int strokeWidth){

  Vec2 l_dir = l.p1.minus(l.p0);
  float l_len =  l_dir.length();
  l_dir.normalize();

  Vec2 CircleTo = l.p0.minus(cir.center);

  float a = 1;
  float b = 2 * dot(l_dir, CircleTo);
  float c = CircleTo.lengthSqr() - (cir.radius+strokeWidth) * (cir.radius+strokeWidth);
  
  float d = b*b - 4*a*c;

  if(d>=0){
    float t1 = (-b - sqrt(d))/(2*a);
    float t2 = (-b + sqrt(d))/(2*a);
    if(t1 < 0) t1 = t2;

    if(t1 >= 0 && t1 < l_len) return true;
  }
  
  // for HW you should count any overlap as collision
  Vec2 c2p0 = l.p0.minus(cir.center);
  Vec2 c2p1 = l.p1.minus(cir.center);
  if(c2p1.lengthSqr() <= cir.radius * cir.radius && c2p0.lengthSqr() <= cir.radius * cir.radius)
    return true;
  
  return false;
}

Intersection getCircleInterLine(Circle cir, Line l, int strokeWidth){
  Intersection res = new Intersection();

   Vec2 l_dir = l.p1.minus(l.p0);
  float l_len =  l_dir.length();
  l_dir.normalize();

  Vec2 CircleTo = l.p0.minus(cir.center);

  float a = 1;
  float b = 2 * dot(l_dir, CircleTo);
  float c = CircleTo.lengthSqr() - (cir.radius+strokeWidth) * (cir.radius+strokeWidth);
  
  float d = b*b - 4*a*c;

  if(d>=0){
    float t1 = (-b - sqrt(d))/(2*a);
    float t2 = (-b + sqrt(d))/(2*a);
    if(t1 < 0) t1 = t2;

    if(t1 >= 0 && t1 < l_len){
      // here 
      res.pos = l.p0.plus(l_dir.times(t1));
      res.hit = true;
      
      // calc the normal
      // closest point on the line
      float proj = dot(cir.center.minus(l.p0), l_dir);
      Vec2 closest = new Vec2(0,0);
      if(proj <= 0) closest = l.p0;
      else if(proj >= l_len) closest = l.p1;
      else{
        closest = l.p0.plus(l_dir.times(proj));
      }
      
      Vec2 n = cir.center.minus(closest);
      // ignore if n.norm > radius, return
      n.normalize();
      res.normal = n;
      
    }
  }
  return res;
}



// box circle 
boolean boxInterCircle(Box b, Circle c){
  Vec2 closest = 
    new Vec2(clamp(c.center.x, b.center.x - b.width*0.5, b.center.x + b.width*0.5),
      clamp(c.center.y, b.center.y - b.height*0.5, b.center.y + b.height*0.5));

  return closest.minus(c.center).lengthSqr() <= (c.radius * c.radius);
}


// line box
boolean lineInterBox(Line l, Box b){
  // build 4 lines from the box
  Vec2 ul = new Vec2(b.center.x - b.width*0.5, b.center.y - b.height*0.5);
  Vec2 ur = new Vec2(b.center.x + b.width*0.5, b.center.y - b.height*0.5);
  Vec2 ll = new Vec2(b.center.x - b.width*0.5, b.center.y + b.height*0.5);
  Vec2 lr = new Vec2(b.center.x + b.width*0.5, b.center.y + b.height*0.5);


  Line up = new Line(ul, ur);
  Line left = new Line(ul, ll); 
  Line right = new Line(ur, lr);
  Line down = new Line(ll, lr);

  if (lineInterLine(l,up)) return true;
  if (lineInterLine(l,left)) return true;
  if (lineInterLine(l,right)) return true;
  if (lineInterLine(l,down)) return true;

  // or two points of the line are inside the box
  Vec2 p0 = l.p0;
  Vec2 p1 = l.p1;
  if(abs(p0.x - b.center.x) <= b.width*0.5 && abs(p0.y - b.center.y) <= b.height*0.5){
    if(abs(p1.x - b.center.x) <= b.width*0.5 && abs(p1.y - b.center.y) <= b.height*0.5)
      return true;
  }

  return false;
}



Set<Integer> getCollisionIDs(ArrayList<Circle> circles, ArrayList<Line> lines, ArrayList<Box> boxes){
   Set<Integer> collision = new HashSet<Integer>();
   // change to array first

   // test collision
   // [circle]     [line] [box] 
   for(int i = 0; i < circles.size(); i++){
      Circle cir = circles.get(i);
      // test circleInterCircle First
      for(int j = i + 1; j < circles.size(); j++){
         Circle cir2 = circles.get(j);
         if(circleInterCircle(cir, cir2)){
            collision.add(cir.ID);
            collision.add(cir2.ID);

         }
      }
      
      // circle test line
      for( int j = 0; j < lines.size(); j++){
         Line l = lines.get(j);
         if(CircleInterLine(cir, l, 0)){
            collision.add(cir.ID);
            collision.add(l.ID);

         }
      }

      // circle test box
      for(int j = 0; j < boxes.size(); j++){
         Box b = boxes.get(j);
         if(boxInterCircle(b, cir)){
            collision.add(cir.ID);
            collision.add(b.ID);

         }
      }
   }


   // [line]   [box]
   for(int i = 0; i < lines.size(); i++){
      Line l = lines.get(i);
      // line test line
      for(int j = i + 1; j < lines.size(); j++){
         Line l2 = lines.get(j);
         if(lineInterLine(l, l2)){
            collision.add(l.ID);
            collision.add(l2.ID);
         }
      }

      // line with box
      for(int j = 0; j < boxes.size(); j++){
         Box b = boxes.get(j);
         if(lineInterBox(l, b)){
            collision.add(l.ID);
            collision.add(b.ID);
         }
      }
   }

   // [box]
   for(int i = 0; i < boxes.size(); i++){
      Box b = boxes.get(i);
      for(int j = i+1; j < boxes.size(); j++){
         Box b2 = boxes.get(j);
         if(BoxInterBox(b,b2)){
            collision.add(b.ID);
            collision.add(b2.ID);
         }
      }
   }

   return collision;
}
