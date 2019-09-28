all: final.tab

clean:
	cat .gitignore | xargs rm -f -v

DEC_10_SF1_P1_with_ann.csv: DEC_10_SF1_P1.zip
	unzip -u DEC_10_SF1_P1.zip
	touch -c DEC_10_SF1_P1_with_ann.csv

part1.tab: DEC_10_SF1_P1_with_ann.csv
	perl proc.pl < DEC_10_SF1_P1_with_ann.csv > part1.tab

final.tab: part1.tab
	perl proc2.pl < part1.tab > final.tab

stat.tab: final.tab
	perl stat.pl < final.tab > stat.tab
