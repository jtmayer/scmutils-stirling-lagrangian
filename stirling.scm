;; Modified scmutils function for path dependent Lagrangians
(define (Lagrangian-action L q t1 t2)
  (definite-integral (L q t1) t1 t2))

(define start-time 0.)
(define revs (expt 10. 1))
(define end-time (* revs (expt 10. 1)))


(define win2 (frame start-time end-time -1. (* revs :2pi)))

(define (nl) (display "\n"))
(define (colon) (display ":"))
(define (angular q) (s:ref q 0)) ;; relating to angle
(define (caloric q) (s:ref q 1)) ;; relating to temperature

;; Modified scmutils function for displaying multivariate screens
;; t0, q0, t1, q1 are our states described above
;; qs are a suggested list of intermediate positions spaced by a timestep
;; Returns the action value of the proposed path.
(define ((parametric-path-action Lagrangian t0 q0 t1 q1) qs)
  (let ((path (make-path t0 q0 t1 q1 qs)))
    ;;compute action
    (let ((action (Lagrangian-action Lagrangian path t0 t1)))
      (display "Drawing screen at ")
      (let ((time (local-decoded-time)))
	(display decoded-time/hour time)
	(colon)
	(display decoded-time/minute time)
	(colon)
	(display decoded-time/second time)
	(nl))
      (graphics-clear win2)
      (plot-function win2 (compose angular path) t0 t1 (/ (- t1 t0) 100)) ;; plot crank position
      (plot-function win2 (compose caloric path) t0 t1 (/ (- t1 t0) 100)) ;; plot temperature
      action)))

(define (((L-stirling m conduction gas-const df stroke ccl bore T-cold T-hot) path t0) t)
  (let ((local (Gamma path)))
    (let ((q (compose coordinate local))
	  (v (compose velocity local))
	  (g 9.8) ;; gravitational acceleration
	  (crank-l (/ stroke 2))) ;; length of crank
      (let ((crank-pos (compose angular q)) ;; crank position (angle), down is 0
	    (angular-v (compose angular v)) ;; angular velocity of crank
	    (T (compose caloric q))) ;; Temperature
	(let ((v (lambda (t) (* crank-l (angular-v t) (sin (crank-pos t))))) ;; v rebound in this closure
	      (-x (lambda (t) (* crank-l (cos (crank-pos t)))))) ;; position of piston
	  (let ((1st-term (* 1/2 m (square (v t)))) ;; kinetic energy
		(2nd-term (* m g (-x t))) ;; gravitational potential energy
		(3rd-term (- (* 1/2 (df (T t)) gas-const (T t)))) ;; thermal energy
		(diff-hot (lambda (t) (- (T t) T-hot)))
		(diff-cold (lambda (t) (- (T t) T-cold)))
		(l-cylinder (lambda (t) (+ ccl crank-l (-x t))))) ;; distance from cylinder head to piston
	    (let ((integrand (lambda (t) (+ (* conduction :pi ;; integrand is the change in thermal energy
					       (+ (* (square (* 1/2 bore)) ;; assumes entire bottom conducts heat 
						     (diff-hot t))
						  (* bore (l-cylinder t) (diff-cold t)))) ;; heat loss to walls
					    (/ (* gas-const (T t) (v t)) (l-cylinder t)))))) ;; pdx
	      (let ((integral (definite-integral integrand t0 t)))
		(+ 1st-term 2nd-term 3rd-term integral)))))))))

(let ((m 1.)
      (conduction (/ 1. revs)) ;; thermal conduction constant
      (gas-const (/ 1. revs)) ;; number of molecules multiplied by Boltzmann's constant
      (df (lambda (T) (if (> T (* revs .77)) ;; degrees of freedom, vibrational modes unfreeze at 77°C
			  6 5))) ;; 3 for a monoatomic gas, 5-6 for a diatomic gas
      
      (stroke 1.) ;; distance between piston at top dead center and bottom dead center
      (ccl .1) ;; cylinder (head) clearance length
      (bore 1.) ;; inner diameter of cylinder
      (T-cold (* revs .2)) ;; temperature of cold reservoir in 100/revs °C
      (T-hot (* revs 2.)) ;; temperature of hot reservoir in 100/revs °C
      (q0 0.)) ;; initial position


  (let ((T-final (+ T-cold (* .8 (- T-hot T-cold)))) ;; final temperature
	(T0 T-cold)) ;; initial temperature
    (display "This may take a while to start displaying. Graph will update as new minimum path is computed.")
    (find-path (L-stirling m conduction gas-const df stroke ccl bore T-cold T-hot)
	       start-time
	       (up q0 T0)
	       end-time
	       (up (* :2pi revs) T-final)
	       2)))
