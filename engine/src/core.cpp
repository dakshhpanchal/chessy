#include "engine/core.h"
#include <algorithm>
#include <cctype>

namespace engine {
    int Core::evaluatePosition(const std::string& fen) {
        int score = 0;
        int boardIndex = 0;
        int material = 0;
        
        for (size_t i = 0; i < fen.length() && fen[i] != ' '; i++) {
            char c = fen[i];
            
            if (c == '/') {
                continue;
            }
            else if (std::isdigit(c)) {
                boardIndex += (c - '0');
            }
            else {
                auto it = pieceValue.find(c);
                if (it != pieceValue.end()) {
                    score += it->second;
                    material += std::abs(it->second);
                }
                boardIndex++;
            }
        }
        
        GamePhase phase = getGamePhase(material);
        
        boardIndex = 0;
        for (size_t i = 0; i < fen.length() && fen[i] != ' '; i++) {
            char c = fen[i];
            
            if (c == '/') {
                continue;
            }
            else if (std::isdigit(c)) {
                boardIndex += (c - '0');
            }
            else {
                score += getPieceSquareValue(c, boardIndex, phase);
                boardIndex++;
            }
        }
        
        score += evaluatePawnStructure(fen);
        
        return Core::normalize(score);
    }

    Core::GamePhase Core::getGamePhase(int material) {
        if (material < 4000) return ENDGAME;
        if (material < 6000) return MIDDLEGAME;
        return OPENING;
    }

    int Core::getPieceSquareValue(char piece, int square, GamePhase phase) {
        int pstIndex = square;
        
        if (std::islower(piece)) {
            pstIndex = 56 - (pstIndex & 0b111000) + (pstIndex & 0b111);
        }
        
        int value = 0;
        switch(std::toupper(piece)) {
            case 'P': value = pstPawnMG[pstIndex]; break;
            case 'N': value = pstKnightMG[pstIndex]; break;
            case 'B': value = pstBishopMG[pstIndex]; break;
            case 'R': value = pstRookMG[pstIndex]; break;
            case 'Q': value = pstQueenMG[pstIndex]; break;
            case 'K': 
                value = (phase == ENDGAME) ? pstKingEG[pstIndex] : pstKingMG[pstIndex];
                break;
            default: value = 0;
        }
        
        return std::islower(piece) ? -value : value;
    }

    int Core::evaluatePawnStructure(const std::string& fen) {
        int pawnScore = 0;
        std::array<int, 8> whitePawns = {0};
        std::array<int, 8> blackPawns = {0};
        
        int boardIndex = 0;
        for (size_t i = 0; i < fen.length() && fen[i] != ' '; i++) {
            char c = fen[i];
            if (c == '/') continue;
            if (std::isdigit(c)) {
                boardIndex += (c - '0');
                continue;
            }
            
            int file = boardIndex % 8;
            if (c == 'P') whitePawns[file]++;
            else if (c == 'p') blackPawns[file]++;
            
            boardIndex++;
        }
        
        for (int file = 0; file < 8; file++) {
            if (whitePawns[file] > 1) pawnScore -= 20 * (whitePawns[file] - 1);
            if (blackPawns[file] > 1) pawnScore += 20 * (blackPawns[file] - 1);
        }
        
        return pawnScore;
    }

    int Core::normalize(int score) {
        double normalized = std::tanh(score / 2000.0);
        return static_cast<int>(normalized * 1000);
    }
}
