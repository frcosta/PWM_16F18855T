
_interrupt:

;PWM_16F18855T.c,53 :: 		void interrupt()
;PWM_16F18855T.c,55 :: 		if (TMR0IF_bit)
	BTFSS      TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
	GOTO       L_interrupt0
;PWM_16F18855T.c,57 :: 		TMR0IF_bit = 0x00;
	BCF        TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
;PWM_16F18855T.c,58 :: 		control_T0 += 0x01;
	INCF       _control_T0+0, 1
;PWM_16F18855T.c,60 :: 		if (control_T0 == 0x64)
	MOVF       _control_T0+0, 0
	XORLW      100
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt1
;PWM_16F18855T.c,63 :: 		read_encoder();
	CALL       _read_encoder+0
;PWM_16F18855T.c,64 :: 		}
L_interrupt1:
;PWM_16F18855T.c,65 :: 		}
L_interrupt0:
;PWM_16F18855T.c,66 :: 		}
L_end_interrupt:
L__interrupt108:
	RETFIE     %s
; end of _interrupt

_main:

;PWM_16F18855T.c,69 :: 		void main() {
;PWM_16F18855T.c,71 :: 		TRISA2_bit = 0;       // bt0 - Troca de Frequencia
	BCF        TRISA2_bit+0, BitPos(TRISA2_bit+0)
;PWM_16F18855T.c,72 :: 		TRISA3_bit = 0;       // bt1 - Output Enable
	BCF        TRISA3_bit+0, BitPos(TRISA3_bit+0)
;PWM_16F18855T.c,73 :: 		TRISA4_bit = 0;       // bt2 - Ajuste fino de duty cycle
	BCF        TRISA4_bit+0, BitPos(TRISA4_bit+0)
;PWM_16F18855T.c,74 :: 		TRISB = 0x00;         // Display LCD
	CLRF       TRISB+0
;PWM_16F18855T.c,77 :: 		ANSELA = 0x00;        // Desabilita Entradas Analogicas nos pinos RA
	CLRF       ANSELA+0
;PWM_16F18855T.c,78 :: 		ANSELB = 0x00;        //Desabilita Entradas Analogicas nos pinos RB
	CLRF       ANSELB+0
;PWM_16F18855T.c,79 :: 		ANSELC = 0x00;        // Desabilita Entradas Analogicas nos pinos RC
	CLRF       ANSELC+0
;PWM_16F18855T.c,81 :: 		PORTB = 0x00;         // Habilita todo o PORTB como saida digital
	CLRF       PORTB+0
;PWM_16F18855T.c,84 :: 		PWM6POL_bit = 0;      // Configure the PWM output polarity by configuring the PWMxPOL bit of the PWMxCON register
	BCF        PWM6POL_bit+0, BitPos(PWM6POL_bit+0)
;PWM_16F18855T.c,85 :: 		PR2 = 0xFF;           // Load the PR2 register with the PWM period value
	MOVLW      255
	MOVWF      PR2+0
;PWM_16F18855T.c,90 :: 		RC2PPS = 0x0E;        // Roteamento de saida do device PWM6 para o pino RC2
	MOVLW      14
	MOVWF      RC2PPS+0
;PWM_16F18855T.c,94 :: 		TMR2IF_bit = 0;       // Clear the TMR2IF interrupt flag bit of the PIR1 register.
	BCF        TMR2IF_bit+0, BitPos(TMR2IF_bit+0)
;PWM_16F18855T.c,95 :: 		T2CKPS2_bit = 1;      // Select the Timer2 prescale 1:16
	BSF        T2CKPS2_bit+0, BitPos(T2CKPS2_bit+0)
;PWM_16F18855T.c,96 :: 		T2CKPS1_bit = 0;
	BCF        T2CKPS1_bit+0, BitPos(T2CKPS1_bit+0)
;PWM_16F18855T.c,97 :: 		T2CKPS0_bit = 0;
	BCF        T2CKPS0_bit+0, BitPos(T2CKPS0_bit+0)
;PWM_16F18855T.c,98 :: 		T2CON |= (1<<TMR2ON); //Enable Timer2
	BSF        T2CON+0, 7
;PWM_16F18855T.c,99 :: 		T2CLKCON = 0x01;      // Timer2 Clock Select bits
	MOVLW      1
	MOVWF      T2CLKCON+0
;PWM_16F18855T.c,104 :: 		TMR0IF_bit = 0;
	BCF        TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
;PWM_16F18855T.c,105 :: 		T0CON0 = 0b10000000;  // Habilita Timer0
	MOVLW      128
	MOVWF      T0CON0+0
;PWM_16F18855T.c,106 :: 		T0CON1 = 0b01000000;  // Seleciona o clock source do timer0
	MOVLW      64
	MOVWF      T0CON1+0
;PWM_16F18855T.c,107 :: 		INTCON = 0xC0;        // Ativa interrupcao global
	MOVLW      192
	MOVWF      INTCON+0
;PWM_16F18855T.c,108 :: 		TMR0 = 0x00;          // Zera o registrador do timer0
	CLRF       TMR0+0
;PWM_16F18855T.c,109 :: 		TMR0IE_bit = 0x01;    // Ativa interrupcao por overflow do TMR0
	BSF        TMR0IE_bit+0, BitPos(TMR0IE_bit+0)
;PWM_16F18855T.c,111 :: 		setDutyPercent(dutySelect_I + dutySelect_F / 10);
	MOVLW      10
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	MOVF       _dutySelect_F+0, 0
	MOVWF      R0
	MOVF       _dutySelect_F+1, 0
	MOVWF      R1
	CALL       _Div_16x16_S+0
	MOVF       _dutySelect_I+0, 0
	ADDWF      R0, 1
	MOVF       _dutySelect_I+1, 0
	ADDWFC     R1, 1
	CALL       _int2double+0
	MOVF       R0, 0
	MOVWF      FARG_setDutyPercent_dutyp+0
	MOVF       R1, 0
	MOVWF      FARG_setDutyPercent_dutyp+1
	MOVF       R2, 0
	MOVWF      FARG_setDutyPercent_dutyp+2
	MOVF       R3, 0
	MOVWF      FARG_setDutyPercent_dutyp+3
	CALL       _setDutyPercent+0
;PWM_16F18855T.c,112 :: 		setFreq(freqSelect);
	MOVF       _freqSelect+0, 0
	MOVWF      FARG_setFreq_freq+0
	MOVF       _freqSelect+1, 0
	MOVWF      FARG_setFreq_freq+1
	CALL       _setFreq+0
;PWM_16F18855T.c,114 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;PWM_16F18855T.c,115 :: 		defCustomChar();
	CALL       _defCustomChar+0
;PWM_16F18855T.c,116 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;PWM_16F18855T.c,117 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;PWM_16F18855T.c,118 :: 		Lcd_Out(1,1,"  PWM Gen v2.0  ");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr1_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,119 :: 		Lcd_Out(2,1," 5 Freq./10bits ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr2_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,120 :: 		delay_ms(3000);
	MOVLW      77
	MOVWF      R11
	MOVLW      25
	MOVWF      R12
	MOVLW      79
	MOVWF      R13
L_main2:
	DECFSZ     R13, 1
	GOTO       L_main2
	DECFSZ     R12, 1
	GOTO       L_main2
	DECFSZ     R11, 1
	GOTO       L_main2
	NOP
	NOP
;PWM_16F18855T.c,122 :: 		while(1)
L_main3:
;PWM_16F18855T.c,124 :: 		telaPrincipal();
	CALL       _telaPrincipal+0
;PWM_16F18855T.c,125 :: 		checkChgFreq();
	CALL       _checkChgFreq+0
;PWM_16F18855T.c,126 :: 		checkChgDuty();
	CALL       _checkChgDuty+0
;PWM_16F18855T.c,127 :: 		checkOut();
	CALL       _checkOut+0
;PWM_16F18855T.c,128 :: 		fineAdj();
	CALL       _fineAdj+0
;PWM_16F18855T.c,129 :: 		delay_ms(1);
	MOVLW      7
	MOVWF      R12
	MOVLW      125
	MOVWF      R13
L_main5:
	DECFSZ     R13, 1
	GOTO       L_main5
	DECFSZ     R12, 1
	GOTO       L_main5
;PWM_16F18855T.c,130 :: 		}
	GOTO       L_main3
;PWM_16F18855T.c,131 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_defCustomChar:

;PWM_16F18855T.c,132 :: 		void defCustomChar()
;PWM_16F18855T.c,134 :: 		Lcd_Cmd(64);
	MOVLW      64
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;PWM_16F18855T.c,135 :: 		Lcd_Chr_CP(0b00011111);
	MOVLW      31
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,136 :: 		Lcd_Chr_CP(0b00010001);
	MOVLW      17
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,137 :: 		Lcd_Chr_CP(0b00011011);
	MOVLW      27
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,138 :: 		Lcd_Chr_CP(0b00011011);
	MOVLW      27
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,139 :: 		Lcd_Chr_CP(0b00011011);
	MOVLW      27
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,140 :: 		Lcd_Chr_CP(0b00011011);
	MOVLW      27
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,141 :: 		Lcd_Chr_CP(0b00011111);
	MOVLW      31
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,142 :: 		Lcd_Chr_CP(0b00000000);
	CLRF       FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,144 :: 		Lcd_Chr_CP(0b00011111);
	MOVLW      31
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,145 :: 		Lcd_Chr_CP(0b00010001);
	MOVLW      17
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,146 :: 		Lcd_Chr_CP(0b00010111);
	MOVLW      23
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,147 :: 		Lcd_Chr_CP(0b00010011);
	MOVLW      19
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,148 :: 		Lcd_Chr_CP(0b00010111);
	MOVLW      23
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,149 :: 		Lcd_Chr_CP(0b00010111);
	MOVLW      23
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,150 :: 		Lcd_Chr_CP(0b00011111);
	MOVLW      31
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,151 :: 		Lcd_Chr_CP(0b00000000);
	CLRF       FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,152 :: 		}
L_end_defCustomChar:
	RETURN
; end of _defCustomChar

_telaPrincipal:

;PWM_16F18855T.c,154 :: 		void telaPrincipal()
;PWM_16F18855T.c,156 :: 		Lcd_Out(1,2,"Duty   ");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr3_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,158 :: 		if (dutySelect_I < 10)
	MOVLW      128
	XORWF      _dutySelect_I+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__telaPrincipal112
	MOVLW      10
	SUBWF      _dutySelect_I+0, 0
L__telaPrincipal112:
	BTFSC      STATUS+0, 0
	GOTO       L_telaPrincipal6
;PWM_16F18855T.c,159 :: 		Lcd_Chr_Cp(' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
L_telaPrincipal6:
;PWM_16F18855T.c,160 :: 		if (dutySelect_I < 100)
	MOVLW      128
	XORWF      _dutySelect_I+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__telaPrincipal113
	MOVLW      100
	SUBWF      _dutySelect_I+0, 0
L__telaPrincipal113:
	BTFSC      STATUS+0, 0
	GOTO       L_telaPrincipal7
;PWM_16F18855T.c,161 :: 		Lcd_Chr_Cp(' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
L_telaPrincipal7:
;PWM_16F18855T.c,162 :: 		disp_number(dutySelect_I);
	MOVF       _dutySelect_I+0, 0
	MOVWF      FARG_disp_number_num+0
	MOVF       _dutySelect_I+1, 0
	MOVWF      FARG_disp_number_num+1
	CALL       _disp_number+0
;PWM_16F18855T.c,163 :: 		Lcd_Chr_Cp('.');
	MOVLW      46
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,164 :: 		disp_number(dutySelect_F);
	MOVF       _dutySelect_F+0, 0
	MOVWF      FARG_disp_number_num+0
	MOVF       _dutySelect_F+1, 0
	MOVWF      FARG_disp_number_num+1
	CALL       _disp_number+0
;PWM_16F18855T.c,165 :: 		Lcd_Chr_Cp('%');
	MOVLW      37
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,166 :: 		Lcd_Chr_Cp(' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,169 :: 		if (fine)
	MOVF       _fine+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_telaPrincipal8
;PWM_16F18855T.c,170 :: 		Lcd_Chr_Cp(1);
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
	GOTO       L_telaPrincipal9
L_telaPrincipal8:
;PWM_16F18855T.c,172 :: 		Lcd_Chr_Cp(' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
L_telaPrincipal9:
;PWM_16F18855T.c,174 :: 		Lcd_Out(2,2,"Freq ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr4_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr4_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,175 :: 		switch(freqSelect)
	GOTO       L_telaPrincipal10
;PWM_16F18855T.c,177 :: 		case 1:
L_telaPrincipal12:
;PWM_16F18855T.c,178 :: 		Lcd_Out(2, 7, " 1.22KHz ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr5_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr5_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,179 :: 		break;
	GOTO       L_telaPrincipal11
;PWM_16F18855T.c,180 :: 		case 2:
L_telaPrincipal13:
;PWM_16F18855T.c,181 :: 		Lcd_Out(2, 7, " 2.44KHz ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr6_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr6_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,182 :: 		break;
	GOTO       L_telaPrincipal11
;PWM_16F18855T.c,183 :: 		case 3:
L_telaPrincipal14:
;PWM_16F18855T.c,184 :: 		Lcd_Out(2, 7, " 4.88KHz ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr7_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr7_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,185 :: 		break;
	GOTO       L_telaPrincipal11
;PWM_16F18855T.c,186 :: 		case 4:
L_telaPrincipal15:
;PWM_16F18855T.c,187 :: 		Lcd_Out(2, 7, " 9.76KHz ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr8_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr8_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,188 :: 		break;
	GOTO       L_telaPrincipal11
;PWM_16F18855T.c,189 :: 		case 5:
L_telaPrincipal16:
;PWM_16F18855T.c,190 :: 		Lcd_Out(2, 7, "19.53KHz ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr9_PWM_16F18855T+0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      hi_addr(?lstr9_PWM_16F18855T+0)
	MOVWF      FARG_Lcd_Out_text+1
	CALL       _Lcd_Out+0
;PWM_16F18855T.c,191 :: 		break;
	GOTO       L_telaPrincipal11
;PWM_16F18855T.c,192 :: 		}
L_telaPrincipal10:
	MOVLW      0
	XORWF      _freqSelect+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__telaPrincipal114
	MOVLW      1
	XORWF      _freqSelect+0, 0
L__telaPrincipal114:
	BTFSC      STATUS+0, 2
	GOTO       L_telaPrincipal12
	MOVLW      0
	XORWF      _freqSelect+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__telaPrincipal115
	MOVLW      2
	XORWF      _freqSelect+0, 0
L__telaPrincipal115:
	BTFSC      STATUS+0, 2
	GOTO       L_telaPrincipal13
	MOVLW      0
	XORWF      _freqSelect+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__telaPrincipal116
	MOVLW      3
	XORWF      _freqSelect+0, 0
L__telaPrincipal116:
	BTFSC      STATUS+0, 2
	GOTO       L_telaPrincipal14
	MOVLW      0
	XORWF      _freqSelect+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__telaPrincipal117
	MOVLW      4
	XORWF      _freqSelect+0, 0
L__telaPrincipal117:
	BTFSC      STATUS+0, 2
	GOTO       L_telaPrincipal15
	MOVLW      0
	XORWF      _freqSelect+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__telaPrincipal118
	MOVLW      5
	XORWF      _freqSelect+0, 0
L__telaPrincipal118:
	BTFSC      STATUS+0, 2
	GOTO       L_telaPrincipal16
L_telaPrincipal11:
;PWM_16F18855T.c,193 :: 		if (outSelect)
	MOVF       _outSelect+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_telaPrincipal17
;PWM_16F18855T.c,194 :: 		Lcd_Chr_Cp(0);
	CLRF       FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
	GOTO       L_telaPrincipal18
L_telaPrincipal17:
;PWM_16F18855T.c,196 :: 		Lcd_Chr_Cp(' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
L_telaPrincipal18:
;PWM_16F18855T.c,197 :: 		}
L_end_telaPrincipal:
	RETURN
; end of _telaPrincipal

_checkOut:

;PWM_16F18855T.c,199 :: 		void checkOut()
;PWM_16F18855T.c,201 :: 		if (bt1 == 0)
	BTFSC      RA2_bit+0, BitPos(RA2_bit+0)
	GOTO       L_checkOut19
;PWM_16F18855T.c,202 :: 		flags |= (1<<1);
	BSF        _flags+0, 1
L_checkOut19:
;PWM_16F18855T.c,203 :: 		if ((bt1 == 1) && (flags&(1<<1)))
	BTFSS      RA2_bit+0, BitPos(RA2_bit+0)
	GOTO       L_checkOut22
	BTFSS      _flags+0, 1
	GOTO       L_checkOut22
L__checkOut98:
;PWM_16F18855T.c,205 :: 		flags &= ~(1<<1);
	BCF        _flags+0, 1
;PWM_16F18855T.c,206 :: 		delay_ms(180);
	MOVLW      5
	MOVWF      R11
	MOVLW      145
	MOVWF      R12
	MOVLW      207
	MOVWF      R13
L_checkOut23:
	DECFSZ     R13, 1
	GOTO       L_checkOut23
	DECFSZ     R12, 1
	GOTO       L_checkOut23
	DECFSZ     R11, 1
	GOTO       L_checkOut23
	NOP
	NOP
;PWM_16F18855T.c,207 :: 		if (outSelect)
	MOVF       _outSelect+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_checkOut24
;PWM_16F18855T.c,209 :: 		outSelect = 0;
	CLRF       _outSelect+0
;PWM_16F18855T.c,210 :: 		PWM6CON &= ~(1<<PWM6EN);
	BCF        PWM6CON+0, 7
;PWM_16F18855T.c,211 :: 		TRISC2_bit = 1;
	BSF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;PWM_16F18855T.c,212 :: 		}
	GOTO       L_checkOut25
L_checkOut24:
;PWM_16F18855T.c,215 :: 		outSelect = 1;
	MOVLW      1
	MOVWF      _outSelect+0
;PWM_16F18855T.c,216 :: 		PWM6CON |= (1<<PWM6EN);
	BSF        PWM6CON+0, 7
;PWM_16F18855T.c,217 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;PWM_16F18855T.c,218 :: 		}
L_checkOut25:
;PWM_16F18855T.c,219 :: 		}
L_checkOut22:
;PWM_16F18855T.c,220 :: 		}
L_end_checkOut:
	RETURN
; end of _checkOut

_fineAdj:

;PWM_16F18855T.c,222 :: 		void fineAdj()
;PWM_16F18855T.c,224 :: 		if (bt2 == 0)
	BTFSC      RA3_bit+0, BitPos(RA3_bit+0)
	GOTO       L_fineAdj26
;PWM_16F18855T.c,225 :: 		flags |= (1<<2);
	BSF        _flags+0, 2
L_fineAdj26:
;PWM_16F18855T.c,226 :: 		if ((bt1 == 1) && (flags&(1<<2)))
	BTFSS      RA2_bit+0, BitPos(RA2_bit+0)
	GOTO       L_fineAdj29
	BTFSS      _flags+0, 2
	GOTO       L_fineAdj29
L__fineAdj99:
;PWM_16F18855T.c,228 :: 		flags &= ~(1<<2);
	BCF        _flags+0, 2
;PWM_16F18855T.c,229 :: 		delay_ms(180);
	MOVLW      5
	MOVWF      R11
	MOVLW      145
	MOVWF      R12
	MOVLW      207
	MOVWF      R13
L_fineAdj30:
	DECFSZ     R13, 1
	GOTO       L_fineAdj30
	DECFSZ     R12, 1
	GOTO       L_fineAdj30
	DECFSZ     R11, 1
	GOTO       L_fineAdj30
	NOP
	NOP
;PWM_16F18855T.c,230 :: 		fine = !fine;
	MOVF       _fine+0, 0
	MOVLW      1
	BTFSS      STATUS+0, 2
	MOVLW      0
	MOVWF      _fine+0
;PWM_16F18855T.c,231 :: 		}
L_fineAdj29:
;PWM_16F18855T.c,232 :: 		}
L_end_fineAdj:
	RETURN
; end of _fineAdj

_checkChgFreq:

;PWM_16F18855T.c,234 :: 		void checkChgFreq()
;PWM_16F18855T.c,236 :: 		if(bt0 == 0)
	BTFSC      RA4_bit+0, BitPos(RA4_bit+0)
	GOTO       L_checkChgFreq31
;PWM_16F18855T.c,237 :: 		flags |= (1<<0);
	BSF        _flags+0, 0
L_checkChgFreq31:
;PWM_16F18855T.c,238 :: 		if ((bt0 == 1) && (flags&(1<<0)))
	BTFSS      RA4_bit+0, BitPos(RA4_bit+0)
	GOTO       L_checkChgFreq34
	BTFSS      _flags+0, 0
	GOTO       L_checkChgFreq34
L__checkChgFreq100:
;PWM_16F18855T.c,240 :: 		flags &= ~(1<<0);
	BCF        _flags+0, 0
;PWM_16F18855T.c,241 :: 		delay_ms(180);
	MOVLW      5
	MOVWF      R11
	MOVLW      145
	MOVWF      R12
	MOVLW      207
	MOVWF      R13
L_checkChgFreq35:
	DECFSZ     R13, 1
	GOTO       L_checkChgFreq35
	DECFSZ     R12, 1
	GOTO       L_checkChgFreq35
	DECFSZ     R11, 1
	GOTO       L_checkChgFreq35
	NOP
	NOP
;PWM_16F18855T.c,243 :: 		if (freqSelect < 5)
	MOVLW      0
	SUBWF      _freqSelect+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkChgFreq122
	MOVLW      5
	SUBWF      _freqSelect+0, 0
L__checkChgFreq122:
	BTFSC      STATUS+0, 0
	GOTO       L_checkChgFreq36
;PWM_16F18855T.c,244 :: 		freqSelect++;
	INCF       _freqSelect+0, 1
	BTFSC      STATUS+0, 2
	INCF       _freqSelect+1, 1
	GOTO       L_checkChgFreq37
L_checkChgFreq36:
;PWM_16F18855T.c,246 :: 		freqSelect = 1;
	MOVLW      1
	MOVWF      _freqSelect+0
	MOVLW      0
	MOVWF      _freqSelect+1
L_checkChgFreq37:
;PWM_16F18855T.c,248 :: 		setFreq(freqSelect);
	MOVF       _freqSelect+0, 0
	MOVWF      FARG_setFreq_freq+0
	MOVF       _freqSelect+1, 0
	MOVWF      FARG_setFreq_freq+1
	CALL       _setFreq+0
;PWM_16F18855T.c,249 :: 		}
L_checkChgFreq34:
;PWM_16F18855T.c,250 :: 		}
L_end_checkChgFreq:
	RETURN
; end of _checkChgFreq

_checkChgDuty:

;PWM_16F18855T.c,252 :: 		void checkChgDuty()
;PWM_16F18855T.c,257 :: 		if ((dutySelectLast_I != dutySelect_I) || (dutySelectLast_F != dutySelect_F))
	MOVF       checkChgDuty_dutySelectLast_I_L0+1, 0
	XORWF      _dutySelect_I+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkChgDuty124
	MOVF       _dutySelect_I+0, 0
	XORWF      checkChgDuty_dutySelectLast_I_L0+0, 0
L__checkChgDuty124:
	BTFSS      STATUS+0, 2
	GOTO       L__checkChgDuty101
	MOVF       checkChgDuty_dutySelectLast_F_L0+1, 0
	XORWF      _dutySelect_F+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkChgDuty125
	MOVF       _dutySelect_F+0, 0
	XORWF      checkChgDuty_dutySelectLast_F_L0+0, 0
L__checkChgDuty125:
	BTFSS      STATUS+0, 2
	GOTO       L__checkChgDuty101
	GOTO       L_checkChgDuty40
L__checkChgDuty101:
;PWM_16F18855T.c,258 :: 		setDutyPercent(dutySelect_I + dutySelect_F / 10);
	MOVLW      10
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	MOVF       _dutySelect_F+0, 0
	MOVWF      R0
	MOVF       _dutySelect_F+1, 0
	MOVWF      R1
	CALL       _Div_16x16_S+0
	MOVF       _dutySelect_I+0, 0
	ADDWF      R0, 1
	MOVF       _dutySelect_I+1, 0
	ADDWFC     R1, 1
	CALL       _int2double+0
	MOVF       R0, 0
	MOVWF      FARG_setDutyPercent_dutyp+0
	MOVF       R1, 0
	MOVWF      FARG_setDutyPercent_dutyp+1
	MOVF       R2, 0
	MOVWF      FARG_setDutyPercent_dutyp+2
	MOVF       R3, 0
	MOVWF      FARG_setDutyPercent_dutyp+3
	CALL       _setDutyPercent+0
L_checkChgDuty40:
;PWM_16F18855T.c,259 :: 		}
L_end_checkChgDuty:
	RETURN
; end of _checkChgDuty

_read_encoder:

;PWM_16F18855T.c,262 :: 		void read_encoder()
;PWM_16F18855T.c,264 :: 		if(!enc_A)
	BTFSC      RC0_bit+0, BitPos(RC0_bit+0)
	GOTO       L_read_encoder41
;PWM_16F18855T.c,266 :: 		if(!flag_enc)
	MOVF       _flag_enc+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_read_encoder42
;PWM_16F18855T.c,268 :: 		flag_enc = 0x01;
	MOVLW      1
	MOVWF      _flag_enc+0
;PWM_16F18855T.c,269 :: 		if (fine)
	MOVF       _fine+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_read_encoder43
;PWM_16F18855T.c,271 :: 		if (dutySelect_F < 9 && dutySelect_I < 100)
	MOVLW      128
	XORWF      _dutySelect_F+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_encoder127
	MOVLW      9
	SUBWF      _dutySelect_F+0, 0
L__read_encoder127:
	BTFSC      STATUS+0, 0
	GOTO       L_read_encoder46
	MOVLW      128
	XORWF      _dutySelect_I+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_encoder128
	MOVLW      100
	SUBWF      _dutySelect_I+0, 0
L__read_encoder128:
	BTFSC      STATUS+0, 0
	GOTO       L_read_encoder46
L__read_encoder102:
;PWM_16F18855T.c,272 :: 		dutySelect_F++;
	INCF       _dutySelect_F+0, 1
	BTFSC      STATUS+0, 2
	INCF       _dutySelect_F+1, 1
	GOTO       L_read_encoder47
L_read_encoder46:
;PWM_16F18855T.c,275 :: 		if (dutySelect_I < 100)
	MOVLW      128
	XORWF      _dutySelect_I+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_encoder129
	MOVLW      100
	SUBWF      _dutySelect_I+0, 0
L__read_encoder129:
	BTFSC      STATUS+0, 0
	GOTO       L_read_encoder48
;PWM_16F18855T.c,277 :: 		dutySelect_I++;
	INCF       _dutySelect_I+0, 1
	BTFSC      STATUS+0, 2
	INCF       _dutySelect_I+1, 1
;PWM_16F18855T.c,278 :: 		dutySelect_F = 0;
	CLRF       _dutySelect_F+0
	CLRF       _dutySelect_F+1
;PWM_16F18855T.c,279 :: 		}
L_read_encoder48:
;PWM_16F18855T.c,280 :: 		}
L_read_encoder47:
;PWM_16F18855T.c,281 :: 		} else
	GOTO       L_read_encoder49
L_read_encoder43:
;PWM_16F18855T.c,283 :: 		dutySelect_F = 0;
	CLRF       _dutySelect_F+0
	CLRF       _dutySelect_F+1
;PWM_16F18855T.c,284 :: 		if (dutySelect_I < 100) dutySelect_I++;
	MOVLW      128
	XORWF      _dutySelect_I+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_encoder130
	MOVLW      100
	SUBWF      _dutySelect_I+0, 0
L__read_encoder130:
	BTFSC      STATUS+0, 0
	GOTO       L_read_encoder50
	INCF       _dutySelect_I+0, 1
	BTFSC      STATUS+0, 2
	INCF       _dutySelect_I+1, 1
L_read_encoder50:
;PWM_16F18855T.c,285 :: 		}
L_read_encoder49:
;PWM_16F18855T.c,286 :: 		}
L_read_encoder42:
;PWM_16F18855T.c,287 :: 		}
	GOTO       L_read_encoder51
L_read_encoder41:
;PWM_16F18855T.c,290 :: 		if(!enc_B)
	BTFSC      RC1_bit+0, BitPos(RC1_bit+0)
	GOTO       L_read_encoder52
;PWM_16F18855T.c,292 :: 		if(!flag_enc)
	MOVF       _flag_enc+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_read_encoder53
;PWM_16F18855T.c,294 :: 		flag_enc = 0x01;
	MOVLW      1
	MOVWF      _flag_enc+0
;PWM_16F18855T.c,295 :: 		if (fine)
	MOVF       _fine+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_read_encoder54
;PWM_16F18855T.c,297 :: 		if (dutySelect_F > 0)
	MOVLW      128
	MOVWF      R0
	MOVLW      128
	XORWF      _dutySelect_F+1, 0
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_encoder131
	MOVF       _dutySelect_F+0, 0
	SUBLW      0
L__read_encoder131:
	BTFSC      STATUS+0, 0
	GOTO       L_read_encoder55
;PWM_16F18855T.c,298 :: 		dutySelect_F--;
	MOVLW      1
	SUBWF      _dutySelect_F+0, 1
	MOVLW      0
	SUBWFB     _dutySelect_F+1, 1
	GOTO       L_read_encoder56
L_read_encoder55:
;PWM_16F18855T.c,301 :: 		if (dutySelect_I > 0)
	MOVLW      128
	MOVWF      R0
	MOVLW      128
	XORWF      _dutySelect_I+1, 0
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_encoder132
	MOVF       _dutySelect_I+0, 0
	SUBLW      0
L__read_encoder132:
	BTFSC      STATUS+0, 0
	GOTO       L_read_encoder57
;PWM_16F18855T.c,303 :: 		dutySelect_I--;
	MOVLW      1
	SUBWF      _dutySelect_I+0, 1
	MOVLW      0
	SUBWFB     _dutySelect_I+1, 1
;PWM_16F18855T.c,304 :: 		dutySelect_F = 9;
	MOVLW      9
	MOVWF      _dutySelect_F+0
	MOVLW      0
	MOVWF      _dutySelect_F+1
;PWM_16F18855T.c,305 :: 		}
L_read_encoder57:
;PWM_16F18855T.c,306 :: 		}
L_read_encoder56:
;PWM_16F18855T.c,307 :: 		} else
	GOTO       L_read_encoder58
L_read_encoder54:
;PWM_16F18855T.c,309 :: 		dutySelect_F = 0;
	CLRF       _dutySelect_F+0
	CLRF       _dutySelect_F+1
;PWM_16F18855T.c,310 :: 		if (dutySelect_I > 0) dutySelect_I--;
	MOVLW      128
	MOVWF      R0
	MOVLW      128
	XORWF      _dutySelect_I+1, 0
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__read_encoder133
	MOVF       _dutySelect_I+0, 0
	SUBLW      0
L__read_encoder133:
	BTFSC      STATUS+0, 0
	GOTO       L_read_encoder59
	MOVLW      1
	SUBWF      _dutySelect_I+0, 1
	MOVLW      0
	SUBWFB     _dutySelect_I+1, 1
L_read_encoder59:
;PWM_16F18855T.c,311 :: 		}
L_read_encoder58:
;PWM_16F18855T.c,313 :: 		}
L_read_encoder53:
;PWM_16F18855T.c,314 :: 		}
L_read_encoder52:
;PWM_16F18855T.c,316 :: 		}
L_read_encoder51:
;PWM_16F18855T.c,318 :: 		if(enc_A)
	BTFSS      RC0_bit+0, BitPos(RC0_bit+0)
	GOTO       L_read_encoder60
;PWM_16F18855T.c,320 :: 		if(enc_B) flag_enc = 0x00;
	BTFSS      RC1_bit+0, BitPos(RC1_bit+0)
	GOTO       L_read_encoder61
	CLRF       _flag_enc+0
L_read_encoder61:
;PWM_16F18855T.c,322 :: 		}
L_read_encoder60:
;PWM_16F18855T.c,324 :: 		}
L_end_read_encoder:
	RETURN
; end of _read_encoder

_setDuty:

;PWM_16F18855T.c,326 :: 		void setDuty(unsigned duty)
;PWM_16F18855T.c,331 :: 		switch(dutySelect_I)
	GOTO       L_setDuty62
;PWM_16F18855T.c,333 :: 		case 0:
L_setDuty64:
;PWM_16F18855T.c,334 :: 		PWM6DCH = 0x00;
	CLRF       PWM6DCH+0
;PWM_16F18855T.c,335 :: 		PWM6DCL = 0x00;
	CLRF       PWM6DCL+0
;PWM_16F18855T.c,336 :: 		break;
	GOTO       L_setDuty63
;PWM_16F18855T.c,337 :: 		case 100:
L_setDuty65:
;PWM_16F18855T.c,338 :: 		PWM6DCH = 0xFF;
	MOVLW      255
	MOVWF      PWM6DCH+0
;PWM_16F18855T.c,339 :: 		PWM6DCL = 0xFF;
	MOVLW      255
	MOVWF      PWM6DCL+0
;PWM_16F18855T.c,340 :: 		break;
	GOTO       L_setDuty63
;PWM_16F18855T.c,341 :: 		default:
L_setDuty66:
;PWM_16F18855T.c,342 :: 		PWM6DCH = 0xFF & (duty>>2);
	MOVF       FARG_setDuty_duty+0, 0
	MOVWF      R0
	MOVF       FARG_setDuty_duty+1, 0
	MOVWF      R1
	LSRF       R1, 1
	RRF        R0, 1
	LSRF       R1, 1
	RRF        R0, 1
	MOVLW      255
	ANDWF      R0, 0
	MOVWF      PWM6DCH+0
;PWM_16F18855T.c,344 :: 		if(duty&0x02)
	BTFSS      FARG_setDuty_duty+0, 1
	GOTO       L_setDuty67
;PWM_16F18855T.c,345 :: 		PWM6DCL |=  (1<<PWM6DC1);
	BSF        PWM6DCL+0, 7
	GOTO       L_setDuty68
L_setDuty67:
;PWM_16F18855T.c,347 :: 		PWM6DCL &= ~(1<<PWM6DC1);
	BCF        PWM6DCL+0, 7
L_setDuty68:
;PWM_16F18855T.c,349 :: 		if(duty&0x01)
	BTFSS      FARG_setDuty_duty+0, 0
	GOTO       L_setDuty69
;PWM_16F18855T.c,350 :: 		PWM6DCL |=  (1<<PWM6DC0);
	BSF        PWM6DCL+0, 6
	GOTO       L_setDuty70
L_setDuty69:
;PWM_16F18855T.c,352 :: 		PWM6DCL &= ~(1<<PWM6DC0);
	BCF        PWM6DCL+0, 6
L_setDuty70:
;PWM_16F18855T.c,353 :: 		}
	GOTO       L_setDuty63
L_setDuty62:
	MOVLW      0
	XORWF      _dutySelect_I+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__setDuty135
	MOVLW      0
	XORWF      _dutySelect_I+0, 0
L__setDuty135:
	BTFSC      STATUS+0, 2
	GOTO       L_setDuty64
	MOVLW      0
	XORWF      _dutySelect_I+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__setDuty136
	MOVLW      100
	XORWF      _dutySelect_I+0, 0
L__setDuty136:
	BTFSC      STATUS+0, 2
	GOTO       L_setDuty65
	GOTO       L_setDuty66
L_setDuty63:
;PWM_16F18855T.c,354 :: 		}
L_end_setDuty:
	RETURN
; end of _setDuty

_setFreq:

;PWM_16F18855T.c,356 :: 		void setFreq(unsigned freq)
;PWM_16F18855T.c,358 :: 		switch(freq)
	GOTO       L_setFreq71
;PWM_16F18855T.c,360 :: 		case 1:
L_setFreq73:
;PWM_16F18855T.c,362 :: 		T2CKPS2_bit = 1;
	BSF        T2CKPS2_bit+0, BitPos(T2CKPS2_bit+0)
;PWM_16F18855T.c,363 :: 		T2CKPS1_bit = 0;
	BCF        T2CKPS1_bit+0, BitPos(T2CKPS1_bit+0)
;PWM_16F18855T.c,364 :: 		T2CKPS0_bit = 0;
	BCF        T2CKPS0_bit+0, BitPos(T2CKPS0_bit+0)
;PWM_16F18855T.c,365 :: 		break;
	GOTO       L_setFreq72
;PWM_16F18855T.c,366 :: 		case 2:
L_setFreq74:
;PWM_16F18855T.c,368 :: 		T2CKPS2_bit = 0;
	BCF        T2CKPS2_bit+0, BitPos(T2CKPS2_bit+0)
;PWM_16F18855T.c,369 :: 		T2CKPS1_bit = 1;
	BSF        T2CKPS1_bit+0, BitPos(T2CKPS1_bit+0)
;PWM_16F18855T.c,370 :: 		T2CKPS0_bit = 1;
	BSF        T2CKPS0_bit+0, BitPos(T2CKPS0_bit+0)
;PWM_16F18855T.c,371 :: 		break;
	GOTO       L_setFreq72
;PWM_16F18855T.c,372 :: 		case 3:
L_setFreq75:
;PWM_16F18855T.c,374 :: 		T2CKPS2_bit = 0;
	BCF        T2CKPS2_bit+0, BitPos(T2CKPS2_bit+0)
;PWM_16F18855T.c,375 :: 		T2CKPS1_bit = 1;
	BSF        T2CKPS1_bit+0, BitPos(T2CKPS1_bit+0)
;PWM_16F18855T.c,376 :: 		T2CKPS0_bit = 0;
	BCF        T2CKPS0_bit+0, BitPos(T2CKPS0_bit+0)
;PWM_16F18855T.c,377 :: 		break;
	GOTO       L_setFreq72
;PWM_16F18855T.c,378 :: 		case 4:
L_setFreq76:
;PWM_16F18855T.c,380 :: 		T2CKPS2_bit = 0;
	BCF        T2CKPS2_bit+0, BitPos(T2CKPS2_bit+0)
;PWM_16F18855T.c,381 :: 		T2CKPS1_bit = 0;
	BCF        T2CKPS1_bit+0, BitPos(T2CKPS1_bit+0)
;PWM_16F18855T.c,382 :: 		T2CKPS0_bit = 1;
	BSF        T2CKPS0_bit+0, BitPos(T2CKPS0_bit+0)
;PWM_16F18855T.c,383 :: 		break;
	GOTO       L_setFreq72
;PWM_16F18855T.c,384 :: 		case 5:
L_setFreq77:
;PWM_16F18855T.c,386 :: 		T2CKPS2_bit = 0;
	BCF        T2CKPS2_bit+0, BitPos(T2CKPS2_bit+0)
;PWM_16F18855T.c,387 :: 		T2CKPS1_bit = 0;
	BCF        T2CKPS1_bit+0, BitPos(T2CKPS1_bit+0)
;PWM_16F18855T.c,388 :: 		T2CKPS0_bit = 0;
	BCF        T2CKPS0_bit+0, BitPos(T2CKPS0_bit+0)
;PWM_16F18855T.c,389 :: 		break;
	GOTO       L_setFreq72
;PWM_16F18855T.c,390 :: 		}
L_setFreq71:
	MOVLW      0
	XORWF      FARG_setFreq_freq+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__setFreq138
	MOVLW      1
	XORWF      FARG_setFreq_freq+0, 0
L__setFreq138:
	BTFSC      STATUS+0, 2
	GOTO       L_setFreq73
	MOVLW      0
	XORWF      FARG_setFreq_freq+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__setFreq139
	MOVLW      2
	XORWF      FARG_setFreq_freq+0, 0
L__setFreq139:
	BTFSC      STATUS+0, 2
	GOTO       L_setFreq74
	MOVLW      0
	XORWF      FARG_setFreq_freq+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__setFreq140
	MOVLW      3
	XORWF      FARG_setFreq_freq+0, 0
L__setFreq140:
	BTFSC      STATUS+0, 2
	GOTO       L_setFreq75
	MOVLW      0
	XORWF      FARG_setFreq_freq+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__setFreq141
	MOVLW      4
	XORWF      FARG_setFreq_freq+0, 0
L__setFreq141:
	BTFSC      STATUS+0, 2
	GOTO       L_setFreq76
	MOVLW      0
	XORWF      FARG_setFreq_freq+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__setFreq142
	MOVLW      5
	XORWF      FARG_setFreq_freq+0, 0
L__setFreq142:
	BTFSC      STATUS+0, 2
	GOTO       L_setFreq77
L_setFreq72:
;PWM_16F18855T.c,391 :: 		}
L_end_setFreq:
	RETURN
; end of _setFreq

_setDutyPercent:

;PWM_16F18855T.c,393 :: 		void setDutyPercent(float dutyp)
;PWM_16F18855T.c,396 :: 		duty = (int)(dutyp * 10.23);
	MOVF       FARG_setDutyPercent_dutyp+0, 0
	MOVWF      R0
	MOVF       FARG_setDutyPercent_dutyp+1, 0
	MOVWF      R1
	MOVF       FARG_setDutyPercent_dutyp+2, 0
	MOVWF      R2
	MOVF       FARG_setDutyPercent_dutyp+3, 0
	MOVWF      R3
	MOVLW      20
	MOVWF      R4
	MOVLW      174
	MOVWF      R5
	MOVLW      35
	MOVWF      R6
	MOVLW      130
	MOVWF      R7
	CALL       _Mul_32x32_FP+0
	CALL       _double2int+0
;PWM_16F18855T.c,397 :: 		setDuty(duty);
	MOVF       R0, 0
	MOVWF      FARG_setDuty_duty+0
	MOVF       R1, 0
	MOVWF      FARG_setDuty_duty+1
	CALL       _setDuty+0
;PWM_16F18855T.c,398 :: 		}
L_end_setDutyPercent:
	RETURN
; end of _setDutyPercent

_disp_number:

;PWM_16F18855T.c,400 :: 		void disp_number(unsigned num)
;PWM_16F18855T.c,403 :: 		short  no_zero = 0;
	CLRF       disp_number_no_zero_L0+0
;PWM_16F18855T.c,405 :: 		dem = (char)(num/10000);
	MOVLW      16
	MOVWF      R4
	MOVLW      39
	MOVWF      R5
	MOVF       FARG_disp_number_num+0, 0
	MOVWF      R0
	MOVF       FARG_disp_number_num+1, 0
	MOVWF      R1
	CALL       _Div_16X16_U+0
	MOVF       R0, 0
	MOVWF      FLOC__disp_number+0
	MOVF       R1, 0
	MOVWF      FLOC__disp_number+1
	MOVF       FLOC__disp_number+0, 0
	MOVWF      disp_number_dem_L0+0
;PWM_16F18855T.c,406 :: 		mil = (char)(num%10000/1000);
	MOVLW      16
	MOVWF      R4
	MOVLW      39
	MOVWF      R5
	MOVF       FARG_disp_number_num+0, 0
	MOVWF      R0
	MOVF       FARG_disp_number_num+1, 0
	MOVWF      R1
	CALL       _Div_16X16_U+0
	MOVF       R8, 0
	MOVWF      R0
	MOVF       R9, 0
	MOVWF      R1
	MOVLW      232
	MOVWF      R4
	MOVLW      3
	MOVWF      R5
	CALL       _Div_16X16_U+0
	MOVF       R0, 0
	MOVWF      disp_number_mil_L0+0
;PWM_16F18855T.c,407 :: 		cen = (char)(num%1000/100);
	MOVLW      232
	MOVWF      R4
	MOVLW      3
	MOVWF      R5
	MOVF       FARG_disp_number_num+0, 0
	MOVWF      R0
	MOVF       FARG_disp_number_num+1, 0
	MOVWF      R1
	CALL       _Div_16X16_U+0
	MOVF       R8, 0
	MOVWF      R0
	MOVF       R9, 0
	MOVWF      R1
	MOVLW      100
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	CALL       _Div_16X16_U+0
	MOVF       R0, 0
	MOVWF      disp_number_cen_L0+0
;PWM_16F18855T.c,408 :: 		dez = (char)(num%100/10);
	MOVLW      100
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	MOVF       FARG_disp_number_num+0, 0
	MOVWF      R0
	MOVF       FARG_disp_number_num+1, 0
	MOVWF      R1
	CALL       _Div_16X16_U+0
	MOVF       R8, 0
	MOVWF      R0
	MOVF       R9, 0
	MOVWF      R1
	MOVLW      10
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	CALL       _Div_16X16_U+0
	MOVF       R0, 0
	MOVWF      disp_number_dez_L0+0
;PWM_16F18855T.c,409 :: 		uni = (char)(num%10);
	MOVLW      10
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	MOVF       FARG_disp_number_num+0, 0
	MOVWF      R0
	MOVF       FARG_disp_number_num+1, 0
	MOVWF      R1
	CALL       _Div_16X16_U+0
	MOVF       R8, 0
	MOVWF      R0
	MOVF       R9, 0
	MOVWF      R1
	MOVF       R0, 0
	MOVWF      disp_number_uni_L0+0
;PWM_16F18855T.c,411 :: 		if(!dem && !no_zero)
	MOVF       FLOC__disp_number+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number80
	MOVF       disp_number_no_zero_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number80
L__disp_number106:
;PWM_16F18855T.c,412 :: 		delay_ms(1);
	MOVLW      7
	MOVWF      R12
	MOVLW      125
	MOVWF      R13
L_disp_number81:
	DECFSZ     R13, 1
	GOTO       L_disp_number81
	DECFSZ     R12, 1
	GOTO       L_disp_number81
	GOTO       L_disp_number82
L_disp_number80:
;PWM_16F18855T.c,415 :: 		Lcd_Chr_Cp(dem+0x30);
	MOVLW      48
	ADDWF      disp_number_dem_L0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,416 :: 		no_zero = 1;
	MOVLW      1
	MOVWF      disp_number_no_zero_L0+0
;PWM_16F18855T.c,417 :: 		}
L_disp_number82:
;PWM_16F18855T.c,419 :: 		if(!mil && !no_zero)
	MOVF       disp_number_mil_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number85
	MOVF       disp_number_no_zero_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number85
L__disp_number105:
;PWM_16F18855T.c,420 :: 		delay_ms(1);
	MOVLW      7
	MOVWF      R12
	MOVLW      125
	MOVWF      R13
L_disp_number86:
	DECFSZ     R13, 1
	GOTO       L_disp_number86
	DECFSZ     R12, 1
	GOTO       L_disp_number86
	GOTO       L_disp_number87
L_disp_number85:
;PWM_16F18855T.c,423 :: 		Lcd_Chr_Cp(mil+0x30);
	MOVLW      48
	ADDWF      disp_number_mil_L0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,424 :: 		no_zero = 1;
	MOVLW      1
	MOVWF      disp_number_no_zero_L0+0
;PWM_16F18855T.c,425 :: 		}
L_disp_number87:
;PWM_16F18855T.c,427 :: 		if(!cen && !no_zero)
	MOVF       disp_number_cen_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number90
	MOVF       disp_number_no_zero_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number90
L__disp_number104:
;PWM_16F18855T.c,428 :: 		delay_ms(1);
	MOVLW      7
	MOVWF      R12
	MOVLW      125
	MOVWF      R13
L_disp_number91:
	DECFSZ     R13, 1
	GOTO       L_disp_number91
	DECFSZ     R12, 1
	GOTO       L_disp_number91
	GOTO       L_disp_number92
L_disp_number90:
;PWM_16F18855T.c,431 :: 		Lcd_Chr_Cp(cen+0x30);
	MOVLW      48
	ADDWF      disp_number_cen_L0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,432 :: 		no_zero = 1;
	MOVLW      1
	MOVWF      disp_number_no_zero_L0+0
;PWM_16F18855T.c,433 :: 		}
L_disp_number92:
;PWM_16F18855T.c,435 :: 		if(!dez && !no_zero)
	MOVF       disp_number_dez_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number95
	MOVF       disp_number_no_zero_L0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_disp_number95
L__disp_number103:
;PWM_16F18855T.c,436 :: 		delay_ms(1);
	MOVLW      7
	MOVWF      R12
	MOVLW      125
	MOVWF      R13
L_disp_number96:
	DECFSZ     R13, 1
	GOTO       L_disp_number96
	DECFSZ     R12, 1
	GOTO       L_disp_number96
	GOTO       L_disp_number97
L_disp_number95:
;PWM_16F18855T.c,439 :: 		Lcd_Chr_Cp(dez+0x30);
	MOVLW      48
	ADDWF      disp_number_dez_L0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,440 :: 		no_zero = 1;
	MOVLW      1
	MOVWF      disp_number_no_zero_L0+0
;PWM_16F18855T.c,441 :: 		}
L_disp_number97:
;PWM_16F18855T.c,443 :: 		Lcd_Chr_Cp(uni+0x30);
	MOVLW      48
	ADDWF      disp_number_uni_L0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;PWM_16F18855T.c,444 :: 		}
L_end_disp_number:
	RETURN
; end of _disp_number
