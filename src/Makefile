# Super Famicast Makefile
# by Scherzo

BUILD_PROFILE ?= release
ENABLE_NETPLAY ?= 0

TARGET = superfamicast.elf
OBJS =  utils.o main.o 2xsai.o apu.o apudebug.o c4.o c4emu.o cheats2.o clip.o cpu.o data.o debug.o dma.o 
OBJS += dsp1.o fxdbg.o fxemu.o fxinst.o gfx.o globals.o loadzip.o memmap.o obc1.o ppu.o screenshot.o 
OBJS += sdd1.o sdd1emu.o seta010.o seta011.o seta018.o seta.o snaporig.o snapshot.o snes9x.o soundux.o spc700.o 
OBJS += spc7110.o spc.o spccycles.o srtc.o tile.o explode.o unreduce.o unshrink.o unzip.o cheats.o scanf.o dc_utils.o 
OBJS += dc_vmu.o XML.o dc_menu.o pvr_texture.o dc_controller.o dc_mouse.o dc_file_browser.o test.o sa1.o scherzo_snd_stream.o 
OBJS += offsets.o sfcast_profile.o sfcast_accuracy.o

CPP_CPU_OBJS = cpuexec.o cpuops.o sa1cpu.o 
ASM_CPU_OBJS = sh/cpuexec.o sh/cpuops.o

# Keep the SH SA-1 core as the fast default; use USE_SA1_ASM=0 to fall back
# to the portable C core while debugging correctness or toolchain issues.
USE_SA1_ASM ?= 1
ifeq ($(USE_SA1_ASM),1)
SA1_CPU_OBJ = sh/sa1ops.o
else
SA1_CPU_OBJ = sa1cpu.o
endif

MY_AFLAGS = -Wa,-little -DSPC700_C -DVAR_CYCLES -DCPU_SHUTDOWN -DSPC700_SHUTDOWN

OBJS += $(ASM_CPU_OBJS) $(SA1_CPU_OBJ)

ifeq ($(ENABLE_NETPLAY),1)
OBJS += netplay.o server.o
endif

KOS_EXTRA_FLAGS = -D_XBOX -DUNZIP_SUPPORT -DNOASM -DSDD1_DECOMP -DSPC700_C -DVAR_CYCLES -DCPU_SHUTDOWN -DSPC700_SHUTDOWN
ifeq ($(ENABLE_NETPLAY),1)
KOS_EXTRA_FLAGS += -DNETPLAY_SUPPORT
endif
KOS_COMMON_FLAGS = -mrelax -m4-single-only -fno-exceptions -fno-strict-aliasing

ifeq ($(wildcard $(KOS_PORTS)/include/plx/font.h),)
KOS_PORTS = /opt/toolchains/dc/kos-ports
endif

SFCAST_INC_PATHS = -I$(KOS_PORTS)/include
SFCAST_LIB_PATHS = -L$(KOS_PORTS)/lib

ifeq ($(BUILD_PROFILE),debug)
KOS_OPTIMIZATION_FLAGS = -O1 -g -fno-omit-frame-pointer -fno-schedule-insns2
else ifeq ($(BUILD_PROFILE),profile)
KOS_OPTIMIZATION_FLAGS = -O2 -g -fomit-frame-pointer -ffast-math -DSFCAST_PROFILE
else ifeq ($(BUILD_PROFILE),compat)
KOS_OPTIMIZATION_FLAGS = -O2 -g -fno-omit-frame-pointer
else ifeq ($(BUILD_PROFILE),accuracy)
KOS_OPTIMIZATION_FLAGS = -O1 -g -fno-omit-frame-pointer -fno-schedule-insns2 -DSFCAST_ACCURACY
else
KOS_OPTIMIZATION_FLAGS = -Ofast -ffast-math -fomit-frame-pointer -falign-functions=4 -falign-loops=4 -falign-labels=4 -falign-jumps=4
endif

KOS_CFLAGS += $(KOS_EXTRA_FLAGS) $(KOS_COMMON_FLAGS) $(KOS_OPTIMIZATION_FLAGS)
KOS_CPPFLAGS += $(KOS_EXTRA_FLAGS) $(KOS_COMMON_FLAGS) $(KOS_OPTIMIZATION_FLAGS) -fno-rtti
KOS_LDFLAGS += $(SFCAST_LIB_PATHS)

CFLAGS += $(KOS_EXTRA_FLAGS) $(KOS_COMMON_FLAGS) $(KOS_OPTIMIZATION_FLAGS)
CXXFLAGS += $(KOS_EXTRA_FLAGS) $(KOS_COMMON_FLAGS) $(KOS_OPTIMIZATION_FLAGS) -fno-rtti
CPPFLAGS += $(SFCAST_INC_PATHS)

all: rm-elf $(TARGET)

include $(KOS_BASE)/Makefile.rules

clean:
	-rm -f $(TARGET) $(BIN) $(OBJS) romdisk.*

cleanasm:
	-rm -f $(ASM_CPU_OBJS) sh/sa1ops.o

rm-elf:
	-rm -f $(TARGET) $(BIN) romdisk.*

$(TARGET): $(OBJS) romdisk.o
	$(KOS_CC) $(KOS_STARTUP) $(OBJS) romdisk.o -o $(TARGET) $(KOS_LDFLAGS) -lparallax -lkmg -lpng -ljpeg -lstdc++ -lsupc++ -lmp3 -loggvorbisplay -lvorbis -logg -lz $(KOS_LIBS)
	$(KOS_STRIP) $(TARGET)
	mkdir -p bin
	$(KOS_OBJCOPY) -O binary $(TARGET) bin/raw.bin
	scramble bin/raw.bin bin/1ST_READ.BIN
	cp bin/1ST_READ.BIN cd/1ST_READ.BIN
	cp $(TARGET) bin/$(TARGET)

romdisk.img:
	$(KOS_GENROMFS) -f romdisk.img -d romdisk -v

romdisk.o: romdisk.img
	$(KOS_BASE)/utils/bin2o/bin2o romdisk.img romdisk_boot romdisk.o

sh/cpuexec.o:
	$(KOS_CC) $(MY_AFLAGS) -c sh/cpuexec.S -o sh/cpuexec.o

sh/cpuops.o:
	$(KOS_CC) $(MY_AFLAGS) -c sh/cpuops.S -o sh/cpuops.o

sh/sa1ops.o:
	$(KOS_CC) $(MY_AFLAGS) -c sh/sa1ops.S -o sh/sa1ops.o

cdimg:
	mkisofs -J -o data.iso cd
