import processing.serial.*;

Serial myPort;

int iAngle = 0;
int iDistance = 0;
float displayedAngle = 0;
int lastTargetTime = 0;
int targetInterval = 300; // ms between allowed detections

int maxDistance = 20;  // Reduced from 40 to 20
float radarRangePx = 400; // Radar visual radius in pixels

class Target {
  PVector pos;
  float angle;
  int time;
  int distance;

  Target(float x, float y, float angle, int distance) {
    pos = new PVector(x, y);
    this.angle = angle;
    this.time = millis();
    this.distance = distance;
  }
}

ArrayList<Target> targets = new ArrayList<Target>();

void setup() {
  size(1400, 800);  // Bigger canvas
  myPort = new Serial(this, "COM7", 9600); // Change COM port as needed
  myPort.clear();
  myPort.bufferUntil('\n');
  smooth();
  frameRate(60);
}

void draw() {
  drawBackground();
  readSerialData();
  displayedAngle = lerp(displayedAngle, iAngle, 0.05);
  drawRadar();
  drawSweep();
  drawTargets();
  drawHUD();
  drawOverlay(); // Text overlay
}

void drawBackground() {
  noStroke();
  fill(0, 50);  // Fade effect
  rect(0, 0, width, height);
}

void readSerialData() {
  while (myPort.available() > 0) {
    String inData = myPort.readStringUntil('\n');
    if (inData != null) {
      inData = trim(inData);
      String[] parts = split(inData, ',');
      if (parts.length == 2) {
        try {
          iAngle = int(parts[0]);
          iDistance = int(parts[1]);

          if (iDistance <= maxDistance && millis() - lastTargetTime > targetInterval) {
            float r = map(iDistance, 0, maxDistance, 0, radarRangePx);
            float x = cos(radians(iAngle)) * r;
            float y = -sin(radians(iAngle)) * r;
            targets.add(new Target(x, y, radians(iAngle), iDistance));
            lastTargetTime = millis();

            if (targets.size() > 5) {
              targets.remove(0);
            }
          }
        } catch (Exception e) {
          println("Parse error: " + inData);
        }
      }
    }
  }
}

void drawRadar() {
  pushMatrix();
  translate(width / 2, height - 100);
  strokeWeight(2);
  noFill();

  for (int r = 1; r <= 4; r++) {
    stroke(0, 255, 100, 80);
    arc(0, 0, r * radarRangePx / 2, r * radarRangePx / 2, PI, TWO_PI);
  }

  for (int a = 0; a <= 180; a += 15) {
    float x = cos(radians(a)) * radarRangePx;
    float y = -sin(radians(a)) * radarRangePx;
    stroke(0, 255, 100, 40);
    line(0, 0, x, y);
  }

  popMatrix();
}

void drawSweep() {
  pushMatrix();
  translate(width / 2, height - 100);
  float x = cos(radians(displayedAngle)) * radarRangePx;
  float y = -sin(radians(displayedAngle)) * radarRangePx;

  for (int i = 0; i < 12; i++) {
    stroke(0, 255, 0, 60 - i * 5);
    line(0, 0, x * (1 - i * 0.03), y * (1 - i * 0.03));
  }

  stroke(0, 255, 0);
  strokeWeight(2.5);
  line(0, 0, x, y);
  popMatrix();
}

void drawTargets() {
  pushMatrix();
  translate(width / 2, height - 100);

  for (Target t : targets) {
    float age = (millis() - t.time) / 1000.0;
    float alpha = map(2.0 - age, 0, 2.0, 0, 255);
    float size = map(2.0 - age, 0, 2.0, 4, 8);
    if (alpha < 0) alpha = 0;
    if (size < 3) size = 3;

    fill(255, 60, 60, alpha);
    noStroke();
    ellipse(t.pos.x, t.pos.y, size, size);

    // Glow
    stroke(255, 0, 0, alpha / 4);
    strokeWeight(1);
    noFill();
    ellipse(t.pos.x, t.pos.y, size + 4, size + 4);

    // Distance label
    fill(255, alpha);
    textSize(12);
    textAlign(CENTER);
    text(t.distance + "cm", t.pos.x, t.pos.y - 10);
  }

  popMatrix();
}

void drawHUD() {
  fill(0);
  noStroke();
  rect(0, height - 60, width, 60);

  textSize(22);
  fill(0, 255, 100);
  text("Angle: " + int(displayedAngle) + "°", 30, height - 20);
  text("Distance: " + iDistance + " cm", 250, height - 20);

  if (iDistance <= maxDistance) {
    fill(255, 80, 80);
    text("Target Detected", 500, height - 20);
  }
}

void drawOverlay() {
  fill(0, 255, 0);  // Green neon text
  textAlign(LEFT);
  textSize(18);
  text("INSTITUTE OF SCIENCE & TECHNOLOGY", 30, 30);  

  textAlign(RIGHT);
  textSize(18);
  text("Project: Smart Sonar Scanner", 250, 50);  

  textAlign(CENTER);
  textSize(22);
  text("Team PIXEL &PULSE", width / 2, 30);  
}
