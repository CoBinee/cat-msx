; Shot.inc : ショット
;


; マクロの定義
;

; ショット
SHOT_TYPE                       =   0x00
SHOT_POSITION_X                 =   0x01
SHOT_POSITION_Y                 =   0x02
SHOT_SPEED_X                    =   0x03
SHOT_SPEED_Y                    =   0x04
SHOT_LENGTH                     =   0x08
SHOT_ENTRY                      =   0x08

; 種類
SHOT_TYPE_NULL                  =   0x00
SHOT_TYPE_0600                  =   0x01
SHOT_TYPE_0900                  =   0x02
SHOT_TYPE_0300                  =   0x03
SHOT_TYPE_0730                  =   0x04
SHOT_TYPE_0430                  =   0x05

; 位置
SHOT_POSITION_NULL              =   0x00
SHOT_POSITION_LEFT              =   0x00
SHOT_POSITION_TOP               =   0x00
SHOT_POSITION_RIGHT             =   0xff
SHOT_POSITION_BOTTOM            =   0xbf

; 速度
SHOT_SPEED_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _ShotInitialize
    .globl  _ShotUpdate
    .globl  _ShotRender
    .globl  _ShotFire

; 外部変数宣言
;

    .globl  _shot

