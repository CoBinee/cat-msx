; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; サウンドを初期化する
;
_SoundInitialize:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmStart0, soundBgmStart1, soundBgmStart2
    .dw     soundBgmIntro0, soundBgmIntro1, soundBgmIntro2
    .dw     soundBgmGame0, soundBgmGame1, soundBgmGame2
    .dw     soundBgmBoss0, soundBgmBoss1, soundBgmBoss2
    .dw     soundBgmOver0, soundBgmOver1, soundBgmOver2
    .dw     soundBgmResult0, soundBgmResult1, soundBgmResult2

; スタート
soundBgmStart0:

    .ascii  "T2@2V15,3"
    .ascii  "L3O6ED+DC+CO5BB-AG+GF+FERRR6R9"
    .db     0x00

soundBgmStart1:

    .ascii  "T2@2V15,3"
    .ascii  "L3O2ABO3CC+DEF+GABO4C+DERRO3A5RA5R7"
    .db     0x00
    
soundBgmStart2:

    .ascii  "T2@2V15,3"
    .ascii  "L3R8R8RRRO2A5RA5R7"
    .db     0x00

; イントロ
soundBgmIntro0:

    .ascii  "T2@5V15,3"
    .ascii  "L3O5CRCO4GGGARABRB"
    .ascii  "L3O5CRCO4GGGARABRB"
    .db     0x00

soundBgmIntro1:

    .ascii  "T2@0V16S1M5N7"
    .ascii  "L3X5XXXXX5XX5X1X1"
    .ascii  "L3X5XXXXX5XX5X1X1"
    .db     0x00
    
soundBgmIntro2:

    .ascii  "T2@14V15,3"
    .ascii  "L3O4EREEEEEREERE"
    .ascii  "L3O4EREEEEEREERE"
    .db     0x00

; ゲーム
soundBgmGame0:

    .ascii  "T2@5V15,3"
    .ascii  "L3O5CRCCREA6GREC6CREG5EF6"
    .ascii  "L3O5DRDDRFB6ARFDRDBRAGRFE6"
    .ascii  "L3O5CRCCREA6GREC6CREG5EF6"
    .ascii  "L3O5DRC+DREDREF+RDGR5AGAGR5@7A6"
    .ascii  "L6O5AB5O6C3DO5BGA5B3O6C8"
    .ascii  "L6O5FG5A3BO6DO5GFE8"
    .ascii  "L6O5DE5F3EDCDE8"
    .ascii  "L3O5A7BO6CD6O5ARB"
    .ascii  "L2O5G6BRABARBRG4R1R3"
    .db     0xff

soundBgmGame1:

    .ascii  "T2@0V16S1M5N7"
    .ascii  "L3X5XX5XX5XX5XX5XX5XX5X1X1XXX"
    .ascii  "L3X5XX5XX5XX5XX5XX5XX5XXXX"
    .ascii  "L3X5XX5XXXXX5XX5XX5XX5XX5X1X1"
    .ascii  "L3X5XX5XXXXXXXX5RXXXX5RX1X1X1X1X1X1"
    .ascii  "L3X5XXXXX5XX5XX5XXXXX5XXXX"
    .ascii  "L3X5XX5XX5X1X1XXXXXXXXXX5X1X1XXX"
    .ascii  "L3X5XX5XX5XX5XXXXX5X1X1XXXX5X"
    .ascii  "L3X5XX5XXXXX5X1X1"
    .ascii  "L2X5X3XRXXXRXRX4R1R3"
    .db     0xff
    
soundBgmGame2:

    .ascii  "T2@12V15,3"
    .ascii  "L3O4EREERO5CF6ERO4GE6ERGO5E5CD6"
    .ascii  "L3O4FRFARO5DF6DRO4AARAO5FRFERDC6"
    .ascii  "L3O4EREERO5CF6ERO4GE6ERGO5E5CD6"
    .ascii  "L3O4ARA+A+RA+A+RA+O5DRO4A+O5DR5FDFDR5@9D6"
    .ascii  "L6O5FG5A3BGEF5G3AE"
    .ascii  "L6O5DE5F3GBEDC+O4A"
    .ascii  "L6O4G+B5O5D3O4BGABO5CO4A5G3"
    .ascii  "L3O5F+7EFA6FRF"
    .ascii  "L2O5F6DRDDFRFRD4R1R3"
    .db     0xff

; ボス
soundBgmBoss0:

    .ascii  "T2@2V15,3"
    .ascii  "L3O4EO3GO4CE5O3GO4CEO4F+O3AO4DF+5O3AO4DF+"
    .ascii  "L3O4EO3GO4CE5O3GO4CEO4F+O3AO4DF+5O3AO4DF+"
    .ascii  "L3O4ACFA5CFAO4GO3A+O4D+G5O3A+O4D+G"
    .ascii  "L3O4ACFA5CFAO4GO3A+O4D+G5O3A+O4D+G"
    .ascii  "L3O4EO3GO4CE5O3GO4CEO4F+O3AO4DF+5O3AO4DF+"
    .ascii  "L3O4EO3GO4CE5O3GO4CEO4F+O3AO4DF+5O3AO4DF+"
    .ascii  "L3O4ACFA5CFAO4GO3A+O4D+G5O3A+O4D+G"
    .ascii  "L3O4ACFA5CFAO4GO3A+O4D+G5O3A+O4D+G"
    .ascii  "@15L3O5CCCCDDDDO4BBBBO5EEEE"
    .ascii  "L3O5CCCCDDDDO5D+D+D+D+G+G+G+G+"
    .ascii  "L3O5CCCCDDDDO4BBBBO5EEEE"
    .ascii  "L3O5CCCCDDDDO5D+D+D+D+G+G+G+G+"
    .db     0xff

soundBgmBoss1:

    .ascii  "T2@14V15,3"
    .ascii  "L3O4CCCCCCCCO4DDDDDDDD"
    .ascii  "L3O4CCCCCCCCO4DDDDDDDD"
    .ascii  "L3O4FFFFFFFFO4D+D+D+D+D+D+D+D+"
    .ascii  "L3O4FFFFFFFFO4D+D+D+D+D+D+D+D+"
    .ascii  "L3O4CCCCCCCCO4DDDDDDDD"
    .ascii  "L3O4CCCCCCCCO4DDDDDDDD"
    .ascii  "L3O4FFFFFFFFO4D+D+D+D+D+D+D+D+"
    .ascii  "L3O4FFFFFFFFO4D+D+D+D+D+D+D+D+"
    .ascii  "L3O4EEEEFFFFO4EEEEG+G+G+G+"
    .ascii  "L3O4EEEEFFFFO4G+G+G+G+O5CCCC"
    .ascii  "L3O4EEEEFFFFO4EEEEG+G+G+G+"
    .ascii  "L3O4EEEEFFFFO4G+G+G+G+O5CCCC"
    .db     0xff

soundBgmBoss2:

    .ascii  "T2@2V15,3"
    .ascii  "L3O3EO2GO3CE5O2GO3CEO3F+O2AO3DF+5O2AO3DF+"
    .ascii  "L3O3EO2GO3CE5O2GO3CEO3F+O2AO3DF+5O2AO3DF+"
    .ascii  "L3O3ACFA5CFAO3GO2A+O3D+G5O2A+O3D+G"
    .ascii  "L3O3ACFA5CFAO3GO2A+O3D+G5O2A+O3D+G"
    .ascii  "L3O3EO2GO3CE5O2GO3CEO3F+O2AO3DF+5O2AO3DF+"
    .ascii  "L3O3EO2GO3CE5O2GO3CEO3F+O2AO3DF+5O2AO3DF+"
    .ascii  "L3O3ACFA5CFAO3GO2A+O3D+G5O2A+O3D+G"
    .ascii  "L3O3ACFA5CFAO3GO2A+O3D+G5O2A+O3D+G"
    .ascii  "@15L3O4AAAABBBBO4G+G+G+G+BBBB"
    .ascii  "L3O4AAAABBBBO5CCCCD+D+D+D+"
    .ascii  "L3O4AAAABBBBO4G+G+G+G+BBBB"
    .ascii  "L3O4AAAABBBBO5CCCCD+D+D+D+"
    .db     0xff

; ゲームオーバー
soundBgmOver0:

    .ascii  "T2@7"
    .ascii  "V15,3L3O4G5O5CCC5E5"
    .ascii  "V15,5L8O5AE5G9"
    .ascii  "R9"
    .db     0x00

soundBgmOver1:

    .ascii  "T2@7"
    .ascii  "V15,3L3O4E5GGG5O5C5"
    .ascii  "V15,5L8O5EC5E9"
    .ascii  "R9"
    .db     0x00

soundBgmOver2:

    .ascii  "T2@7"
    .ascii  "V15,3L3O4C5EEE5G5"
    .ascii  "V15,5L8O5CO4G5O5C9"
    .ascii  "R9"
    .db     0x00

; リザルト
soundBgmResult0:

    .ascii  "T2@2V15,5"
    .ascii  "L3O4BRRBRRO5C+5DERR"
    .ascii  "L3O4BRRBRRO5C+5DERD"
    .ascii  "L8RO5D"
    .db     0x00

soundBgmResult1:

    .ascii  "T2@2V15,5"
    .ascii  "L3O4GRRGRRA6O5C+RR"
    .ascii  "L3O4GRRGRRA6O5C+RO4A"
    .ascii  "L8RO4A"
    .db     0x00

soundBgmResult2:

    .ascii  "T2@2V15,5"
    .ascii  "L3O3ERRERRO2A6ARR"
    .ascii  "L3O3ERRERRO2A6ARO3D"
    .ascii  "L8RO3F+"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeHit
    .dw     soundSeMiss
    .dw     soundSeBomb

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; ヒット
soundSeHit:

    .ascii  "T1@0V13,1L4O2E"
    .db     0x00

; ミス
soundSeMiss:

    .ascii  "T1@0V13,1L4O6B"
    .db     0x00

; 爆発
soundSeBomb:

    .ascii  "T1@0V15L0O4GFEDCO3BAG"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
