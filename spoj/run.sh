#!/bin/zsh

problem=$argv[1]
type=$argv[2]
known=$argv[3]

if [[ -n $known ]] then
  extension=.expected
else
  extension=$type
fi

function runLisp() {
  time sbcl --script $argv[1] < $argv[2] > $argv[3]
}

function runOcaml() {
  time ocaml $argv[1] < $argv[2] > $argv[3]
}

function runD() {
	/home/matt/Apps/dmd/linux/bin/dmd $argv[1] -ofdrun -debug -w -gc
	time ./drun < $argv[2] > $argv[3]
}
	

function runProblem() {
  scriptFile=$problem.$type
  inFile=input/$problem
  outputFile=output/$problem$extension
  expectedFile=output/$problem.expected
  
  if [[ $argv[2] == "lisp" ]] then
  	  echo "--- $scriptFile ---"
    runLisp $scriptFile $inFile $outputFile
  elif [[ $argv[2] == "ml" ]] then
  	  echo "--- $scriptFile ---"
  	  runOcaml $scriptFile $inFile $outputFile
  	elif [[ $argv[2] == "d" ]] then
  	  echo "--- $scriptFile ---"
  	  runD $scriptFile $inFile $outputFile
  	else
  	  return
  fi
  
  if [[ $outputFile != $expectedFile ]] then
  	  if [[ -a output/$problem.expected ]] then
  	  	  diff -q $outputFile $expectedFile
  	  	  if [[ $? == 0 ]] then
  	  	  	  echo "Matched expected results!"
  	  	  	fi
  	  	fi
  fi
}

if [[ -n $type ]] then
  runProblem $problem $type $extension
else
  for f in $problem.*; do
    type=${f/*./}
    if [[ -z $extension ]] then
      extension=.$type
    fi
    runProblem $problem $type $extension
  done
fi

if [[ -z $extension ]] then
  extension=".ml"
fi
