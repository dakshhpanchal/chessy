from ctypes import CDLL, c_char_p, c_int, c_char_p

try:
    my_library = CDLL("./build/libengine.so")
except OSError as e:
    print(f"Error loading library: {e}")
    exit()

my_library.add_numbers.argtypes = [c_int, c_int]
my_library.add_numbers.restype = c_int

my_library.return_move.argtypes = [c_char_p]
my_library.return_move.restype = c_char_p

my_library.eval.argtypes = [c_char_p]
my_library.eval.restype = c_int

#sampleFEN = b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR "
#sampleFEN = b"r1bqkbr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R "
sampleFEN = b"8/8/8/8/1P6/8/8/7k "
sum_result = my_library.eval(sampleFEN)
print(f"Sum: {sum_result}")

