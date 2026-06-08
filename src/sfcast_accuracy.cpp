#include "sfcast_accuracy.h"

#ifdef SFCAST_ACCURACY

#include <stddef.h>
#include <stdio.h>

#include "apu.h"
#include "cpuexec.h"
#include "memmap.h"
#include "ppu.h"

static uint32 accuracy_frame_count;

static uint32 SfcastFnv1a(const void *data, size_t size)
{
	const uint8 *bytes = (const uint8 *) data;
	uint32 hash = 2166136261UL;

	while (size--)
	{
		hash ^= *bytes++;
		hash *= 16777619UL;
	}

	return hash;
}

static uint32 SfcastHashPointer(const uint8 *data, size_t size)
{
	if (!data)
		return 0;
	return SfcastFnv1a(data, size);
}

static uint32 SfcastHashSram()
{
	if (!Memory.SRAM)
		return 0;

	size_t size = Memory.SRAMMask ? (size_t) Memory.SRAMMask + 1 : 0;
	if (!size || size > 0x20000)
		size = 0x20000;

	return SfcastFnv1a(Memory.SRAM, size);
}

void SfcastAccuracyFrameEnd()
{
	accuracy_frame_count++;

	uint32 pc = ((uint32) Registers.PB << 16) | Registers.PC;
	uint32 apu_pc = APURegisters.PC;
	uint32 wram_hash = SfcastHashPointer(Memory.RAM, 0x20000);
	uint32 vram_hash = SfcastHashPointer(Memory.VRAM, 0x10000);
	uint32 fillram_hash = SfcastHashPointer(Memory.FillRAM, 0x8000);
	uint32 sram_hash = SfcastHashSram();
	uint32 apuram_hash = SfcastHashPointer(IAPU.RAM, 0x10000);
	uint32 apudsp_hash = SfcastFnv1a(APU.DSP, sizeof(APU.DSP));
	uint32 cgram_hash = SfcastFnv1a(PPU.CGDATA, sizeof(PPU.CGDATA));
	uint32 oam_hash = SfcastFnv1a(PPU.OBJ, sizeof(PPU.OBJ));

	printf("SFCAST_ACCURACY frame=%lu pc=%06lx a=%04lx x=%04lx y=%04lx s=%04lx d=%04lx db=%02lx p=%04lx cpu_cycles=%ld vc=%ld apu_pc=%04lx apu_ya=%04lx apu_x=%02lx apu_s=%02lx apu_p=%02lx apu_cycles=%ld wram=%08lx vram=%08lx fillram=%08lx sram=%08lx apuram=%08lx apudsp=%08lx cgram=%08lx oam=%08lx ppu_mode=%02lx brightness=%02lx forced_blank=%lu render=%lu\n",
		(unsigned long) accuracy_frame_count,
		(unsigned long) pc,
		(unsigned long) Registers.A.W,
		(unsigned long) Registers.X.W,
		(unsigned long) Registers.Y.W,
		(unsigned long) Registers.S.W,
		(unsigned long) Registers.D.W,
		(unsigned long) Registers.DB,
		(unsigned long) Registers.P.W,
		(long) CPU.Cycles,
		(long) CPU.V_Counter,
		(unsigned long) apu_pc,
		(unsigned long) APURegisters.YA.W,
		(unsigned long) APURegisters.X,
		(unsigned long) APURegisters.S,
		(unsigned long) APURegisters.P,
		(long) APU.Cycles,
		(unsigned long) wram_hash,
		(unsigned long) vram_hash,
		(unsigned long) fillram_hash,
		(unsigned long) sram_hash,
		(unsigned long) apuram_hash,
		(unsigned long) apudsp_hash,
		(unsigned long) cgram_hash,
		(unsigned long) oam_hash,
		(unsigned long) PPU.BGMode,
		(unsigned long) PPU.Brightness,
		(unsigned long) PPU.ForcedBlanking,
		(unsigned long) IPPU.RenderThisFrame);
}

#endif
