.data
levels:

.string "000000000000000wp00000wwmww00000wmwm00000ww00000000wbwwbw0000wbwbwwg00"
.string "000000000000wwww000000m0ssww000ws00zzb000ww00wsw000pw00wmw0000000gwm00"
.string "0000gggw000000000t00000wsswwp0000s0s0ww0000wwmss000k0s0s0w000wwwwwmw00"
.string "00000000000p0kwb00000wbszwtw000bwbwbbwg00wbwbwbbw000wbwbw0000000000000"
.string "0000000wg0000000wtbw0000p0awbw0000w0wawa0000m0bbbb0000wwawwa000000000k"

# moves
movesLabel:
.byte 23, 24, 32, 23, 27

.include "resources/mainMenuImage.data"
.include "resources/chapterSelectImage.data"

imagesLabel:
.include "resources/pandemonicaImage.s"
.include "resources/modeusImage.s"
.include "resources/cerberusImage.s"
.include "resources/malinaImage.s"
.include "resources/zdradaImage.s"

correctKeys:
.byte '2', '2', '1', '1', '1'

successImages:
.include "resources/pandemonicaD2.data"
.include "resources/modeusD2.data"
.include "resources/cerberusD2.data"
.include "resources/malinaD2.data"

dialogueImages:
.include "resources/pandemonicaD1.s"
.include "resources/modeusD1.data"
.include "resources/cerberusD1.data"
.include "resources/malinaD1.data"
.include "resources/zdradaD1.data"

.include "resources/victoryScreen.data"
.include "resources/badEndImage.s"
