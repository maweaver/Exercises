import std.stdio;

struct DecimalDigit {
	string one;
	string five;
	bool subJump;
}

DecimalDigit[] traditional = [
  DecimalDigit("I", "V", true),
	DecimalDigit("X", "L", true),
	DecimalDigit("C", "D", false),
	DecimalDigit("M", null, false) ];
	
DecimalDigit[] butchered = [
  DecimalDigit("\u2160", "\u2164", true),
	DecimalDigit("\u2169", "\u216c", true),
	DecimalDigit("\u216d", "\u216e", true),
	DecimalDigit("\u2160\u0305", "\u2164\u0305", true),
	DecimalDigit("\u2169\u0305", "\u216c\u0305", true),
	DecimalDigit("\u216d\u0305", "\u216e\u0305", true),
	DecimalDigit("\u2170", "\u2174", true),
	DecimalDigit("\u2179", "\u217c", true),
	DecimalDigit("\u217d", "\u217e", true),
	DecimalDigit("\u2170\u0305", "\u2174\u0305", true),
	DecimalDigit("\u2179\u0305", "\u217c\u0305", true),
	DecimalDigit("\u217d\u0305", "\u217e\u0305", true),
	DecimalDigit("\u217f\u0305", null, true) ];

string decimalToRoman(uint value, DecimalDigit[] system) {
	string ret;
	int pos = 0;
	uint curDigit;
	
	while(value) {
		curDigit = value % 10;
		DecimalDigit roman = system[pos];
		
		if(roman.five) {
			if(curDigit < 4) {
				for(int i = 0; i < curDigit; i++) {
					ret = roman.one ~ ret;
				}
			} else if(curDigit == 4) {
				ret = roman.one ~ roman.five ~ ret;
			} else if((curDigit < 9 && pos < system.length - 1) || !roman.subJump) {
				for(int i = 0; i < curDigit - 5; i++) {
					ret = roman.one ~ ret;
				}
				ret = roman.five ~ ret;
			} else {
				ret = roman.one ~ system[pos + 1].one ~ ret;
			}
			
		} else {
			for(int i = 0; i < value; i++) {
				ret = roman.one ~ ret;
			}
			value = 0;
		}
		
		value /= 10;
		pos++;
	}
	
	return ret;
}

uint romanToDecimal(string value, DecimalDigit[] system) {
  uint ret = 0;
	int pos = system.length - 1;
  int curChar = 0;
	
	enum NextChar {
		One,
		Five,
		Ten,
		Neither
	};
	
	NextChar getNextChar() {
		DecimalDigit curRoman = system[pos];
		DecimalDigit prevRoman = DecimalDigit(null, null);
		if(pos != system.length - 1) {
			prevRoman = system[pos + 1];
		}
		if(curRoman.one && curChar + curRoman.one.length <= value.length && value[curChar..curChar + curRoman.one.length] == curRoman.one) {
			return NextChar.One;
		} else if(curRoman.five && curChar + curRoman.five.length <= value.length && value[curChar..curChar + curRoman.five.length] == curRoman.five) {
			return NextChar.Five;
		} else if(prevRoman.one && curChar + prevRoman.one.length <= value.length && value[curChar..curChar + prevRoman.one.length] == prevRoman.one) {
			return NextChar.Ten;
		} else {
			return NextChar.Neither;
		}
	}

  while(pos >= 0 && curChar < value.length) {
		ret *= 10;
		
		int curDigit = 0;		
		
		while(getNextChar() == NextChar.Neither && pos >= 0) {
			pos--;
		}
		
		DecimalDigit roman = system[pos];

		while(getNextChar() == NextChar.One) {
			curDigit--;
			curChar += roman.one.length;
		}
		
		if(getNextChar() != NextChar.Five && getNextChar() != NextChar.Ten) {
			curDigit = -curDigit;
		}
		
		while(getNextChar() == NextChar.Five) {
			curDigit += 5;
			curChar += roman.five.length;
		}
		
		while(getNextChar() == NextChar.Ten) {
			curDigit += 10;
			curChar += system[pos + 1].one.length;
		}

		while(getNextChar() == NextChar.One) {
			curDigit++;
			curChar += roman.one.length;
		}
		
		ret += curDigit;
	}
	
	return ret;
}

string addRoman(string value1, string value2, DecimalDigit[] inSystem, DecimalDigit[] outSystem) {
	return decimalToRoman(romanToDecimal(value1, inSystem) + romanToDecimal(value2, inSystem), outSystem);
}

void main() {
	writefln("%s", decimalToRoman(1732, traditional));
	writefln("%d", romanToDecimal("MDCCXXXII", traditional));
	
	writefln("%s", decimalToRoman(1956, traditional));
	writefln("%d", romanToDecimal("MDCCCCLVI", traditional));
	
	writefln("%s", decimalToRoman(uint.max, butchered));

	writefln("%d", romanToDecimal("CCCLXIX", traditional));
	writefln("%d", romanToDecimal("CDXLVIII", traditional));
	writefln("%s", romanToDecimal("DCCCXVII", traditional));
  writefln("%s", addRoman("CCCLXIX", "CDXLVIII", traditional, traditional));
}
