#include "engine/core.h"
#include "engine/engine.h"

extern "C" {
	int add_numbers(int a, int b){
		return engine::Core::addNumbers(a,b);
	}
}
