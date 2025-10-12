#include "engine/core.h"
#include <algorithm>
#include <cctype>

namespace engine {
    int Core::addNumbers(int a, int b){
        return a + b;	
    }

    char* Core::returnMove(char* move){
        return "e4";	
    }

    int Core::parseFEN(const std::string& fen){
        int score = 0;
        int boardIndex = 0;
        
        // Parse the board position part of FEN (before the first space)
        for (size_t i = 0; i < fen.length() && fen[i] != ' '; i++) {
            char c = fen[i];
            
            if (c == '/') {
                continue; // Skip rank separator
            }
            else if (std::isdigit(c)) {
                // Skip empty squares
                boardIndex += (c - '0');
            }
            else {
                // It's a piece - add its value and positional score
                auto it = pieceValue.find(c);
                if (it != pieceValue.end()) {
                    score += it->second;
                    score += getPieceSquareValue(c, boardIndex);
                }
                boardIndex++;
            }
        }
        
        return score;
    }

    int Core::getPieceSquareValue(char piece, int square) {
        int pstIndex = square;
        
        if (std::islower(piece)) {
            pstIndex = 63 - square;
        }
        
        switch(std::toupper(piece)) {
            case 'P': return pstPawn[pstIndex];
            case 'N': return pstKnight[pstIndex];
            case 'B': return pstBishop[pstIndex];
            case 'R': return pstRook[pstIndex];
            case 'Q': return pstQueen[pstIndex];
            case 'K': return pstKing[pstIndex];
            default: return 0;
        }
    }

    int Core::evaluatePosition(const std::string& fen) {
        int materialScore = parseFEN(fen);
        
	//more eval here
        
        return materialScore;
    }
} // engine
