int ast_number(double val);

int ast_binary_expression(char operation, int lhIndex, int rhIndex);

int ast_variable(int identifier);

int ast_identifier(char *name);

int ast_call(int identifier, int args);

int ast_call_arg(int value, int nextArg);

int ast_prototype(int identifier, int args);

int ast_prototype_arg(int identifier, int nextArg);

int ast_function(int prototype, int expression);

int ast_extern(int prototype);

int ast_output(int expression);
