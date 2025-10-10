# chess-engine (unnamed)
A chess engine built from scratch.

# Important references 
PGN notation: https://en.wikipedia.org/wiki/Portable_Game_Notation <br>
PGN implementation in latex: https://www.overleaf.com/learn/latex/Chess_notation <br>
FEN notation to represent a board: https://www.chess.com/terms/fen-chess <br>
Chess board asset: https://sharechess.github.io/ <br>

# Project structure 
chess_project/
├── engine/             # C++ core logic
│   ├── include/        # Header files (Core.h, etc.)
│   ├── src/            # Source files (Core.cpp, etc.)
│   └── CMakeLists.txt  # Build configuration
│
├── app/                # Flutter frontend
│   ├── lib/            # Dart source
│   ├── pubspec.yaml    # Flutter project config
│   └── ...             
│
└── README.md

> [!WARNING]
> YOU MAY NEED TO INSTALL SHARED FILE PRODUCED BY THE ENGINE ACCORDING TO YOUR RESPECTIVE PLATFORM AS OF NOW

# Requirements
CMake ≥ 3.16 <br>
GCC or Clang (Linux/macOS) <br>
make or ninja <br>
Flutter SDK installed for the frontend <br>
