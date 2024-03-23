; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Shot.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存

    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_player + PLAYER_DAMAGE)
    and     #0x01
    jr      nz, 19$
    ld      a, (_player + PLAYER_TYPE)
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSprite
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_TOP)
    ld      bc, (_player + PLAYER_POSITION_X)
    call    18$
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_BOTTOM)
    call    18$
    jr      19$
18$:
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld       a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld       a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ret
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
10$:

    ; 移動
    ld      c, #0x00
    ld      hl, #(_player + PLAYER_POSITION_X)
;   ld      a, (_input + INPUT_KEY_LEFT)
;   or      a
;   jr      z, 21$
    ld      a, (_game + GAME_INPUT)
    and     #GAME_INPUT_LEFT
    jr      z, 21$
    ld      a, (hl)
    sub     #PLAYER_SPEED_MOVE
    cp      #PLAYER_POSITION_LEFT
    jr      nc, 20$
    ld      a, #PLAYER_POSITION_LEFT
20$:
    ld      (hl), a
    inc     c
    jr      23$
21$:
;   ld      a, (_input + INPUT_KEY_RIGHT)
;   or      a
;   jr      z, 23$
    ld      a, (_game + GAME_INPUT)
    and     #GAME_INPUT_RIGHT
    jr      z, 23$
    ld      a, (hl)
    add     a, #PLAYER_SPEED_MOVE
    cp      #PLAYER_POSITION_RIGHT
    jr      c, 22$
    ld      a, #PLAYER_POSITION_RIGHT
22$:
    ld      (hl), a
    inc     c
;   jr      23$
23$:
    inc     hl
;   ld      a, (_input + INPUT_KEY_UP)
;   or      a
;   jr      z, 25$
    ld      a, (_game + GAME_INPUT)
    and     #GAME_INPUT_UP
    jr      z, 25$
    ld      a, (hl)
    sub     #PLAYER_SPEED_MOVE
    cp      #PLAYER_POSITION_TOP
    jr      nc, 24$
    ld      a, #PLAYER_POSITION_TOP
24$:
    ld      (hl), a
    inc     c
    jr      27$
25$:
;   ld      a, (_input + INPUT_KEY_DOWN)
;   or      a
;   jr      z, 27$
    ld      a, (_game + GAME_INPUT)
    and     #GAME_INPUT_DOWN
    jr      z, 27$
    ld      a, (hl)
    add     a, #PLAYER_SPEED_MOVE
    cp      #PLAYER_POSITION_BOTTOM
    jr      c, 26$
    ld      a, #PLAYER_POSITION_BOTTOM
26$:
    ld      (hl), a
    inc     c
;   jr      27$
27$:

    ; 種類の切り替え
;   ld      a, (_input + INPUT_BUTTON_SHIFT)
;   dec     a
;   jr      nz, 31$
    ld      a, (_game + GAME_INPUT)
    and     #GAME_INPUT_CHANGE
    jr      z, 31$
    ld      hl, #(_player + PLAYER_TYPE)
    ld      a, (hl)
    inc     a
    cp      #PLAYER_TYPE_LENGTH
    jr      c, 30$
    xor     a
30$:
    ld      (hl), a
31$:

    ; 発射
    ld      a, (_player + PLAYER_DAMAGE)
    or      a
    jr      nz, 40$
;   ld      a, (_input + INPUT_BUTTON_SPACE)
;   dec     a
;   jr      nz, 40$
    ld      a, (_game + GAME_INPUT)
    and     #GAME_INPUT_FIRE
    jr      z, 40$
    ld      a, (_player + PLAYER_TYPE)
    add     a, a
    ld      e, a
    ld      hl, #(_player + PLAYER_FIRE)
    inc     (hl)
    ld      a, (hl)
    and     #0x01
    add     a, e
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerFire
    add     hl, de
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, (hl)
    ld      e, a
    inc     hl
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      d, a
    inc     hl
    ld      a, (hl)
    call    _ShotFire
40$:

    ; プレイの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが死亡した
;
PlayerDead:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがクリアした
;
PlayerClear:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerPlay
    .dw     PlayerDead
    .dw     PlayerClear

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_TYPE_DORAEMON
    .db     PLAYER_STATE_PLAY
    .db     PLAYER_FLAG_NULL
    .db     0x80 ; PLAYER_POSITION_NULL
    .db     0x40 ; PLAYER_POSITION_NULL
    .db     PLAYER_FIRE_NULL
    .db     PLAYER_DAMAGE_NULL
    .db     0x00

; 発射
;
playerFire:

    ; DORAEMON
    .db     -0x06,  0x08, SHOT_TYPE_0600, 0x00
    .db      0x05,  0x08, SHOT_TYPE_0600, 0x00
    ; NOBY
    .db      0x00,  0x08, SHOT_TYPE_0600, 0x00
    .db      0x00,  0x08, SHOT_TYPE_0600, 0x00
    ; BIG G
    .db     -0x08,  0x00, SHOT_TYPE_0900, 0x00
    .db      0x07,  0x00, SHOT_TYPE_0300, 0x00
    ; SNEECH
    .db     -0x06,  0x05, SHOT_TYPE_0730, 0x00
    .db      0x05,  0x06, SHOT_TYPE_0430, 0x00

; スプライト
;
playerSprite:

    ; DORAEMON
    .db     0xf8 - 0x01, 0xf8, 0x40, VDP_COLOR_LIGHT_BLUE
    .db     0xe8 - 0x01, 0xf8, 0x20, VDP_COLOR_LIGHT_BLUE
    ; NOBY
    .db     0xf8 - 0x01, 0xf8, 0x44, VDP_COLOR_DARK_YELLOW
    .db     0xe8 - 0x01, 0xf8, 0x24, VDP_COLOR_DARK_YELLOW
    ; BIG G
    .db     0xf8 - 0x01, 0xf8, 0x48, VDP_COLOR_LIGHT_RED
    .db     0xe8 - 0x01, 0xf8, 0x28, VDP_COLOR_LIGHT_RED
    ; SNEECH
    .db     0xf8 - 0x01, 0xf8, 0x4c, VDP_COLOR_CYAN
    .db     0xe8 - 0x01, 0xf8, 0x2c, VDP_COLOR_CYAN


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

