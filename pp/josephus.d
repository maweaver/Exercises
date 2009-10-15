import std.stdio;

class Person {
	int id;
	Person next;
	
	this(int id) {
		this.id = id;
	}
}
	
Person createCircle(int n) {
	Person start = null;
	Person end = null;
	for(int i = 0; i < n; i++) {
		auto p = new Person(i);
		if(end) {
			end.next = p;
		}
		end = p;
		if(!start) {
			start = p;
		}
	}
	end.next = start;
	
	return start;
}
	

int[] josephus(int n, int m) {
	int[] killed;
	
	Person alive = createCircle(n);
	
	int numPasses = 1;
	Person passer = alive;
	Person passee = alive.next;
	
	while(killed.length != n) {
		if(numPasses == m - 1) {
			killed ~= passee.id;
			passer.next = passee.next;
			passee = passee.next;
			numPasses = 0;
		} else {
			passer = passee;
			passee = passee.next;
			numPasses++;
		}
	}
	
	return killed;
}

void main() {
	auto killed = josephus(41, 3);

	writef("[ ");
	foreach(s; killed) {
		writef(" %02d ", s);
	}
	writefln(" ]");
}
