; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    ld      a, #0xb0
    call    _SystemClearPatternName

    ; サウンドの停止
    call    _SoundStop

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 状態の設定
    ld      a, #TITLE_STATE_LOOP
    ld      (titleState), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (titleState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleProc
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

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを待機する
;
TitleLoop:

    ; レジスタの保存

    ; 初期化
    ld      a, (titleState)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    xor     a
    ld      (titleFrame), a

    ; ロゴのパターンネームの描画
    call    TitlePrintLogoPatternName

    ; スコアの描画
    call    TitlePrintScore

    ; OPLL の描画
    call    TitlePrintOpll

    ; リプレイの描画
    call    TitlePrintReplay

    ; 初期化の完了
    ld      hl, #titleState
    inc     (hl)
09$:

    ; スペースキーの押下
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 10$

    ; 操作の記録の開始
    call    _AppStartRecordOperate

    ; 状態の更新
    ld      a, #TITLE_STATE_START
    ld      (titleState), a
    jr      19$

    ; ESC キーの押下
10$:
    ld      a, (_input + INPUT_BUTTON_ESC)
    dec     a
    jr      nz, 19$

    ; 操作の記録の開始
    call    _AppStartRecordOperate
    call    _AppIsOperate
    call    c, _AppStartReplayOperate

    ; 状態の更新
    ld      a, #TITLE_STATE_START
    ld      (titleState), a
;   jr      19$
19$:

    ; フレームの更新
    ld      hl, #titleFrame
    inc     (hl)

    ; ロゴのスプライトの描画
    call    TitlePrintLogoSprite

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; タイトルをスタートする
;
TitleStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (titleState)
    and     #0x0f
    jr      nz, 09$

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #titleState
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #titleFrame
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a

    ; 再生の監視
    call    _SoundIsPlaySe
    jr      c, 19$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
19$:

    ; ロゴのスプライトの描画
    call    TitlePrintLogoSprite

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; ロゴを描画する
;
TitlePrintLogoPatternName:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleLogoPatternName
    ld      de, #(_patternName + 0x00cd)
    ld      b, #0x08
10$:
    push    bc
    ld      bc, #0x0006
    ldir
    ex      de, hl
    ld      bc, #(0x0020 - 0x0006)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

TitlePrintLogoSprite:

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #titleLogoSprite
    ld      de, #(_sprite + TITLE_SPRITE_LOGO)
    ld      bc, #(0x000f * 0x0004)
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; スコアを描画する
;
TitlePrintScore:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleScorePatternName
    ld      de, #(_patternName + 0x0029)
    ld      bc, #0x000e
    ldir
    ld      hl, #(_patternName + 0x002d)
    ld      de, #(_appScore + APP_SCORE_10000000)
    ld      b, #(APP_SCORE_LENGTH - 0x01)
10$:
    ld      a, (de)
    or      a
    jr      nz, 11$
    ld      (hl), #0xb0
    inc     de
    inc     hl
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (de)
    add     a, #0xc0
    ld      (hl), a
    inc     de
    inc     hl
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を描画する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; HIT SPACE BAR の描画
    ld      a, (titleFrame)
    and     #0x10
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleHitSpaceBarPatternName
    add     hl, de
    ld      de, #(_patternName + 0x0268)
    ld      bc, #0x0010
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; OPLL を描画する
;
TitlePrintOpll:

    ; レジスタの保存

    ; OPLL の描画
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 19$
    ld      hl, #(_patternName + 0x02a1)
    ld      a, #0xcc
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    ld      de, #0x001f
    add     hl, de
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; リプレイを描画する
;
TitlePrintReplay:

    ; レジスタの保存

    ; リプレイの描画
    call    _AppIsOperate
    jr      nc, 19$
    ld      hl, #titleReplayPatternName
    ld      de, #(_patternName + 0x02d5)
    ld      bc, #0x000a
    ldir
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
titleProc:
    
    .dw     TitleNull
    .dw     TitleLoop
    .dw     TitleStart

; ロゴ
;
titleLogoPatternName:

    .db     0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5
    .db     0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb
    .db     0xdc, 0xdd, 0xde, 0xdf, 0xe0, 0xe1
    .db     0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7
    .db     0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed
    .db     0xee, 0xef, 0xf0, 0xf1, 0xb0, 0xB0
    .db     0xf2, 0xf3, 0xf4, 0xf5, 0xb0, 0xb0
    .db     0xf6, 0xf7, 0xf8, 0xf9, 0xb0, 0xb0

titleLogoSprite:

    .db     0x28 - 0x01, 0x68, 0xc0, VDP_COLOR_LIGHT_BLUE
    .db     0x28 - 0x01, 0x78, 0xc4, VDP_COLOR_LIGHT_BLUE
    .db     0x28 - 0x01, 0x88, 0xc8, VDP_COLOR_LIGHT_BLUE
    .db     0x38 - 0x01, 0x68, 0xcc, VDP_COLOR_LIGHT_BLUE
    .db     0x38 - 0x01, 0x78, 0xd0, VDP_COLOR_LIGHT_BLUE
    .db     0x38 - 0x01, 0x88, 0xd4, VDP_COLOR_LIGHT_BLUE
    .db     0x48 - 0x01, 0x68, 0xd8, VDP_COLOR_LIGHT_BLUE
    .db     0x48 - 0x01, 0x78, 0xdc, VDP_COLOR_LIGHT_BLUE
    .db     0x48 - 0x01, 0x88, 0xe0, VDP_COLOR_LIGHT_BLUE
    .db     0x58 - 0x01, 0x70, 0xf4, VDP_COLOR_MAGENTA
    .db     0x58 - 0x01, 0x80, 0xf8, VDP_COLOR_MAGENTA
    .db     0x58 - 0x01, 0x68, 0xe4, VDP_COLOR_LIGHT_BLUE
    .db     0x58 - 0x01, 0x78, 0xe8, VDP_COLOR_LIGHT_BLUE
    .db     0x68 - 0x01, 0x68, 0xec, VDP_COLOR_LIGHT_BLUE
    .db     0x68 - 0x01, 0x78, 0xf0, VDP_COLOR_LIGHT_BLUE

; スコア
;
titleScorePatternName:

    .db     0xb1, 0xb2, 0xb3, 0xb0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xb4, 0xb5

; HIT SPACE BAR
;
titleHitSpaceBarPatternName:

    .db     0xb0, 0xb0, 0xb6, 0xb7, 0xb1, 0xb0, 0xb8, 0xb9, 0xba, 0xb8, 0xb0, 0xbb, 0xba, 0xb0, 0xb0, 0xb0
    .db     0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0

; リプレイ
;
titleReplayPatternName:

    .db     0xbc, 0xbd, 0xbe, 0xbf, 0xba, 0xa8, 0xa9, 0xb3, 0xaa, 0xab

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
titleState:
    
    .ds     1

; フレーム
;
titleFrame:

    .ds     1
