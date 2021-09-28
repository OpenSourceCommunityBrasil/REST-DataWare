#include <String.h>

class RDWBaseclass
{
  public:
  
    /** If there is spaceAvailable in the buffer, lets send a XON
     */
    void ParseRequest(String &paramSTR, String &contextName, String &eventName, String &paramsValues);    
};