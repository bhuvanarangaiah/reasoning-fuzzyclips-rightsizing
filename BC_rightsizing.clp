;;; ============================================================
;;; BC_rightsizing.clp
;;; Base de Conocimientos (Knowledge Base) - FuzzyCLIPS
;;; Asesor de rightsizing de instancias EC2 (AWS)
;;; Autor: Bhuvana Cheemala
;;;
;;; NOTA: la sintaxis exacta puede variar segun la version de
;;; FuzzyCLIPS instalada. Verificar contra el manual oficial /
;;; el articulo de instalacion antes de la entrega final.
;;; ============================================================

;; (clear) borra por completo el entorno (deftemplates, reglas y
;; hechos de una carga anterior) antes de redefinir nada. Sin esto,
;; recargar este archivo en la misma sesion de FuzzyCLIPS falla con
;; "Cannot redefine deftemplate ... while it is in use" en cuanto
;; queden hechos de una ejecucion previa (p.ej. recomendacion).
(clear)

;; --------------------------------------------------------------
;; Plantillas borrosas (fuzzy deftemplates)
;; Cada termino lingueistico se define como una lista de puntos
;; (x y) que describen su funcion de pertenencia trapezoidal /
;; triangular sobre el universo de discurso indicado.
;; --------------------------------------------------------------

(deftemplate cpu
   0 100 "%"
   (
     (baja  (0 1) (30 1) (50 0))
     (media (30 0) (50 1) (70 0))
     (alta  (50 0) (70 1) (100 1))
   )
)

(deftemplate memoria
   0 100 "%"
   (
     (baja  (0 1) (30 1) (50 0))
     (media (30 0) (50 1) (70 0))
     (alta  (50 0) (70 1) (100 1))
   )
)

(deftemplate recomendacion
   -100 100 "% cambio de capacidad"
   (
     (reducir  (-100 1) (-30 1) (0 0))
     (mantener (-30 0) (0 1) (30 0))
     (aumentar (0 0) (30 1) (100 1))
   )
)

;; --------------------------------------------------------------
;; Graficos ASCII de los conjuntos borrosos de entrada
;; (usa la funcion nativa de FuzzyCLIPS plot-fuzzy-value)
;;
;; Sintaxis: (plot-fuzzy-value logname plotchar(s) low high fuzzyvalue...)
;;   - logname     : nombre logico de salida (t = stdout)
;;   - plotchar(s) : caracter(es) usados para dibujar la curva
;;   - low / high  : limites del eje X del grafico (from/to = usar
;;                   los limites del universo definidos en el deftemplate)
;;   - fuzzyvalue  : variable ligada en el patron LHS al valor borroso
;;                   del hecho (p.ej. ?c en (cpu ?c))
;;
;; Se declara con salience alta para que se dispare nada mas resetear,
;; antes que las reglas R1-R5, y asi ver primero las entradas.
;; --------------------------------------------------------------

(defrule mostrar-entradas
   "Grafica ASCII de los conjuntos borrosos de entrada CPU y Memoria"
   (declare (salience 100))
   (cpu ?c)
   (memoria ?m)
   =>
   (printout t crlf "======================================================" crlf)
   (printout t "  GRAFICOS ASCII DE ENTRADA (plot-fuzzy-value)" crlf)
   (printout t "======================================================" crlf)
   (printout t crlf "--- CPU (%) ---" crlf)
   (plot-fuzzy-value t "*" from to ?c)
   (printout t crlf "--- Memoria (%) ---" crlf)
   (plot-fuzzy-value t "*" from to ?m)
   (printout t crlf)
)

;; --------------------------------------------------------------
;; Base de reglas (razonamiento hacia delante, inferencia Mamdani)
;; Implicacion: minimo. Combinacion de antecedentes (Y): minimo.
;; Agregacion de reglas con misma conclusion: maximo.
;; Defuzzificacion: centro de gravedad (centroide).
;; --------------------------------------------------------------

(defrule R1-reducir
   "Si CPU es Baja Y Memoria es Baja Entonces Recomendacion es Reducir"
   (cpu baja)
   (memoria baja)
   =>
   (assert (recomendacion reducir))
)

(defrule R2-aumentar
   "Si CPU es Alta Y Memoria es Alta Entonces Recomendacion es Aumentar"
   (cpu alta)
   (memoria alta)
   =>
   (assert (recomendacion aumentar))
)

(defrule R3-mantener
   "Si CPU es Media Y Memoria es Media Entonces Recomendacion es Mantener"
   (cpu media)
   (memoria media)
   =>
   (assert (recomendacion mantener))
)

(defrule R4-mantener-revisar-familia-cpu
   "Si CPU es Alta Y Memoria es Baja Entonces Recomendacion es Mantener
    (posible cuello de botella de CPU: valorar familia optimizada en computo)"
   (cpu alta)
   (memoria baja)
   =>
   (assert (recomendacion mantener))
   (printout t "Aviso: posible cuello de botella de CPU. Valorar familia optimizada en computo (p.ej. C-family)." crlf)
)

(defrule R5-mantener-revisar-familia-memoria
   "Si CPU es Baja Y Memoria es Alta Entonces Recomendacion es Mantener
    (posible cuello de botella de memoria: valorar familia optimizada en memoria)"
   (cpu baja)
   (memoria alta)
   =>
   (assert (recomendacion mantener))
   (printout t "Aviso: posible cuello de botella de memoria. Valorar familia optimizada en memoria (p.ej. R-family)." crlf)
)

;; --------------------------------------------------------------
;; Regla auxiliar para mostrar el resultado desfuzzificado
;; (ajustar el nombre de la funcion de desfuzzificacion segun la
;; version de FuzzyCLIPS: por ejemplo fuzzy-get-cf, moment-defuzzify...)
;; --------------------------------------------------------------

(defrule mostrar-resultado
   "Se dispara cada vez que la 'contribucion global' de FuzzyCLIPS
    actualiza el hecho recomendacion (una vez por cada regla R1-R5
    que concluye sobre el), asi que muestra la agregacion Mamdani
    paso a paso; la ULTIMA vez que se dispara refleja el conjunto
    agregado final y su centroide y* definitivos."
   (recomendacion ?r)
   =>
   (printout t "Recomendacion (conjunto borroso de salida): " ?r crlf)
   (printout t crlf "--- Grafico ASCII de la recomendacion (plot-fuzzy-value) ---" crlf)
   (plot-fuzzy-value t "*" from to ?r)
   (printout t "Valor desfuzzificado (centroide, moment-defuzzify): "
             (moment-defuzzify ?r) crlf)
   (printout t crlf)
)
