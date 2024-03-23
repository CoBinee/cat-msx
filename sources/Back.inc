; Back.inc : 背景
;


; マクロの定義
;

; 背景
BACK_SCROLL                     =   0x00
BACK_OUTER_LEFT                 =   0x01
BACK_OUTER_RIGHT                =   0x02
BACK_OUTER_MINIMUM              =   0x03
BACK_OUTER_MAXIMUM              =   0x04
BACK_LENGTH                     =   0x08

; スクロール
BACK_SCROLL_NULL                =   0x00

; 外側
BACK_OUTER_NULL                 =   0x00

; セル
BACK_CELL_NULL                  =   0x00
BACK_CELL_OUTER_FLAT            =   0x01
BACK_CELL_INNER_FLAT            =   0x02
BACK_CELL_INNER_BLOCK           =   0x03
BACK_CELL_OUTER_LT              =   0x04
BACK_CELL_OUTER_RT              =   0x05
BACK_CELL_OUTER_LB              =   0x06
BACK_CELL_OUTER_RB              =   0x07
BACK_CELL_INNER_FACE            =   0x08
BACK_CELL_INNER_FACE_BIT        =   0x03
BACK_CELL_INNER_FACE_LIFE_MASK  =   0x07
BACK_CELL_INNER_FACE_0          =   0x08
BACK_CELL_INNER_FACE_1          =   0x09
BACK_CELL_INNER_FACE_2          =   0x0a
BACK_CELL_INNER_FACE_3          =   0x0b
BACK_CELL_INNER_FACE_4          =   0x0c
BACK_CELL_SIZE_X                =   0x10
BACK_CELL_SIZE_Y                =   0x10

; 外部関数宣言
;

    .globl  _BackInitialize
    .globl  _BackUpdate
    .globl  _BackRender
    .globl  _BackHit

; 外部変数宣言
;

    .globl  _back

