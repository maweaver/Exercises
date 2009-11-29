#include <iostream>

#include <parser.tab.hh>

extern "C" {
#include <mixstdlib.h>
#include <stdlib.h>
}

#include <memgen.hh>

namespace mixal {

	MemGen::MemGen(bool debug)
		: mDebug(debug), mMemory()
	{
	}

	std::vector<int> MemGen::memory(Statement *statements) {
		mMemory.clear();
		mMemory.resize(4000);

		statements->accept(NULL, *this);
		if(mDebug) {
			int i = 0;
			for(std::vector<int>::iterator it = mMemory.begin();
				it != mMemory.end();
				++it) {
				
				if(i % 8 == 0) {
					std::cerr.fill('0');
					std::cerr.width(2);
					std::cerr << std::endl << "0x";
					std::cerr.width(5);
					std::cerr << std::hex << i << "   ";
				}
				i++;
				std::cerr.width(10);
				std::cerr.fill(' ');
				std::cerr << std::dec  << *it << " ";
			}
			std::cerr << std::endl;
		}

		return mMemory;
	}

	void MemGen::preVisit(AstNode *parent, AstNode &node)
	{
	}

	void MemGen::postVisit(AstNode *parent, AstNode &node)
	{
		mixal::Con *con = dynamic_cast<mixal::Con *>(&node);
		if(con) {
			mMemory[con->address] = con->wExpression()->address()->value();
		}

		mixal::Alf *alf = dynamic_cast<mixal::Alf *>(&node);
		if(alf) {
			char *str = mix_ascii_to_str(alf->str().c_str());
			mMemory[alf->address] =
				(((int) str[0]) << (6 * 4)) +
				(((int) str[1]) << (6 * 3)) +
				(((int) str[2]) << (6 * 2)) +
				(((int) str[3]) << (6 * 1)) +
				(((int) str[4]) << (6 * 0));
			free(str);
		}
	}

	void MemGen::visit(AstNode *parent, AstNode &node)
	{
		
	}

}
