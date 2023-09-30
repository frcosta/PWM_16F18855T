// LCD module connections
sbit LCD_RS at RB0_bit;
sbit LCD_EN at RB1_bit;
sbit LCD_D4 at RB2_bit;
sbit LCD_D5 at RB3_bit;
sbit LCD_D6 at RB4_bit;
sbit LCD_D7 at RB5_bit;

sbit LCD_RS_Direction at TRISB0_bit;
sbit LCD_EN_Direction at TRISB1_bit;
sbit LCD_D4_Direction at TRISB2_bit;
sbit LCD_D5_Direction at TRISB3_bit;
sbit LCD_D6_Direction at TRISB4_bit;
sbit LCD_D7_Direction at TRISB5_bit;


// Mapeamento de pinos PIC16F18855

#define bt1       RA2_bit    // Input  -> Output Enable
#define bt2       RA3_bit    // Input  -> Ajuste Fino
#define bt0       RA4_bit    // Input  -> Troca de Frequencia

#define enc_A     RC0_bit    // Input  -> Encoder rotativo
#define enc_B     RC1_bit    // Input  -> Encoder rotativo
#define saida_PWM RC2_bit    // Output -> Saida do sinal PWM


// --- Prototipo de Funcoes ---
void defCustomChar();
void read_encoder();
void setDuty(unsigned duty);
void setFreq(unsigned freq);
void setDutyPercent(float dutyp);
void disp_number(unsigned num);
void telaPrincipal();
void checkChgFreq();
void checkOut();
void fineAdj();
void checkChgDuty();

// Variaveis Globais
char fine = 1;
char outSelect = 0;
char flags = 0;
char flag_dutySelect = 1;
unsigned char flag_enc   = 0x01;
unsigned freqSelect = 1;
int dutySelect_I = 50;
int dutySelect_F = 0;
char control_T0 = 0x00;


void interrupt()
{
   if (TMR0IF_bit)
   {
      TMR0IF_bit = 0x00;
      control_T0 += 0x01;

      if (control_T0 == 0x64)
      {
         control_T0 == 0x00;
         read_encoder();
      }
   }
}


void main() {
     // Configuracoes de Portas de Entrada e Saida
     TRISA2_bit = 0;       // bt0 - Troca de Frequencia
     TRISA3_bit = 0;       // bt1 - Output Enable
     TRISA4_bit = 0;       // bt2 - Ajuste fino de duty cycle
     TRISB = 0x00;         // Display LCD
     //TRISC2_bit = 1;       // Desabilita saida PWM
     
     ANSELA = 0x00;        // Desabilita Entradas Analogicas nos pinos RA
     ANSELB = 0x00;        //Desabilita Entradas Analogicas nos pinos RB
     ANSELC = 0x00;        // Desabilita Entradas Analogicas nos pinos RC
     
     PORTB = 0x00;         // Habilita todo o PORTB como saida digital

     // Configuracoes do PWM
     PWM6POL_bit = 0;      // Configure the PWM output polarity by configuring the PWMxPOL bit of the PWMxCON register
     PR2 = 0xFF;           // Load the PR2 register with the PWM period value
     //PWM6DCH = 0x80;       // PWMxDCH contains the eight MSbs
     //PWM6DCL = 0x00;       // PWMxDCL<7:6> bits contain the two LSbs

     // Roteamento de saida do sinal de PWM
     RC2PPS = 0x0E;        // Roteamento de saida do device PWM6 para o pino RC2

     
     // Configuracoes do Timer2 utilizado para geracao do sinal PWM
     TMR2IF_bit = 0;       // Clear the TMR2IF interrupt flag bit of the PIR1 register.
     T2CKPS2_bit = 1;      // Select the Timer2 prescale 1:16
     T2CKPS1_bit = 0;
     T2CKPS0_bit = 0;
     T2CON |= (1<<TMR2ON); //Enable Timer2
     T2CLKCON = 0x01;      // Timer2 Clock Select bits
     
     // PWM6CON |= (1<<PWM6EN); // Ativa modulo PWM

     // Configuracoes do Timer0 utilizado para leitura do Encoder Rotativo
     TMR0IF_bit = 0;
     T0CON0 = 0b10000000;  // Habilita Timer0
     T0CON1 = 0b01000000;  // Seleciona o clock source do timer0
     INTCON = 0xC0;        // Ativa interrupcao global
     TMR0 = 0x00;          // Zera o registrador do timer0
     TMR0IE_bit = 0x01;    // Ativa interrupcao por overflow do TMR0

     setDutyPercent(dutySelect_I + dutySelect_F / 10);
     setFreq(freqSelect);

     Lcd_Init();
     defCustomChar();
     Lcd_Cmd(_LCD_CLEAR);
     Lcd_Cmd(_LCD_CURSOR_OFF);
     Lcd_Out(1,1,"  PWM Gen v2.0  ");
     Lcd_Out(2,1," 5 Freq./10bits ");
     delay_ms(3000);

     while(1)
     {
        telaPrincipal();
        checkChgFreq();
        checkChgDuty();
        checkOut();
        fineAdj();
        delay_ms(1);
     }
}
void defCustomChar()
{
  Lcd_Cmd(64);
  Lcd_Chr_CP(0b00011111);
  Lcd_Chr_CP(0b00010001);
  Lcd_Chr_CP(0b00011011);
  Lcd_Chr_CP(0b00011011);
  Lcd_Chr_CP(0b00011011);
  Lcd_Chr_CP(0b00011011);
  Lcd_Chr_CP(0b00011111);
  Lcd_Chr_CP(0b00000000);

  Lcd_Chr_CP(0b00011111);
  Lcd_Chr_CP(0b00010001);
  Lcd_Chr_CP(0b00010111);
  Lcd_Chr_CP(0b00010011);
  Lcd_Chr_CP(0b00010111);
  Lcd_Chr_CP(0b00010111);
  Lcd_Chr_CP(0b00011111);
  Lcd_Chr_CP(0b00000000);
}

void telaPrincipal()
{
   Lcd_Out(1,2,"Duty   ");

   if (dutySelect_I < 10)
      Lcd_Chr_Cp(' ');
      if (dutySelect_I < 100)
         Lcd_Chr_Cp(' ');
   disp_number(dutySelect_I);
   Lcd_Chr_Cp('.');
   disp_number(dutySelect_F);
   Lcd_Chr_Cp('%');
   Lcd_Chr_Cp(' ');


   if (fine)
      Lcd_Chr_Cp(1);
   else
      Lcd_Chr_Cp(' ');

   Lcd_Out(2,2,"Freq ");
   switch(freqSelect)
   {
      case 1:
         Lcd_Out(2, 7, " 1.22KHz ");
         break;
      case 2:
         Lcd_Out(2, 7, " 2.44KHz ");
         break;
      case 3:
         Lcd_Out(2, 7, " 4.88KHz ");
         break;
      case 4:
         Lcd_Out(2, 7, " 9.76KHz ");
         break;
      case 5:
         Lcd_Out(2, 7, "19.53KHz ");
         break;
   }
   if (outSelect)
      Lcd_Chr_Cp(0);
   else
      Lcd_Chr_Cp(' ');
}

void checkOut()
{
   if (bt1 == 0)
      flags |= (1<<1);
   if ((bt1 == 1) && (flags&(1<<1)))
   {
      flags &= ~(1<<1);
      delay_ms(180);
      if (outSelect)
      {
         outSelect = 0;
         PWM6CON &= ~(1<<PWM6EN);
         TRISC2_bit = 1;
      }
      else
      {
         outSelect = 1;
         PWM6CON |= (1<<PWM6EN);
         TRISC2_bit = 0;
      }
   }
}

void fineAdj()
{
   if (bt2 == 0)
      flags |= (1<<2);
   if ((bt1 == 1) && (flags&(1<<2)))
   {
      flags &= ~(1<<2);
      delay_ms(180);
      fine = !fine;
   }
}

void checkChgFreq()
{
   if(bt0 == 0)
      flags |= (1<<0);
   if ((bt0 == 1) && (flags&(1<<0)))
   {
      flags &= ~(1<<0);
      delay_ms(180);

      if (freqSelect < 5)
         freqSelect++;
      else
         freqSelect = 1;

      setFreq(freqSelect);
   }
}

void checkChgDuty()
{
   static int dutySelectLast_I = 0;
   static int dutySelectLast_F = 0;

   if ((dutySelectLast_I != dutySelect_I) || (dutySelectLast_F != dutySelect_F))
      setDutyPercent(dutySelect_I + dutySelect_F / 10);
}


void read_encoder()
{
    if(!enc_A)
    {
       if(!flag_enc)
       {
          flag_enc = 0x01;
          if (fine)
          {
              if (dutySelect_F < 9 && dutySelect_I < 100)
                    dutySelect_F++;
              else
              {
                 if (dutySelect_I < 100)
                 {
                    dutySelect_I++;
                    dutySelect_F = 0;
                 }
              }
          } else
          {
               dutySelect_F = 0;
               if (dutySelect_I < 100) dutySelect_I++;
          }
       }
    }
    else
    {
       if(!enc_B)
       {
         if(!flag_enc)
         {
          flag_enc = 0x01;
          if (fine)
          {
              if (dutySelect_F > 0)
                    dutySelect_F--;
              else
              {
                 if (dutySelect_I > 0)
                 {
                    dutySelect_I--;
                    dutySelect_F = 9;
                 }
              }
          } else
          {
               dutySelect_F = 0;
               if (dutySelect_I > 0) dutySelect_I--;
          }

         }
       }

    }

    if(enc_A)
    {
       if(enc_B) flag_enc = 0x00;

    }

}

void setDuty(unsigned duty)
{
// PWMxDCH contains the eight MSbs
// PWMxDCL<7:6> bits contain the two LSbs

switch(dutySelect_I)
  {
     case 0:
        PWM6DCH = 0x00;
        PWM6DCL = 0x00;
        break;
     case 100:
        PWM6DCH = 0xFF;
        PWM6DCL = 0xFF;
        break;
     default:
        PWM6DCH = 0xFF & (duty>>2);

        if(duty&0x02)
          PWM6DCL |=  (1<<PWM6DC1);
        else
          PWM6DCL &= ~(1<<PWM6DC1);

        if(duty&0x01)
          PWM6DCL |=  (1<<PWM6DC0);
        else
          PWM6DCL &= ~(1<<PWM6DC0);
  }
}

void setFreq(unsigned freq)
{
     switch(freq)
     {
        case 1:
          // Timer Prescaler 16 (1.22 KHz)
          T2CKPS2_bit = 1;
          T2CKPS1_bit = 0;
          T2CKPS0_bit = 0;
          break;
        case 2:
          // Timer Prescaler 8 (2.44 KHz)
          T2CKPS2_bit = 0;
          T2CKPS1_bit = 1;
          T2CKPS0_bit = 1;
          break;
        case 3:
          // Timer Prescaler 4 (4.88 KHz)
          T2CKPS2_bit = 0;
          T2CKPS1_bit = 1;
          T2CKPS0_bit = 0;
          break;
        case 4:
          // Timer Prescaler 2 (9.76 KHz)
          T2CKPS2_bit = 0;
          T2CKPS1_bit = 0;
          T2CKPS0_bit = 1;
          break;
       case 5:
          // Timer Prescaler 1 (19.53 KHz)
          T2CKPS2_bit = 0;
          T2CKPS1_bit = 0;
          T2CKPS0_bit = 0;
          break;
     }
}

void setDutyPercent(float dutyp)
{
   unsigned duty;
   duty = (int)(dutyp * 10.23);
   setDuty(duty);
}

void disp_number(unsigned num)
{
  char  dem, mil, cen, dez, uni;
  short  no_zero = 0;

  dem = (char)(num/10000);
  mil = (char)(num%10000/1000);
  cen = (char)(num%1000/100);
  dez = (char)(num%100/10);
  uni = (char)(num%10);

  if(!dem && !no_zero)
    delay_ms(1);
  else
  {
    Lcd_Chr_Cp(dem+0x30);
    no_zero = 1;
  }

  if(!mil && !no_zero)
    delay_ms(1);
  else
  {
    Lcd_Chr_Cp(mil+0x30);
    no_zero = 1;
  }

  if(!cen && !no_zero)
    delay_ms(1);
  else
  {
    Lcd_Chr_Cp(cen+0x30);
    no_zero = 1;
  }

  if(!dez && !no_zero)
    delay_ms(1);
  else
  {
    Lcd_Chr_Cp(dez+0x30);
    no_zero = 1;
  }

  Lcd_Chr_Cp(uni+0x30);
}