CC = gcc
LEX = lex
YACC = yacc -d
CFLAGS = -O2 -Wall
LDFLAGS = -ly -ll # Linux: -lfl / OSX: -ll
EXEC = stencc
SRC =  symbol.c quad.c assembly_generator.c quad_list.c
OBJ = $(SRC:.c=.o)

all: $(OBJ) y.tab.c lex.yy.c
	$(CC) -o $(EXEC) $^ $(LDFLAGS) -g

y.tab.c: $(EXEC).y
	$(YACC) $(EXEC).y

lex.yy.c: $(EXEC).l
	$(LEX) $(EXEC).l

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS) -g

clean:
	/bin/rm $(EXEC) *.o y.tab.c y.tab.h lex.yy.c
