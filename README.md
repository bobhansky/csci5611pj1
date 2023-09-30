# csci5611pj1    
# Name: Bob Zhou
## Import processing Sound library for sound effect
 

### control the simulation:

**s** to send ball from plunger (at most 5 balls in each simulation)

**r** to reset

# demo image:
![alt text](https://github.com/bobhansky/csci5611pj1/blob/main/img.png)

### demo video:

https://www.youtube.com/watch?v=kgArrB1H1Wc


# Timestamp
## (also available under the youtube video description )
<pre>

Basic Pinball Dynamics && Circular Obstacles can be seen throghout the video
  
- Textured Background:                0:05
  
- Plunger/Launcher to shoot balls:    0:29
      Each ball (at most 5 balls) is sent by this plunger (just a path seperated by a line) with a 
      random velovity within a specific range
  
- Line-Segment/Polygonal Obstacles:   0:40

- Multiple Balls Interacting          0:42
  
- Particle System Effects:            0:45
      when ball hits purple rectangle, fountain-like particle effects would be triggered.
  
- Sound Effects                       1:12
      firework sound, may not be heard in the video, please try it on local machine and then can hear it.
</pre>



## • List of the tools/library you used && All code for your project with a clear indication of what code you wrote
     Vec2.pde is provided by Dr Stephen J Guy.
     All other files are written by me.
     Using processing. Only use the Sound Library (by Processing) as extra dependency.

## Brief write-up explaining difficulties you encountered
     intersecting with line-segment or polygon can be annoying.
     I need to calculate the normal direction of the intersection point
     to find out the reflection direction. (I use closest point to the line, to calculate N)
     and re-position the intersected ball to the right place.
     
