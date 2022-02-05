INCLUDE MACROS.LIB

.MODEL HUGE 

DATA SEGMENT
;;------------------游戏主体-----------------------
SEGMENT1C DW 0					;保存1C号中断段地址
OFF1C DW 0						;保存1C号中断偏移地址
GAMEBOARD DW 24 DUP(?),0FFFFH	;游戏空间总共24行，最后0FFFH为游戏框底
CURRENT_ROW DB ?				;当前行
NEXT_ROW DB ?					;暂存行
RIGHT_SHIFT DB ?				;方块右移量
LEFT_SHIFT DB ?					;方块左移量
NOW_BLOCK DB ?					;当前方块的颜色和类型（0~6）
DIRECTION DB ?					;方块方向
NEXT_BLOCK DB ?					;下一个方块的颜色和类型（0~6）
TIME DB 0						;时间
SPEED DB 0						;速度
LIFE DB 0						;一个方块下落是否结束
ADD_SCORE DB 0					;得分增量
FULL DB 0						;标志是否满行
SOUND DW ?						;声音
SCORE DB 5 DUP('0'),'$'			;分数

;;------------------方块信息-----------------------
BLOCK 	DW   0H,3C0H,  0H,  0H	
		DW 100H,100H,100H,100H 
		DW   0H,3C0H,  0H,  0H	
		DW 100H,100H,100H,100H	;长条形
		
		DW   0H,180H,180H,  0H 	
		DW   0H,180H,180H,  0H	
		DW   0H,180H,180H,  0H	
		DW   0H,180H,180H,  0H	;"田"字形

		DW   0H,380H,100H,  0H 	
		DW 100H,180H,100H,  0H	
		DW 100H,380H,  0H,  0H	
		DW 100H,300H,100H,  0H	;"凸"字形
		
		DW   0H,380H,200H,  0H 	
		DW 200H,200H,300H,  0H	
		DW   0H, 80H,380H,  0H	
		DW   0H,300H,100H,100H	;"L"形
		
		DW   0H,380H, 80H,  0H 	
		DW 300H,200H,200H,  0H	
		DW   0H,200H,380H,  0H	
		DW 100H,100H,300H,  0H	;反"L"形
		
		DW   0H,300H,180H,  0H 	
		DW  80H,180H,100H,  0H	
		DW   0H,300H,180H,  0H	
		DW  80H,180H,100H,  0H	;"Z"形

		DW   0H,180H,300H,  0H 	
		DW 100H,180H, 80H,  0H	
		DW   0H,180H,300H,  0H	
		DW 100H,180H, 80H,  0H	;反"Z"形
BLOCK1 DW 4 DUP(?)				;方块稳态
BLOCK2 DW 4 DUP(?)				;方块实验态
COLOR DB 00001001b,00001010b,00001011b,00001100b,00001101b,00001110b,00000001b	;各方块颜色
NOW_COLOR DB ?					;当前方块颜色

;;------------------欢迎界面-----------------------
;游戏logo标志，logo.bin为TERTRIS图片的二进制文件
LogoWidth 			EQU 297D;391 	;设置logo宽度
LogoHeight 			EQU 200D;128	;设置logo高度
LogostX				EQU 150D	;设置logo横坐标
LogostY				EQU 30D		;设置logo纵坐标
LogofnX				EQU LogostX + LogoWidth		;logo位置和logo宽度之和，表示logo的最大横坐标
LogofnY				EQU LogostY + LogoHeight	;logo位置和logo高度之和，表示logo的最大纵坐标
Logofilename 		DB 'logo.bin', 0	;logo文件名和相对路径，logo与本文件存放于同一目录下
LogoFilehandle 		DW ?				;文件句柄，从而对文件的内容进行操作
positionInLogoFile 	DW 0				;当前在logo文件的位置
LogoData			DB  0				;logo文件读取的数据信息
;欢迎字符串，置于logo图片之下
WELMSG1 DB "WELCOME TO OUR FANTASTIC TETRIS WORLD!"
WELLEN1	EQU 38					;语句字符个数
WELMSG2 DB "PRESS ANY KEY TO START..."
WELLEN2 EQU 25					;语句字符个数
WELMSG3 DB "                         "
WELLEN3 EQU 25					;语句字符个数
;;-----------------选择速度界面---------------------
STARTMSG1 DB "------Select speed------"
STARTLEN1 EQU 24				;语句字符个数
STARTMSG2 DB "1.                 Fast"
STARTLEN2 EQU 23				;语句字符个数
STARTMSG3 DB "2.                 Middle"
STARTLEN3 EQU 25				;语句字符个数
STARTMSG4 DB "3.                 Slow"
STARTLEN4 EQU 23				;语句字符个数
STARTMSG5 DB "0.                 Exit"
STARTLEN5 EQU 23				;语句字符个数
;;------------------游戏界面-----------------------
PADMSG DB 25 DUP(219)			;小方格信息（每种俄罗斯方块由多个小方格组成）
COLMSG DB 25 DUP(179)			;列打印的线条 '|'
ROWMSG DB 25 DUP(223)			;行打印的线条 '_'
TMPMSG DB 25 DUP(?)				;暂存小方格信息	
;得分窗口（右侧窗口）信息
SCOREMSG1 DB 201,19 dup(205),187
SCOREMSG2 DB 186,' Score: ',32
SCOREMSG3 DB 32,9 dup(32),186
SCOREMSG4 DB 186,19 dup(32),186
SCOREMSG5 DB 186,19 dup(32),186
SCOREMSG6 DB 186,19 dup(32),186
SCOREMSG7 DB 186,19 dup(32),186,186,19 dup(32),186
SCOREMSG8 DB 204,19 dup(205),185
SCOREMSG9  DB 186,4 dup(32),' A  : Left  ',3 dup(32),186
SCOREMSG10 DB 186,4 dup(32),' D  : Right ',3 dup(32),186
SCOREMSG11 DB 186,4 dup(32),' W  : Rotate',3 dup(32),186
SCOREMSG12 DB 186,4 dup(32),' S  : Down  ',3 dup(32),186
SCOREMSG13 DB 186,4 dup(32),' Q  : Quit  ',3 dup(32),186
SCOREMSG14 DB 186,3 dup(32),'  Esc: Exit  ',3 dup(32),186
SCOREMSG15 DB 200,19 dup(205),188
;最高分显示
SIGNMSG1 DB 32,'Highest score:',32
;游戏窗口（左侧窗口）边框修饰，置于游戏窗口的窗顶，同样为图片的二进制文件
TopWidth	EQU  219			;设置icetop图片的宽度
TopHeight	EQU 54				;设置icetop高度
FrameTopX	EQU 50D				;设置icetop横坐标
FrameTopY	EQU 10D				;设置icetop纵坐标
TopFilename DB 'icetop.bin', 0	;icetop文件名和相对路径，icetop.bin与本文件存放于同一目录下
TopFilehandle DW ?				;文件句柄，从而对文件的内容进行操作
FrameData	DB	TopWidth*TopHeight DUP(0)	;存放icetop文件读取的数据信息
;;------------------游戏结束界面-----------------------
ENDMSG DB 0DH,0AH,'Good Bye!',0DH,0AH,'$'

;;------------------历史最高记录功能-----------------------
TD DB ' '
TP DB 1 dup(?)
BUFFER DB 100 dup(?)
FNAME DB 10 DUP(?);
PFILE DB 'C:\RECORD.TXT',00
UNAME DB 17,0,15 DUP(?)  		;UNAME记录当前用户的用户名
USCORE DB '0','0','0','0','0','$';USCORE记录当前用户的分数（分数表示标准化：5个字符，高位补零）
LASTSCORE DB 5 DUP('0'),'$'		;LASTSCORE记录历史记录最高分（分数表示标准化：5个字符，高位补零）
LASTUSER DB 20 DUP(?)			;LASTUSER记录历史记录最高分保持者
;历史最高纪录功能提示语
remind_rdmessage00   DB     0DH,0AH,'Wish you break the record next time!' ,0DH,0AH, '$'
remind_rdmessage01   DB     0DH,0AH,'Congratulations! You broke the record of the highest score!' ,0DH,0AH, '$'  
remind_rdmessage02   DB     0DH,0AH,'Congratulations! You reached the highest score!' ,0DH,0AH, '$'  
remind_rdmessage1   DB     'Your name:' ,0DH,0AH, '$'
remind_rdmessage2   DB     'Your score:' ,0DH,0AH, '$'
remind_rdmessage3   DB     'YOUR NAME AND SCORE ARE:' ,0DH,0AH, '$'
remind_rdmessage4   DB     'The RECORD was:' ,0DH,0AH, '$' 					;记录提示语连接词by
remind_rdmessage5   DB     ' by ' , '$' 									;记录提示语连接词by
remind_rdmessage6	 DB		0DH,0AH,'PRESS ANY KEY TO LEAVE...',0DH,0AH,'$'	;“等待任意键键入退出”的提示语

DATA ENDS

STACK SEGMENT STACK
DB 200 DUP(?)
STACK ENDS

CODE SEGMENT
		ASSUME 	CS:CODE,DS:DATA,ES:DATA,SS:STACK

;;--------初始页动画设计---------
;欢迎页面
WELCOME PROC NEAR				
		MOV     AX, 4F02H		;设置显示模式
		MOV     BX, 0100H		;将显示模式设置为640×400×256色
		INT     10H				
		CALL DRAWLOGO			;绘制logo图片
		CALL PRINTWEL			;打印欢迎语句
		RET
WELCOME ENDP

;绘制logo图片
DRAWLOGO PROC NEAR				
		MOV POSITIONINLOGOFILE,0;初始化在logo文件中的位置为0，即文件首
		CALL OPENLOGOFILE		;打开logo文件
		LEA BX,LOGODATA			;将logo数据的值赋给BX
		MOV CX,LOGOSTX			;加载logo横坐标
		MOV DX,LOGOSTY			;加载logo纵坐标
		MOV AH,0CH 				;清除键盘缓冲区，然后输入
DRAWLOOP:						;绘制LOGO图片
		PUSHA					
		MOV AH,42H 				;移动文件读写指针
		MOV AL,0				;从LOGO文件首位置开始
		MOV BX,LOGOFILEHANDLE	;logo文件数据缓冲区首址
		MOV CX,0				;记录当前该行打印的个数
		MOV DX,POSITIONINLOGOFILE;加载LOGO文件当前位置
		INT 21H
		CALL READLOGODATA		;读取logo文件数据
		POPA	
		MOV AL,[BX]				;加载文件句柄		
		CMP AL, 0FH				;判断当前像素颜色是否为白色
		JZ SKIPPIXEL			;是白色，则跳过该像素，不打印
			
		PUSH BX					;不是白色，打印该像素
		MOV BX,0100H			
		INT 10H					
		POP BX
SKIPPIXEL:	
		INC CX					;当前该行打印的个数递增
		CMP CX,LOGOFNX			;比较当前X和LOGOX的大小，考虑是否换行操作
		JNE DRAWLOOP 			;若当前行未完，继续打印该行
		MOV CX , LOGOSTX		;否则，跳转到图片的第一列
		INC DX					;转到下一行
		CMP DX , LOGOFNY		;比较当前Y和LOGOY的大小，考虑是否打印完图片
		JNE DRAWLOOP			;若未打印完图片，继续打印
		CALL CLOSELOGOFILE		;若打印完图片，关闭文件
		RET
DRAWLOGO ENDP	

;打开LOGO.BIN文件
OPENLOGOFILE PROC NEAR			
		MOV AH, 3DH				;打开文件
		MOV AL, 0				;只读
		LEA DX, LOGOFILENAME	;加载文件名
		INT 21H
		MOV [LOGOFILEHANDLE], AX ;将当前文件号移入LOGOFILEHANDLE
		RET
OPENLOGOFILE ENDP

;读取LOGO.BIN中的数据
READLOGODATA PROC NEAR			
		MOV AH,3FH				;读文件
		MOV BX, [LOGOFILEHANDLE];加载文件句柄
		MOV CX, 1				;读取的字节数
		INC POSITIONINLOGOFILE	;所处文件的位置递增
		LEA DX, LOGODATA		;logo文件数据缓冲区首址
		INT 21H					
		RET
READLOGODATA ENDP

;关闭LOGO.BIN文件
CLOSELOGOFILE PROC NEAR
			MOV AH, 3EH				;关闭文件	
			MOV BX, [LOGOFILEHANDLE];载入文件号
			INT 21H
			RET
CLOSELOGOFILE ENDP


;打印欢迎语句，闪动PRESS A KEY语句
PRINTWEL PROC NEAR
		MOV AX,DATA				
		MOV ES,AX				
		MOV BP, OFFSET WELMSG1	;显示欢迎字符串
		MOV CX, WELLEN1			;设置字符串长度	
		MOV DH, 16				;设置字符串位置的行				
		MOV DL, 22				;设置字符串位置的列
		MOV BL, 04H				;设置颜色为红色
		CALL PRINTMSG			;打印
WAIT_KEY:
		MOV BP, OFFSET WELMSG2	;显示PRESS A KEY字符串
		MOV CX, WELLEN2			;设置字符串长度
		MOV DH, 18				;设置字符串位置的行
		MOV DL, 22				;设置字符串位置的列
		MOV BL, 0FH				;设置颜色为白色
		CALL PRINTMSG			;打印PRESS A KEY字符串

		MOV SI,5				;传入SI，调用SLEEP进行等待
		CALL SLEEP				;此处等待时间约为1/4s
		MOV AH,1				;判别有无按键
		INT 16H					;键盘输入
		JNZ CONTINUE

		MOV BP, OFFSET WELMSG3	;打印空字符串，覆盖原字符串，实现闪动
		MOV CX, WELLEN3			;设置字符串长度
		MOV DH, 18				;设置字符串位置的行
		MOV DL, 22				;设置字符串位置的列
		MOV BL, 0FH				;设置颜色为白色
		CALL PRINTMSG			;打印PRESS A KEY字符串

		MOV SI,10				;传入SI，调用SLEEP2进行等待
		CALL SLEEP				;此处等待时间约为1/2s
		MOV AH,1				;判别有无按键
		INT 16H					;键盘输入
		JZ WAIT_KEY				;等待输入任意一个键，跳转循环
CONTINUE:
		MOV AH,0				;读入状态
		INT 16H					;键盘输入
		RET
PRINTWEL ENDP

;打印语句
PRINTMSG PROC NEAR
		MOV AH,13H				;打印字符串
		MOV AL,00H				
		MOV BH,0				
		INT 10H
		RET
PRINTMSG ENDP

;根据SI的大小调整等待时间
SLEEP PROC NEAR
		MOV AH, 0					;读当前时钟
		INT 1AH						;读写时钟参数
		MOV BX, DX					;记录初始时钟
SLEEPLOOP:	
		MOV AH, 0					;读当前时钟
		INT 1AH						;读写时钟参数
		SUB DX, BX					;将当前时钟减去初始时钟
		CMP DX, SI					;比较时间差与输入目标等待时间si
		JL SLEEPLOOP				;若等待未结束，继续等待
		RET
SLEEP ENDP
;;--------初始页动画设计---------

;;--------方块运动与控制逻辑---------
;下落以及控制操作主体函数
EXECUTE PROC NEAR					
EXECUTE1:
		STI						;开中断
		MOV AL,TIME
		CMP AL,SPEED			;将经过时间与所选速度比较
		JG NOMAL				;若时间已超过阈值，就下落
		MOV AH,1
		INT 16H					;读键盘
		JZ EXECUTE1
		
		MOV AH,0
		INT 16H					;读键盘
		CMP AL,1BH				;如果是Esc键则退出
		JNZ CONTIN				;不是则进行读取判断
		CALL RESTART
CONTIN:	
		CMP AL,'q'				;输入q
		JZ SDEND
		CMP AL,'a'				;输入a	
		JZ SD1
		CMP AL,'w'				;输入w	
		JZ SD2
		CMP AL,'d'				;输入d	
		JZ SD3
		CMP AL,'s'				;输入s	
		JZ SD4
		JMP NOMAL				;没有输入则正常下落

SD1:	MOV SOUND, 500H			;赋声音变量按键a对应的频率值
		JMP SDEND
SD2:	MOV SOUND, 1000H		;赋声音变量按键w对应的频率值
		JMP SDEND
SD3:	MOV SOUND, 1500H		;赋声音变量按键d对应的频率值
		JMP SDEND
SD4:	MOV SOUND, 2000H		;赋声音变量按键s对应的频率值
		JMP SDEND
SDEND:	CALL SOUNDFUN

		CMP AL,'q'				;按键q跳转
		JZ KQ
		CMP AL,'a'				;按键a跳转
		JZ KA
		CMP AL,'w'				;按键w跳转
		JZ KW
		CMP AL,'d'				;按键d跳转
		JZ KD
		CMP AL,'s'				;按键s跳转
		Jz KS

NOMAL:  MOV TIME,0H
		CALL TURN_DOWN			;自然下落
		CMP LIFE,0				;此方块下落过程未结束
		JE EXECUTE1
		CALL A_BLOCK			;此方块下落过程已结束，进入下一个方块
		JMP EXECUTE1
				
KQ:		CALL QUIT				;调用暂停游戏
		JMP EXECUTE1							
KA:    	CALL TURN_LEFT			;调用向左移动
		JMP EXECUTE1
KW: 	CALL ROTATE				;调用换向
		JMP EXECUTE1
KD:		CALL TURN_RIGHT			;调用向右移动
		JMP EXECUTE1
KS:   	CALL DELAY				;如果是s键则一直下落
		CALL TURN_DOWN
		CMP LIFE,1				;如果还能下落则继续下落
		JNE KS							
		CALL A_BLOCK			;无法下落，则当前方块生命周期结束，考虑下一个新方块
		JMP EXECUTE1
		RET		
EXECUTE ENDP

;变换方块方向
ROTATE PROC NEAR					
		MOV SI,OFFSET BLOCK		;取方块地址
		MOV AL,NOW_BLOCK		;取方块类型
		MOV AH,0H						
		MOV CL,32				;左移5位
		MUL CL
		ADD SI,AX				;把类型号给si（占前3位）
		
		MOV AL,DIRECTION		;取方向
		INC AL
		AND AL,03H				;尝试改变方向值
		
		MOV AH,0H						
		MOV CL,8				;左移3位
		MUL CL
		ADD SI,AX				;SI指向旋转后的BLOCK位置
		MOV DI,OFFSET BLOCK2	;将P2的地址给DI
		MOV CX,04H						
		CLD
ROT1: 	PUSH CX
		LODSW					;将SI的内容加载到AX
		MOV CL,RIGHT_SHIFT		;将XR给CL
		SHR AX,CL				;逻辑右移
		MOV CL,LEFT_SHIFT
		SHL AX,CL				;逻辑左移
		STOSW					;把AX中的内容复制到DI
		POP CX
		LOOP ROT1				;逐行进行变换

		CALL CHECK
		CMP AL,0H
		JNE ROT2
		MOV BX,0000H						
		CALL DISPPAD			;清空原来的方块
		CALL COPY21				;把方块数据从实验态复制到稳态，说明可以变换
		INC DIRECTION
		AND DIRECTION,3H		;改变方向值
		MOV BH,00H
		MOV BL,NOW_COLOR	
		CALL DISPPAD			;画新的方块
ROT2: RET
ROTATE ENDP

;右移操作
TURN_RIGHT PROC NEAR
		CALL COPY12
		MOV SI,OFFSET BLOCK2
		MOV CX,04H
TUR1:  	MOV AX,[SI]
		SHR AX,1				;右移一位，反应到图形上即向右平移
		MOV [SI],AX
		INC SI
		INC SI					;SI直到图形下一行
		LOOP TUR1				;逐行右移
		CALL CHECK
		CMP AL,0H
		JNE TUR3
		MOV BX,0000H
		CALL DISPPAD			;清空原来的方块
		CALL COPY21
		CMP LEFT_SHIFT,0
		JE TUR2					;无左移过，则右移记录加一
		DEC LEFT_SHIFT
		DEC RIGHT_SHIFT			;左移过，则抵消一次
TUR2:  	INC RIGHT_SHIFT
		MOV BH,00H
		MOV BL,NOW_COLOR
		CALL DISPPAD			;画新的方块
TUR3:  	RET
TURN_RIGHT ENDP

;左移操作（同右移）
TURN_LEFT PROC NEAR
		CALL COPY12
		MOV SI,OFFSET BLOCK2
		MOV CX,04H
TUL1: 	MOV AX,[SI]
		SHL AX,1
		MOV [SI],AX
		INC SI
		INC SI
		LOOP TUL1
		CALL CHECK
		CMP AL,0H
		JNE TUL3
		MOV BX,0000H
		CALL DISPPAD
		CALL COPY21
		CMP RIGHT_SHIFT,0
		JE TUL2
		DEC RIGHT_SHIFT
		DEC LEFT_SHIFT
TUL2:  	INC LEFT_SHIFT
		MOV BH,00H
		MOV BL,NOW_COLOR
		CALL DISPPAD
TUL3: 	RET
TURN_LEFT ENDP

;方块下落
TURN_DOWN PROC NEAR
		CALL COPY12
		INC NEXT_ROW			;尝试下一行
		CALL CHECK
		CMP AL,0H
		JNE TUD					;下一行冲突，则说明已经落底
		MOV BX,0000H
		CALL DISPPAD			;清空原来的方块
		CALL COPY21				;实验态可行，传回稳态
		MOV BH,00H
		MOV BL,NOW_COLOR
		CALL DISPPAD			;画新的方块
		MOV LIFE,00H			;这一个方块落下过程仍没结束
		RET
TUD:  	CALL AFTERMATH
		MOV LIFE,01H			;这个方块落下过程已结束
		RET
TURN_DOWN ENDP

;暂停游戏，按任意键恢复
QUIT PROC NEAR
		MOV AH,07H
		INT 21H					;中断暂停
		RET
QUIT ENDP
;;--------方块运动与控制逻辑---------

;;--------方块生命周期逻辑---------
;一个方块的过程
A_BLOCK PROC NEAR
		MOV AL,NEXT_BLOCK
		MOV NOW_BLOCK,AL
		CALL RANDOM				;构建随机方块
		CALL DISPSCORE			;显示分数
		CALL DISPNEXT			;构建下一个方块
		MOV DIRECTION,0			;置初始方向为0
		MOV CURRENT_ROW,4		;设初值
		MOV NEXT_ROW,4					
		MOV RIGHT_SHIFT,0					
		MOV LEFT_SHIFT,0
		
		MOV AH,0
		MOV AL,NOW_BLOCK		;将AX设置为NOW_BLOCK
		MOV SI,AX				;将AX的值传给SI
		MOV CL,COLOR[SI]		;将颜色属性值传给cl
		MOV NOW_COLOR,CL		;用NCOLOR保存颜色属性
		MOV DI,OFFSET BLOCK2	;将BLOCK2的地址给DI
		MOV SI,OFFSET BLOCK		;将BLOCK的地址给SI
		MOV BL,32					
		MUL BL					;左移5位
		ADD SI,AX				;AX相当于第几个
		MOV CX,08
		CLD
		REP MOVSB				;将SI所指的内容复制给DI所指内容
		
		CALL COPY21				;BLOCK2复制到BLOCK1,SI指向BLOCK2，DI指向BLOCK1
		MOV BH,0H				;0页
		MOV BL,NOW_COLOR		;颜色属性
		CALL DISPPAD			;画方块
		CALL CHECK				;检查是否存在冲突，若冲突AL=F,否则AL=0
		CMP AL,0
		JE AB1					;不冲突跳转
		MOV AH,08H				;冲突则说明不能容纳新方块，游戏重新开始
		INT 21H
		CALL RESTART
AB1:  	CALL DELAY
		MOV TIME,0H				;计时清零
		RET
A_BLOCK ENDP

;生成随机数决定方块类型
RANDOM PROC NEAR
RAN1:  	IN AX,40H				;开始随机选择方块类型,al=时间随机值
		INC AL					
		AND AL,07H				;保留后三位
		CMP AL,07H				;选择0-6之间的数字
		JE RAN1				
		MOV NEXT_BLOCK,AL		;将AL的值传给NEXT_BLOCK
		RET
RANDOM ENDP
		
;检测实验态（P2）是否和边框等存在冲突
CHECK PROC NEAR 				;返回AL=0或F 0为OK F为NO
		MOV AH,0H
		MOV AL,NEXT_ROW
		ADD AL,NEXT_ROW			;移至暂存行
		MOV SI,OFFSET GAMEBOARD	;把当前的游戏情况加载到SI
		ADD SI,AX
		MOV DI,00H
		MOV CX,04H
		CLD
CHE1:  	LODSW					;将SI中的内容（暂存行）加载到AX
		AND AX,BLOCK2[DI]		
		JNZ CHE2				;非0说明有列原来有方块，新方块也要占据此位置，有冲突
		INC DI
		INC DI					
		LOOP CHE1				;循环判断，逐行检查
		MOV AL,00H
		RET
CHE2: 	MOV AL,0FH
		RET
CHECK ENDP

;将BLOCK2复制到BLOCK1
COPY21 	PROC NEAR
		CLD						;从前往后处理字符串
		MOV SI,OFFSET BLOCK2
		MOV DI,OFFSET BLOCK1
		MOV CX,08				
		REP MOVSB				;复制BLOCK2串到BLOCK1串
		MOV CL,NEXT_ROW
		MOV CURRENT_ROW,CL
		RET
COPY21 ENDP
		
;将BLOCK1复制到BLOCK2（同上）
COPY12 	PROC NEAR
		CLD
		MOV SI,OFFSET BLOCK1
		MOV DI,OFFSET BLOCK2
		MOV CX,08
		REP MOVSB
		MOV CL,CURRENT_ROW
		MOV NEXT_ROW,CL
		RET
COPY12 ENDP
;;--------方块生命周期逻辑---------

;;--------整行消除相关逻辑---------
;方块落底善后处理（落底指落到游戏框底部或其他方块上）
AFTERMATH PROC NEAR				;改颜色、消除整行、方块下落处理
		CALL CHANGE_COLOR		;落底变色

		CALL FUSION				;新方块填入原有的方块空隙中

		MOV SI,OFFSET GAMEBOARD	;进入整行消除
		ADD SI,23*2				;从最后一行开始
		MOV DI,SI
		MOV CX,20				;循环次数，可能有方块的区域共20行
		MOV BH,00H				
		MOV FULL,00H			;标志清零
		STD						;SI自减
		
AFT1: 	LODSW					;将SI的内容加载到AX,即AX为当前检查行的内容
		CMP AX,0FFFFH			;检查是否满行
		JNE AFT2				;不是整行跳转(则此行为第一个不是整行处)
		MOV FULL,0FFH			;是整行,则标志
		MOV AL,ADD_SCORE
		SAL AL,1
		MOV ADD_SCORE,AL		;得分加
		JMP AFT1

AFT2: 	STOSW					;将AX的内容写回DI所指区域（即消除整行，非整行下落）,AX自动指向上一行
		CMP FULL,0H				;判断此前是否检查到整行
		JE AFT5					;如果没有消除则跳转
		
		PUSH CX					;进入消除
		MOV DH,CL				;CL即为当前行在可能有方块区域中的位置						
		ADD DH,03H				;游戏区域前3行不会有方块
		MOV DL,0AH				;行列属性
		MOV BX,0000H			;颜色属性，先置为涂黑
		MOV BP,OFFSET PADMSG	;BP指向小方格串
		MOV CX,20
		PUSH AX
		MOV AX,1300H					
		INT 10H					;将bp所指内容在指定行列输出，循环20次（清空消除整行），显示字符串PADMSG
		POP AX

		MOV CL,03H						
		SHL AX,CL				;清除前导3个1
		MOV CX,0AH				;游戏区宽度共10个小方格
		MOV DL,08H				;列号
AFT3: 	INC DL
		INC DL					;每个小方格边长为2，故INC两次
		MOV BL,0H
		
		SHL AX,1				;检查上一行是否有方块下落
		JNC AFT4				;无进位跳转直接涂黑
		MOV BL,01011001b		;落定块以特定颜色显示
AFT4: 	CALL DRAW_PAD			;画出方块
		LOOP AFT3				;循环检查每一列
		POP CX							
AFT5: 	LOOP AFT1

		CALL COMPUTE_SCORE		;计算得分
		RET
AFTERMATH ENDP

;改变方块颜色，先清除原色再上新色
CHANGE_COLOR PROC NEAR
		MOV BH,0H
		MOV BL,0h
		CALL DISPPAD			;清除原有方块
		MOV BH,0H
		MOV BL,01011001b		;设置颜色
		CALL DISPPAD			;显示新方块
		RET
CHANGE_COLOR ENDP

;新方块和已累积的方块合并
FUSION PROC NEAR
		MOV ADD_SCORE,01H						
		MOV AH,0H
		MOV AL,CURRENT_ROW
		ADD AL,CURRENT_ROW		;CURRENT_ROW是逻辑行数要*2转化为图形上的行数
		MOV SI,OFFSET GAMEBOARD
		ADD SI,AX				;指到这个方块落下的底部的行数
		MOV DI,00H
		MOV CX,04H				;新方块最多涉及四行
		CLD						;SI自增
FUS1: 	LODSW					;将SI所指内容加载到AX
		OR AX,BLOCK1[DI]		;填入新方块					
		MOV [SI-2],AX
		INC DI
		INC DI					
		LOOP FUS1				;将BLOCK1中的内容整合到游戏区;;DI 0~6填入所有方块
		RET
FUSION ENDP

;分数计算
COMPUTE_SCORE PROC NEAR
		MOV AL,ADD_SCORE
		SAR AL,1
		ADD SCORE[3],AL			;一个方块下落完成后总得分
		MOV CX,05H
		MOV SI,04H
COM1: 	CMP SCORE[SI],'9'		;得分转换
		JNG COM2
		INC SCORE[SI-1]
		SUB SCORE[SI],0AH
COM2: 	DEC SI
		LOOP COM1
		RET
COMPUTE_SCORE ENDP
;;--------整行消除相关逻辑---------

;;--------方块绘制---------
;绘制方块主体函数（涂黑可作清除用，其他颜色可作画方块用）
DISPPAD PROC NEAR					
		MOV SI,OFFSET BLOCK1	;将BLOCK1的地址给SI
		MOV CX,04H				;循环次数
		MOV DL,08H				;生成方块初始位置的列数
		MOV DH,CURRENT_ROW
		ADD DH,04H				;设置行列，前3列不会存在方块
		PUSH DX
		
		CLD						;从前往后
DIS1:  	LODSW					;将SI中的内容加载到AX
		POP DX
		PUSH DX
		SUB DH,CL				;起始行改变，CURRENT_ROW+0、+1、+2、+3共4行画出方块
		PUSH CX					
		MOV CL,03H					
		SHL AX,CL				;去掉开头3位
		MOV CX,0AH				;循环次数（10列）
DIS2:  	INC DL						
		INC DL					;列数加
		SHL AX,1				;左移一位
		JNC DIS3				;没有进位则无方格，跳转
		CALL DRAW_PAD			;有进位则显示方块
DIS3:  	LOOP DIS2				;10列全部扫描
		POP CX					
		LOOP DIS1				;画出整个方块
		POP DX
		RET
DISPPAD ENDP

;画方块
DRAW_PAD PROC NEAR 				;DH:行 DL:列 BH:页 BL:颜色
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI					;保存寄存器
		
		MOV BP,OFFSET PADMSG	;将PADMSG的地址传给BP
		MOV CX,02H					
		MOV AX,1300H			;将BP所指地址的内容显示出来
		INT 10H					;将原方块位置处的方块涂成背景色
		
		CMP BL,0H					
		JE DBL5					;清完原来的方块跳转
		
		MOV AH,0H					
		MOV AL,DH				;行号传AL
		MOV CL,16
		MUL CL					;左移4位
		MOV SI,AX					
		MOV AH,0H					
		MOV AL,DL				;列号传AL
		MOV CL,8				;左移3位
		MUL CL
		MOV DI,AX					
		MOV AX,0C00H			;AH = 0CH，表示显示一点
		MOV DX,SI				;DX存Y坐标
		ADD DX,15					
		MOV CX,16				;CX存X坐标
DBL1: 	ADD CX,DI
		DEC CX
		INT 10H
		INC CX
		SUB CX,DI
		LOOP DBL1				;循环显示一小行亮点（美化作用）
		MOV DX,SI
		MOV CX,15
		ADD DI,15
DBL2: 	PUSH CX
		MOV CX,DI
		INT 10H
		INC DX
		POP CX
		LOOP DBL2
		SUB DI,2
		DEC DX
		MOV CX,13
DBL3: 	PUSH CX
		DEC DX
		MOV CX,DI
		INT 10H
		SUB CX,12
		MOV AL,07H
		INT 10H
		MOV AL,00H
		POP CX
		LOOP DBL3
		MOV AX,0C07H
		MOV DX,SI
		ADD DX,1
		MOV CX,12
		SUB DI,12
DBL4: 	ADD CX,DI
		INT 10H
		SUB CX,DI
		LOOP DBL4				;上述的函数的作用在于输出一行行亮斑行，将被显示的方块包裹起来
DBL5: 	POP SI
		POP DI
		POP DX
		POP CX
		POP BX
		POP AX					;还原寄存器的值
		RET
DRAW_PAD ENDP
;;--------方块绘制---------


;;--------选择速度界面---------
;选择速度，共3档可选
SELECT_SPEED PROC NEAR
		CALL CLS					;清屏函数
		MOV     AX, 4F02H			;设置显示模式
		MOV     BX, 0100H			;将显示模式设置为640×400×256色
		INT     10H
		CALL DRAWLOGO				;调用绘制logo函数，打印logo图片
SELECT:	
		;;打印字符串
		MOV BP, OFFSET STARTMSG1
		MOV CX, STARTLEN1			;设置字符串长度
		MOV DH, 15					;设置字符串行位置
		MOV DL, 25					;设置字符串列位置
		MOV BL, 0FH					;设置颜色
		CALL PRINTMSG				;打印字符串
		;1. Fast
		MOV BP, OFFSET STARTMSG2
		MOV CX, STARTLEN2			;设置字符串长度
		MOV DH, 16					;设置字符串行位置
		MOV DL, 25					;设置字符串列位置
		MOV BL, 0FH					;设置颜色
		CALL PRINTMSG				;打印字符串
		;2.	Middle
		MOV BP, OFFSET STARTMSG3
		MOV CX, STARTLEN3			;设置字符串长度
		MOV DH, 17					;设置字符串行位置
		MOV DL, 25					;设置字符串列位置
		MOV BL, 0FH					;设置颜色
		CALL PRINTMSG				;打印字符串
		;3. Slow	
		MOV BP, OFFSET STARTMSG4
		MOV CX, STARTLEN4			;设置字符串长度
		MOV DH, 18					;设置字符串行位置
		MOV DL, 25					;设置字符串列位置
		MOV BL, 0FH					;设置颜色
		CALL PRINTMSG				;打印字符串
		;4. Exit
		MOV BP, OFFSET STARTMSG5
		MOV CX, STARTLEN5			;设置字符串长度
		MOV DH, 19					;设置字符串行位置
		MOV DL, 25					;设置字符串列位置
		MOV BL, 0FH					;设置颜色
		CALL PRINTMSG				;打印字符串

		;;检查输入是否为0-3
		MOV AH,08H					;输入一个字符					
		INT 21H						
		SUB AL,'0'					;将输入字符减去0
		MOV CL,AL					;将结果移入cl中
		AND AL,3					;和3与运算
		CMP AL,CL					;比较是否在0-3之间
		JNE SELECT					;如果不是0-3继续输入
		
		;;判断输入是否为0
		INC AL						
		INC CL						
		MUL CL						
		CMP CL,1H					;比较
		JZ EX						;若相等，说明输入的字符为0
		MOV SPEED,AL				;若不等，根据AL设置速度
		RET
EX: 	CALL EXIT					;退出
SELECT_SPEED ENDP
;;--------选择速度界面---------

;;--------游戏页面绘制---------
;初始化
INITGAME PROC NEAR						
		CLD							;从前往后处理
		MOV DI,OFFSET GAMEBOARD		;将BOARD的地址给DI
		MOV CX,24					;构建游戏区
		MOV AX,0E007H				;1110000000000111（0为游戏区）24行
		REP STOSW					;将ax中的值拷贝到ES:DI指向的地址
		
		MOV DI,OFFSET SCORE			;构建分数
		MOV AL,'0'
		MOV CX,05H
		REP STOSB					;将al中的值拷贝到ES:DI指向的地址
		
		CALL RANDOM					;调用随机函数
		MOV AL,NEXT_BLOCK
		MOV NOW_BLOCK,AL
		RET
INITGAME ENDP

;绘制页面
DRAW_WINDOW PROC NEAR
		CALL CLS					;初始化屏幕
		CALL DRAW_RIGHT_WINDOW		;画右边窗口
		CALL DRAW_LEFT_WINDOW		;画左边窗口
		CALL DRAW_RIGHT_WINDOW		;画右边窗口
		CALL DRAW_HIGHEST			;显示最高分
		RET
DRAW_WINDOW ENDP

;画右侧框（仅SCOREMSG内容）
DRAW_RIGHT_WINDOW PROC NEAR
		MOV CX,15					;右侧框共15条MSG
		MOV BP,OFFSET SCOREMSG1		;将SCOREMSG1的地址传给BP，即输出串地址
		MOV DX,0529H				;DX控制小窗口位置，DH = 起始行，DL = 起始列
LOOPFRAME: 
		PUSH CX						
		MOV CX,21					;每行宽度
		MOV AL,0H					;逐个字符读，光标返回起始位置
		MOV BH,0H					;BH = 页号
		MOV BL,1111B				;设置为白色
		MOV AH,13H					;显示字符串SCOREMSG1
		INT 10H						
		
		ADD BP,21					;下一个字符串
		INC DH						;起始行号加1
		POP CX
		LOOP LOOPFRAME				;将右侧框15条MSG显示出来
		RET
DRAW_RIGHT_WINDOW ENDP

;画左侧框
DRAW_LEFT_WINDOW PROC NEAR
		PUSHA
		MOV     AX, 4F02H			;设置显示模式
		MOV     BX, 0100H			;将显示模式设置为640×400×256色
		INT     10H				
		CALL TOP_FILE_OPERATION		;进行icetop文件的打开、读取、关闭的操作
		CALL DRAW_MAIN_FRAME		;打印左侧游戏框上侧的装饰图片
		POPA
		;;框线统一初始化
		MOV BL,0FH					;设置框线颜色为白色
		;;纵向框线的统一初始化
		MOV BP,OFFSET COLMSG		;列的竖线表示，采用字符'|'

		;;打印左侧游戏框的左框线
		 MOV CX,20					;左侧框线打印的个数
		 MOV DX,0309H				;左线框位置
LOOPLEFT:
		 MOV SI,CX					;将目标打印个数移入SI中暂存，表示循环次数
		 MOV CX,01					
		 MOV BH,0H					;BH = 页号
		 INC DH						;纵坐标位置+1
		 INT 10H						
		 MOV CX,SI					
		 LOOP LOOPLEFT				;未打印完全则继续打印
		 ;;打印左侧游戏框的右框线
		MOV CX,20					;右侧框线打印的个数
		MOV DX,031EH                ;右边框位置
 LOOPRIGHT:
		MOV SI,CX					;将目标打印个数移入SI中暂存，表示循环次数
		MOV CX,01					
		MOV BH,0H					;BH = 页号
		INC DH						;纵坐标位置+1
		INT 10H						
		MOV CX,SI					
		LOOP LOOPRIGHT				;未打印完全则继续打印
		
		;;打印左侧游戏框的底框线
		MOV BP,OFFSET ROWMSG	    ;行的横线表示，采用字符'_'	
		MOV BH,0H					;BH = 页号			
		MOV CX,20					;底框线长度                    
		MOV DX,180AH                ;底框线位置  
		INT 10H	

		RET
DRAW_LEFT_WINDOW ENDP

;处理bin文件
TOP_FILE_OPERATION PROC NEAR
;;打开bin文件
	MOV AH, 3DH						;打开文件
	MOV AL, 0						;只读
	LEA DX, TopFilename				;加载文件名
	INT 21H
	MOV [TOPFILEHANDLE], AX			;将icetop文件号移入LOGOFILEHANDLE
;;读取bin文件
	MOV AH,3FH						;读文件
	MOV BX, [TOPFILEHANDLE]			;加载文件句柄
	MOV CX, TOPWIDTH*TOPHEIGHT		;读取的字节数
    LEA DX, FRAMEDATA				;icetop文件数据缓冲区首址
	INT 21H
;;关闭文件
	MOV AH, 3EH						;关闭文件
	MOV BX, [TOPFILEHANDLE]			;载入文件号
	INT 21H
TOP_FILE_OPERATION ENDP

;绘制Frame图片
DRAW_MAIN_FRAME PROC NEAR
	LEA BX, FRAMEDATA				;将icetop数据的值赋给BX
	MOV CX, FRAMETOPX				;加载icetop横坐标
	MOV DX, FRAMETOPY				;加载icetop纵坐标
	MOV AH, 0CH						;清除键盘缓冲区，然后输入
DRAWICETOP:
		MOV AL,[BX]					;移入文件句柄				
		INT 10H						
		INC CX						;当前图片横坐标递增
		INC BX						;下一条icetop数据
		CMP CX, TOPWIDTH + FRAMETOPX;比较，判断当前行是否打印完
		JNE DRAWICETOP				;若当前行未完，继续打印该行
		MOV CX , FRAMETOPX			;否则，跳转到图片的第一列
		INC DX						;转到下一行
		CMP DX, TOPHEIGHT + FRAMETOPY;比较，判断是否打印完图片	
		JNE DRAWICETOP				;若未打印完图片，继续打印，直到全部打印完				
DRAW_MAIN_FRAME ENDP

;清屏函数
CLS PROC NEAR						
		MOV CX,0					;CH = 左上角行号，CL = 左上角列号
		MOV DH,24					;DH = 右下角行号
		MOV DL,79					;DL = 右下角列号
		MOV BH,0					;BH = 卷入行属性
		MOV AX,600H					;初始化屏幕,AL = 0全屏幕为空白
		;;AH=06H BIOS
		INT 10H
		RET
CLS ENDP

;显示最高分
DRAW_HIGHEST PROC NEAR
        MOV BP,OFFSET SIGNMSG1	;显示字符串提示：（“Highest score:”）
		MOV CX,22				;字符串长度   	          
		MOV BL,0FH				;字符串颜色
		MOV DX,0229H			;字符串起始位置	
		MOV AH,13H              
		INT 10H	
		
		MOV BP,OFFSET BUFFER	;读取并显示历史最高分
		MOV CX,22           	;显示区长度    
		PUSH BP
		CALL READ_TOPRANK		;调用读取最高历史分的函数
		POP BP    	          
		MOV BL,0FH          
		MOV DX,0239H			;显示开始位置
		MOV AH,13H              
	    INT 10H	
		RET
DRAW_HIGHEST ENDP

;显示分数（游戏界面右方框中的实时分数）
DISPSCORE PROC NEAR					
		MOV AX,DATA					
		MOV ES,AX					
		MOV BP,OFFSET SCORE			;将Score的地址给BP	
		MOV CX,05H					;字符串长度
		MOV DX,0635H				;起始位置
		MOV BH,0H					;页码
		MOV AL,0H					;逐个字符输出，光标返回起始位置
		MOV BL,00110100B			;字符属性
		MOV AH,13H
		INT 10H						;输出
		RET
DISPSCORE ENDP

;显示下一个方块
DISPNEXT PROC NEAR					
		MOV AX,DATA
		MOV ES,AX
		MOV BP,OFFSET TMPMSG		;将TMPMSG的地址给BP
		MOV DI,BP					;将TMPMSG的地址给DI
		MOV SI,OFFSET BLOCK			;将BLOCK的地址给SI
		MOV AL,NEXT_BLOCK			;将方块数传给AL
		MOV AH,0					
		MOV BL,32					;方块号左移5位
		MUL BL
		ADD SI,AX					;SI = 0[al]00000
		CLD							;从前往后读取
		MOV CX,04H					;4个字符
DISN1:  PUSH CX						;保存CX的值
		LODSW						;从SI中取一个字到AX
		MOV CL,06H
		SHL AX,CL					;左移6位清空前导0(ax的数据为0000+[pad]（12位）)
		MOV CX,04H					;最多一行4个1
DISN2:  MOV BL,20H					;将空格的ASCII值传给BL
		SHL AX,1					;逻辑左移一位，高位进CF位
		JNC DISN3					;如果CF不是1则跳转
		MOV BL,219					;如果CF是1则将BL的值变为方块的ASCII
DISN3:  MOV [DI],BL					;将BL的值传给TMPMSG
		INC DI						;DI自增
		MOV [DI],BL					
		INC DI
		LOOP DISN2					;循环画出所有的是1的位置（一行）
		MOV DX,0C30H				;起始位置s
		POP CX						;还原CX的值
		SUB DH,CL					;行号减（从底往上画）
		PUSH CX						;保存CX的值
		MOV CX,08H					;字符串长度
		MOV BH,0H					;页号
		PUSH SI						;保存SI的值
		MOV AH,0H					
		MOV AL,NEXT_BLOCK			;将下个方块值传给AL
		MOV SI,AX					
		MOV BL,COLOR[SI]			;设置颜色属性
		POP SI
		MOV AX,1300H				;显示字符串
		INT 10H
		POP CX						;还原cx的值
		MOV DI,BP					;把BP的值给DI
		LOOP DISN1					;循环画出整个方块
		RET
DISPNEXT ENDP
;;--------游戏页面绘制---------

;;--------声音效果---------
SOUNDFUN PROC NEAR
		PUSH AX						;推入堆栈保存原始值
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		MOV AL,0B6H					;设置定时器工作方式
		OUT 43H,AL					;将AL寄存器的值写入端口地址为34H的端口
		MOV DX,12H
		MOV AX, SOUND 				;将声音变量频率值赋给AX
		OUT 42H,AL					;设置定时器计数值
		MOV AL,AH
		OUT 42H,AL
		IN AL,61H					;打开扬声器声音
		MOV AH,AL
		OR AL,3						;其他位不变
		OUT 61H,AL
SOU1:  	MOV CX,663
		CALL WAITF
		DEC BX
		JNZ SOU1
		MOV AL,AH
		OUT 61H,AL
		POP SI						;推出堆栈还原各寄存器值
		POP DI
		POP DX
		POP CX
		POP BX
		POP AX
		RET
SOUNDFUN ENDP

WAITF PROC NEAR
		PUSH AX
WAITF1: IN AL,61H
		AND AL,10H					;取AL从低往高第5位
		CMP AL,AH
		JE WAITF1					;若AL与AH相等则跳转WAITF1
		MOV AH,AL
		LOOP WAITF1					;循环WAITF1
		POP AX
		RET
WAITF ENDP
;;--------声音效果---------

;;--------历史最高纪录功能---------
;展示历史最高纪录
TOPRANK PROC NEAR
		MOV AX,DATA
		MOV DS,AX
		;复制score给当前用户分数uscore
		MOV ES,AX					;将目标位置uscore的地址基址传给ES
		MOV SI,OFFSET SCORE			;源字符串score的偏移地址传给SI
		MOV DI,OFFSET USCORE		;将目标位置uscore的偏移地址传给DI
		MOV CX,5					
		CLD							
		REP MOVSB					;串操作命令(5次)，复制score给当前用户分数uscore
		;显示将读取排行榜的最高纪录   
		lea dx,remind_rdmessage4	;将提示语偏移地址传给DX，将读取最高纪录
		mov ah,09h					;显示字符串
		int 21h
		CALL RDF1					;调用RDF1，读取并显示历史最高纪录
CMPSTR:
		;用串操作比较大小比较历史最高纪录与当前分数	
		LEA SI,USCORE				;传比较数的偏移地址给SI
		LEA DI,LASTSCORE			;传被比较数的偏移地址给DI
		MOV CX,5					
		CLD							
		REPZ CMPSB					;串操作比较指令(5次)，当字符不相等时结束比较
		JG BIGGER   				;若USCORE>LASTSCORE则跳转SMALLER
		JE EQUAL					;若USCORE=LASTSCORE，则跳转EQUAL
		JL SMALLER					;若USCORE<LASTSCORE则跳转SMALLER
EXT:   
		CALL WAIT_ANY_KEY			;调用WAIT_ANY_KEY子程序
		RET							;退出子程序
BIGGER:
		CALL OUT_ALL				;回车空行
		lea DX,remind_rdmessage01	;屏幕显示提示语
		mov AH,09H					;显示字符串
		int 21H
		CALL OUT_ALL				;回车空行
		CALL UPDATE					;更新本地文件的最高历史记录
		JMP EXT						;无条件跳转至退出段
SMALLER:
		lea DX,remind_rdmessage00 	;屏幕显示提示语
		mov AH,09H					;显示字符串
		int 21H
		JMP EXT						;无条件跳转至退出段

EQUAL:
		lea DX,remind_rdmessage00	;屏幕显示提示语
		mov AH,09H					;显示字符串
		int 21H
		JMP EXT						;无条件跳转至退出段
TOPRANK ENDP

;等待任意键键入再运行程序下一步
WAIT_ANY_KEY PROC NEAR
		MOV AX,DATA
		MOV DS,AX		
		LEA DX, remind_rdmessage6	;显示"按任意键退出程序"的英文字符串
		MOV AH,09H					;显示字符串	
		INT 21h
		CALL QUIT					;执行QUIT子程序（按任意键退出程序）
		RET
WAIT_ANY_KEY ENDP

;对内存中的字符串加修饰
MODIFY_UNAME PROC NEAR		
		MOV AX,DATA
		MOV DS,AX
		LEA DX,UNAME				;将UNAME基址传给DX
		MOV CL,UNAME+1;				;读取字符串实际写入的字符个数到CX
		XOR CH,CH					
		ADD DX,CX					;相加得到字符串尾的实际地址CX并写入DX
		MOV BX,DX					;将DX中的字符串尾地址传给BX
		MOV BYTE PTR[BX+2],'$'		;在字符串最后加'$'
		RET
MODIFY_UNAME ENDP

;在屏幕上输出用户信息的内容
SHOW_USERINFO PROC NEAR
		
		MOV AX,DATA
		MOV DS,AX
		lea dx,remind_rdmessage3	;屏幕显示提示语
		mov ah,09h					;显示字符串
		int 21h
		MOV BX,OFFSET UNAME[2]		;传UNAME实际开始的位置UNAME[2]的偏移地址给BX
		MOV DX,BX					;传BX值给DX
		MOV AH,09H					;显示UNAME（从下标为2处写）
		INT 21H
		CALL OUT_ALL				;在界面上显示空一行
		MOV BX,OFFSET USCORE		;传USCORE的偏移地址给BX
		MOV DX,BX
		MOV AH,09H					;显示USCORE
		INT 21H
		RET
SHOW_USERINFO ENDP

;更新历史最高纪录
UPDATE PROC NEAR
		;从键盘读取字符串并存入内存中
		MOV AX,DATA
		MOV DS,AX
		lea dx,remind_rdmessage1	;屏幕显示提示语：输入用户名
		mov ah,09h					;显示字符串
		int 21h
		LEA DX,UNAME				;获得UNAME的偏移地址
		MOV AH,0AH					;从键盘读入字符串
		INT 21H
		CALL OUT_ALL				;在界面上显示空一行
		CALL MODIFY_UNAME			;对内存中的字符串加修饰
		CALL SHOW_USERINFO			;在屏幕上输出用户信息的内容
		MOV AX,DATA
		MOV DS,AX
		CALL OUT_ALL
		JMP CRF  
CRF:								;创建文件
		MOV AH,3CH					;将创建文件功能号传给3CH
		MOV CX,00H					;设定文件属性CX，0为默认
		LEA DX,PFILE				;将PFILE的偏移地址传给文件绝对路径DX
		INT 21H						
		LEA BX,FNAME				;获取文件存储标记的偏移量
		MOV [BX],AX;
WRF:								;写文件
		LEA SI,FNAME;				;将文件存储标记的偏移量传给BX
		MOV BX,[SI]					
		MOV AX,OFFSET UNAME[2]		;向文件写入UNAME
		MOV DX,AX					
		MOV CL,UNAME+1				;将UNAME中实际写入的字符数传给CX
		XOR CH,CH					
		MOV AH,40H					;将写入文件功能号传给AX
		INT 21H						
		;for循环用于规范写入文件的UNAME格式（若UNAME字符数不到8则补空格）
		MOV TP,8					;设定临时变量TP的值为8
		SUB TP,CL					;减法计算得到需要写入的空格数，传给TP
NEXTTB1:
		LEA SI,FNAME;				;将文件存储标记通过SI偏移量传给SIBX
		MOV BX,[SI]						
		MOV AX,OFFSET TD			;将TD（空格）的偏移地址通过AX传给DX
		MOV DX,AX						
		MOV CL,1					;设定CX为0001H
		XOR CH,CH
		MOV AH,40H					;将写入文件功能号传给AH
		INT 21H	
		SUB TP,1					;需要写入的空格个数TP自减1
		CMP TP,1					;比较TP与1大小，判断是否需要继续写空格
		JNC NEXTTB1;				;若TP>=1，则重复循环
		LEA SI,FNAME;				;将文件存储标记通过SI偏移量传给SIBX
		MOV BX,[SI]						
		MOV AX,OFFSET USCORE		;将USCORE的偏移地址通过AX传给DX
		MOV DX,AX
		MOV CL,5					;cx的值为0005H
		XOR CH,CH					;CX表示写入字符的个数						
		MOV AH,40H
		INT 21H						;将写入文件功能号传给AX执行写入
		JMP CLF
CLF:								;关闭文件
		LEA SI,FNAME;				;将文件存储标记通过SI偏移量传给BX
		MOV BX,[SI]
		MOV AH,3FH					;将关闭文件功能号传给AX执行写入
		INT 21H
		RET
UPDATE ENDP

;回车换行
OUT_ALL PROC NEAR
		MOV  DL, 13   				;回车
		MOV  AH, 2
		INT  21H
		MOV  DL, 10   				;光标换行
		MOV  AH, 2
		INT  21H
		RET
OUT_ALL ENDP

;从缓冲区复制到lastuser的内容
NAME_CPY PROC NEAR
		MOV AX,DATA					;源操作数BUFFER的段地址通过AX传给DX					
		MOV DS,AX
		MOV AX,DATA					;目标操作数LASTUSER的段地址通过AX传给DX
		MOV ES,AX
		MOV SI,OFFSET BUFFER		;源操作数BUFFER的偏移地址传给SI
		MOV DI,OFFSET LASTUSER		;目标操作数LASTUSER的偏移地址传给DI
		MOV CX,8					;CX表示复制字符个数，设为8
		CLD	
		REP MOVSB					;串操作复制出lastuser的内容
		RET
NAME_CPY ENDP

;从缓冲区复制到lastscore
SCORE_CPY PROC NEAR
		MOV AX,DATA					;源操作数BUFFER的段地址通过AX传给DX
		MOV DS,AX
		MOV AX,DATA					;目标操作数LASTUSER的段地址通过AX传给DX
		MOV ES,AX
		MOV SI,OFFSET BUFFER		;源操作数BUFFER的偏移地址传给SI
		ADD SI,8					;修正BUFFER，加上lastuser占去的8位
		MOV DI,OFFSET LASTSCORE		;目标操作数LASTSCORE的偏移地址传给DI
		MOV CX,5					;CX表示复制字符个数，设为5
		CLD
		REP MOVSB					;串操作复制出LASTSCORE的内容
		RET
SCORE_CPY ENDP

;修饰LASTUSER的最后字符为'$'
MODIFY_STR PROC NEAR
		LEA DX,LASTUSER				;将LASTUSER偏移地址传给DX
		MOV CL,7
		XOR CH,CH
		ADD DX,CX					;得到LASTUSER[7]的地址（最后一个字符
		MOV BX,DX
		MOV BYTE PTR[BX],'$'		;修饰LASTUSER的最后字符为'$'
		RET
MODIFY_STR ENDP

;读取文件内容至缓冲区
RDF1 PROC NEAR
		CALL READ_TOPRANK			;从文本读内容到缓冲区
		CALL NAME_CPY				;从缓冲区复制到LASTUSER
		CALL SCORE_CPY				;从缓冲区复制到LASTSCORE
		CALL MODIFY_STR				;修饰LASTUSER的最后字符为'$'
		;显示历史最高分
		MOV AX,DATA
		MOV DS,AX
		MOV DX, OFFSET LASTSCORE	;将LASTSCORE的偏移量传给DX
		MOV AH,09H
		INT 21H						;显示LASTSCORE
		LEA dx,remind_rdmessage5
		mov ah,09h					;显示字符串by
		int 21h
		;显示历史最高分创造者
		MOV DX, OFFSET LASTUSER		;将LASTUSER的偏移地址传给DX
		MOV AH,09H
		INT 21H  					;显示LASTUSER 
		RET
RDF1 ENDP
		
;读历史最高纪录至缓冲区
READ_TOPRANK PROC NEAR
OPF0:
		;打开文件
		MOV AH,3DH					;将打开文件的功能号传给AX
		MOV AL,00H					;设定文件模式AL为只读
		LEA DX,PFILE				;将PFILE（文件路径）的偏移地址传给DX
		INT 21H
		LEA BX,FNAME				;将文件代号的偏移地址传给BX
		MOV [BX],AX					;将AX中代号数据保存到FNAME中
RDF0:
		;读文件到内存
		LEA SI,FNAME
		MOV BX,[SI]					;将文件存储标记通过SI偏移量传给BX
		MOV AH,3FH
		LEA DX,BUFFER				;读数据到BUFFER中
		MOV CX,0EH
		INT 21H						;执行读文件功能
CLF0:
		;关闭文件
		LEA SI,FNAME
		MOV AH,3FH
		MOV BX,[SI]					;将文件存储标记通过SI偏移量传给BX
		INT 21H						;关闭文件
		RET
READ_TOPRANK ENDP
;;--------历史最高纪录功能---------

;;--------串联函数---------
;主函数，设定新的用户中断使得俄罗斯方块能够隔一定时间正常下落一次
MAIN PROC FAR
		MOV AX,DATA
		MOV DS,AX
		PUSH DS						;保存DS的值
		;设定1ch中断子程式
		;时脉中断8,每1秒运行18.2次,每次中断8都会呼叫一次int1ch
		;给用户一个利用时脉的机会.
		;所以用户自行拦截中断1ch,执行一般工作
		MOV AL,1CH					;设置AL = 中断号
		MOV AH,35H					;ES:BX为入口
		INT 21H						;读取中断1ch原来的段:偏移,存于es:bx前两步
		MOV SEGMENT1C,ES			;将ES的值给1C中断段
		MOV OFF1C,BX				;设置关中断的地址
		;保存1C号中断入口

		MOV DX,OFFSET INT1C			;调用子函数INT1C取偏移地址   dx=新的1ch入口
		MOV AX,SEG INT1C			;SEG标号段地址
		MOV DS,AX
		MOV AL,1CH
		MOV AH,25H					;设置新的中断向量，DS:DX为入口
		INT 21H						;以ds:dx设定中断1ch的新段:偏移 前两步
		POP DS
		CALL STARTGAME

		MOV AH,4CH
		INT 21H
MAIN ENDP

;用户的新的时脉中断子程式		
INT1C PROC NEAR
		STI							;开中断
		PUSH AX						;保存寄存器
		PUSH DX							
		MOV AX,DATA					;将数据段DATA存入DS中
		MOV DS,AX
		INC TIME					;+计时
		POP DX
		POP AX						;恢复寄存器
		IRET						;中断返回
INT1C ENDP

;延时函数		
DELAY PROC NEAR							
		PUSH CX
		MOV CX,00FFH
DEL1: 	LOOP DEL1
		POP CX
		RET
DELAY ENDP

;游戏主体函数，控制游戏整体流程
STARTGAME PROC NEAR
		CALL WELCOME				;显示欢迎界面			
		MOV AH,00H
		MOV AL,12H
		INT 10H						;设置显示模式（640*480*16色）
		
		MOV AH,0BH					;设置调色板、背景色或边框
		MOV BH,01					;选择调色板
		MOV BL,00H					;选择调色板0（RGB）
		INT 10H						;开始游戏
		
		CALL SELECT_SPEED			;选择速度
		CALL DRAW_WINDOW			;游戏页面绘制		
		CALL INITGAME				;参数初始化
		CALL A_BLOCK				;生成方块
		CALL DELAY					;延时
		MOV TIME,0H					;重置时间
		CALL EXECUTE				;开始可以操纵方块
		RET
STARTGAME ENDP

;游戏结束重启回到STARTGAME
RESTART PROC NEAR
		MOV AH,00H					;设置显示模式3（80*25*16色）
		MOV AL,03H						
		INT 10H
		PUSHA
		CALL TOPRANK				;进入历史最高分记录功能，比较得分
		POPA
		CALL STARTGAME				;游戏结束回到START_GAME
		RET
RESTART ENDP

;退出游戏
EXIT PROC NEAR					
		MOV AX,0003H				;设置显示模式（80*25*16色）
		INT 10H
		MOV AX,DATA
		MOV DS,AX
		MOV DX,OFFSET ENDMSG			
		MOV AH,09H					;显示字符串
		INT 21H							
		MOV DX,OFF1C					
		MOV AX,SEGMENT1C				
		MOV DS,AX
		MOV AL,1CH
		MOV AH,25H						
		INT 21H
		MOV AX,4C00H					
		INT 21H						;返回dos,退出整个游戏
		RET
EXIT ENDP
;;--------串联函数---------

CODE 	ENDS
		END MAIN