#ifndef ZLIB_H
#define ZLIB_H

typedef unsigned char Bytef;
typedef unsigned int uInt;
typedef unsigned long uLong;

#ifndef Z_NULL
#define Z_NULL 0
#endif

uLong crc32(uLong crc, const Bytef *buf, uInt len);

#endif
