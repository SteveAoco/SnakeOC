;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname SnakeGame) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; Snake Game (Jogo da Cobra) (torne isto mais específico)
;; Cenário sempre terá proporcao 1:1
;; _Funcionamento_:
;; Ao encostar em uma "fruta" aumenta em 1 o tamanho da cobra (LISTA-GOMOS)
;; _Fim de Jogo_:
;; Ao encostar no limite do mapa ou em seu próprio corpo o jogo termina
;; =================
;; Constantes:
(define CENARIO-ALTURA 300)
(define CENARIO-LARGURA 300)
(define CENARIO (empty-scene CENARIO-LARGURA CENARIO-ALTURA))

(define MEIO (/ CENARIO-LARGURA 2))
(define LIMITE-MIN 0)
(define LIMITE-MAX CENARIO-ALTURA)

(define GOMO (square 10 "solid" "black"))
(define FRUTA (circle 10 "solid" "red"))

(define DX-PADRAO 1)
(define TC-VIRA " ")


;; =================
;; Definições de dados:
;; Snake Game é (make-jogo Cobra Fruta)
;; Interp. jogo possui uma cobra que aumenta a proporcao e varias frutas que irão spawnar conforme um tempo,
;; e uma pontuacao de contagem de gomos

(define-struct JOGO (COBRA FRUTA))

(define-struct COBRA (CABECA RABO DIRECAO))
  

