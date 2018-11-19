.extern	fread, fwrite

	.text
	.globl	readbyte
 # Navn:	readbyte
 # Synopsis:	Leser en byte fra en binÃ¦rfil.
 # C-signatur: 	int readbyte (FILE *f)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
readbyte:
	pushl	%ebp		  # Standard funksjonsstart
  movl	%esp,%ebp	#
  subl    $4, %esp

  #status = fread
  movl    8(%ebp),%eax
  pushl   %eax
  pushl   $1
  pushl   $1
# andl		$0, -4(%ebp)
  leal    -4(%ebp), %eax
  pushl   %eax
  call    fread
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
	ret			     	# retur.

	.globl	readutf8char
 # Navn:	readutf8char
 # Synopsis:	Leser et Unicode-tegn fra en binÃ¦rfil.
 # C-signatur: 	long readutf8char (FILE *f)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
 #              EDX - Arbeidsregister
  #             EBX - Arbeidsregister
readutf8char:
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

  andl  $0xf0, %eax  #fire første bits
  cmpl  $0xe0, %eax
  je    .Lik0xe0     # hvis == 0xe0

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

  movl  %eax, -8(%ebp)  	# lagrer byte 2

  movl  -4(%ebp),%edx
	andl	$0x3f, %eax				# nuller ut de 2 første mest signifikante bitene
	andl	$0x1f, %edx				# nuller ut de 3 første mest signifikante bitene

  sall  $6, %edx
  orl   %edx, %eax

  jmp   .ru8_x

.Lik0xe0:
	movl  8(%ebp), %eax     # kaller på readbyte
	pushl %eax              # for å få tak i
	call  readbyte					# neste byte
	addl  $4, %esp

	movl  %eax, -8(%ebp)  	# lagrer byte 2 lokalt

	movl  8(%ebp), %eax     # kaller på readbyte
	pushl %eax              # for å få tak i
	call  readbyte					# neste byte
	addl  $4, %esp

	movl	%eax, -16(%ebp)		# lagrer byte 3 lokalt

	movl  -4(%ebp),%edx			# byte 1
	movl	-8(%ebp), %eax		# byte 2
	movl	-16(%ebp), %ecx   # byte 3

	andl	$0x3f, %ecx				# nuller ut de 2 mest signifikante bitene
	andl	$0x3f, %eax				# nuller ut de 2 mest signifikante bitene
	andl	$0xf, %edx				# nuller ut de 3 mest signifikante bitene

	sall  $6, %edx
	orl   %eax, %edx 				# slår sammen bit 1 og 2
	sall	$6, %edx
	orl		%ecx, %edx				# slår sammen bit 1, 2 og 3

	jmp   .ru8_x

.Lik0xf0:
	movl  8(%ebp), %eax     # kaller på readbyte
	pushl %eax              # for å få tak i
	call  readbyte					# neste byte
	addl  $4, %esp

	movl  %eax, -8(%ebp)  	# lagrer byte 2 lokalt

	movl  8(%ebp), %eax     # kaller på readbyte
	pushl %eax              # for å få tak i
	call  readbyte					# neste byte
	addl  $4, %esp

	movl	%eax, -16(%ebp)		# lagrer byte 3 lokalt

	movl  -4(%ebp),%edx			# byte 1
	movl	-8(%ebp), %eax		# byte 2
	movl	-16(%ebp), %ecx   # byte 3

	andl	$0x3f, %ecx				# nuller ut de 2 mest signifikante bitene
	andl	$0x3f, %eax				# nuller ut de 2 mest signifikante bitene
	andl	$0x7, %edx				# nuller ut de 4 mest signifikante bitene

	sall  $6, %edx
	orl   %eax, %edx 				# slår sammen bit 1 og 2
	sall	$6, %edx
	orl		%ecx, %edx				# slår sammen bit 1, 2 og 3
	sall  $6, %edx

	movl  8(%ebp), %eax     # kaller på readbyte
	pushl %eax              # for å få tak i
	call  readbyte					# neste byte
	addl  $4, %esp

	andl	$0x34, %eax				# nuller ut de 2 mest signifikante bitene
	orl		%eax, %edx				# slår sammen bit 1, 2, 3 og 4

	jmp   .ru8_x

.ru8_x:
  addl  $16, %esp
	popl	%ebp		 # Standard
	ret			       # retur.

	.globl	writebyte
 # Navn:	writebyte
 # Synopsis:	Skriver en byte til en binÃ¦rfil.
 # C-signatur: 	void writebyte (FILE *f, unsigned char b)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
writebyte:
	pushl	%ebp	  	# Standard funksjonsstart
	movl	%esp,%ebp	#

  movl	8(%ebp), %eax
  pushl %eax          # FILE *f
  pushl $1
  pushl $1
  leal	12(%ebp), %eax # adressen til b
  pushl %eax          # b
  call 	fwrite

  addl  $16, %esp # fjerner paramterne
	popl	%ebp		# Standard
	ret		      	# retur.

	.globl	writeutf8char
 # Navn:	writeutf8char
 # Synopsis:	Skriver et tegn kodet som UTF-8 til en binÃ¦rfil.
 # C-signatur: 	void writeutf8char (FILE *f, unsigned long u)
 # Registre:    EAX - Resultatregister
 #              EBP - Arbeidsregister
 #              ESP - Arbeidsregister
writeutf8char:
	pushl	%ebp		   # Standard funksjonsstart
	movl	%esp,%ebp	 #

	cmpl	$0x00, %eax				# sjekker om verdien ligger mellom
	je		.hop1							# 0x00 og 0x7f, hvis sant hopper
	cmpl	$0x7f, %eax				# den til hop1
	jle		.hop1							#

	cmpl 	$0x80, %eax				# sjekker om verdien ligger mellom
	je		.hop2							# 0x80 og 0x7ff, hvis sant hopper
	cmpl 	$0x7ff, %eax			# den til hop2
	jle		.hop2							#

	cmpl 	$0x800, %eax			# sjekker om verdien ligger mellom
	je		.hop3							# 0x800 og 0xffff, hvis sant hopper
	cmpl 	$0xffff, %eax			# den til hop3
	jle		.hop3							#

	cmpl 	$0x10000, %eax				# sjekker om verdien ligger mellom
	je		.hop4							# 0x10000 og 0x1ffff, hvis sant hopper
	cmpl 	$0x1fffff, %eax		# den til hop4
	jle		.hop4							#

	jne		.wu8_x

.hop1:
	movl 	12(%ebp), %eax		# byte 1
  pushl %eax
  movl	8(%ebp), %eax			# FILE *f
  pushl %eax
  call  writebyte
  addl 	$8, %esp

	jmp  	.wu8_x

.hop2:
# Dette blir den første byten
	shrl	$6, %eax					# skyver bitene 6 ganger mot høyre
	orl		$0xc0, %eax				# legger til 110 på 3 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl 	$8, %esp

# Dette blir den siste byten
	movl 	12(%ebp), %eax		# u
	andl  $0x3f, %eax				# nuller ut 2 MSB
	orl		$0x80, %eax				# legger til 10 på 2 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl	$8, %eax

	jmp		.wu8_x

.hop3:
# Dette blir byte nr 1
	shrl	$12, %eax					# skyver bitene 12 ganger mot høyre
	orl		$0xe0, %eax				# legger til 1110 på 4 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl 	$8, %esp

# Dette blir byte nr 2
	movl 	12(%ebp), %eax		# u
	shrl	$6, %eax					# skyver bitene 6 ganger mot høyre
	orl		$0x80, %eax				# legger til 10 på 2 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl 	$8, %esp

# Dette blir byte nr 3
	movl 	12(%ebp), %eax		# u
	andl  $0x3f, %eax				# nuller ut 2 MSB
	orl		$0x80, %eax				# legger til 10 på 2 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl	$8, %eax

	jmp		.wu8_x

.hop4:
# Dette blir byte nr 1
	shrl	$18, %eax					# skyver bitene 18 ganger mot høyre
	orl		$0xf0, %eax				# legger til 11110 på 5 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl 	$8, %esp

# Dette blir byte nr 2
	movl 	12(%ebp), %eax		# u
	shrl	$12, %eax					# skyver bitene 12 ganger mot høyre
	orl		$0x80, %eax				# legger til 10 på 2 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl 	$8, %esp

# Dette blir byte nr 3
	movl 	12(%ebp), %eax		# u
	shrl	$6, %eax					# skyver bitene 6 ganger mot høyre
	orl		$0x80, %eax				# legger til 10 på 2 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl 	$8, %esp

# Dette blir byte nr 4
	movl 	12(%ebp), %eax		# u
	andl  $0x3f, %eax				# nuller ut 2 MSB
	orl		$0x80, %eax				# legger til 10 på 2 MSB
	pushl	%eax
	pushl 8(%ebp)						# FILE *f
	call  writebyte
	addl	$8, %eax

	jmp		.wu8_x

.wu8_x:
	addl	$16, %esp
  popl	%ebp		# Standard
	ret		      	# retur.
