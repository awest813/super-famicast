/* utils.c - stricmp/strnicmp are provided via port.h macros on KOS/POSIX.
   These function bodies are kept for reference only; actual calls are
   resolved to strcasecmp/strncasecmp at compile time via port.h. */

#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "utils.h"
