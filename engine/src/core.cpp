#include "engine/core.h"
#include <algorithm>
#include <cctype>

namespace engine {
    int Core::evaluatePosition(const std::string& fen){
        int score = 0;
        int boardIndex = 0;
        
        // we are currently parsing only chess pieces
        for (size_t i = 0; i < fen.length() && fen[i] != ' '; i++) {
            char c = fen[i];
            
            if (c == '/') {
                continue; // rank seperator
            }
            else if (std::isdigit(c)) {
                boardIndex += (c - '0'); // pwns
            }
            else {
                auto it = pieceValue.find(c);
                if (it != pieceValue.end()) {
                    score += it->second;
                    score += getPieceSquareValue(c, boardIndex);
                }
                boardIndex++;
            }
        }

        
        return Core::normalize(score);
    }

    int Core::normalize(int score) {
        double normalized = std::tanh(score / 1000.0);
        return static_cast<int>(normalized * 1000);
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
} // engine
