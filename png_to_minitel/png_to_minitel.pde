/*
  Transformer une image PNG 1bit 80x72
  en octet pour affichage sur un minitel
  Quimper, 27 juin 2017 / pierre@lesporteslogiques.net
  
  Révisé pour processing 4.0b2, le 15 février 2022
  processing 3.2.1 @ urzhiata
 
*/
 
 
int pix[][] = new int[80][72]; 
color fg;
int x_offset = 12, y_offset = 12;
PImage template;
 
void setup() {
  size(824, 600);
  template = loadImage("test.png");
  for (int i = 0; i < 80; i++) {
    for (int j = 0; j < 72; j++) {   
      if (brightness(template.get(i,j)) < 10) pix[i][j] = 0;
      else pix[i][j] = 1;
    }
  }
}
 
void draw() {
  background(100);
  for (int i = 0; i < 80; i++) {
    for (int j = 0; j < 72; j++) {
      if (pix[i][j] == 0) fg = color(0);
      else fg = color(255);
      fill(fg);
      stroke(fg);
      rect(x_offset + (i * 10), y_offset + (j * 8), 10, 8);
    }
  }
}
 
void keyPressed() {
  if (key == 'e') exportData();
}
 
/*
|---------|
|2^0 | 2^1|
|---------|
|2^2 | 2^3|
|---------|
|2^4 | 2^6|
|---------|
 
Attention, c'est subtil !
 
Le codage de ces caractères est réalisé suivant un repérage par puissances de 2 : 
le premier point de la matrice d’un caractère graphique représente 2^0=1 ; 
le second 2^1=2 etc.. jusqu’à l’avant dernier, 2^4=16, et le dernier, 
le 6è point, qui représente 2^6=64. 
Pour chaque point activé, on additionne sa valeur, 
puis on ajoute finalement 32 au nombre obtenu pour obtenir un caractère 
de code supérieur à 32. Ainsi les caractères graphiques vont de l’ascii 32 
(qui représente une matrice vide de points, et qui donc est identique 
visuellement à un caractère de texte espace) 
à l’ascii 2^0+2^1+..2^4+2^6+32=127 (qui représente une matrice pleine). 
Une fois en mode graphique (attribut mode graphique activé) 
l’envoi de ces codes permettra d’afficher les mosaïques correspondantes. 
*/
 
void exportData() {
  //int b1, b2, b3, b4, b5, b6;
  int octet;
  int compteur = 0;
  print("FLASH_ARRAY(byte, c, ");
  for (int j = 0; j < 24; j++) {
    for (int i = 0; i < 40; i++) {
      octet  = 0;
      octet += pix[i*2][j*3]       * 1;
      octet += pix[i*2+1][j*3]     * 2;
      octet += pix[i*2][j*3 + 1]   * 4;
      octet += pix[i*2+1][j*3 + 1] * 8;
      octet += pix[i*2][j*3 + 2]   * 16;
      octet += pix[i*2+1][j*3 + 2] * 64;
      octet += 32;
      print(octet);
 
      if (i*j < 23 * 39) {
        print(",");
      }
      if (compteur % 100 == 0) println();
      compteur ++;
    }
  }
  print(");");
}
