;----------------------------------------
;Autor: Heine Morantin (@hmorantin) 
;PWM & Selector de frecuencias [6 Rangos]
;Version: Alpha 0.0.2
;RAN01> 01.00Mhz
;RAN02> 01.25MHz
;RAN03> 02.50Mhz
;RAN04> 05.00Mhz
;RAN05> 01.00Khz - 20.00Khz
;RAN06> 20.00Khz - 250.00Khz
;----------------------------------------

;Configuracion Inicial
;----------------------------------------
	ORG	0x00
	bsf	STATUS,rp0
	clrf	OSCCON 
	clrf	OSCTUNE
	clrf	ADCON1
	movlw	0x03 
	movwf	ANSEL 
	movwf	TRISB 
	movlw	0xDF
	movwf	TRISA
	movwf	OPTION_REG
	movlw	0x80
	movwf	ADCON1
	bcf	STATUS,rp0
	movlw	0x0F
	movwf	CCP1CON
	clrf	ADCON0
	bsf	ADCON0,0
	clrf	PORTA
	clrf	PORTB

;Modulo Selector de Frecuencia
;----------------------------------------
SELFRE	btfss	PORTA,2
	goto	$+4
	btfsc	PORTA,2
	goto 	$-1
	call	RAN01

	btfss	PORTA,3
	goto	$+4
	btfsc	PORTA,3
	goto 	$-1
	call	RAN02

	btfss	PORTA,4
	goto	$+4
	btfsc	PORTA,4
	goto 	$-1
	call	RAN03
	
	btfss	PORTA,5
	goto	$+4
	btfsc	PORTA,5
	goto 	$-1
	call	RAN04

	btfss	PORTB,0
	goto	$+4
	btfsc	PORTB,0
	goto 	$-1
	call	RAN05

	btfss	PORTB,1
	goto	$+4
	btfsc	PORTB,1
	goto 	$-1
	call	RAN06

	btfss	0x20,1
	goto 	$+2
	goto	PWM

	btfss	0x20,2
	goto	$+2
	goto	PWM
	
	btfss	0x20,3
	goto	$+2
	goto	PWM

	btfss	0x20,4
	goto	$+2
	goto	PWM

	btfss	0x20,5
	goto	$+2
	goto	PWMFRE

	btfss	0x20,6
	goto	$+2
	goto	PWMFRE

	goto	SELFRE

;Modulo de PWM Only
;----------------------------------------
PWM	bsf	ADCON0,2
WAIT0	btfsc	ADCON0,2
	goto	WAIT0
	movf	ADRESH,0
	movwf	CCPR1L
	bsf	STATUS,rp0
	movf	ADRESL,0
	bcf	STATUS,rp0
	movwf	CCPR1H
	goto 	SELFRE

;Modulo de PWM & FREQVAR 01
;----------------------------------------
PWMFRE	bsf	ADCON0,2 ; Enciende el CAD
WAIT1	btfsc	ADCON0,2 ; Espera que termine la conversion
	goto	WAIT0
	movf	ADRESH,0 ; 
	movwf	CCPR1L
	bsf	STATUS,rp0
	movf	ADRESL,0
	bcf	STATUS,rp0
	movwf	CCPR1H
	bsf	STATUS,rp0
	bsf	ADCON1,7
	bcf	STATUS,rp0
	bsf	ADCON0,3
	bsf	ADCON0,2
WAIT2	btfsc	ADCON0,2
	goto	WAIT1
	bcf	T2CON,2
	bsf	STATUS,rp0	
	bcf	ADCON1,7
	movf	ADRESL,0
	movwf	PR2
	bcf	STATUS,rp0
	bsf	T2CON,2
	goto 	SELFRE

;Rangos de Frecuencias
;----------------------------------------
RAN01	clrf	T2CON
	clrf	0x20
	bsf	STATUS,rp0
	movlw	0x04
	movwf	PR2
	bcf	STATUS,rp0
	bsf	0x20,1
	bsf 	T2CON,2
	return

RAN02	clrf	T2CON
	clrf	0x20
	bsf	STATUS,rp0
	movlw	0x02
	movwf	PR2
	bcf	STATUS,rp0
	bsf	0x20,2
	bsf 	T2CON,2
	return
	
RAN03	clrf	T2CON
	clrf	0x20
	bsf	STATUS,rp0
	movlw	0x01
	movwf	PR2
	bcf	STATUS,rp0
	bsf	0x20,2
	bsf 	T2CON,2
	return

RAN04	clrf	T2CON
	clrf	0x20
	bsf	STATUS,rp0
	clrf	PR2
	bcf	STATUS,rp0
	bsf	0x20,4
	bsf 	T2CON,2
	return

RAN05	clrf	T2CON
	clrf	0x20
	bsf	0x20,5
	bsf	T2CON,1
	return

RAN06	clrf	T2CON
	clrf	0x20
	bsf	0x20,6
	return		