CXX = g++ -std=c++17

all:
	cd parser && bison -d parser.y
	cd scanner && flex lexer.l

	cd parser \
		&& $(CXX) -c *.c
	cd scanner \
		&& $(CXX) -c *.c

	$(CXX) -o Program parser/*.o scanner/*.o

clean:
	cd parser && rm -rf *.tab.*
	cd scanner && rm -rf *.yy.*
	rm -rf Program
