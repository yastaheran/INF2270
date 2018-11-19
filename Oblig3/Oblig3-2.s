	.extern	fread, fwrite
	.extern	_fread, _fwrite
	
	.text
	.globl	readbyte
	.globl	_readbyte
 # Navn:	readbyte
 # Synopsis:	Leser en byte fra en binÃ¦rfil.
 # C-signatur: 	int readbyte (FILE *f)
 # Registre:
	
readbyte:
_readbyte:
	pushl	%ebp		# Standard funksjonsstart
	movl	%esp,%ebp	#
	
.rb_x:	
	popl	%ebp		# Standard
	ret					# retur.

	.globl	readutf8char
	.globl	_readutf8char
 # Navn:	readutf8char
 # Synopsis:	Leser et Unicode-tegn fra en binÃ¦rfil.
 # C-signatur: 	long readutf8char (FILE *f)
 # Registre:
	
readutf8char:
_readutf8char:
	pushl	%ebp		# Standard funksjonsstart
	movl	%esp,%ebp	#

	popl	%ebp		# Standard
	ret					# retur.

	.globl	writebyte
	.globl	_writebyte
 # Navn:	writebyte
 # Synopsis:	Skriver en byte til en binÃ¦rfil.
 # C-signatur: 	void writebyte (FILE *f, unsigned char b)
 # Registre:
	
writebyte:
_writebyte:
	pushl	%ebp		# Standard funksjonsstart
	movl	%esp,%ebp	# kopierer stack pointer til base pointer
	subl 	$16,%esp	#lagrer plass til data
	
#	movl	%edi,-8(%ebp)# parameter FILE *f
#	movl	%esi,%eax	
#	movb	%al,-12(%ebp) #parameter unsigned char b
	
#	movl 	-8(%ebp),%edx #FILE *f
#	movl	$1,%edi		#setter verdien 1 inn i data index registeret
#	movl	$1,%esi		#setter verdien 1 inn i stack index registeret
#	leal	-12(%ebp),%eax #adressen til byte b
#	pushl	%eax
#	call	_fwrite

	movl	%edi,-8(%ebp)	# parameter FILE *f
	movl	%esi, %eax
	movb	%al, -12(%ebp)	#parameter unsigned char b
	
	movl 	-8(%ebp),%edx 	#FILE *f
	leal	-12(%ebp),%eax #adressen til byte b
	movl	%edx,%ecx
	movl	$1,%edx
	movl	$1, %esi
	movl	%eax,%edi
	call	_fwrite
	
	addl 	$16,%esp	#fjerner parametere	
	popl	%esi		
	popl	%esp
	popl	%edi
	popl	%ebp		# Standard
	ret					# retur.	
	
	.globl	writeutf8char
	.globl	_writeutf8char
 # Navn:	writeutf8char
 # Synopsis:	Skriver et tegn kodet som UTF-8 til en binÃ¦rfil.
 # C-signatur: 	void writeutf8char (FILE *f, unsigned long u)
 # Registre:
	
writeutf8char:
_writeutf8char:
	pushl	%ebp		# Standard funksjonsstart
	movl	%esp,%ebp	#

.wu8_x:	
	popl	%ebp		# Standard
	ret			# retur.