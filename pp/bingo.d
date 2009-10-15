import std.random;
import std.stdio;

class Card {
	int[][] spots;
	
	this() {
		spots = new int[][](5, 5);
		
		for(int col = 0; col < 5; col++) {
			auto used = new bool[15];
			for(int i = 0; i < 5; i++) {
				if(col == 2 && i == 2) {
					spots[col][i] = -1;
				} else {
					int n;
					while(true) {
						n = (rand() % 15) + 1 ;
						if(!used[n - 1]) {
							used[n - 1] = true;
							spots[col][i] = n + (col * 15);
							break;
						}
					}
				}
			}
		}
	}
	
	void call(int num) {
		int col = (num - 1) / 15;
		foreach(ref spot; spots[col]) {
			if(spot == num) {
				spot = -1;
			}
		}
	}
	
	string toString() {
		char[] res = "";
		for(int y = 0; y < 5; y++) {
			for(int x = 0; x < 5; x++) {
				auto v = spots[x][y];
				if(v == -1) {
					res ~= "XX";
				} else {
					if(v < 10 && v != -1) {
						res ~= "0";
					}
					res ~= std.string.toString(v);
				}
				res ~= " ";
			}
			res ~= "\n";
		}
		return res;
	}
	
	bool solved() {
		// Check each row
		for(int row = 0; row < 5; row++) {
			bool rowSolved = true;
			for(int col = 0; col < 5; col++) {
				if(spots[col][row] != -1) {
					rowSolved = false;
				}
			}
			if(rowSolved) {
				return true;
			}
		}
		
		// Check each column
		for(int col = 0; col < 5; col++) {
			bool colSolved = true;
			for(int row = 0; col < 5; col++) {
				if(spots[col][row] != -1) {
					colSolved = false;
				}
			}
			if(colSolved) {
				return true;
			}
		}
		
		// Do the diagonals manually
		if(spots[0][0] == -1 &&
			spots[1][1] == -1 &&
			spots[3][3] == -1 &&
			spots[4][4] == -1) {
				return true;
			}

		// Do the diagonals manually
		if(spots[4][0] == -1 &&
			spots[3][1] == -1 &&
			spots[1][3] == -1 &&
			spots[0][4] == -1) {
				return true;
			}
			
		return false;
	}
}

int countCalls(int numCards) {
	auto cards = new Card[numCards];
	for(int i = 0; i < numCards; i++) {
		cards[i] = new Card();
	}
	
	int numCalls = 0;
	auto solved = false;
	auto called = new bool[75];
	
	while(!solved) {
		while(true) {
			auto call = rand() % 75 + 1;
			if(!called[call - 1]) {
				called[call - 1] = true;
		
				foreach(card; cards) {
					card.call(call);
					solved |= card.solved;
				}
				
				numCalls++;
				break;
			}
		}
	}
	
	return numCalls;
}

void main() {
	int totalCalls = 0;
	for(int i = 0; i < 10000; i++) {
		totalCalls += countCalls(1);
	}
	writefln("%d", totalCalls / 10000);
	totalCalls = 0;
	for(int i = 0; i < 10000; i++) {
		totalCalls += countCalls(500);
	}
	writefln("%d", totalCalls / 10000);
}
