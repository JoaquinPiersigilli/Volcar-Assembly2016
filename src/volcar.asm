SECTION .bss
	BUFFLEN EQU 1000000
	Buff resb BUFFLEN
	bufferlen equ 8
	buffer resb bufferlen
	
SECTION .data
	LineaMemoria db "0"
	LongLineaMemoria EQU $ - LineaMemoria
	LineaHexa db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
	LongLineaHexa EQU $ - LineaHexa
	LineaAscii db "|................|",10
	LongLineaAscii EQU $ - LineaAscii
	FullLong EQU $ - LineaHexa

	TablaDigitosHex db "0123456789ABCDEF"

	TablaAscii: db    2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
				db    2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	            db    20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
				db    30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
				db    40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	            db    50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
				db    60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
          	    db    70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
				db    80h,81h,82h,83h,84h,85h,86h,87h,88h,89h,8Ah,8Bh,8Ch,8Dh,8Eh,8Fh
	            db    90h,91h,92h,93h,94h,95h,96h,97h,98h,99h,9Ah,9Bh,9Ch,9Dh,9Eh,9Fh
		    db    0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF
		    db    0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF
		    db    0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF
		    db    0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0xDF
		    db    0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF
		    db    0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF

	
	mensajeErrorParametros db  "Se ingresaron mal los parametros", 0xA
	longitudParametros equ $ - mensajeErrorParametros

	mensajeErrArchivo db "Ocurrio un error con el archivo", 0xA
	longitudErrArchivo equ $ - mensajeErrArchivo
	
	mensajeAyuda db "Bienvenido a volcar. Este programa vuelca el contenido de un archivo en formato hexadecimal y ASCII. La salida es similar a la producida por el comando hexdump -C. El tamaño maximo del archivo a volcar es de 1MB, en caso de que se ingrese un archivo de tamaño mayor, solo se mostrar el contenido del primer MB de informacion. Los parametros de entrada de este programa solo pueden ser 2 y uno de ellos es opcional. La forma de ejecucion es $ ./volcar [-h] <archivo>. el parametro -h es opcional y en caso de existir, muestra esta ayuda del programa en la consola. el parametro <archivo> es obligatorio y es la ruta de un archivo de cualquier formato.",0xA

	longitud equ $ - mensajeAyuda
	tamano equ 999000
	archivo dd 0
	manejadorArchivo dd 0

SECTION .text
	global _start

	;; la funcion itoa convierte un entero decimal a hexadecimal y devuelve su string . recibe el entero en el registro EAX y un puntero a char en EBX. retorna la cantidad de caracteres del string en EAX y el resultado
	;; de la conversion en EBX
itoa:
	push ebp			;guardo el puntero a la base original
	mov ebp,esp			;nuevo EBP apunta al tope

	push 16				;guardo un entero de valor 16

	push ebx			;guardo una copia del puntero al string

	mov ecx,0			;inicializo el contador de caracteres
itoa_dividir:
	mov edx,0			;inicializo edx en 0 para dividir (por la forma de idiv)
	idiv DWORD[EBP-4]	;dividi el entero por 16
	cmp edx,9			;comparo el digito con 9
	jg sumar			;si es mayor, salto a la rutina sumar
	add edx,48			;sino, le sumo 48 (de esta forma consigo el digito del 0 al 9 en hexa)
	jmp vueltaSumar		;salto a la rutina vueltaSumar(salteo la rutina sumar)
sumar:	
	add edx,55			;si en la comparacion anterior cmp edx,9 edx era mayor, le sumo 55 (de esta forma consigo el digito del 10 al 15 en hexa, A-F)
vueltaSumar:	
	push edx			;guardo el char en la pila
	inc ecx				;incremento el contador
	cmp eax,0			;comparo eax con 0
	jnz itoa_dividir	;si no es 0 paso al siguiente digito
	mov eax,ecx			;ecx tiene la cantidad de caracteres apilados, lo paso a eax y queda uno de los valores de retorno
itoa_guardar:
	pop edx				;desapilo el siguiente caracter
	mov [ebx],dl		;guardo el char en el buffer
	inc ebx				;avanzo a la siguiente posicion de ebx
	dec ecx				;resto uno a la cantidad de caracteres apilados ya que desapile uno
	cmp ecx,0			;quedan caracteres apilados?
	jnz itoa_guardar	;si quedan, vuelvo a itoa_guardar

	mov ebx,[EBP-8]		;sino, recupero ebx
	mov esp,ebp			;restauro el tope de la pila
	pop ebp				;restauro la base de la pila
	ret					;retorno a la rutina que llamo a itoa

LimpiarLinea:
	;; Esta rutina restaura "LineaHexa" y vuelve a poner todos sus valores en 0. Como son 16 valores, voy del 0 al 15
	pushad					;pushad hace un push de todos los registros (para no sobreescribir nada) en el orden EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI
	mov edx,15				;guardo el valor 15 en edx que es parametro de entrada de AgregarValorHex
rut:	
	mov eax,0				;guardo el valor 0 en eax que es parametro de entrada de AgregarValorHex
	call AgregarValorHex	;llamo a la rutina AgregarValorHex
	sub edx,1				;le resto 1 a edx
	jae rut					;si edx es mayor o igual a 0, vuelvo a rut.
	popad					;de lo contrario, termine y popad restaura los registros que guardo pushad
	ret						;retorno a la rutina que llamo LimpiarLinea

AgregarValorHex:
	;; esta rutina recibe en eax un valor para poner tanto en LineaHexa como en LineaAscii respetando su respectivo formato y en edx recibe la posicion de la linea (que es la misma para las 2)
	;; la tabla "TablaDigitosHex" son 16 bytes seguidos en memoria, por lo que con un corrimiento simple voy avanzando sobre la misma
	;; la tabla "LineaHexa" en cambio, tiene varios valores y cada uno es una double word de 32 bits (4 bytes). la direccion del primer elemento es simplemente LineaHexa pero para avanzar a los proximos,
	;; se deben sumar de a 4 bytes. Esto se hace [tabla+ECX*4] siendo ECX el indice del valor en la tabla al que quiero acceder.
	;; la tabla "TablaAscii"
	
	push ebx						 ;guardo ebx
	push edi						 ;guardo edi
	mov bl, byte[TablaAscii+eax]	 ; guardo en bl el caracter ascii en hexadecimal, los caracteres no imprimibles serán 2Eh (el punto)
	mov byte [LineaAscii+edx+1],bl	 ; una vez que tengo ese valor lo guardo en la LineaAscii. LineaAscii es la direccion de comienzo de la linea, EDX es la posicion y se le suma 1 porque comienza con la barra vertical "|"
	mov ebx,eax						 ;guardo el valor hexa en ebx
	lea edi, [edx*3]				 ;(load effective address) cargo en edi el valor edx*3. multiplico por 3 porque esta posicion se usara en LineaHexa, y ahi tambien hay que contar los espacios que hay entre cada 00. Hay 16 "00" que contando de a 1 lugar son 32 lugares, + 16 lugares de los espacios. por eso la posicion hay que multiplicarla *3.
									 ;Por ejemplo si tenemos 00 00 '00' 00, la posicion entre comillas simples seria la 2 porque se empieza a contar del 0, y para llegar ahi hay que avanzar 6 lugares teniendo en cuenta que se esta posicionado en el primer espacio en blanco
	and eax, 0000000Fh				 ;0Fh es como tener 0000 1111 para que en el and me quede el valor de los ultimos 4 bits (ultimo byte), se agregan los 0 adelante porque eax es un registro de 32 bits, de esta forma pongo todos los bits de eax en 0 excepto los ultimos 4
	mov al,byte[TablaDigitosHex+eax] ; guardo en al el valor del digito en hexadecimal (como en eax solo valen los ultimos 4 bits, si o si su valor esta entre 0 y 15 que son las posiciones de TablaDigitosHex)
	mov byte [LineaHexa+edi+2],al	 ; Guardo ese valor en LineaHexa+edi+2. +2 porque es el lugar menos significativo del "00" que habra en la LineaHexa
	and ebx, 000000F0h				 ;en ebx me queda el Byte (4bits) mas significativo del valor hexadecimal de entrada
	shr ebx,4						 ; paso ese valor a los 4 bits menos significativos
	mov bl,byte[TablaDigitosHex+ebx] ; pongo en bl el valor de esos 4 bits menos significativos de ebx sacado de la TablaDigitosHex
	mov byte [LineaHexa+edi+1],bl	 ; Lo guardo en LineaHexa+edi+1. +1 porque esta vez ese digito hexadecimal va en el lugar mas significativo del "0X" que habra en la LineaHexa
	pop edi							 ; restauro edi
	pop ebx							 ; restauro ebx
	ret								 ; retorno a la rutina que llamo a AgregarValorHex


ImprimirLinea:
	pushad			;guardo todos los registros (por el orden de pushad edi queda primero en la pila)
	pop edi			;recupero el contador de direccion de memoria
	mov eax,edi		;pongo el valor edi en eax
	add edi,16		;le sumo 16 para la direccion de la proxima linea
	push edi		;guardo edi
	mov ebx,buffer	;pongo en ebx el buffer donde tendre el valor en string
	call itoa		;llamo a itoa
	;; en eax tengo la cantidad de caracteres del string.
	;; en el buffer tengo el valor en string
	xor esi,esi		;pongo esi en 0
	mov esi, 8		;pongo esi en 8
	sub esi,eax		;a 8 le resto la cantidad de caracteres que llevo de direccion
	;; en esi tengo la cantidad de 0s que debo imprimir antes de la direccion
imprimoCeros:
	mov eax,4		 ;syscall write
	mov ebx,1		 ;stdout
	mov ecx,LineaMemoria	 ;pongo en ecx el mensaje a escribir (LineaMemoria es "0")
	mov edx,LongLineaMemoria ;pongo en edx la longitud del mensaje
	int 80h			 ;llamo al kernel
	dec esi			 ;decremento en 1 la cantidad de 0s que debo imprimir
	cmp esi,0		 ;comparo la cantidad de 0s con 0
	jg imprimoCeros		 ;si es mayor, sigo imprimiendo hasta que no queden 0s por imprimir

	;; cuando no quedan mas 0's para imprimir imprimo el valor de la direccion
	mov eax,4		;syscall write
	mov ebx,1		;file descriptor (stdout)
	mov ecx,buffer		;mensaje a escribir
	mov edx,bufferlen	;longitud del mensaje
	int 80h			;llamo al kernel	.

	mov eax,4		;syscall write
	mov ebx,1		;stdout
	mov ecx,LineaHexa	;pongo en ecx la lineaHexa (empezara a imprimir desde ahi)
	mov edx, FullLong	;pongo en edx la longitud del mensaje, como es la longitud FullLong, continuara escribiendo tambien LineaAscii
	int 80h			;llamo al kernel
	popad			;restauro los registro del pushad
	ret			;regreso a la rutina que llamo a ImprimirLinea


leerFile:
	;; Llena el buffer Buff con la cantidad de caracteres del archivo que alcancen para llenarlo.
	push eax		  		   	 ;guardo eax
	push ebx		 			 ;guardo ebx
	push edx		 		 	 ;guardo edx
	mov eax,3		  			 ;syscall read
	mov ebx,[manejadorArchivo] 	 ;pongo en ebx el filehandler del archivo que se ingreso como parametro
	mov ecx,Buff		   		 ;pongo en ecx el buffer donde se guardara lo leido
	mov edx,BUFFLEN		   		 ;pongo en edx el tamaño de dicho buffer
	int 80h			   			 ;llamo al kernel
	mov ebp,eax		   			 ;guardo en ebp la cantidad de bytes leidos(este es un valor de retorno de leerFile)
	
	;; cierro el programa ya que no hace falta "rellenar" el buffer porque el tamaño maximo es 1mb y ese es el tamaño del buffer. Si el archivo es mas grande solo se mostrara 1mb
	mov eax,6		 			 ;syscall close
	mov ebx,[manejadorArchivo] 	 ;filehandler del archivo
	int 80h			  			 ;llamo al kernel	
	xor ecx,ecx		   			 ;pongo en 0 ecx
	pop edx			   			 ;restauro edx
	pop ebx			   			 ;restauro ebx
	pop eax			   		 	 ;restauro eax
	ret			   				 ;regreso a la rutina que llamo a leerFile

_start:	
	pop ebx			;obtengo el argc (cantidad de parametros +1 que es el nombre del programa
	cmp ebx, 2		;comparo argc con 2 (cantidad minima de parametros aceptables. nombre,archivo)
	je dosParametros 	;si argc es 2, voy a la rutina dosParametros
	cmp ebx, 3		;sino, comparo argc con 3 (cantidad maxima de parametros aceptables. nombre,-h,archivo)
	je tresParametros	;si argc es 3, voy a la rutina tresParametros
	jmp errParametros	;si no hay 2 o 3 parametros, muestro error de parametros
	


dosParametros:
	;; si hay 2 parametros estos deben ser el nombre del programa y luego el archivo.

	pop ebx			;elimino el nombre del programa de argv
	pop ebx			;paso a ebx el nombre del archivo

	mov [archivo], ebx	;guardo la ruta del archivo de entrada.
	mov eax, 5		;syscall open
	mov ebx, [archivo]	;pongo en ebx la ruta del archivo
	mov ecx, 0		;fileaccess mode "read only"
	int 0x80		;llamo al kernel
	test eax,eax		;verifico si hubo error en el archivo
	js errArchivo		;si lo hubo voy a la rutina errArchivo
	
	;; con esto quedo abierto el programa.

	mov [manejadorArchivo], eax ;guardo el fileHandler
	xor esi,esi		    ;pongo esi en 0 para usar de contador total de bytes
	xor edi,edi		    ;pongo edi en 0 para usar de contador
	call leerFile		;llamo a la rutina leerFile por lo que tengo en el buffer Buff la primera linea a imprimir
	cmp ebp,0		    ;Si la cantidad de bytes leidos es 0... 
	jbe salir		    ;...termina el programa

AvanzarBuff:
	;; avanza en buff y convierte los valores binarios a hexadecimales
	;; a esta altura ecx que se usa de contador para avanzar sobre el buffer vale 0 ya que es un valor de retorno de leerFile para asegurar que por cada linea se empiece desde el principio.

	mov al,byte[Buff+ecx]	;guardo en al el byte que se encuentra en la posicion ecx del buffer
	mov edx,esi				;pongo en edx el contador esi
	and edx,0000000Fh		;and con 0000000Fh es el and entre el valor de edx y 0000 0000 0000 0000 0000 0000 0000 1111(15 en dec, F en hex) y guarda el resultado en edx quedando asi un digito entre 0 y F
	call AgregarValorHex	;llamo a la rutina AgregarValorHex con parametros EAX y EDX

	inc esi					;incremento en uno el contador total de bytes
	inc ecx					;incremento en uno ecx, que es la posicion que se tomara del buffer
	cmp ecx,ebp				;comparo la posicion que se leera del buffer con la cantidad de bytes leidos, 
	jb VerSiHayQimprimir	;si la posicion del buffer es menor que la cantidad de bytes del mismo, llamo a VerSiHayQimprimir,
	jmp Listo				;sino...termine, solo debo imprimir la ultima linea (esto lo hace la rutina Listo), sino continuo con hayQimprimir
	
VerSiHayQimprimir:
	;; en esta rutina veo si ya lei 16 bytes y debo imprimir la linea, o si simplemente debo avanzar al proximo byte del buffer.
	test esi, 0000000Fh	; test funciona como el and solo que no guarda el resultado, compruebo si los ultimos 4 bits de esi son 0, en caso de serlo el contador es modulo 16 y estoy al final de una linea y debo imprimirla
	jnz AvanzarBuff		; si no es 0, sigo avanzando en el buffer Buff,
	call ImprimirLinea	; si lo es, llamo a imprimirLinea 
	call LimpiarLinea	; y luego a limpiarLinea para tenerla toda en 0 de nuevo.
	jmp AvanzarBuff		; Continuo avanzando sobre el buffer
	

tresParametros:
	;; si hay 3 parametros tiene que estar la ayuda
	
	pop ebx			;elimino el nombre del programa de argv
	
	;; a esta altura deben estar -h y el nombre del archivo

	;; verifico si es la ayuda
	pop ebx			;obtengo el primer argumento
	cmp BYTE[ebx] , 2dh 	;es un guion?
	jne errParametros	;no lei guion, entonces hay error de parametros
	inc ebx			;lei guion, por lo tanto sigo
	cmp BYTE[ebx], 68h	;es una h?
	jne errParametros	;el unico parametro valido con un guion que lo precede es -h pero se ingreso otra letra despues del guion.
	inc ebx
	cmp BYTE[ebx],0		;luego de la h no debe haber nada (termina ahi el parametro)
	je ayuda		;lei h, muestro ayuda
	jmp errParametros	;sino, error de parametros


ayuda:
	mov edx, longitud	;longitud del mensaje
	mov ecx, mensajeAyuda	;mensaje a escribir
	mov ebx, 1		;file descriptor (stdout)
	mov eax, 4		;syscall write
	int 80h			;llamo al kernel
	mov eax, 1		;syscall exit
	mov ebx, 0		;codigo de terminacion normal
	int 80h			;llamo al kernel

errParametros:
	mov edx, longitudParametros 	;longitud del mensaje
	mov ecx, mensajeErrorParametros ;mensaje a escribir
	mov ebx, 1			;file descriptor (stdout)
	mov eax, 4			;syscall write
	int 80h				;llamo al kernel
	mov eax, 1			;syscall exit
	mov ebx, 1			;codigo de terminacion anormal
	int 80h				;llamo al kernel

errArchivo:
	mov edx, longitudErrArchivo 	;longitud del mensaje
	mov ecx, mensajeErrArchivo 		;mensaje a escribir
	mov ebx, 1	   					;file descriptor (stdout)
	mov eax, 4	        			;syscall write
	int 80h							;llamo al kernel
	mov eax, 1						;syscall exit
	mov ebx, 2						;codigo de terminacion con error en archivo
	int 80h							;llamo al kernel
	
	
Listo:
	call ImprimirLinea	;Imprimo la ultima linea
	
salir:
	mov eax,1		;syscall exit
	mov ebx,0		;codigo de terminacion normal
	int 80h			;llamo al kernel

