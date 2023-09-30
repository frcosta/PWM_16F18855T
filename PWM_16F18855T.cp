#line 1 "C:/Users/fcost/OneDrive/Programas/PIC/PWM_16F18855T/PWM_16F18855T.c"

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
#line 29 "C:/Users/fcost/OneDrive/Programas/PIC/PWM_16F18855T/PWM_16F18855T.c"
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


char fine = 1;
char outSelect = 0;
char flags = 0;
char flag_dutySelect = 1;
unsigned char flag_enc = 0x01;
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

 TRISA2_bit = 0;
 TRISA3_bit = 0;
 TRISA4_bit = 0;
 TRISB = 0x00;


 ANSELA = 0x00;
 ANSELB = 0x00;
 ANSELC = 0x00;

 PORTB = 0x00;


 PWM6POL_bit = 0;
 PR2 = 0xFF;




 RC2PPS = 0x0E;



 TMR2IF_bit = 0;
 T2CKPS2_bit = 1;
 T2CKPS1_bit = 0;
 T2CKPS0_bit = 0;
 T2CON |= (1<<TMR2ON);
 T2CLKCON = 0x01;




 TMR0IF_bit = 0;
 T0CON0 = 0b10000000;
 T0CON1 = 0b01000000;
 INTCON = 0xC0;
 TMR0 = 0x00;
 TMR0IE_bit = 0x01;

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
 if ( RA2_bit  == 0)
 flags |= (1<<1);
 if (( RA2_bit  == 1) && (flags&(1<<1)))
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
 if ( RA3_bit  == 0)
 flags |= (1<<2);
 if (( RA2_bit  == 1) && (flags&(1<<2)))
 {
 flags &= ~(1<<2);
 delay_ms(180);
 fine = !fine;
 }
}

void checkChgFreq()
{
 if( RA4_bit  == 0)
 flags |= (1<<0);
 if (( RA4_bit  == 1) && (flags&(1<<0)))
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
 if(! RC0_bit )
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
 if(! RC1_bit )
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

 if( RC0_bit )
 {
 if( RC1_bit ) flag_enc = 0x00;

 }

}

void setDuty(unsigned duty)
{



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
 PWM6DCL |= (1<<PWM6DC1);
 else
 PWM6DCL &= ~(1<<PWM6DC1);

 if(duty&0x01)
 PWM6DCL |= (1<<PWM6DC0);
 else
 PWM6DCL &= ~(1<<PWM6DC0);
 }
}

void setFreq(unsigned freq)
{
 switch(freq)
 {
 case 1:

 T2CKPS2_bit = 1;
 T2CKPS1_bit = 0;
 T2CKPS0_bit = 0;
 break;
 case 2:

 T2CKPS2_bit = 0;
 T2CKPS1_bit = 1;
 T2CKPS0_bit = 1;
 break;
 case 3:

 T2CKPS2_bit = 0;
 T2CKPS1_bit = 1;
 T2CKPS0_bit = 0;
 break;
 case 4:

 T2CKPS2_bit = 0;
 T2CKPS1_bit = 0;
 T2CKPS0_bit = 1;
 break;
 case 5:

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
 char dem, mil, cen, dez, uni;
 short no_zero = 0;

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
