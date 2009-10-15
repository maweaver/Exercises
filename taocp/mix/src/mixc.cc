///   \file mixc.cc 
///   \brief Driver application for the compiler

#include <iostream>
#include <fstream>
#include <argp.h>

#include <mixal.hh>

int debug_lexer; /*!< Flag used to tell the lexer to go into debug mode */


static const char *doc                      = "mixc -- A compiler for MIX programs";   /*!< Overview documentation                 */
static const char *args_doc                 = "inputfile";                             /*!< Arguments overview documentation       */
       const char *argp_program_version     = "1.0";                                   /*!< Version number displayed in help       */
       const char *argp_program_bug_address = "matt@innerweaver.com";                  /*!< Maintainer address displayed in help   */



static const int argp_option_verbose      = 'v';   /*!< Verbose output */
static const int argp_option_debug_parser = -101;  /*!< Debug the parser */
static const int argp_option_debug_lexer  = -102;  /*!< Debug the lexer */
static const int argp_option_inputfile    = 'i';   /*!< Input file     */

/*!
 *  \brief  List of available options
 */
static struct argp_option options[] = {
	{ "verbose",     argp_option_verbose,           0, 0, "Produce verbose output" },
	{ "debugparser", argp_option_debug_parser,      0, 0, "Debug the parser" },
	{ "debuglexer",  argp_option_debug_lexer,       0, 0, "Debug the lexer" },
	{ "inputfile",   argp_option_inputfile,    "FILE", 0, "Compile from source FILE" },
	{ 0 }
};

/*!
 *  \brief  Holder for argument values
 */
struct Arguments {
	
	/*!
	 *   \brief Default constructor
	 */
	Arguments() 
	: verbose(false),
	  debugParser(false),
	  debugLexer(false),
	  inputFile("")
	{
	}
	
	bool        verbose;     /*!< Whether to create verbose output     */
	bool        debugParser; /*!< Whether to debug the parser          */
	bool        debugLexer;  /*!< Whether to debug the lexer           */
	std::string inputFile;   /*!< Name of the source file to compile   */
};

/*!
 *   \brief Handle a single argument
 *
 *   Callback function used to handle arguments
 *
 *   \param   key    Key of the argument
 *   \param   arg    Argument value
 *   \param   state  Argument parser state
 */
static error_t parse_opt(int key, char *arg, struct argp_state *state) {
	Arguments *args = reinterpret_cast<Arguments *>(state->input);
	
	switch(key) {
	case argp_option_verbose:
		args->verbose = true;
		break;
		
	case argp_option_debug_parser:
		args->debugParser = true;
		break;

	case argp_option_debug_lexer:
		args->debugLexer = true;
		break;

	case argp_option_inputfile:
		args->inputFile = arg;
		break;
		
	case ARGP_KEY_ARG:
		if(state->arg_num >= 1) {
			argp_usage(state);
		}
		
		args->inputFile = arg;
		break;
		
	default:
		return ARGP_ERR_UNKNOWN;
	}
	
	return 0;
}

/*!
 *   \brief Application entry point
 *
 *   Main entry point for the application.  Parses arguments and delegates
 *   control to other parts of the application.
 */
int main(int argc, char **argv)
{
	Arguments args;
	args.verbose = false;
	struct argp argp = { options, parse_opt, args_doc, doc };
	
	/* Parse arguments */
	argp_parse(&argp, argc, argv, 0, 0, &args);
	
	/* Ensure we have an input file */
	if(args.inputFile.size() == 0) {
		std::cerr << "No input file specified" << std::endl;
		return -1;
	}
	
	if(args.verbose) {
		std::cout << "Compiling file '" << args.inputFile << "'" << std::endl;
	}

	if(args.debugLexer) {
		debug_lexer = 1;
	} else {
		debug_lexer = 0;
	}
	
	mixal::Program prog;

	prog.debug = args.debugParser;

	/* Parse the program */
	try {
		prog.parse(args.inputFile);
	} catch(const char *msg) {
		std::cerr << msg << std::endl;
		return -1;
	}
	
	return 0;
}
