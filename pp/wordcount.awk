BEGIN {
	RS = "[^A-Za-z]"
	cur_word = 0;
}

{
	if($0 != "") {
		word = tolower($0);
		if(word in wc) {
			wc[word] = wc[word] + 1;
		} else {
			wc[word] = 1;
		}
	}
}

END {
	for(word in wc) {
		if(wc[word] in freq) {
			freq[wc[word]] = freq[wc[word]] SUBSEP word;
		} else {
			freq[wc[word]] = word;
		}
	}
	
	num_words = asort(wc);
	
	for(i = num_words; i > num_words - n; i--) {
		split(freq[wc[i]], words, SUBSEP);
		for(word in words) {
			print words[word], ": ", wc[i]
		}
	}
}
