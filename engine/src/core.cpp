#include "engine/core.h"

namespace engine {
	int Core::addNumbers(int a, int b){
		return a + b;	
	}

	char* Core::returnMove(char* move){
		return "e4";	
	}

	//sample FEN rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
	int value = 0;
	int Core::parseFEN(const std::string& fen){
		int index = 0;
		char c = fen[index];
		while(c != ' ')
		{	
			c = fen[index];
			try{
				value += pieceValue.at(c);
			}
			catch (const std::out_of_range& e){
			
			}
			c = fen[++index];
		}
		return value;
	}
} // engine
