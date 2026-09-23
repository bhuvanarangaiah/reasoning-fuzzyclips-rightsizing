;;; ============================================================
;;; BH_rightsizing.clp
;;; Base de Hechos (Fact Base) - FuzzyCLIPS
;;; Caso de ejemplo: CPU = 60%, Memoria = 55%
;;; (mismo caso desarrollado a mano en el apartado 4 del PDF)
;;;
;;; Cargar despues de BC_rightsizing.clp:
;;;   (load "BC_rightsizing.clp")
;;;   (load "BH_rightsizing.clp")
;;;   (reset)
;;;   (run)
;;; ============================================================

;; NOTA sobre sintaxis: cpu y memoria son deftemplates borrosos con un
;; unico slot implicito, asi que no se puede afirmar un numero crudo
;; como (cpu 60), ni basta con un unico par (cpu (60 1)) -- FuzzyCLIPS
;; extiende el ultimo punto de la lista de singletons hacia +/-infinito,
;; asi que un solo punto (60 1) daria grado de pertenencia 1 en TODO
;; el universo, no solo en x=60.
;;
;; Para representar un valor crisp (60) como en el manual oficial
;; (Example 15: "(three (3 0) (3 1) (3 0))"), se usa un pico vertical
;; de 3 puntos: sube de 0 a 1 y vuelve a 0 en el mismo x.
;; (cpu (60 0) (60 1) (60 0)) = "CPU es exactamente 60%".

(deffacts caso-1-lectura-sensores
   "Lectura de CloudWatch para una instancia EC2 concreta"
   (cpu (60 0) (60 1) (60 0))
   (memoria (55 0) (55 1) (55 0))
)

;; Para probar otros casos, comentar el bloque anterior y usar,
;; por ejemplo, uno de los siguientes:

;; Caso claramente infrautilizado -> deberia disparar R1 (Reducir)
;; (deffacts caso-2-infrautilizada
;;    (cpu (15 0) (15 1) (15 0))
;;    (memoria (20 0) (20 1) (20 0))
;; )

;; Caso claramente saturado -> deberia disparar R2 (Aumentar)
;; (deffacts caso-3-saturada
;;    (cpu (85 0) (85 1) (85 0))
;;    (memoria (90 0) (90 1) (90 0))
;; )

;; Caso con senales contradictorias -> deberia disparar R4 y avisar
;; de posible cambio de familia de instancia
;; (deffacts caso-4-cpu-bound
;;    (cpu (90 0) (90 1) (90 0))
;;    (memoria (20 0) (20 1) (20 0))
;; )
