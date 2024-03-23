; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Title.inc"
    .include    "Game.inc"

; 外部変数宣言
;
    .globl  _patternTable


; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; アプリケーションの初期化
    
    ; 画面表示の停止
    call    DISSCR
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; 割り込みの禁止
    di
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternTable + 0x0000)
    ld      d, #0x08
10$:
    ld      e, #0x10
11$:
    push    de
    ld      b, #0x08
    otir
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
    otir
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 11$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 10$
    
    ; パターンジェネレータの転送
    ld      hl, #(_patternTable + 0x0800)
    ld      de, #APP_PATTERN_GENERATOR_TABLE
    ld      bc, #0x0800
    call    LDIRVM
    
    ; カラーテーブルの初期化
    ld      hl, #appColorTable
    ld      de, #APP_COLOR_TABLE
    ld      bc, #0x0020
    call    LDIRVM
    
    ; パターンネームの初期化
    ld      hl, #APP_PATTERN_NAME_TABLE
    xor     a
    ld      bc, #0x0300
    call    FILVRM
    
    ; 割り込み禁止の解除
    ei

    ; スコアの初期化
    ld      hl, #appScoreDefault
    ld      de, #_appScore
    ld      bc, #APP_SCORE_LENGTH
    ldir

    ; 操作の初期化
    ld      hl, #(appOperate + 0x0000)
    ld      de, #(appOperate + 0x0001)
    ld      bc, #(APP_OPERATE_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 状態の初期化
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_appState)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; デバッグの表示
;   call    AppPrintDebug

    ; 更新の終了
90$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 処理なし
;
_AppNull::

    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; デバッグ情報を表示する
;
AppPrintDebug:

    ; レジスタの保存

    ; SP の表示
    ld      de, #(_patternName + 0x02e0)
    ld      hl, #appDebugStringSp
    call    70$
    ld      hl, #0x0000
    add     hl, sp
    ld      a, h
    call    80$
    ld      a, l
    call    80$
19$:

    ; OPLL の表示
    ld      de, #(_patternName + 0x02e8)
    ld      hl, #appDebugStringOpllNg
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 20$
    ld      hl, #appDebugStringOpllOk
20$:
    call    70$
29$:

    ; デバッグの表示
;   jr      39$
    ld      de, #(_patternName + 0x02f0)
    ld      hl, #_appDebug
    ld      b, #0x08
30$:
    ld      a, (hl)
    call    80$
    inc     hl
    djnz    30$
39$:
    jr      90$

    ; 文字列の表示
70$:
    ld      a, (hl)
    sub     #0x20
    ret     c
    ld      (de), a
    inc     hl
    inc     de
    jr      70$

    ; 16 進数の表示
80$:
    push    af
    rrca
    rrca
    rrca
    rrca
    call    81$
    pop     af
    call    81$
    ret
81$:
    and     #0x0f
    cp      #0x0a
    jr      c, 82$
    add     a, #0x07
82$:
    add     a, #0x10
    ld      (de), a
    inc     de
    ret

    ; デバッグ表示の完了
90$:
    ld      hl, #(_patternName + 0x02e0)
    ld      (_patternNameLine + 0x002e), hl

    ; レジスタの復帰

    ; 終了
    ret

; スコアを更新する
;
_AppUpdateScore::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < スコア
    ; cf > 1 = 更新された

    ; スコアの更新
    ld      hl, #_appScore
    ld      b, #APP_SCORE_LENGTH
10$:
    ld      a, (de)
    cp      (hl)
    jr      c, 11$
    jr      nz, 12$
    inc     de
    inc     hl
    djnz    10$
11$:
    or      a
    jr      19$
12$:
    ld      a, #APP_SCORE_LENGTH
    sub     b
    ex      de, hl
    ld      e, a
    ld      d, #0x00
    or      a
    sbc     hl, de
    ld      de, #_appScore
    ld      bc, #APP_SCORE_LENGTH
    ldir
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 操作があるかどうかを取得する
;
_AppIsOperate::

    ; レジスタの保存

    ; cf > 1 = 操作あり

    ; 操作の判定
    ld      a, (appOperate + APP_OPERATE_STATE)
    or      a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 操作の記録を開始する
;
_AppStartRecordOperate::

    ; レジスタの保存
    push    hl

    ; 記録の開始
    ld      hl, #appOperateBuffer
    ld      (appOperate + APP_OPERATE_HEAD_L), hl
    ld      (appOperate + APP_OPERATE_PLAY_L), hl
    ld      a, #APP_OPERATE_STATE_RECORD
    ld      (appOperate + APP_OPERATE_STATE), a

    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; 操作の再生を開始する
;
_AppStartReplayOperate::

    ; レジスタの保存
    push    hl

    ; 再生の開始
    ld      hl, #appOperateBuffer
    ld      (appOperate + APP_OPERATE_HEAD_L), hl
    ld      (appOperate + APP_OPERATE_PLAY_L), hl
    ld      a, #APP_OPERATE_STATE_REPLAY
    ld      (appOperate + APP_OPERATE_STATE), a

    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; 操作を記録する
;
_AppRecordOperate::

    ; レジスタの保存
    push    hl

    ; a < 操作データ

    ; 操作の記録
    ld      hl, (appOperate + APP_OPERATE_PLAY_L)
    ld      (hl), a
    inc     hl
    ld      (appOperate + APP_OPERATE_PLAY_L), hl

    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; 操作を再生する
;
_AppReplayOperate::

    ; レジスタの保存
    push    hl

    ; a > 操作データ

    ; 操作の記録
    ld      hl, (appOperate + APP_OPERATE_PLAY_L)
    ld      a, (hl)
    inc     hl
    ld      (appOperate + APP_OPERATE_PLAY_L), hl

    ; レジスタの復帰
    pop     hl
    
    ; 終了
    ret

; 操作を記録中かどうかを取得する
;
_AppIsRecordOperate::

    ; レジスタの保存

    ; cf > 1 = 記録中

    ; 操作の判定
    ld      a, (appOperate + APP_OPERATE_STATE)
    cp      #APP_OPERATE_STATE_RECORD
    jr      z, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの保存

    ; 終了
    ret

; 操作を再生中かどうかを取得する
;
_AppIsReplayOperate::

    ; レジスタの保存

    ; cf > 1 = 再生中

    ; 操作の判定
    ld      a, (appOperate + APP_OPERATE_STATE)
    cp      #APP_OPERATE_STATE_REPLAY
    jr      z, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの保存

    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000111

; カラーテーブル
;
appColorTable:

    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK, (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK, (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK, (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK, (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK, (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK, (VDP_COLOR_BLACK        << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK        << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK        << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_WHITE, (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_WHITE, (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_WHITE, (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_WHITE

; 状態別の処理
;
appProc:
    
    .dw     _AppNull
    .dw     _TitleInitialize
    .dw     _TitleUpdate
    .dw     _GameInitialize
    .dw     _GameUpdate

; スコア
;
appScoreDefault:

    .db     0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; デバッグ
;
appDebugStringSp:

    .ascii  "SP="
    .db     0x00

appDebugStringOpllNg:

    .ascii  "OPLL=NG"
    .db     0x00

appDebugStringOpllOk:

    .ascii  "OPLL=OK"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
_appState::

    .ds     1

; デバッグ
;
_appDebug::

    .ds     0x08

; スコア
;
_appScore::

    .ds     APP_SCORE_LENGTH

; 操作
;
appOperate:

    .ds     APP_OPERATE_LENGTH

appOperateBuffer:

    .ds     APP_OPERATE_BUFFER_LENGTH
