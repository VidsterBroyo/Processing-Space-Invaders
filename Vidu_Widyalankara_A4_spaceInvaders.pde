



/******************************************************************************
 * Vidu Widyalankara                            Vidu_Widyalankara_A4_spaceInvaders.pde
 *
 * COURSE: ICS3U1
 * ASSIGNMENT: A4, Space Invaders
 *
 * DESCRIPTION :
 *       A recreation of the classic game Space Invaders.
 *
 * VERSION DATE: 12/20/2022
 ******************************************************************************/
import processing.sound.*;

// cannon variables
PImage Cannon;
int cannonX = 468;
int cannonV = 0;
boolean moveLeft = false;
boolean moveRight = false;

// laser variables
boolean laserExisting = false;
int laserX = 0;
int laserY = 0;

// alien variables
ArrayList<int[]> aliens = new ArrayList<int[]>();
PImage alienImgs[][] = new PImage[3][2];
int alienVelocity = 16;
int moveDown = 0;
ArrayList<int[]> alienLasers = new ArrayList<int[]>();

// sound & font objects
SoundFile laserSound;
SoundFile hitSound;
SoundFile music;
PFont font;

// general game/control variables
int score = 0;
int lives = 3;
int gameState = 0;
int costumeCounter = 0;
int startTime = 0;
int lastMove = 0;


void setup() {
  // setup screen
  size(1000, 800);
  background(#000000);

  // loading assets (images, font, sound)
  Cannon = loadImage("cannon.png");
  alienImgs = new PImage[][] {{loadImage("enemy1.png"), loadImage("enemy12.png")}, {loadImage("enemy2.png"), loadImage("enemy22.png")}, {loadImage("enemy3.png"), loadImage("enemy32.png")}};
  font = createFont("space_invaders.ttf", 64);
  textFont(font);
  laserSound = new SoundFile(this, "laserSound.wav");
  hitSound = new SoundFile(this, "hitSound.wav");
  music = new SoundFile(this, "music.mp3");
  

  // create aliens
  populateArray();
}


void draw() {
  background(#000000);

  // draw and move cannon
  image(Cannon, cannonX, 650);
  moveCannon();

  // draw & move laser
  if (laserExisting) {
    rect(laserX, laserY, 10, 20);
    laserY -= 12;

    // delete laser if it reaches top of screen
    if (laserY < 0) {
      laserExisting = false;
    }
  }

  // home screen
  if (gameState == 0) {
    image(loadImage("title.png"), 135, 50);

    textAlign(CENTER);
    textSize(50);
    text("Press [Enter] to Start", 500, 600);

    // instructions screen
  } else if (gameState == 1) {
    // instructions
    textAlign(CENTER);
    textSize(20);
    text("use < & > to move the cannon\npress space to fire lasers", 500, 550);

    // display for 3 seconds
    if (millis() - startTime > 3000) {
      gameState = 2;
      music.loop();
    }

    // game screen
  } else if (gameState == 2) {
    // score display
    textAlign(LEFT);
    textSize(30);
    fill(#FFFFFF);
    text("Score: "+score, 10, 45);

    // lives display
    textAlign(RIGHT);
    fill(#FFFFFF);
    text("Lives: "+lives, 970, 45);

    // draw aliens, check laser collision
    drawAliensCheckLaserCollision();

    // check if all aliens dissappeared
    if (aliens.size() == 0) {
      gameState = 3;
      music.stop();
    } else {
      // move alien lasers
      drawMoveAlienLasers();

      // move aliens periodically based on how many aliens left
      if (millis() - lastMove > 20*aliens.size() + 100) {
        moveAliens();
      }
    }

    // win screen
  } else if (gameState == 3) {
    // win text
    textAlign(CENTER);
    textSize(50);
    fill(#00FF00);
    text("!!!YOU WIN!!!", 500, 300);
    textSize(30);
    fill(#FFFFFF);
    text("PRESS <R> TO RESTART", 500, 400);

    // lose screen
  } else if (gameState == 4) {
    // lose text
    textAlign(CENTER);
    textSize(50);
    fill(#FF0000);
    text(".YOU LOSE.", 500, 300);
    textSize(30);
    fill(#FFFFFF);
    text("PRESS <R> TO RESTART", 500, 400);
  }
}


// move player's cannon based on key pressed and boundary
void moveCannon() {
  if (moveLeft && cannonX - 8 > 0) {
    cannonX += -8;
  } else if (moveRight && cannonX + 8 < 930) {
    cannonX += 8;
  }
}


// creates laser
void fireLaser() {
  laserY = 625;
  laserX = cannonX+26;
  laserExisting = true;
  laserSound.play();
}


// spawn aliens
void populateArray() {
  aliens.clear();
  for (int j=0; j<5; j++) {
    for (int i=0; i<9; i++) {
      if (j<1) {
        aliens.add(new int[] {i*75+8+50, j*75+53, 2});
      } else if (j<3) {
        aliens.add(new int[] {i*75+50, j*75+53, 1});
      } else {
        aliens.add(new int[] {i*75+50, j*75+53, 3});
      }
    }
  }
}


// note: i put the drawing of aliens with the laser collision detection to lower the amount of for loops run on one draw cycle, therefore improving efficiency
// draw aliens and check laser collision
void drawAliensCheckLaserCollision() {
  for (int i=0; i<aliens.size(); i++) {

    // draw aliens
    image(alienImgs[aliens.get(i)[2]-1][costumeCounter % 2], aliens.get(i)[0], aliens.get(i)[1]);

    // check if aliens should go down
    if (aliens.get(i)[0] > 900 && moveDown == 0 || aliens.get(i)[0] < 20 && moveDown == 0) {
      moveDown = 1;
      alienVelocity = -alienVelocity;
    }

    // check laser collision to alien
    if (laserExisting) {
      if (laserX > aliens.get(i)[0] && laserX < aliens.get(i)[0]+64 && laserY < aliens.get(i)[1] + 47) {
        // calculate score and delete alien
        score += (4-aliens.get(i)[2])*100;
        aliens.remove(i);
        laserExisting = false;
        hitSound.play();
      }
    }
  }
}


// move aliens using for loop
void moveAliens() {
  // loop through all aliens
  fireAlienLaser();
  for (int i=0; i<aliens.size(); i++) {

    // move aliens down, if not, move sideways
    if (moveDown == 1 || moveDown == -1) {
      aliens.get(i)[1] += 45;
      moveDown = -1;

      // check if aliens reach player
      if (aliens.get(i)[1] >= 600) {
        gameState = 4;
        music.stop();
      }

      // move aliens sideways
    } else {
      aliens.get(i)[0] += alienVelocity;
    }
  }

  costumeCounter++;
  lastMove = millis();

  if (moveDown == -1) {
    moveDown = -2;
  } else if (moveDown == -2) {
    moveDown = 0;
  }
}


// create new alien laser
void fireAlienLaser() {
  int alienFiring = int(random(aliens.size()));
  alienLasers.add(new int[] {aliens.get(alienFiring)[0]+20, aliens.get(alienFiring)[1]+30});
}


// draw and move all alien lasers using for loop
void drawMoveAlienLasers() {
  // loop through alien lasers
  for (int i=0; i<alienLasers.size(); i++) {
    // draw laser
    rect(alienLasers.get(i)[0], alienLasers.get(i)[1], 8, 25);

    // move laser
    alienLasers.get(i)[1] += 12;

    // delete laser if it reaches bottom of screen
    if (alienLasers.get(i)[1] >= 775) {
      alienLasers.remove(i);
      continue;
    }

    // detect laser-player collision
    if (alienLasers.get(i)[1] >= 627 && alienLasers.get(i)[0] > cannonX-7 && alienLasers.get(i)[0] < cannonX+64) {
      alienLasers.remove(i);
      lives--;

      // check if player is out of lives
      if (lives <= 0) {
        gameState = 4;
        music.stop();
      }
    }
  }
}


void keyPressed() {
  // listening for enter key press to start game
  if (keyCode == 10 && gameState == 0) {
    gameState = 1;
    startTime = millis();
  }

  // listening for right and left keys for player control
  if (keyCode == 37) {
    moveLeft = true;
  } else if (keyCode == 39) {
    moveRight = true;
  }

  // listening for space bar to fire laser
  if (keyCode == 32 && !laserExisting) {
    fireLaser();
  }

  // listening for r key to restart game
  if (keyCode == 82 && gameState == 4 || keyCode == 82 && gameState == 3) {
    // reset variables & music
    populateArray();
    alienLasers.clear();
    alienVelocity = 10;
    gameState = 2;
    score = 0;
    music.loop();
    lives=3;
  }
}


void keyReleased() {
  // listening for release of cannon controls
  if (keyCode == 37) {
    moveLeft = false;
  }
  if (keyCode == 39) {
    moveRight = false;
  }
}
