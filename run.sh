./clean.sh
mkdir build
mkdir output
flex ./code/tinylexical.l
bison ./code/grammer.y -v -d
cp lex.yy.c ./ccode/lex.yy.c
cp grammer.tab.c ./ccode/grammer.tab.c
cp grammer.tab.h ./lib/grammer.tab.h
rm lex.yy.c
rm grammer.tab.c
rm grammer.tab.h
gcc -I ./lib -o ./build/a.out ./ccode/*.c -lfl -ll
./build/a.out ./sample/sample.tiny
cp interCode ./output/interCode
cp syntaxTree ./output/syntaxTree
cp tokenSeq ./output/tokenSeq
cp symbolTable ./output/symbolTable
rm interCode
rm syntaxTree
rm tokenSeq
rm symbolTable
