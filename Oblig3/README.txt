Oblig 3

Tanker:

writebyte:
legge inn parametere
kalle på fwrite
pop register

void writebyte (FILE *f, unsigned char b) {
	fwrite(&b, 1, 1, f);
}


writeutf8char:
sjekka først i hvilken range tallet var i. 
Ut ifra det bruke shift og and (til utnulling) til å lage de ulike bytene
kalle writebyte for hver byte

void writeutf8char(FILE *f, unsigned long u) {
	unsigned char bytes[4];
	unsigned char b, b2, b3, b4;
	if(u == 0xf0 && u < 0xff0) { 				//hvis 4 byte
		bytes[0] = (u >> 24) & 0xf0;
		b = bytes[0];
		writebyte(f, b);
		bytes[1] = (u >> 16) & 0xf0;
		b2 = bytes[1];
		writebyte(f, b2);
		bytes[2] = (u >> 8) & 0xf0;
		b3 = bytes[2];
		writebyte(f, b3);
		bytes[3] = u & 0xf0;
		b4 = bytes[3];
		writebyte(f, b4);
	} else if(u == 0xe0 && u < 0xf0) {			//hvis 3 byte
		bytes[0] = (u >> 16) & 0xe0;
		b = bytes[0];
		writebyte(f, b);
		bytes[1] = (u >> 8) & 0xe0;
		b2 = bytes[1];
		writebyte(f, b2);
		bytes[2] = u & 0xe0;
		b3 = bytes[2];
		writebyte(f, b3);
	} else if(u == 0xc0 && u < 0xe0) {			//hvis 2 byte
		bytes[0] = (u >> 8) & 0xc0;
		b = bytes[0];
		writebyte(f, b);
		bytes[1] = u & 0xc0;
		b2 = bytes[1];
		writebyte(f, b2);
	} else if(u == 0x0 && u < 0xc0) {			//hvis 1 byte
		bytes[0] = u & 0x0;
		b = bytes[0];
		writebyte(f, b);
	}
}

reabyte:
leal for å lagre adressen til c
kalle på fread
if-setning: cmp & jmp
pop register
int readbyte (FILE *f) {
	int status;
	char c;
	status = fread(&c, 1, 1, f);							
	if (status <= 0) return -1;
	return (int)c;
}

readut8char:
Leser du først en byte, sjekker hva den starter med, f.eks. '110'
Leser 1-3 byte til, ut ifra hvilken byte den starter med

long cret;
int a[4];

big endian
cret  = (unsigned long) a[0] << 24 | (unsigned long) a[1] << 16;
cret |= (unsigned long) a[2] << 8 | a[3]; 

little endian
cret  = (unsigned long) a[3] << 24 | (unsigned long) a[2] << 16;
cret |= (unsigned long) a[1] << 8 | a[0];

long readutf8char(FILE *f) {
	long cret;
	int ch[4];
 ch[0] = readbyte(f);
	if(ch[0] == 0x00) {
		cret = 0x00|ch[0];
	} else if(ch[0] == 0xc0) {
		ch[1] = readbyte(f);
		cret = ch[0] << 8 | ch[1];
	} else if(ch[0] == 0xe0) {
		ch[1] = readbyte(f);
		ch[2] = readbyte(f);
		cret = ch[0] << 16 | ch[1] <<8 | ch[2];
	} else if (ch[0] == 0xf0) {
		ch[1] = readbyte(f);
		ch[2] = readbyte(f);
		ch[3] = readbyte(f);
		cret = ch[0] << 24 | ch[1] << 16 | ch[2] << 8 | ch[3];
	}
	return cret;
}

Testing:
	Filen kompilerer, men når jeg skal kjøre den får jeg "Segmentation fault: 11":
	
Process 63567 launched: '/Users/YasTah/Documents/ProgNett/Vår2016/INF2270/Oblig3/testing' (i386)
Process 63567 stopped
	* thread #1: tid = 0xd0c556, 0x971682f0 libdyld.dylib`misaligned_stack_error_, queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=EXC_I386_GPFLT)
    frame #0: 0x971682f0 libdyld.dylib`misaligned_stack_error_
libdyld.dylib`misaligned_stack_error_:
->  0x971682f0 <+0>:  movdqa %xmm0, 0x10(%esp)
    0x971682f6 <+6>:  movdqa %xmm1, 0x20(%esp)
    0x971682fc <+12>: movdqa %xmm2, 0x30(%esp)
    0x97168302 <+18>: movdqa %xmm3, 0x40(%esp)



Andre kilder enn semestersiden:
https://www.exploit-db.com/papers/13136/
http://www.cs.dartmouth.edu/~sergey/cs258/tiny-guide-to-x86-assembly.pdf
http://www.cs.virginia.edu/~evans/cs216/guides/x86.html
http://mark.masmcode.com/