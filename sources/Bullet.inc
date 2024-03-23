; Bullet.inc : 敵弾
;


; マクロの定義
;

; ショット
BULLET_SIZE                     =   0x00
BULLET_POSITION_X               =   0x01
BULLET_POSITION_Y               =   0x02
BULLET_MOVE_X                   =   0x03
BULLET_MOVE_Y                   =   0x04
BULLET_SPEED_X                  =   0x05
BULLET_SPEED_Y                  =   0x06
BULLET_ANIMATION                =   0x07
BULLET_LENGTH                   =   0x08
BULLET_ENTRY                    =   0x0c

; 大きさ
BULLET_SIZE_NULL                =   0x00
BULLET_SIZE_SMALL               =   (0x04 + 0x02)
BULLET_SIZE_LARGE               =   (0x08 + 0x02)

; 位置
BULLET_POSITION_NULL            =   0x00
BULLET_POSITION_LEFT            =   0x00
BULLET_POSITION_TOP             =   0x00
BULLET_POSITION_RIGHT           =   0xff
BULLET_POSITION_BOTTOM          =   0xbf

; 移動
BULLET_MOVE_NULL                =   0x00

; 速度
BULLET_SPEED_NULL               =   0x00

; 外部関数宣言
;

    .globl  _BulletInitialize
    .globl  _BulletUpdate
    .globl  _BulletRender
    .globl  _BulletFireDirection
    .globl  _BulletFirePlayer
    .globl  _BulletHit

; 外部変数宣言
;

    .globl  _bullet

