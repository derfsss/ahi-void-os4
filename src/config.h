/* SPDX-License-Identifier: MIT */
/*
 * config.h -- what AHI's configure answers for powerpc-unknown-amigaos
 * (upstream/ahi/configure.in, the powerpc-unknown-amigaos arm), written out
 * once because this repository builds one driver for one target and runs
 * no configure.
 */
#ifndef AHI_VOID_OS4_CONFIG_H
#define AHI_VOID_OS4_CONFIG_H

#define __USE_INLINE__   1   /* configure.in: "Use inlines" */
#define __USE_BASETYPE__ 1   /* configure.in: "Use traditional library base type" */

#define HAVE_INTTYPES_H  1
#define HAVE_STDINT_H    1
#define HAVE_STDIO_H     1
#define HAVE_STDLIB_H    1
#define HAVE_STRING_H    1
#define HAVE_STRINGS_H   1
#define HAVE_SYS_STAT_H  1
#define HAVE_SYS_TYPES_H 1
#define HAVE_UNISTD_H    1
#define STDC_HEADERS     1

#define WORDS_BIGENDIAN  1

/* AROS's pointer-sized integer, which the AHI sources use for tag data.
 * The AmigaOS 4 SDK has none; a pointer is 32 bits there, as ULONG is. */
#ifndef IPTR
#define IPTR ULONG
#endif

/* The Void slave's timer: the SDK's devices/timer.h names the classic
 * struct timerequest and tv_secs/tv_micro only under this symbol. */
#define __USE_OLD_TIMEVAL__ 1

/* AROS's unsigned 64-bit type, for the slave's E-clock deadline. */
#ifndef UQUAD
#define UQUAD unsigned long long
#endif

#endif /* AHI_VOID_OS4_CONFIG_H */
