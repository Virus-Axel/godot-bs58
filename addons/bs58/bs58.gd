@tool
extends EditorPlugin
class_name bs58

const BASE_58_MAP := [
	'1', '2', '3', '4', '5', '6', '7', '8',
	'9', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q',
	'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
	'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
	'h', 'i', 'j', 'k', 'm', 'n', 'o', 'p',
	'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
	'y', 'z' ];

const ALPHABET_MAP := [
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255,  0,  1,  2,  3,  4,  5,  6,  7,  8, 255, 255, 255, 255, 255, 255,
	255,  9, 10, 11, 12, 13, 14, 15, 16, 255, 17, 18, 19, 20, 21, 255,
	22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 255, 255, 255, 255, 255,
	255, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 255, 44, 45, 46,
	47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
]


static func encode(bytes: PackedByteArray) -> String:
	var encoded := PackedByteArray()
	
	# Calculate the total length of the result
	var encoded_size: int = (bytes.size() * 138 / 100) + 1
	
	encoded.resize(encoded_size)
	var digit_size: int = 1
	
	for i in range(bytes.size()):
		var carry := int(bytes[i])
		
		for j in range(digit_size):
			carry = carry + int(encoded[j] << 8)
			encoded[j] = (carry % 58) % 256
			carry /= 58
			
		while carry:
			encoded[digit_size] = (carry % 58) % 256
			digit_size += 1
			carry /= 58
			
	var result: String
	
	for i in range(bytes.size() - 1):
		if bytes[i]:
			break
		result += BASE_58_MAP[0];
		
	for i in range(digit_size):
		var map_index: int = encoded[digit_size - 1 - i]
		result += (BASE_58_MAP[map_index]);

	return result


static func decode(str: String) -> PackedByteArray:
	var result := PackedByteArray()
	if str.length() == 0:
		
		return result
	
	# Worst case size
	result.resize(str.length() * 2)
	result[0] = 0;

	var resultlen: int = 1;
	for i in range(str.length()):
		var carry: int = ALPHABET_MAP[str.to_utf8_buffer()[i]];
		if (carry == -1):
			return [];
		for j in range(resultlen):
			carry += (result[j]) * 58;
			result[j] = (carry & 0xff) % 256;
			carry = carry >> 8;

		while (carry > 0):
			result[resultlen] = carry & 0xff
			resultlen += 1
			carry = carry >> 8

	for i in range(str.length()):
		if str[i] != '1':
			break
		result[resultlen] = 0;
		resultlen += 1

	var i: int = resultlen - 1
	var z: int = (resultlen >> 1) + (resultlen & 1)
	
	while(i >= z):
		var k: int = result[i];
		result[i] = result[resultlen - i - 1];
		result[resultlen - i - 1] = k;
		i -= 1

	return result.slice(0, resultlen)
