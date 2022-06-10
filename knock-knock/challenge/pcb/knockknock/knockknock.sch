EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MCU_Microchip_ATmega:ATmega328P-AU U?
U 1 1 62770D36
P 5200 2850
F 0 "U?" H 4750 1400 50  0000 C CNN
F 1 "ATmega328P-AU" H 5600 1400 50  0000 C CNN
F 2 "Package_QFP:TQFP-32_7x7mm_P0.8mm" H 5200 2850 50  0001 C CIN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/ATmega328_P%20AVR%20MCU%20with%20picoPower%20Technology%20Data%20Sheet%2040001984A.pdf" H 5200 2850 50  0001 C CNN
	1    5200 2850
	1    0    0    -1  
$EndComp
NoConn ~ 4600 1650
NoConn ~ 4600 1850
NoConn ~ 4600 1950
$Comp
L Device:Crystal Y?
U 1 1 62772042
P 1700 2550
F 0 "Y?" H 1700 2818 50  0000 C CNN
F 1 "8MHz" H 1700 2727 50  0000 C CNN
F 2 "" H 1700 2550 50  0001 C CNN
F 3 "~" H 1700 2550 50  0001 C CNN
	1    1700 2550
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C?
U 1 1 62772BC6
P 1900 2700
F 0 "C?" H 1992 2746 50  0000 L CNN
F 1 "15pF" H 1992 2655 50  0000 L CNN
F 2 "" H 1900 2700 50  0001 C CNN
F 3 "~" H 1900 2700 50  0001 C CNN
	1    1900 2700
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C?
U 1 1 62772EA3
P 1500 2700
F 0 "C?" H 1592 2746 50  0000 L CNN
F 1 "15pF" H 1592 2655 50  0000 L CNN
F 2 "" H 1500 2700 50  0001 C CNN
F 3 "~" H 1500 2700 50  0001 C CNN
	1    1500 2700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 627735F8
P 1700 2950
F 0 "#PWR?" H 1700 2700 50  0001 C CNN
F 1 "GND" H 1705 2777 50  0000 C CNN
F 2 "" H 1700 2950 50  0001 C CNN
F 3 "" H 1700 2950 50  0001 C CNN
	1    1700 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 1950 6050 1950
Wire Wire Line
	5800 2050 6050 2050
Wire Wire Line
	5800 2150 6050 2150
Text Label 6050 1950 2    50   ~ 0
MOSI
Text Label 6050 2050 2    50   ~ 0
MISO
Text Label 6050 2150 2    50   ~ 0
SCK
Wire Wire Line
	5800 1850 6050 1850
Text Label 6050 1850 2    50   ~ 0
~CS
Wire Wire Line
	5800 2250 6050 2250
Wire Wire Line
	5800 2350 6050 2350
Text Label 6050 2250 2    50   ~ 0
XIN
Text Label 6050 2350 2    50   ~ 0
XOUT
Wire Wire Line
	1850 2550 1900 2550
Wire Wire Line
	1900 2550 1900 2600
Wire Wire Line
	1550 2550 1500 2550
Wire Wire Line
	1500 2550 1500 2600
Wire Wire Line
	1500 2800 1700 2800
Wire Wire Line
	1700 2800 1700 2950
Connection ~ 1700 2800
Wire Wire Line
	1700 2800 1900 2800
$Comp
L power:GND #PWR?
U 1 1 6277794F
P 5200 4450
F 0 "#PWR?" H 5200 4200 50  0001 C CNN
F 1 "GND" H 5205 4277 50  0000 C CNN
F 2 "" H 5200 4450 50  0001 C CNN
F 3 "" H 5200 4450 50  0001 C CNN
	1    5200 4450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5200 4350 5200 4450
$Comp
L Switch:SW_Push SW?
U 1 1 627783B2
P 7500 1700
F 0 "SW?" V 7454 1848 50  0000 L CNN
F 1 "1" V 7545 1848 50  0000 L CNN
F 2 "" H 7500 1900 50  0001 C CNN
F 3 "~" H 7500 1900 50  0001 C CNN
	1    7500 1700
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 62779CBA
P 8500 1700
F 0 "SW?" V 8454 1848 50  0000 L CNN
F 1 "3" V 8545 1848 50  0000 L CNN
F 2 "" H 8500 1900 50  0001 C CNN
F 3 "~" H 8500 1900 50  0001 C CNN
	1    8500 1700
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 6277A0C6
P 8000 1700
F 0 "SW?" V 7954 1848 50  0000 L CNN
F 1 "2" V 8045 1848 50  0000 L CNN
F 2 "" H 8000 1900 50  0001 C CNN
F 3 "~" H 8000 1900 50  0001 C CNN
	1    8000 1700
	0    1    1    0   
$EndComp
$Comp
L Device:D D?
U 1 1 62782AC8
P 8500 2150
F 0 "D?" V 8546 2070 50  0000 R CNN
F 1 "D" V 8455 2070 50  0000 R CNN
F 2 "" H 8500 2150 50  0001 C CNN
F 3 "~" H 8500 2150 50  0001 C CNN
	1    8500 2150
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 6278303A
P 8000 2150
F 0 "D?" V 8046 2070 50  0000 R CNN
F 1 "D" V 7955 2070 50  0000 R CNN
F 2 "" H 8000 2150 50  0001 C CNN
F 3 "~" H 8000 2150 50  0001 C CNN
	1    8000 2150
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 62783511
P 7500 2150
F 0 "D?" V 7546 2070 50  0000 R CNN
F 1 "D" V 7455 2070 50  0000 R CNN
F 2 "" H 7500 2150 50  0001 C CNN
F 3 "~" H 7500 2150 50  0001 C CNN
	1    7500 2150
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8500 1500 8500 1350
Wire Wire Line
	8500 1350 8000 1350
Wire Wire Line
	7500 1500 7500 1350
Connection ~ 7500 1350
Wire Wire Line
	7500 1350 7150 1350
Wire Wire Line
	8000 1500 8000 1350
Connection ~ 8000 1350
Wire Wire Line
	8000 1350 7500 1350
$Comp
L Switch:SW_Push SW?
U 1 1 62786D86
P 7500 2850
F 0 "SW?" V 7454 2998 50  0000 L CNN
F 1 "4" V 7545 2998 50  0000 L CNN
F 2 "" H 7500 3050 50  0001 C CNN
F 3 "~" H 7500 3050 50  0001 C CNN
	1    7500 2850
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 62786D8C
P 8500 2850
F 0 "SW?" V 8454 2998 50  0000 L CNN
F 1 "6" V 8545 2998 50  0000 L CNN
F 2 "" H 8500 3050 50  0001 C CNN
F 3 "~" H 8500 3050 50  0001 C CNN
	1    8500 2850
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 62786D92
P 8000 2850
F 0 "SW?" V 7954 2998 50  0000 L CNN
F 1 "5" V 8045 2998 50  0000 L CNN
F 2 "" H 8000 3050 50  0001 C CNN
F 3 "~" H 8000 3050 50  0001 C CNN
	1    8000 2850
	0    1    1    0   
$EndComp
$Comp
L Device:D D?
U 1 1 62786D98
P 8500 3300
F 0 "D?" V 8546 3220 50  0000 R CNN
F 1 "D" V 8455 3220 50  0000 R CNN
F 2 "" H 8500 3300 50  0001 C CNN
F 3 "~" H 8500 3300 50  0001 C CNN
	1    8500 3300
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 62786D9E
P 8000 3300
F 0 "D?" V 8046 3220 50  0000 R CNN
F 1 "D" V 7955 3220 50  0000 R CNN
F 2 "" H 8000 3300 50  0001 C CNN
F 3 "~" H 8000 3300 50  0001 C CNN
	1    8000 3300
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 62786DA4
P 7500 3300
F 0 "D?" V 7546 3220 50  0000 R CNN
F 1 "D" V 7455 3220 50  0000 R CNN
F 2 "" H 7500 3300 50  0001 C CNN
F 3 "~" H 7500 3300 50  0001 C CNN
	1    7500 3300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8500 2650 8500 2500
Wire Wire Line
	8500 2500 8000 2500
Wire Wire Line
	7500 2650 7500 2500
Connection ~ 7500 2500
Wire Wire Line
	7500 2500 7150 2500
Wire Wire Line
	8000 2650 8000 2500
Connection ~ 8000 2500
Wire Wire Line
	8000 2500 7500 2500
$Comp
L Switch:SW_Push SW?
U 1 1 6278CA49
P 7500 4000
F 0 "SW?" V 7454 4148 50  0000 L CNN
F 1 "7" V 7545 4148 50  0000 L CNN
F 2 "" H 7500 4200 50  0001 C CNN
F 3 "~" H 7500 4200 50  0001 C CNN
	1    7500 4000
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 6278CA4F
P 8500 4000
F 0 "SW?" V 8454 4148 50  0000 L CNN
F 1 "9" V 8545 4148 50  0000 L CNN
F 2 "" H 8500 4200 50  0001 C CNN
F 3 "~" H 8500 4200 50  0001 C CNN
	1    8500 4000
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 6278CA55
P 8000 4000
F 0 "SW?" V 7954 4148 50  0000 L CNN
F 1 "8" V 8045 4148 50  0000 L CNN
F 2 "" H 8000 4200 50  0001 C CNN
F 3 "~" H 8000 4200 50  0001 C CNN
	1    8000 4000
	0    1    1    0   
$EndComp
$Comp
L Device:D D?
U 1 1 6278CA5B
P 8500 4450
F 0 "D?" V 8546 4370 50  0000 R CNN
F 1 "D" V 8455 4370 50  0000 R CNN
F 2 "" H 8500 4450 50  0001 C CNN
F 3 "~" H 8500 4450 50  0001 C CNN
	1    8500 4450
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 6278CA61
P 8000 4450
F 0 "D?" V 8046 4370 50  0000 R CNN
F 1 "D" V 7955 4370 50  0000 R CNN
F 2 "" H 8000 4450 50  0001 C CNN
F 3 "~" H 8000 4450 50  0001 C CNN
	1    8000 4450
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 6278CA67
P 7500 4450
F 0 "D?" V 7546 4370 50  0000 R CNN
F 1 "D" V 7455 4370 50  0000 R CNN
F 2 "" H 7500 4450 50  0001 C CNN
F 3 "~" H 7500 4450 50  0001 C CNN
	1    7500 4450
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8500 3800 8500 3650
Wire Wire Line
	8500 3650 8000 3650
Wire Wire Line
	7500 3800 7500 3650
Connection ~ 7500 3650
Wire Wire Line
	7500 3650 7150 3650
Wire Wire Line
	8000 3800 8000 3650
Connection ~ 8000 3650
Wire Wire Line
	8000 3650 7500 3650
$Comp
L Switch:SW_Push SW?
U 1 1 6278CA75
P 7500 5150
F 0 "SW?" V 7454 5298 50  0000 L CNN
F 1 "*" V 7545 5298 50  0000 L CNN
F 2 "" H 7500 5350 50  0001 C CNN
F 3 "~" H 7500 5350 50  0001 C CNN
	1    7500 5150
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 6278CA7B
P 8500 5150
F 0 "SW?" V 8454 5298 50  0000 L CNN
F 1 "#" V 8545 5298 50  0000 L CNN
F 2 "" H 8500 5350 50  0001 C CNN
F 3 "~" H 8500 5350 50  0001 C CNN
	1    8500 5150
	0    1    1    0   
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 6278CA81
P 8000 5150
F 0 "SW?" V 7954 5298 50  0000 L CNN
F 1 "0" V 8045 5298 50  0000 L CNN
F 2 "" H 8000 5350 50  0001 C CNN
F 3 "~" H 8000 5350 50  0001 C CNN
	1    8000 5150
	0    1    1    0   
$EndComp
$Comp
L Device:D D?
U 1 1 6278CA87
P 8500 5600
F 0 "D?" V 8546 5520 50  0000 R CNN
F 1 "D" V 8455 5520 50  0000 R CNN
F 2 "" H 8500 5600 50  0001 C CNN
F 3 "~" H 8500 5600 50  0001 C CNN
	1    8500 5600
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 6278CA8D
P 8000 5600
F 0 "D?" V 8046 5520 50  0000 R CNN
F 1 "D" V 7955 5520 50  0000 R CNN
F 2 "" H 8000 5600 50  0001 C CNN
F 3 "~" H 8000 5600 50  0001 C CNN
	1    8000 5600
	0    -1   -1   0   
$EndComp
$Comp
L Device:D D?
U 1 1 6278CA93
P 7500 5600
F 0 "D?" V 7546 5520 50  0000 R CNN
F 1 "D" V 7455 5520 50  0000 R CNN
F 2 "" H 7500 5600 50  0001 C CNN
F 3 "~" H 7500 5600 50  0001 C CNN
	1    7500 5600
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8500 4950 8500 4800
Wire Wire Line
	8500 4800 8000 4800
Wire Wire Line
	7500 4950 7500 4800
Connection ~ 7500 4800
Wire Wire Line
	7500 4800 7150 4800
Wire Wire Line
	8000 4950 8000 4800
Connection ~ 8000 4800
Wire Wire Line
	8000 4800 7500 4800
Wire Wire Line
	7350 1050 7350 2300
Wire Wire Line
	7350 5750 7500 5750
Wire Wire Line
	7850 1050 7850 2300
Wire Wire Line
	7850 5750 8000 5750
Wire Wire Line
	8350 1050 8350 2300
Wire Wire Line
	8350 5750 8500 5750
Wire Wire Line
	7500 1900 7500 2000
Wire Wire Line
	8000 1900 8000 2000
Wire Wire Line
	8500 1900 8500 2000
Wire Wire Line
	8500 3050 8500 3150
Wire Wire Line
	8000 3050 8000 3150
Wire Wire Line
	7500 3050 7500 3150
Wire Wire Line
	7500 4200 7500 4300
Wire Wire Line
	8000 4200 8000 4300
Wire Wire Line
	8500 4200 8500 4300
Wire Wire Line
	8500 5350 8500 5450
Wire Wire Line
	8000 5350 8000 5450
Wire Wire Line
	7500 5350 7500 5450
Wire Wire Line
	7500 2300 7350 2300
Connection ~ 7350 2300
Wire Wire Line
	7350 2300 7350 3450
Wire Wire Line
	7500 3450 7350 3450
Connection ~ 7350 3450
Wire Wire Line
	7350 3450 7350 4600
Wire Wire Line
	7500 4600 7350 4600
Connection ~ 7350 4600
Wire Wire Line
	7350 4600 7350 5750
Wire Wire Line
	8000 2300 7850 2300
Connection ~ 7850 2300
Wire Wire Line
	7850 2300 7850 3450
Wire Wire Line
	8000 3450 7850 3450
Connection ~ 7850 3450
Wire Wire Line
	7850 3450 7850 4600
Wire Wire Line
	8000 4600 7850 4600
Connection ~ 7850 4600
Wire Wire Line
	7850 4600 7850 5750
Wire Wire Line
	8500 2300 8350 2300
Connection ~ 8350 2300
Wire Wire Line
	8350 2300 8350 3450
Wire Wire Line
	8500 3450 8350 3450
Connection ~ 8350 3450
Wire Wire Line
	8350 3450 8350 4600
Wire Wire Line
	8500 4600 8350 4600
Connection ~ 8350 4600
Wire Wire Line
	8350 4600 8350 5750
Text Label 8350 1050 0    50   ~ 0
COL3
Text Label 7850 1050 0    50   ~ 0
COL2
Text Label 7350 1050 0    50   ~ 0
COL1
Text Label 7150 1350 0    50   ~ 0
ROW1
Text Label 7150 2500 0    50   ~ 0
ROW2
Text Label 7150 3650 0    50   ~ 0
ROW3
Text Label 7150 4800 0    50   ~ 0
ROW4
Wire Wire Line
	5800 3350 6050 3350
Wire Wire Line
	5800 3450 6050 3450
Wire Wire Line
	5800 3550 6050 3550
Wire Wire Line
	5800 3650 6050 3650
Wire Wire Line
	5800 3750 6050 3750
Wire Wire Line
	5800 3850 6050 3850
Wire Wire Line
	5800 3950 6050 3950
Text Label 6050 3650 2    50   ~ 0
ROW1
Text Label 6050 3750 2    50   ~ 0
ROW2
Text Label 6050 3850 2    50   ~ 0
ROW3
Text Label 6050 3950 2    50   ~ 0
ROW4
Text Label 6050 3350 2    50   ~ 0
COL1
Text Label 6050 3450 2    50   ~ 0
COL2
Text Label 6050 3550 2    50   ~ 0
COL3
NoConn ~ 5800 4050
$Comp
L power:VCC #PWR?
U 1 1 627C4628
P 5200 1200
F 0 "#PWR?" H 5200 1050 50  0001 C CNN
F 1 "VCC" H 5215 1373 50  0000 C CNN
F 2 "" H 5200 1200 50  0001 C CNN
F 3 "" H 5200 1200 50  0001 C CNN
	1    5200 1200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5200 1200 5200 1250
Wire Wire Line
	5200 1250 5300 1250
Wire Wire Line
	5300 1250 5300 1350
Connection ~ 5200 1250
Wire Wire Line
	5200 1250 5200 1350
Text Label 1900 2550 0    50   ~ 0
XIN
Text Label 1500 2550 2    50   ~ 0
XOUT
$Comp
L Regulator_Linear:LM7805_TO220 U?
U 1 1 627CFDE9
P 1700 1500
F 0 "U?" H 1700 1742 50  0000 C CNN
F 1 "LM7805_TO220" H 1700 1651 50  0000 C CNN
F 2 "Package_TO_SOT_THT:TO-220-3_Vertical" H 1700 1725 50  0001 C CIN
F 3 "https://www.onsemi.cn/PowerSolutions/document/MC7800-D.PDF" H 1700 1450 50  0001 C CNN
	1    1700 1500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 627D1339
P 1700 1850
F 0 "#PWR?" H 1700 1600 50  0001 C CNN
F 1 "GND" H 1705 1677 50  0000 C CNN
F 2 "" H 1700 1850 50  0001 C CNN
F 3 "" H 1700 1850 50  0001 C CNN
	1    1700 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	1700 1850 1700 1800
$Comp
L power:VCC #PWR?
U 1 1 627D3B19
P 2150 1450
F 0 "#PWR?" H 2150 1300 50  0001 C CNN
F 1 "VCC" H 2165 1623 50  0000 C CNN
F 2 "" H 2150 1450 50  0001 C CNN
F 3 "" H 2150 1450 50  0001 C CNN
	1    2150 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2150 1450 2150 1500
Wire Wire Line
	2150 1500 2000 1500
$Comp
L power:+12V #PWR?
U 1 1 627D6569
P 1150 1350
F 0 "#PWR?" H 1150 1200 50  0001 C CNN
F 1 "+12V" H 1165 1523 50  0000 C CNN
F 2 "" H 1150 1350 50  0001 C CNN
F 3 "" H 1150 1350 50  0001 C CNN
	1    1150 1350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1400 1500 1150 1500
Wire Wire Line
	1150 1500 1150 1350
$Comp
L Device:Electromagnetic_Actor L?
U 1 1 627DC464
P 10450 2250
F 0 "L?" H 10580 2346 50  0000 L CNN
F 1 "LOCK" H 10580 2255 50  0000 L CNN
F 2 "" V 10425 2350 50  0001 C CNN
F 3 "~" V 10425 2350 50  0001 C CNN
	1    10450 2250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 627DF38E
P 10450 2450
F 0 "#PWR?" H 10450 2200 50  0001 C CNN
F 1 "GND" H 10455 2277 50  0000 C CNN
F 2 "" H 10450 2450 50  0001 C CNN
F 3 "" H 10450 2450 50  0001 C CNN
	1    10450 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	10450 2450 10450 2350
$Comp
L Relay:G5Q-1A K?
U 1 1 627E297E
P 10250 1650
F 0 "K?" H 10580 1696 50  0000 L CNN
F 1 "RLY" H 10580 1605 50  0000 L CNN
F 2 "Relay_THT:Relay_SPST_Omron-G5Q-1A" H 10600 1600 50  0001 L CNN
F 3 "https://www.omron.com/ecb/products/pdf/en-g5q.pdf" H 10250 1650 50  0001 C CNN
	1    10250 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	10450 1950 10450 2050
$Comp
L power:VCC #PWR?
U 1 1 627F2216
P 10050 1250
F 0 "#PWR?" H 10050 1100 50  0001 C CNN
F 1 "VCC" H 10065 1423 50  0000 C CNN
F 2 "" H 10050 1250 50  0001 C CNN
F 3 "" H 10050 1250 50  0001 C CNN
	1    10050 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	10050 1250 10050 1300
$Comp
L power:+12V #PWR?
U 1 1 627F5675
P 10450 1250
F 0 "#PWR?" H 10450 1100 50  0001 C CNN
F 1 "+12V" H 10465 1423 50  0000 C CNN
F 2 "" H 10450 1250 50  0001 C CNN
F 3 "" H 10450 1250 50  0001 C CNN
	1    10450 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	10450 1250 10450 1350
$Comp
L Device:D D?
U 1 1 627F8717
P 9650 1650
F 0 "D?" V 9604 1730 50  0000 L CNN
F 1 "D" V 9695 1730 50  0000 L CNN
F 2 "" H 9650 1650 50  0001 C CNN
F 3 "~" H 9650 1650 50  0001 C CNN
	1    9650 1650
	0    1    1    0   
$EndComp
Wire Wire Line
	10050 1300 9650 1300
Wire Wire Line
	9650 1300 9650 1500
Connection ~ 10050 1300
Wire Wire Line
	10050 1300 10050 1350
Wire Wire Line
	10050 1950 9650 1950
Wire Wire Line
	9650 1950 9650 1800
$Comp
L Transistor_FET:BSS138 Q?
U 1 1 62804763
P 9950 2300
F 0 "Q?" H 10154 2346 50  0000 L CNN
F 1 "BSS138" H 10154 2255 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 10150 2225 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BSS138-D.PDF" H 9950 2300 50  0001 L CNN
	1    9950 2300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 628071DB
P 10050 2650
F 0 "#PWR?" H 10050 2400 50  0001 C CNN
F 1 "GND" H 10055 2477 50  0000 C CNN
F 2 "" H 10050 2650 50  0001 C CNN
F 3 "" H 10050 2650 50  0001 C CNN
	1    10050 2650
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 628081AF
P 9750 2500
F 0 "R?" H 9809 2546 50  0000 L CNN
F 1 "10k" H 9809 2455 50  0000 L CNN
F 2 "" H 9750 2500 50  0001 C CNN
F 3 "~" H 9750 2500 50  0001 C CNN
	1    9750 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	10050 2650 9750 2650
Wire Wire Line
	9750 2650 9750 2600
Wire Wire Line
	10050 2650 10050 2500
Connection ~ 10050 2650
Wire Wire Line
	9750 2400 9750 2300
Wire Wire Line
	9750 2300 9400 2300
Connection ~ 9750 2300
Text Label 9400 2300 0    50   ~ 0
DRCTL
Wire Wire Line
	10050 2100 10050 1950
Connection ~ 10050 1950
Wire Wire Line
	5800 2550 6050 2550
Text Label 6050 2550 2    50   ~ 0
DRCTL
NoConn ~ 5800 1650
NoConn ~ 5800 1750
Wire Wire Line
	1950 3800 2050 3800
Text Label 2700 3800 2    50   ~ 0
SIGRST
$Comp
L power:GND #PWR?
U 1 1 62840941
P 1450 3900
F 0 "#PWR?" H 1450 3650 50  0001 C CNN
F 1 "GND" H 1455 3727 50  0000 C CNN
F 2 "" H 1450 3900 50  0001 C CNN
F 3 "" H 1450 3900 50  0001 C CNN
	1    1450 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	1450 3900 1450 3800
Wire Wire Line
	1450 3800 1550 3800
$Comp
L Switch:SW_Push SW?
U 1 1 6284403B
P 1750 3800
F 0 "SW?" H 1750 4085 50  0000 C CNN
F 1 "RST" H 1750 3994 50  0000 C CNN
F 2 "" H 1750 4000 50  0001 C CNN
F 3 "~" H 1750 4000 50  0001 C CNN
	1    1750 3800
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 62845F8B
P 2300 3800
F 0 "R?" V 2104 3800 50  0000 C CNN
F 1 "100" V 2195 3800 50  0000 C CNN
F 2 "" H 2300 3800 50  0001 C CNN
F 3 "~" H 2300 3800 50  0001 C CNN
	1    2300 3800
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R?
U 1 1 62846452
P 2050 3600
F 0 "R?" H 1991 3554 50  0000 R CNN
F 1 "10k" H 1991 3645 50  0000 R CNN
F 2 "" H 2050 3600 50  0001 C CNN
F 3 "~" H 2050 3600 50  0001 C CNN
	1    2050 3600
	-1   0    0    1   
$EndComp
Wire Wire Line
	2050 3700 2050 3800
Connection ~ 2050 3800
Wire Wire Line
	2050 3800 2200 3800
$Comp
L power:VCC #PWR?
U 1 1 6284A4CC
P 2050 3500
F 0 "#PWR?" H 2050 3350 50  0001 C CNN
F 1 "VCC" H 2065 3673 50  0000 C CNN
F 2 "" H 2050 3500 50  0001 C CNN
F 3 "" H 2050 3500 50  0001 C CNN
	1    2050 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2400 3800 2700 3800
$Comp
L Device:C_Small C?
U 1 1 6284E1EB
P 2050 4000
F 0 "C?" H 2142 4046 50  0000 L CNN
F 1 "1uF" H 2142 3955 50  0000 L CNN
F 2 "" H 2050 4000 50  0001 C CNN
F 3 "~" H 2050 4000 50  0001 C CNN
	1    2050 4000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6284E67A
P 2050 4100
F 0 "#PWR?" H 2050 3850 50  0001 C CNN
F 1 "GND" H 2055 3927 50  0000 C CNN
F 2 "" H 2050 4100 50  0001 C CNN
F 3 "" H 2050 4100 50  0001 C CNN
	1    2050 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2050 3900 2050 3800
Wire Wire Line
	5800 3150 6050 3150
Text Label 6050 3150 2    50   ~ 0
SIGRST
Wire Wire Line
	5800 2650 6050 2650
Wire Wire Line
	5800 2750 6050 2750
NoConn ~ 5800 2850
NoConn ~ 5800 2950
NoConn ~ 5800 3050
Text Label 6050 2650 2    50   ~ 0
RED
Text Label 6050 2750 2    50   ~ 0
GRN
$Comp
L Device:LED D?
U 1 1 6286DCDB
P 3200 1750
F 0 "D?" V 3239 1632 50  0000 R CNN
F 1 "LED_R" V 3148 1632 50  0000 R CNN
F 2 "" H 3200 1750 50  0001 C CNN
F 3 "~" H 3200 1750 50  0001 C CNN
	1    3200 1750
	0    -1   -1   0   
$EndComp
$Comp
L Device:LED D?
U 1 1 6286EA41
P 3600 1750
F 0 "D?" V 3639 1632 50  0000 R CNN
F 1 "LED_G" V 3548 1632 50  0000 R CNN
F 2 "" H 3600 1750 50  0001 C CNN
F 3 "~" H 3600 1750 50  0001 C CNN
	1    3600 1750
	0    -1   -1   0   
$EndComp
$Comp
L Device:R_Small R?
U 1 1 62872E48
P 3200 2150
F 0 "R?" H 3141 2104 50  0000 R CNN
F 1 "100" H 3141 2195 50  0000 R CNN
F 2 "" H 3200 2150 50  0001 C CNN
F 3 "~" H 3200 2150 50  0001 C CNN
	1    3200 2150
	-1   0    0    1   
$EndComp
$Comp
L Device:R_Small R?
U 1 1 62873B0D
P 3600 2150
F 0 "R?" H 3541 2104 50  0000 R CNN
F 1 "100" H 3541 2195 50  0000 R CNN
F 2 "" H 3600 2150 50  0001 C CNN
F 3 "~" H 3600 2150 50  0001 C CNN
	1    3600 2150
	-1   0    0    1   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 62874596
P 3200 1400
F 0 "#PWR?" H 3200 1250 50  0001 C CNN
F 1 "VCC" H 3215 1573 50  0000 C CNN
F 2 "" H 3200 1400 50  0001 C CNN
F 3 "" H 3200 1400 50  0001 C CNN
	1    3200 1400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 1400 3200 1500
Wire Wire Line
	3200 1500 3600 1500
Wire Wire Line
	3600 1500 3600 1600
Connection ~ 3200 1500
Wire Wire Line
	3200 1500 3200 1600
Wire Wire Line
	3200 1900 3200 2050
Wire Wire Line
	3600 1900 3600 2050
Wire Wire Line
	3200 2250 3200 2550
Wire Wire Line
	3200 2550 3800 2550
Wire Wire Line
	3600 2250 3600 2350
Wire Wire Line
	3600 2350 3800 2350
Text Label 3800 2350 2    50   ~ 0
GRN
Text Label 3800 2550 2    50   ~ 0
RED
$Comp
L Memory_Flash:MX25R3235FM1xx0 U?
U 1 1 62897EB7
P 5250 5900
F 0 "U?" H 5700 5650 50  0000 L CNN
F 1 "MX25R3235FM1xx0" H 5550 5550 50  0000 L CNN
F 2 "Package_SO:SOP-8_3.9x4.9mm_P1.27mm" H 5250 5300 50  0001 C CNN
F 3 "http://www.macronix.com/Lists/Datasheet/Attachments/7534/MX25R3235F,%20Wide%20Range,%2032Mb,%20v1.6.pdf" H 5250 5900 50  0001 C CNN
	1    5250 5900
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 6289BCB6
P 5450 5400
F 0 "#PWR?" H 5450 5250 50  0001 C CNN
F 1 "VCC" H 5465 5573 50  0000 C CNN
F 2 "" H 5450 5400 50  0001 C CNN
F 3 "" H 5450 5400 50  0001 C CNN
	1    5450 5400
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6289CB4E
P 5450 6400
F 0 "#PWR?" H 5450 6150 50  0001 C CNN
F 1 "GND" H 5455 6227 50  0000 C CNN
F 2 "" H 5450 6400 50  0001 C CNN
F 3 "" H 5450 6400 50  0001 C CNN
	1    5450 6400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 5400 5450 5500
Wire Wire Line
	5450 6300 5450 6400
Wire Wire Line
	5750 5900 5950 5900
Wire Wire Line
	4750 5700 4550 5700
Wire Wire Line
	4750 5800 4550 5800
Wire Wire Line
	4750 5900 4550 5900
Text Label 5950 5900 2    50   ~ 0
MISO
Text Label 4550 5700 0    50   ~ 0
MOSI
Text Label 4550 5800 0    50   ~ 0
SCK
Text Label 4550 5900 0    50   ~ 0
~CS
NoConn ~ 4750 6000
NoConn ~ 4750 6100
$EndSCHEMATC
