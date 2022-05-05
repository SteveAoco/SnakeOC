;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Snake) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require racket/gui)

;;Snake Game (Jogo da Cobra) (torne isto mais específico)
;;Cenário sempre terá proporcao 1:1
;;_Funcionamento_:
;;Ao encostar em uma "fruta" aumenta em 1 o tamanho da cobra (LISTA-GOMOS)
;;_Fim de Jogo_:
;;Ao encostar no limite do mapa ou em seu próprio corpo o jogo termina
;;=================
;;Constantes:

(define BLOCKS_WIDTH 20) ; tamanho da altura, em blocos
(define BLOCKS_HEIGHT 20) ; tamanho da largura, em blocos
(define BLOCK_SIZE 14) ; tamanho em pixels de cada bloco


;;Definições de dados:
;;Snake Game é (make-jogo cobra fruta)
;;Interp. jogo possui uma cobra que aumenta a proporcao em blocos e varias frutas em blocos que spawnam conforme são comidas,
;;e uma pontuacao de contagem de frutas comidas
;;Exemplos:

(define COBRA (list (list 2 1) (list 1 1))) ; lista com as posições da cobra
(define DIRECAO 'r); para onde a cobra está indo
(define FRUTA (list 9 8)); onde a fruta está
(define PONTOS 0); quantas frutas tomou

(define frame (new frame% 
  [label "Snake Game"]
  [width (* BLOCKS_WIDTH BLOCK_SIZE)]
  [height (* BLOCKS_HEIGHT BLOCK_SIZE)])); define o cenario

;;=================
;;Funcoes:

;inteiro inteiro -> lista
;funcao que remove o último elemento da lista e adiciona um novo no começo dela
(define (move-bloco x y) 
  (reverse (append (cdr (reverse COBRA)) (list(list x y)))))

;inteiro lista -> ?
;funcao que pega o elemento no indice do primeiro elemento da lista
;exemplo:
(check-expect (pega-cabeca 1 (list (list 4 5) (list 6 7))) 5)

(define (pega-cabeca posicao lst)
  (list-ref (list-ref lst 0) posicao))

;dc inteiro inteiro string -> void
;funcao que desenha os blocos referente à cobra como a fruta
;o parametro color pode ser uma string ou um objeto de cor
(define (desenha-bloco screen x y color) 
  (send screen set-brush color 'solid)
  (send screen draw-rectangle (* x BLOCK_SIZE) (* y BLOCK_SIZE) BLOCK_SIZE BLOCK_SIZE)) 

;;simbolo -> void
;;funcao que seta a direcao conforme a tecla correspondente('l, 'r, 'u ou 'd)
(define (move-cobra posicao)
  (case posicao
    ['l (set! COBRA (move-bloco (- (pega-cabeca 0 COBRA) 1) (pega-cabeca 1 COBRA)))]
    ['r (set! COBRA (move-bloco (+ (pega-cabeca 0 COBRA) 1) (pega-cabeca 1 COBRA)))]
    ['u (set! COBRA (move-bloco (pega-cabeca 0 COBRA) (- (pega-cabeca 1 COBRA) 1)))]
    ['d (set! COBRA (move-bloco (pega-cabeca 0 COBRA) (+ (pega-cabeca 1 COBRA) 1)))]))

;lista lista [número] [número] -> bool
;funcao que verifica se a lista de pontos de frutas comidas está na lista cobra
;g representa o índice de exclusão
(define (encostou-bloco COBRA bloco [i 0] [g 666])
  (if (> (length COBRA) i)  ; length (cobra) > i
    (if (and (not (= g i)) (and 
      (eq? (list-ref (list-ref COBRA i) 0) (list-ref bloco 0)) ; verifica pelo x e pelo y
      (eq? (list-ref (list-ref COBRA i) 1) (list-ref bloco 1)))) 
        #t
      (encostou-bloco COBRA bloco (+ i 1) g))
    #f))

;λ -> void
;funcao que faz a cobra crescer, copiando o último elemento da lista cobra, movendo a cobra para outra posiçao
;e adicionando o último elemento pego anteriormente
(define cresce-cobra (lambda () 
  (define x (car (reverse COBRA)))
  (set! FRUTA (list (inexact->exact (round (* (random) (- BLOCKS_WIDTH 1)))) (inexact->exact (round (* (random) (- BLOCKS_HEIGHT 1)))) ))
  (move-cobra DIRECAO)
  (set! PONTOS (add1 PONTOS))
  (set! COBRA (append COBRA (list x)))))

;λ -> void
;funcao que reinicia o jogo, seta todas as constantes para o estado original
(define restart (lambda()
  (set! DIRECAO 'r)
  (set! FRUTA (list 9 8))
  (set! COBRA (list (list 2 1) (list 1 1)))
  (set! PONTOS 0)
))

; -> canvas%
;funcao que trata o pressionamento da tecla e direciona a cobra
(define (trata-tecla frame) (class canvas%
  (define/override (on-char key-event)
    (cond
      [(eq? (send key-event get-key-code) 'left) (if (eq? DIRECAO 'r) (set! DIRECAO 'r) (set! DIRECAO 'l))]
      [(eq? (send key-event get-key-code) 'right) (if (eq? DIRECAO 'l) (set! DIRECAO 'l) (set! DIRECAO 'r))]
      [(eq? (send key-event get-key-code) 'up) (if (eq? DIRECAO 'd) (set! DIRECAO 'd) (set! DIRECAO 'u))]
      [(eq? (send key-event get-key-code) 'down) (if (eq? DIRECAO 'u) (set! DIRECAO 'u) (set! DIRECAO 'd))]
      [(eq? (send key-event get-key-code) '#\ ) (restart)]))
  (super-new [parent frame])))

;λ -> void
;funcao que atualiza a tela e movimenta cobra
(define atualiza-cobra (lambda () 
  (desenha-bloco dc (list-ref FRUTA 0) (list-ref FRUTA 1) "red")
  (desenha-bloco dc (list-ref FRUTA 0) (list-ref FRUTA 1) "red")                      ; desenha a fruta
  (cond [(encostou-bloco COBRA FRUTA) (cresce-cobra)] [else (move-cobra DIRECAO)]) ; checa por colisão com a fruta
  (send dc draw-text (number->string PONTOS) (-(* BLOCKS_WIDTH BLOCK_SIZE) 30) 10)
  (for ([block COBRA]) (
    if (eq? block (car COBRA)) 
      (desenha-bloco dc (list-ref block 0) (list-ref block 1) "green") 
      (desenha-bloco dc (list-ref block 0) (list-ref block 1) "green")))))

;λ -> void
;funcao que cria o cenario de game-over
(define game-over (lambda ()
  (send dc draw-text "VOCÊ MORREU" (- (round (/ (* BLOCKS_WIDTH BLOCK_SIZE) 2)) 70) (- (round (/ (* BLOCKS_HEIGHT BLOCK_SIZE) 2)) 20))
  (send dc draw-text "(ESPACO PARA REINICIAR)" (- (round (/ (* BLOCKS_WIDTH BLOCK_SIZE) 2)) 110) (- (round (/ (* BLOCKS_HEIGHT BLOCK_SIZE) 2)) 5))
))

;instancia o cenario
(define cenario (
  new (trata-tecla frame)))

;pega o desenha cenario
(define dc (send cenario get-dc))

;seta a fonte
(send dc set-font (make-object font% 12 'decorative))
(send dc set-text-foreground "white")

;manda o objeto frame aparecer
(send frame show #t)

;loop com colisoes e frames
(define timer (new timer%
  [notify-callback (lambda()
    (send dc clear)
    (send dc set-brush "black" 'solid)       
    (send dc draw-rectangle 0 0 (* BLOCKS_WIDTH BLOCK_SIZE) (* BLOCKS_HEIGHT BLOCK_SIZE))                
    
    (define colisao #f)
    (for ([block COBRA]
         [j (in-naturals 0)])
      (cond 
            [(or (> (list-ref block 0) BLOCKS_WIDTH) (> 0 (list-ref block 0))) (set! colisao #t )]
            [(or (> (list-ref block 1) BLOCKS_HEIGHT) (> 0 (list-ref block 1))) (set! colisao #t)]
            [(eq? #f colisao) (set! colisao (eq? #t (encostou-bloco COBRA block 0 j)))]))
    (if colisao (game-over) (atualiza-cobra)))]
  [interval #f]))

(send timer start 100)