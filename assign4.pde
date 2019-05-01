/*
    Assign 4 : Explore the Geocenter
    Update : 5.1.2019
*/

PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, stone1, stone2, soilEmpty;
PImage soldier;
PImage soil0, soil1, soil2, soil3, soil4, soil5;
PImage[][] soils, stones;

final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

int[][] soilHealth;

final int START_BUTTON_WIDTH = 144;
final int START_BUTTON_HEIGHT = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

float[] cabbageX, cabbageY, soldierX, soldierY;
float soldierSpeed = 2f;

float playerX, playerY;
int playerCol, playerRow;
final float PLAYER_INIT_X = 4 * SOIL_SIZE;
final float PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false;
boolean rightState = false;
boolean downState = false;
int playerHealth = 2;
final int PLAYER_MAX_HEALTH = 5;
int playerMoveDirection = 0;
int playerMoveTimer = 0;
int playerMoveDuration = 15;
float frameError = 0;
final float ONE_STEP = (float)SOIL_SIZE/playerMoveDuration;

boolean demoMode = false;

void setup() {
  size(640, 480, P2D);
  bg = loadImage("img/bg.jpg");
  title = loadImage("img/title.jpg");
  gameover = loadImage("img/gameover.jpg");
  startNormal = loadImage("img/startNormal.png");
  startHovered = loadImage("img/startHovered.png");
  restartNormal = loadImage("img/restartNormal.png");
  restartHovered = loadImage("img/restartHovered.png");
  groundhogIdle = loadImage("img/groundhogIdle.png");
  groundhogLeft = loadImage("img/groundhogLeft.png");
  groundhogRight = loadImage("img/groundhogRight.png");
  groundhogDown = loadImage("img/groundhogDown.png");
  life = loadImage("img/life.png");
  soldier = loadImage("img/soldier.png");
  cabbage = loadImage("img/cabbage.png");

  soilEmpty = loadImage("img/soils/soilEmpty.png");

  // Load PImage[][] soils
  soils = new PImage[6][5];
  for(int i = 0; i < soils.length; i++){
    for(int j = 0; j < soils[i].length; j++){
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
  } }

  // Load PImage[][] stones
  stones = new PImage[2][5];
  for(int i = 0; i < stones.length; i++){
    for(int j = 0; j < stones[i].length; j++){
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
  } }

  // Initialize player
  playerX = PLAYER_INIT_X;
  playerY = PLAYER_INIT_Y;
  playerCol = (int) (playerX / SOIL_SIZE);
  playerRow = (int) (playerY / SOIL_SIZE);

  // Initialize soilHealth
  soilHealth = new int[SOIL_ROW_COUNT][SOIL_COL_COUNT];
  for(int i = 0; i < soilHealth.length; i++){
    for (int j = 0; j < soilHealth[i].length; j++) { 
    // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
      soilHealth[i][j] = 15;
      int areaIndex = floor(i / 4);

      switch(areaIndex){
        case 0:
        case 1:
          if(i == j) soilHealth[i][j] = 30;
        break;
        case 2:
        case 3:
          if((i - j) % 4 == 2 || (i + j) % 4 == 1) soilHealth[i][j] = 30;
        break;
        default:
          if((i + j) % 3 == 0) soilHealth[i][j] = 45;
          else if((i + j) % 3 != 1) soilHealth[i][j] = 30;
        break;
    } }
    
    if(i != 0){     
      int empty = floor(random(2)+1);
      int last = -1;     
      for(int k = 0; k < empty; k++){
        
        int j = floor(random(8)); 
        if(j == last) k--;
        else{
          soilHealth[i][j] = 0;
          last = j;         
  } } } }


  // Initialize soldiers and their position
  soldierX = new float[6];
  soldierY = new float[6];
  
  for(int s = 0; s < soldierX.length; s++){
    soldierX[s] = random(width);
  }
    
  for(int s = 0; s < soldierY.length; s++){
    soldierY[s] = (floor(random(4)) + s * 4) * SOIL_SIZE;
  }


  // Initialize cabbages and their position  
  cabbageX = new float[6];
  cabbageY = new float[6];
  
  for(int c = 0; c < cabbageX.length; c++){
    cabbageX[c] = floor(random(8)) * SOIL_SIZE;
  }
    
  for(int c = 0; c < cabbageY.length; c++){
    cabbageY[c] = (floor(random(4)) + c * 4) * SOIL_SIZE;
} } 

void draw() {

  switch (gameState) {

  case GAME_START: // Start Screen
    image(title, 0, 0);
    if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
    && START_BUTTON_X < mouseX
    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
    && START_BUTTON_Y < mouseY) {
  
      image(startHovered, START_BUTTON_X, START_BUTTON_Y);
  
      if(mousePressed){
  	gameState = GAME_RUN;
  	mousePressed = false;
      }
  
    }else image(startNormal, START_BUTTON_X, START_BUTTON_Y);

  break;


  case GAME_RUN: // In-Game
    // Background
    image(bg, 0, 0);
  
    // Sun
    stroke(255,255,0);
    strokeWeight(5);
    fill(253,184,19);
    ellipse(590,50,120,120);
  
    // Coordinate System {
    pushMatrix();
    translate(0, max(SOIL_SIZE * -18, 80 - playerY - frameError));
    /*max(maximum of the translation, difference between two coordinate system & frameError)*/
  
    // Ground  
    fill(124, 204, 25);
    noStroke();
    rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);
  
    // Soil 
    for(int i = 0; i < soilHealth.length; i++){
      for (int j = 0; j < soilHealth[i].length; j++) {
  
  	int areaIndex = floor(i / 4);
        int healthIndex = floor((soilHealth[i][j] - 1) / 3);
          
  	if(soilHealth[i][j] == 0) image(soilEmpty, j * SOIL_SIZE, i * SOIL_SIZE);
        else image(soils[areaIndex][min(4, healthIndex)], j * SOIL_SIZE, i * SOIL_SIZE);          
        if(soilHealth[i][j] > 15) image(stones[0][min(4, healthIndex-5)], j * SOIL_SIZE, i * SOIL_SIZE);
        if(soilHealth[i][j] > 30) image(stones[1][min(4, healthIndex-10)], j * SOIL_SIZE, i * SOIL_SIZE);
          
    } }
  
    // Cabbages     
    for(int c = 0; c < cabbageX.length; c++){
        
      if(cabbageX[c] < playerX+80 && cabbageX[c]+80 > playerX
      && cabbageY[c] < playerY+80 && cabbageY[c]+80 > playerY){
          
        if(playerHealth < PLAYER_MAX_HEALTH) playerHealth += 1;
        cabbageX[c] = 640;
        
      }else image(cabbage, cabbageX[c], cabbageY[c]);
    }      
  
    // Groundhog 
    PImage groundhogDisplay = groundhogIdle;
  
    if(playerMoveTimer == 0){
      if(playerRow < SOIL_ROW_COUNT-1 && soilHealth[playerRow+1][playerCol] == 0){
          
        groundhogDisplay = groundhogDown;
        playerMoveDirection = DOWN;
        playerMoveTimer = playerMoveDuration;
          
      }else if(downState){
  
        groundhogDisplay = groundhogDown;
        if(playerRow < SOIL_ROW_COUNT-1){
            
          max(0, -- soilHealth[playerRow+1][playerCol]);
          if(soilHealth[playerRow+1][playerCol] == 0) frameError = ONE_STEP; 
        }
         
      }else if(leftState){
  
  	groundhogDisplay = groundhogLeft;
  
  	if(playerCol > 0){
          if(playerRow >= 0 && soilHealth[playerRow][playerCol-1] > 0){
              
            max(0, -- soilHealth[playerRow][playerCol-1]);
              
          }else{
  
            playerMoveDirection = LEFT;
            playerMoveTimer = playerMoveDuration;  
  	} }
  
      }else if(rightState){
  
  	groundhogDisplay = groundhogRight;
  
  	if(playerCol < SOIL_COL_COUNT - 1){
          if(playerRow >= 0 && soilHealth[playerRow][playerCol+1] > 0){
              
            max(0, --soilHealth[playerRow][playerCol+1]);
              
          }else{
  
            playerMoveDirection = RIGHT;
            playerMoveTimer = playerMoveDuration;  
    } } } }
  
  
    if(playerMoveTimer > 0){
  
      playerMoveTimer --;
      switch(playerMoveDirection){
  
  	case LEFT:
          groundhogDisplay = groundhogLeft;
          if(playerMoveTimer == 0){
            playerCol--;
            playerX = SOIL_SIZE * playerCol;
          }else{
            playerX = (float(playerMoveTimer) / playerMoveDuration + playerCol - 1) * SOIL_SIZE;
          }
  	break;
  
  	case RIGHT:
          groundhogDisplay = groundhogRight;
          if(playerMoveTimer == 0){
            playerCol++;
            playerX = SOIL_SIZE * playerCol;
          }else{
            playerX = (1f - float(playerMoveTimer) / playerMoveDuration + playerCol) * SOIL_SIZE;
          }
  	break;
  
  	case DOWN:
          groundhogDisplay = groundhogDown;
          if(playerMoveTimer == 0){
            playerRow++;
            playerY = SOIL_SIZE * playerRow;
            if(playerRow < SOIL_ROW_COUNT-1){
              frameError = (soilHealth[playerRow+1][playerCol] == 0) ? ONE_STEP : 0;
            }
          }else{
            playerY = (1f - float(playerMoveTimer) / playerMoveDuration + playerRow) * SOIL_SIZE;
          }
  	break;
    } }
  
    image(groundhogDisplay, playerX, playerY);
    
    // Soldiers 
    for(int s = 0; s < soldierX.length; s++){
        
      image(soldier, soldierX[s] += 5, soldierY[s]);
      if(soldierX[s] > width) soldierX[s] = -SOIL_SIZE;
        
      if(soldierX[s] < playerX+80 && soldierX[s]+80 > playerX
      && soldierY[s] < playerY+80 && soldierY[s]+80 > playerY ){
          
        playerHealth -= 1;
        playerMoveTimer = playerMoveDuration;
        playerMoveDirection = 0;

        playerX = PLAYER_INIT_X;
        playerY = PLAYER_INIT_Y;
        playerCol = (int) (playerX / SOIL_SIZE);
        playerRow = (int) (playerY / SOIL_SIZE);
          
        if(soilHealth[playerRow+1][playerCol] < 15) soilHealth[playerRow+1][playerCol] = 15;         
    } }
  
    // Demo mode: Show the value of soilHealth on each soil
    // (DO NOT CHANGE THE CODE HERE!)  
    if(demoMode){	
  
      fill(255);
      textSize(26);
      textAlign(LEFT, TOP);
  
      for(int i = 0; i < soilHealth.length; i++){
        for(int j = 0; j < soilHealth[i].length; j++){
          text(soilHealth[i][j], j * SOIL_SIZE, i * SOIL_SIZE);
    } } }
  
    //Coordinate System }
    popMatrix();
  
    // Health UI  
    for(int h = 0; h < playerHealth; h++){
      image(life, 10 + (50 + 20) * h, 10);
    }
    if(playerHealth == 0) gameState = GAME_OVER;

  break;


  case GAME_OVER: // Gameover Screen
    image(gameover, 0, 0);
  		
    if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
    && START_BUTTON_X < mouseX
    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
    && START_BUTTON_Y < mouseY) {
  
      image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
      if(mousePressed){
        gameState = GAME_RUN;
        mousePressed = false;

        // Initialize player
        playerX = PLAYER_INIT_X;
        playerY = PLAYER_INIT_Y;
        playerCol = (int) (playerX / SOIL_SIZE);
        playerRow = (int) (playerY / SOIL_SIZE);
        playerMoveTimer = 0;
        playerHealth = 2;

        // Initialize soilHealth
        for(int i = 0; i < soilHealth.length; i++){
          for (int j = 0; j < soilHealth[i].length; j++) { 
            // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
            soilHealth[i][j] = 15;
            int areaIndex = floor(i / 4);

            switch(areaIndex){
              case 0:
              case 1:
                if(i == j) soilHealth[i][j] = 30;
              break;
              case 2:
              case 3:
                if((i - j) % 4 == 2 || (i + j) % 4 == 1) soilHealth[i][j] = 30;
              break;
              default:
                if((i + j) % 3 == 0) soilHealth[i][j] = 45;
                else if((i + j) % 3 != 1) soilHealth[i][j] = 30;
              break;
          } }
 
          if(i != 0){     
            int empty = floor(random(2)+1);
            int last = -1;     
            for(int k = 0; k < empty; k++){
                
              int j = floor(random(8)); 
              if(j == last) k--;
              else{
                soilHealth[i][j] = 0;
                last = j;         
        } } } }
        
        // Initialize soldiers and their position          
        for(int s = 0; s < soldierX.length; s++){
          soldierX[s] = random(width);
        }
            
        for(int s = 0; s < soldierY.length; s++){
          soldierY[s] = (floor(random(4)) + s * 4) * SOIL_SIZE;
        }
        
        
        // Initialize cabbages and their position           
        for(int c = 0; c < cabbageX.length; c++){
          cabbageX[c] = floor(random(8)) * SOIL_SIZE;
        }
            
        for(int c = 0; c < cabbageY.length; c++){
          cabbageY[c] = (floor(random(4)) + c * 4) * SOIL_SIZE;
      } }
  
    }else image(restartNormal, START_BUTTON_X, START_BUTTON_Y);

  break;
		
} }


void keyPressed(){
  if(key==CODED){
    switch(keyCode){
      case LEFT:
	leftState = true;
      break;
      case RIGHT:
        rightState = true;
      break;
      case DOWN:
	downState = true;
      break;
    }
  }else{
    if(key=='b'){
      // Press B to toggle demo mode
      demoMode = !demoMode;
} } }


void keyReleased(){
  if(key==CODED){
    switch(keyCode){
      case LEFT:
	leftState = false;
      break;
      case RIGHT:
	 rightState = false;
      break;
      case DOWN:
	downState = false;
      break;
} } }
