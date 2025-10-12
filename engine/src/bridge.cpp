#include "engine/core.h"
#include "engine/engine.h"

extern "C" {
	int eval(char* fen){
		engine::Core c;
        return c.evaluatePosition(fen);
	}
}
