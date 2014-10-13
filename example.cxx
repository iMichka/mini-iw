/* File: example.cxx */

#include <string>
#include <iostream>
#include "example.h"

bool myfunc(std::string &value)
{
  value = "ccc";
  bool val;
  return val;
}


int main(void) {

  /*
  std::string a;
  std::string value;

  bool ret = myfunc(a, value);

  std::cout << ret << std::endl;
  std::cout << a << std::endl;
  */

  return 0;
}
