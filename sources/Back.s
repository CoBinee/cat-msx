; Back.s : 背景
;


; モジュール宣言
;
    .module Back

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Back.inc"
    .include    "Bullet.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 背景を初期化する
;
_BackInitialize::
    
    ; レジスタの保存

    ; 背景の初期化
    ld      hl, #backDefault
    ld      de, #_back
    ld      bc, #BACK_LENGTH
    ldir

    ; セルの初期化
    ld      hl, #(backCell + 0x0000)
    ld      de, #(backCell + 0x0001)
    ld      bc, #(BACK_CELL_SIZE_X * BACK_CELL_SIZE_Y - 0x0001)
    ld      (hl), #BACK_CELL_NULL
    ldir

    ; パターンネームの初期化
    call    BackBuildCellPatternName

    ; レジスタの復帰
    
    ; 終了
    ret

; 背景を更新する
;
_BackUpdate::
    
    ; レジスタの保存
    
    ; リクエストの監視
    ld      hl, #(_game + GAME_REQUEST)
    bit     #GAME_REQUEST_BACK_OUT_BIT, (hl)
    jr      z, 09$
    xor     a
    ld      (_back + BACK_OUTER_MINIMUM), a
    inc     a
    ld      (_back + BACK_OUTER_MAXIMUM), a
    res     #GAME_REQUEST_BACK_OUT_BIT, (hl)
09$:

    ; スクロールの更新
    ld      hl, #(_back + BACK_SCROLL)
    inc     (hl)

    ; セルの作成
    ld      a, (hl)
    and     #0x0f
    jp      nz, 190$

    ; セル１ラインのクリア
    ld      a, (hl)
    and     #0xf0
    sub     #0x10
    ld      e, a
    ld      d, #0x00
    ld      hl, #backCell
    add     hl, de
    ld      e, l
    ld      d, h
    ld      a, #BACK_CELL_NULL
    ld      b, #BACK_CELL_SIZE_X
100$:
    ld      (hl), a
    inc     hl
    djnz    100$

    ; 左外側の作成
    call    180$
    ld      hl, #(_back + BACK_OUTER_LEFT)
    ld      bc, (_back + BACK_OUTER_MINIMUM)
    add     a, (hl)
    jp      p, 110$
    xor     a
110$:
    cp      c
    jr      nc, 111$
    inc     a
    jr      112$
111$:
    cp      b
    jr      c, 112$
    dec     a
;   jr      112$
112$:
    ld      b, a
    cp      (hl)
    jr      nz, 113$
    or      a
    jr      z, 119$
    ld      c, #BACK_CELL_OUTER_FLAT
    jr      115$
113$:
    jp      p, 114$
    ld      c, #BACK_CELL_OUTER_RB
    inc     b
    jr      115$
114$:
    ld      c, #BACK_CELL_OUTER_RT
;   jr      115$
115$:
    ld      (hl), a
    ld      l, e
    ld      h, d
    dec     b
    jr      z, 117$
    ld      a, #BACK_CELL_OUTER_FLAT
116$:
    ld      (hl), a
    inc     hl
    djnz    116$
117$:
    ld      (hl), c
119$:

    ; 左内側の作成
    ld      a, (_back + BACK_OUTER_LEFT)
    cp      #0x03
    jr      c, 129$
    call    _GameGetRandom
    and     #0x70
    ld      c, a
    ld      a, (_back + BACK_SCROLL)
    and     #0x10
    rrca
    add     a, c
    ld      c, a
    ld      b, #0x00
    ld      hl, #backCellInner
    add     hl, bc
    call    _GameGetRandom
    rlca
    ld      a, (_back + BACK_OUTER_LEFT)
    sbc     #0x00
    dec     a
    ld      c, a
    ld      b, #0x00
    push    de
    ldir
    pop     de
129$:

    ; 右外側の作成
    ld      hl, #(BACK_CELL_SIZE_X - 0x0001)
    add     hl, de
    ex      de, hl
    call    180$
    ld      hl, #(_back + BACK_OUTER_RIGHT)
    ld      bc, (_back + BACK_OUTER_MINIMUM)
    add     a, (hl)
    jp      p, 130$
    xor     a
130$:
    cp      c
    jr      nc, 131$
    inc     a
    jr      132$
131$:
    cp      b
    jr      c, 132$
    dec     a
;   jr      132$
132$:
    ld      b, a
    cp      (hl)
    jr      nz, 133$
    or      a
    jr      z, 139$
    ld      c, #BACK_CELL_OUTER_FLAT
    jr      135$
133$:
    jp      p, 134$
    ld      c, #BACK_CELL_OUTER_LB
    inc     b
    jr      135$
134$:
    ld      c, #BACK_CELL_OUTER_LT
;   jr      135$
135$:
    ld      (hl), a
    ld      l, e
    ld      h, d
    dec     b
    jr      z, 137$
    ld      a, #BACK_CELL_OUTER_FLAT
136$:
    ld      (hl), a
    dec     hl
    djnz    136$
137$:
    ld      (hl), c
139$:

    ; 右内側の作成
    ld      a, (_back + BACK_OUTER_RIGHT)
    cp      #0x03
    jr      c, 149$
    call    _GameGetRandom
    and     #0x70
    ld      c, a
    ld      a, (_back + BACK_SCROLL)
    and     #0x10
    rrca
    add     a, c
    ld      c, a
    ld      b, #0x00
    ld      hl, #backCellInner
    add     hl, bc
    call    _GameGetRandom
    rlca
    ld      a, (_back + BACK_OUTER_RIGHT)
    sbc     #0x00
    dec     a
    ld      b, a
    push    de
140$:
    ld      a, (hl)
    ld      (de), a
    inc     hl
    dec     de
    djnz    140$
    pop     de
149$:

    ; パターンネームの作成
    ld      a, (_back + BACK_SCROLL)
    sub     #0x10
    call    BackBuildCellPatternNameLine
    jr      190$

    ; 振幅の取得
180$:
    push    hl
    push    de
    call    _GameGetRandom
    and     #0x07
    ld      e, a
    ld      d, #0x00
    ld      hl, #backAmplitude
    add     hl, de
    ld      a, (hl)
    pop     de
    pop     hl
    ret

    ; セル作成の完了
190$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 背景を描画する
;
_BackRender::

    ; レジスタの保存

    ; パターンネームの登録
    ld      a, (_back + BACK_SCROLL)
    and     #0xf8
    ld      h, #0x00
    add     a, a
    rl      h
    add     a, a
    rl      h
    ld      l, a
    ld      de, #_patternNameLine
    ld      b, #0x18
10$:
    push    bc
    push    hl
    ld      bc, #backPatternName
    add     hl, bc
    ld      a, l
    ld      (de), a
    inc     de
    ld      a, h
    ld      (de), a
    inc     de
    pop     hl
    ld      bc, #0x0020
    add     hl, bc
    ld      a, h
    and     #0x03
    ld      h, a
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; セルのパターンネームを展開する
;
BackBuildCellPatternName:

    ; レジスタの保存

    ; 全ラインの展開
    xor     a
10$:
    push    af
    call    BackBuildCellPatternNameLine
    pop     af
    add     a, #BACK_CELL_SIZE_X
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

BackBuildCellPatternNameLine:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < Y 位置

    ; １ラインの展開
    and     #0xf0
    ld      c, a
    ld      b, #0x00
    ld      hl, #backCell
    add     hl, bc
    ex      de, hl
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, a
    ld      hl, #backPatternName
    add     hl, bc
    ld      b, #BACK_CELL_SIZE_X
10$:
    push    bc
    ld      a, (de)
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    push    hl
    ld      hl, #backCellPatternName
    add     hl, bc
    ld      c, l
    ld      b, h
    pop     hl
    push    de
    ld      de, #0x001f
    ld      a, (bc)
    ld      (hl), a
    inc     bc
    inc     hl
    ld      a, (bc)
    ld      (hl), a
    inc     bc
    add     hl, de
    ld      a, (bc)
    ld      (hl), a
    inc     bc
    inc     hl
    ld      a, (bc)
    ld      (hl), a
;   inc     bc
    or      a
    sbc     hl, de
    pop     de
    inc     de
    pop     bc
    djnz    10$

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 背景のヒット判定を行う
;
_BackHit::

    ; レジスタの保存
    push    de

    ; de < Y/X 位置
    ; cf > 1 = ヒットした

    ; ヒット判定
    ld      a, e
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    ld      e, a
    ld      a, (_back + BACK_SCROLL)
    and     #0xf8
    add     a, d
    and     #0xf0
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #backCell
    add     hl, de
    ld      a, (hl)
    cp      #BACK_CELL_INNER_BLOCK
    jr      nz, 10$
    ld      a, #SOUND_SE_MISS
    call    _SoundPlaySe
    jr      18$
10$:
    or      a
    bit     #BACK_CELL_INNER_FACE_BIT, a
    jr      z, 19$
    and     #BACK_CELL_INNER_FACE_LIFE_MASK
    jr      z, 19$
    dec     a
    push    af
    push    de
    or      #BACK_CELL_INNER_FACE
    ld      (hl), a
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #backCellPatternName
    add     hl, bc
    ld      c, l
    ld      b, h
    ld      a, e
    and     #0xf0
    ld      d, a
    ld      a, e
    and     #0x0f
    add     a, a
    ld      e, a
    ld      a, d
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, e
    ld      e, a
    ld      hl, #backPatternName
    add     hl, de
    ld      de, #0x001f
    ld      a, (bc)
    ld      (hl), a
    inc     bc
    inc     hl
    ld      a, (bc)
    ld      (hl), a
    inc     bc
    add     hl, de
    ld      a, (bc)
    ld      (hl), a
    inc     bc
    inc     hl
    ld      a, (bc)
    ld      (hl), a
    pop     de
    pop     af
    jr      nz, 11$
    ld      a, (_back + BACK_SCROLL)
    ld      d, a
    ld      a, e
    and     #0xf0
    sub     d
    add     a, #0x08
    ld      d, a
    ld      a, e
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x08
    ld      e, a
    ld      c, #BULLET_SIZE_SMALL
    call    _BulletFirePlayer
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe
    jr      12$
11$:
    ld      a, #SOUND_SE_HIT
    call    _SoundPlaySe
;   jr      12$
12$:
    call    _GameAddScore
18$:
    scf
19$:

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 定数の定義
;

; 背景の初期値
;
backDefault:

    .db     BACK_SCROLL_NULL
    .db     BACK_OUTER_NULL
    .db     BACK_OUTER_NULL
    .db     0x02 ; BACK_OUTER_NULL
    .db     0x07 ; BACK_OUTER_NULL
    .db     0x00, 0x00, 0x00

; 内側のセル
;
backCellInner:

    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
;   .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK
;   .db     BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1
    .db     BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_4, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_4, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_4, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_4
    .db     BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
;   .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT
;   .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_BLOCK,  BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_4, BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_4, BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FLAT
    .db     BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FACE_4, BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FLAT,   BACK_CELL_INNER_FACE_1, BACK_CELL_INNER_FACE_4, BACK_CELL_INNER_FLAT

; セルのパターンネーム
;
backCellPatternName:

    .db     0x00, 0x00, 0x00, 0x00
    .db     0x40, 0x41, 0x42, 0x43
    .db     0x50, 0x51, 0x52, 0x53
    .db     0x54, 0x55, 0x56, 0x57
    .db     0x00, 0x44, 0x45, 0x46
    .db     0x47, 0x00, 0x48, 0x49
    .db     0x4a, 0x4b, 0x00, 0x4c
    .db     0x4d, 0x4e, 0x4f, 0x00
    .db     0x60, 0x61, 0x62, 0x63
    .db     0x5c, 0x5d, 0x5e, 0x5f
    .db     0x58, 0x59, 0x5a, 0x5b
    .db     0x58, 0x59, 0x5a, 0x5b
    .db     0x58, 0x59, 0x5a, 0x5b

; 振幅
;
backAmplitude:

    .db     0x00, 0x00, 0x01, 0x01, 0x01, -0x01, -0x01, -0x01


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 背景
;
_back::
    
    .ds     BACK_LENGTH

; セル
;
backCell:

    .ds     BACK_CELL_SIZE_X * BACK_CELL_SIZE_Y

; パターンネーム
;
backPatternName:

    .ds     (BACK_CELL_SIZE_X * 0x02) * (BACK_CELL_SIZE_Y * 0x02)
