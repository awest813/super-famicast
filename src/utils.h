#ifndef _UTILS_H_
#define _UTILS_H_

/* On KOS/POSIX these are provided by strings.h */
#ifndef __WIN32__
#include <strings.h>
#ifndef stricmp
#define stricmp strcasecmp
#define strnicmp strncasecmp
#endif
#else

#ifdef __cplusplus
extern "C" {
#endif
int stricmp(const char *a, const char *b);
int strnicmp(const char *s1, const char *s2, unsigned int len);
#ifdef __cplusplus
}
#endif

#endif /* __WIN32__ */

#endif /* _UTILS_H_ */
