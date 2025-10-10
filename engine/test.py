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

sum_result = my_library.add_numbers(1, 2)
print(f"Sum: {sum_result}")
move = my_library.return_move(b"sex")
print(f"Move: {move}")

