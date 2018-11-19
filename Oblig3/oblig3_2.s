.extern	fread, fwrite
.extern	_fread, _fwrite

	.text
	.globl	readbyte
	.globl	_readbyte
 # Navn:	readbyte
 # Synopsis:	Leser en byte fra en binÃ¦rfil.
 # C-signatur: 	int readbyte (FILE *f)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
readbyte:
_readbyte:
	pushl	%ebp		  # Standard funksjonsstart
	movl	%esp,%ebp	#
	subl    $4, %esp

  #status = fread
  movl    8(%ebp),%eax
  pushl   %eax
  pushl   $1
  pushl   $1
#  andl    $0, -4(%esp)
  leal    -4(%ebp), %eax
  pushl   %eax
  call    _fread
  addl    $16, %esp

  #ifsetningen
  cmpl    $0, %eax
  jg      .HentByte       #hvis > 0

  movl    $-1, %eax
  jmp     .rb_x

.HentByte:
  movl   -4(%ebp), %eax

.rb_x:
  addl  $4, %esp
  popl	%ebp		# Standard
	ret			    # retur.

	.globl	readutf8char
	.globl	_readutf8char
 # Navn:	readutf8char
 # Synopsis:	Leser et Unicode-tegn fra en binÃ¦rfil.
 # C-signatur: 	long readutf8char (FILE *f)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
 #              EDX - Arbeidsregister
readutf8char:
_readutf8char:
	pushl	%ebp	  	# Standard funksjonsstart
	movl	%esp,%ebp	#
	subl  $16, %esp

	movl  8(%ebp), %eax    #mulig å bare skrive pushl 8(%esp)?
	pushl %eax
	call  readbyte
	addl  $4, %esp
	
	cmpl  $0, %eax
	jle   .ru8_x        #hvis EOF

	movl  %eax, -4(%ebp) #lagrer byte 1

	andl  $0x80, %eax   # to første bits
	cmpl  $0, %eax      #
	je    .Lik0x0       # hopp hvis == 0x0

	movl  -4(%ebp), %eax
	andl  $0xe0, %eax   # tre første bits
	cmpl  $0xc0, %eax   #
	je    .Lik0xc0      # hvis == 0xc0

#  andl  $0xf0, %eax  #fire første bits
#  cmpl  $0xe0, %eax
#  je    .Lik0xe0     # hvis == 0xe0

#  andl  0xf0, %eax   #fire første bits
#  cmpl  $0xf0, %eax
#  je    .Lik0xf0     # hvis == 0xf0

	jne   .ru8_x

.Lik0x0:
	movl  -4(%ebp), %eax
	jmp   .ru8_x

.Lik0xc0:
	movl  8(%ebp), %eax     # kaller på readbyte
	pushl %eax              # for å få tak i
	call  readbyte					# neste byte
	addl  $4, %esp

	movl  %eax, -8(%ebp)  #lagrer byte 2

	movl  -4(%ebp),%edx
	andl	$0x3f, %eax
	andl	$0x1f, %edx

	sall  $6, %edx
	orl   %edx, %eax

	jmp   .ru8_x

.Lik0xe0:

.Lik0xf0:


.ru8_x:
  addl  $16, %esp
	popl	%ebp		 # Standard
	ret			       # retur.

	.globl	writebyte
	.globl	_writebyte
 # Navn:	writebyte
 # Synopsis:	Skriver en byte til en binÃ¦rfil.
 # C-signatur: 	void writebyte (FILE *f, unsigned char b)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
writebyte:
_writebyte:
	pushl	%ebp	  	# Standard funksjonsstart
	movl	%esp,%ebp	#

  movl  8(%ebp), %eax
  pushl %eax          # FILE *f
  pushl $1
  pushl $1
  leal 12(%ebp), %eax # adressen til b
  pushl %eax          # b
  call _fwrite

  addl  $16, %esp # fjerner paramterne
	popl	%ebp		# Standard
	ret		      	# retur.

	.globl	writeutf8char
	.globl	_writeutf8char
 # Navn:	writeutf8char
 # Synopsis:	Skriver et tegn kodet som UTF-8 til en binÃ¦rfil.
 # C-signatur: 	void writeutf8char (FILE *f, unsigned long u)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
writeutf8char:
_writeutf8char:
	pushl	%ebp		   	# Standard funksjonsstart
	movl	%esp,%ebp	 	#

	movl 	8(%ebp), %eax     	# FILE *f
	pushl 	%eax              	#
	movl 	12(%ebp), %eax		# Byte 1
	call  	writebyte			#
	addl  	$4, %esp

	cmpl	$0x00, %eax			# Sjekker om
	je		.hop1				# det er en byte
	cmpl	$0x7f, %eax			# hopper til hop1
	jle		.hop1				# hvis sant

#	cmpl 	$0x80, %eax			# Sjekker om
#	je		.hop2				# det er to bytes
#	cmpl 	$0x7ff, %eax		# hopper til hop2 
#	jle		.hop2				# hvis sant

#	cmpl 	$0x800, %eax
#	je		.hop3
#	cmpl	$0x7ff, %eax
#	jle		.hop3

#	cmpl	$0x10000, %eax
#	je		.hop4
#	cmpl	$0x1fffff, %eax
#	jle		.hop4

	jne		.wu8_x

.hop1:
	movl 	%eax, -4(%ebp)		# lagrer byte 1 lokalt
	
	andl	$0x7f, %eax
#	orl		%eax, -4(%ebp)
	call	writebyte
	addl	$4, %esp
	jmp  	.wu8_x

.hop2:
	movl 	%eax, -4(%ebp)		#lagrer byte 1 lokalt

	movl  	8(%ebp), %eax     	# FILE *f
	pushl 	%eax              	#
	movl	12(%ebp), %eax		# skriver byte 1
	call  	writebyte			#
	addl  	$4, %esp
	
	movl %eax, -8(%ebp)			#lagrer byte 2 lokalt


	jmp		.wu8_x

.wu8_x:
	addl	$16, %esp
  popl	%ebp		# Standard
	ret		      	# retur.
