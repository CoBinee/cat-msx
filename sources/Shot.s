; Shot.s : ショット
;


; モジュール宣言
;
    .module Shot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Shot.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ショットを初期化する
;
_ShotInitialize::
    
    ; レジスタの保存

    ; ショットの初期化
    ld      hl, #(_shot + 0x0000)
    ld      de, #(_shot + 0x0001)
    ld      bc, #(SHOT_LENGTH * SHOT_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを更新する
;
_ShotUpdate::
    
    ; レジスタの保存
    
    ; ショットの走査
    ld      ix, #_shot
    ld      de, #SHOT_LENGTH
    ld      b, #SHOT_ENTRY
10$:
    ld      a, SHOT_TYPE(ix)
    or      a
    jr      z, 19$

    ; 移動
    ld      a, SHOT_SPEED_X(ix)
    or      a
    jp      p, 11$
    neg
    ld      c, a
    ld      a, SHOT_POSITION_X(ix)
    sub     c
    jr      c, 18$
    jr      12$
11$:
    add     a, SHOT_POSITION_X(ix)
    jr      c, 18$
;   jr      12$
12$:
    ld      SHOT_POSITION_X(ix), a
    ld      a, SHOT_SPEED_Y(ix)
    or      a
    jp      p, 13$
    neg
    ld      c, a
    ld      a, SHOT_POSITION_Y(ix)
    sub     c
    jr      c, 18$
    jr      14$
13$:
    add     a, SHOT_POSITION_Y(ix)
    jr      c, 18$
;   jr      14$
14$:
    ld      SHOT_POSITION_Y(ix), a
    jr      19$

    ; ショットの削除
18$:
    ld      SHOT_TYPE(ix), #SHOT_TYPE_NULL
;   jr      19$

    ; 次のショットへ
19$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを描画する
;
_ShotRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_shot
    ld      de, #(_sprite + GAME_SPRITE_SHOT)
    ld      b, #SHOT_ENTRY
10$:
    push    bc
    ld      a, SHOT_TYPE(ix)
    or      a
    jr      z, 19$
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #shotSprite
    add     hl, bc
    ld      a, SHOT_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, SHOT_POSITION_X(ix)
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
19$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret
    
; ショットを撃つ
;
_ShotFire::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; a  < ショットの種類
    ; de < Y/X 座標

    ; ショットの登録
    ex      de, hl
    ld      c, a
    ld      ix, #_shot
    ld      de, #SHOT_LENGTH
    ld      b, #SHOT_ENTRY
10$:
    ld      a, SHOT_TYPE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    jr      19$
11$:
    push    hl
    ld      a, c
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #shotDefault
    add     hl, de
    push    ix
    pop     de
    ld      bc, #SHOT_LENGTH
    ldir
    pop     hl
    ld      SHOT_POSITION_X(ix), l
    ld      SHOT_POSITION_Y(ix), h
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; ショットの初期値
;
shotDefault:

    ; なし
    .db     SHOT_TYPE_NULL
    .db     SHOT_POSITION_NULL
    .db     SHOT_POSITION_NULL
    .db     SHOT_SPEED_NULL
    .db     SHOT_SPEED_NULL
    .db     0x00, 0x00, 0x00
    ; 06:00
    .db     SHOT_TYPE_0600
    .db     SHOT_POSITION_NULL
    .db     SHOT_POSITION_NULL
    .db     0x00 ; SHOT_SPEED_NULL
    .db     0x0c ; SHOT_SPEED_NULL
    .db     0x00, 0x00, 0x00
    ; 09:00
    .db     SHOT_TYPE_0900
    .db     SHOT_POSITION_NULL
    .db     SHOT_POSITION_NULL
    .db     -0x0c ; SHOT_SPEED_NULL
    .db      0x00 ; SHOT_SPEED_NULL
    .db     0x00, 0x00, 0x00
    ; 03:00
    .db     SHOT_TYPE_0300
    .db     SHOT_POSITION_NULL
    .db     SHOT_POSITION_NULL
    .db     0x0c ; SHOT_SPEED_NULL
    .db     0x00 ; SHOT_SPEED_NULL
    .db     0x00, 0x00, 0x00
    ; 07:30
    .db     SHOT_TYPE_0730
    .db     SHOT_POSITION_NULL
    .db     SHOT_POSITION_NULL
    .db     -0x08 ; SHOT_SPEED_NULL
    .db      0x08 ; SHOT_SPEED_NULL
    .db     0x00, 0x00, 0x00
    ; 04:30
    .db     SHOT_TYPE_0430
    .db     SHOT_POSITION_NULL
    .db     SHOT_POSITION_NULL
    .db     0x08 ; SHOT_SPEED_NULL
    .db     0x08 ; SHOT_SPEED_NULL
    .db     0x00, 0x00, 0x00

; スプライト
;
shotSprite:

    ; なし
    .db     0xf8 - 0x01, 0xf8, 0x00, VDP_COLOR_TRANSPARENT
    ; 06:00
    .db     0xf1 - 0x01, 0xf8, 0x04, VDP_COLOR_LIGHT_YELLOW
    ; 09:00
    .db     0xf8 - 0x01, 0x00, 0x08, VDP_COLOR_LIGHT_YELLOW
    ; 03:00
    .db     0xf8 - 0x01, 0xf1, 0x0c, VDP_COLOR_LIGHT_YELLOW
    ; 07:30
    .db     0xf1 - 0x01, 0x00, 0x10, VDP_COLOR_LIGHT_YELLOW
    ; 04:30
    .db     0xf1 - 0x01, 0xf1, 0x14, VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ショット
;
_shot::
    
    .ds     SHOT_LENGTH * SHOT_ENTRY
