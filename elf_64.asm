; ELF Header Reader in Assembly (x86, Linux)
; Assembler: nasm
; Usage: nasm -f elf32 elf_reader.asm -o elf_reader.o
;        ld -m elf_i386 elf_reader.o -o elf_reader
;        ./elf_reader <elf_file_path>

section .data
    pathname dd "/bin/sh"
    prompt db 'Enter file path: ', 10
    hex_table db "0123456789ABCDEF"
    err_open db "Error: Cannot open file", 10, 0
    err_read db "Error: Cannot read file", 10, 0
;ELFHeader
    elf_header db "ELF Header: ", 10
    elf_magic db 9,"Magic: ", 9
    elf_class db 9,"Class: ", 9, 9, 9, 9, 9
    elf_class_64bit db "ELF64", 10
    elf_class_32bit db "ELF32", 10
    elf_data db 9,"Data: ", 9, 9, 9, 9, 9
    elf_data_bigendian db "1's complement, big endian", 10
    elf_data_littleendian db "2's complement, little endian", 10
    elf_version db 9,"Version: ", 9, 9, 9, 9
    elf_version_1 db "1 (current)", 10
    elf_version_sth db "sth", 10
    elf_osabi db 9,"OS/ABI: ", 9, 9, 9, 9, 9
    
    ELFOSABI_NONE db "UNIX - System V", 10
    ELFOSABI_HPUX db "UNIX - HP-UX", 10
    ELFOSABI_NETBSD db "UNIX - NetBSD", 10
    ELFOSABI_GNU db "UNIX - GNU", 10
    ELFOSABI_SOLARIS db "UNIX - Solaris", 10
    ELFOSABI_AIX db "UNIX - AIX", 10
    ELFOSABI_IRIX db "UNIX - TRU64", 10
    ELFOSABI_FREEBSD db "UNIX - FreeBSD", 10
    ELFOSABI_TRU64 db "UNIX - HP-UX", 10
    ELFOSABI_MODESTO db "Novell - Modesto", 10
    ELFOSABI_OPENBSD db "UNIX - OpenBSD", 10
    ELFOSABI_OPENVMS db "VMS - OpenVMS", 10
    ELFOSABI_NSK db "HP - Non-Stop Kernel", 10
    ELFOSABI_AROS db "AROS", 10
    ELFOSABI_FENIXOS db "FenixOS", 10
    ELFOSABI_CLOUDABI db "Nuxi CloudAB", 10
    ELFOSABI_OPENVOS db "Stratus Technologies OpenVOS", 10
    ELFOSABI_CUDA db "CUDA", 10

    elf_abi_version db 9,"ABI Version: ", 9, 9, 9, 9, 9
    elf_type db 9,"Type: ", 9, 9, 9, 9, 9

    ET_NONE db "NONE (None)", 10
    ET_REL db "REL (Relocatable file)", 10
    ET_EXEC db "EXEC (Executable file)", 10
    ET_DYN db "DYN (Shared object file)", 10
    ET_CORE db "CORE (Core file)", 10
    ET_OS db "Reserved inclusive range. Operating system specific", 10
    ET_PROC db "Reserved inclusive range. Processor specific", 10

    elf_machine db 9,"Machine: ", 9, 9, 9, 9, 9

    EM_NONE db  "None",10
    EM_M32 db  "WE32100" , 10
    EM_SPARC db  "Sparc" , 10
    EM_386 db  "Intel 80386" , 10
    EM_68K db  "MC68000" , 10
    EM_88K db  "MC88000" , 10
    EM_IAMCU db  "Intel MCU" , 10
    EM_860 db  "Intel 80860" , 10
    EM_MIPS db  "MIPS R3000" , 10
    EM_S370 db  "IBM System/370" , 10
    EM_MIPS_RS3_LE db "MIPS R4000 big-endian" , 10
    EM_OLD_SPARCV9 db "Sparc v9 (old)" , 10
    EM_PARISC db  "HPPA" , 10
    EM_VPP550 db  "Fujitsu VPP500" , 10
    EM_SPARC32PLUS db "Sparc v8+"  , 10
    EM_960 db  "Intel 80960" , 10
    EM_PPC db  "PowerPC" , 10
    EM_PPC64 db  "PowerPC64" , 10
    EM_S390_OLD db  "IBM S/390" , 10
    EM_S390 db  "IBM S/390" , 10
    EM_SPU db  "SPU" , 10
    EM_V800 db  "Renesas V850 (using RH850 ABI)" , 10
    EM_FR20 db  "Fujitsu FR20" , 10
    EM_RH32 db  "TRW RH32" , 10
    EM_MCORE db  "MCORE" , 10
    EM_ARM db  "ARM" , 10
    EM_OLD_ALPHA db  "Digital Alpha (old)" , 10
    EM_SH db "Renesas / SuperH SH" , 10
    EM_SPARCV9 db  "Sparc v9" , 10
    EM_TRICORE db  "Siemens Tricore" , 10
    EM_ARC db  "ARC" , 10
    EM_H8_300 db  "Renesas H8/300" , 10
    EM_H8_300H db  "Renesas H8/300H" , 10
    EM_H8S db  "Renesas H8S" , 10
    EM_H8_500 db  "Renesas H8/500" , 10
    EM_IA_64 db  "Intel IA-64" , 10
    EM_MIPS_X db  "Stanford MIPS-X" , 10
    EM_COLDFIRE db  "Motorola Coldfire" , 10
    EM_68HC12 db  "Motorola MC68HC12 Microcontroller" , 10
    EM_MMA db  "Fujitsu Multimedia Accelerator" , 10
    EM_PCP db  "Siemens PCP" , 10
    EM_NCPU db  "Sony nCPU embedded RISC processor" , 10
    EM_NDR1 db  "Denso NDR1 microprocessor" , 10
    EM_STARCORE db  "Motorola Star*Core processor" , 10
    EM_ME16 db  "Toyota ME16 processor" , 10
    EM_ST100 db  "STMicroelectronics ST100 processor" , 10
    EM_TINYJ db  "Advanced Logic Corp. TinyJ embedded processor" , 10
    EM_X86_64 db  "Advanced Micro Devices X86-64" , 10
    EM_PDSP db  "Sony DSP processor" , 10
    EM_PDP10 db  "Digital Equipment Corp. PDP-10" , 10
    EM_PDP11 db  "Digital Equipment Corp. PDP-11" , 10
    EM_FX66 db  "Siemens FX66 microcontroller" , 10
    EM_ST9PLUS db  "STMicroelectronics ST9+ 8/16 bit microcontroller" , 10
    EM_ST7 db  "STMicroelectronics ST7 8-bit microcontroller" , 10
    EM_68HC16 db  "Motorola MC68HC16 Microcontroller" , 10
    EM_68HC11 db  "Motorola MC68HC11 Microcontroller" , 10
    EM_68HC08 db  "Motorola MC68HC08 Microcontroller" , 10
    EM_68HC05 db  "Motorola MC68HC05 Microcontroller" , 10
    EM_SVX db  "Silicon Graphics SVx" , 10
    EM_ST19 db  "STMicroelectronics ST19 8-bit microcontroller" , 10
    EM_VAX db  "Digital VAX" , 10
    EM_CRIS db  "Axis Communications 32-bit embedded processor" , 10
    EM_JAVELIN db  "Infineon Technologies 32-bit embedded cpu" , 10
    EM_FIREPATH db  "Element 14 64-bit DSP processor" , 10
    EM_ZSP db  "LSI Logic's 16-bit DSP processor" , 10
    EM_MMIX db  "Donald Knuth's educational 64-bit processor" , 10
    EM_HUANY db  "Harvard Universitys's machine-independent object format" , 10
    EM_PRISM db  "Vitesse Prism" , 10
    EM_AVR_OLD db  "Atmel AVR 8-bit microcontroller" , 10
    EM_AVR db  "Atmel AVR 8-bit microcontroller" , 10
    EM_CYGNUS_FR30 db  "Fujitsu FR30" , 10
    EM_FR30 db  "Fujitsu FR30" , 10
    EM_CYGNUS_D10V db  "d10v" , 10
    EM_D10V db  "d10v" , 10
    EM_CYGNUS_D30V db  "d30v" , 10
    EM_D30V db  "d30v" , 10
    EM_CYGNUS_V850 db  "Renesas V850" , 10
    EM_V850 db  "Renesas V850" , 10
    EM_CYGNUS_M32R db  "Renesas M32R (formerly Mitsubishi M32r)" , 10
    EM_M32R db  "Renesas M32R (formerly Mitsubishi M32r)" , 10
    EM_CYGNUS_MN10300 db  "mn10300" , 10
    EM_MN10300 db  "mn10300" , 10
    EM_CYGNUS_MN10200 db  "mn10200" , 10
    EM_MN10200 db  "mn10200" , 10
    EM_PJ db "picoJava" , 10
    EM_OR1K db  "OpenRISC 1000" , 10
    EM_ARC_COMPACT db "ARCompact" , 10
    EM_XTENSA_OLD db  "Tensilica Xtensa Processor" , 10
    EM_XTENSA db  "Tensilica Xtensa Processor" , 10
    EM_VIDEOCORE db  "Alphamosaic VideoCore processor" , 10
    EM_TMM_GPP db  "Thompson Multimedia General Purpose Processor" , 10
    EM_NS32K db  "National Semiconductor 32000 series" , 10
    EM_TPC db  "Tenor Network TPC processor" , 10
    EM_SNP1K db "Trebia SNP 1000 processor" , 10
    EM_ST200 db  "STMicroelectronics ST200 microcontroller" , 10
    EM_IP2K_OLD db  "Ubicom IP2xxx 8-bit microcontrollers" , 10
    EM_IP2K db  "Ubicom IP2xxx 8-bit microcontrollers" , 10
    EM_MAX db  "MAX Processor" , 10
    EM_CR db "National Semiconductor CompactRISC" , 10
    EM_F2MC16 db  "Fujitsu F2MC16" , 10
    EM_MSP430 db  "Texas Instruments msp430 microcontroller" , 10
    EM_BLACKFIN db  "Analog Devices Blackfin" , 10
    EM_SE_C33 db  "S1C33 Family of Seiko Epson processors" , 10
    EM_SEP db  "Sharp embedded microprocessor" , 10
    EM_ARCA db  "Arca RISC microprocessor" , 10
    EM_UNICORE db  "Unicore" , 10
    EM_EXCESS db  "eXcess 16/32/64-bit configurable embedded CPU" , 10
    EM_DXP db  "Icera Semiconductor Inc. Deep Execution Processor" , 10
    EM_ALTERA_NIOS2 db "Altera Nios II" , 10
    EM_CRX db  "National Semiconductor CRX microprocessor" , 10
    EM_XGATE db  "Motorola XGATE embedded processor" , 10
    EM_C166 db  "Infineon Technologies xc16x" , 10
    EM_XC16X db  "Infineon Technologies xc16x" , 10
    EM_M16C db  "Renesas M16C series microprocessors" , 10
    EM_DSPIC30F db  "Microchip Technology dsPIC30F Digital Signal Controller" , 10
    EM_CE db "Freescale Communication Engine RISC core" , 10
    EM_M32C db "Renesas M32c" , 10
    EM_TSK3000 db  "Altium TSK3000 core" , 10
    EM_RS08 db  "Freescale RS08 embedded processor" , 10
    EM_ECOG2 db  "Cyan Technology eCOG2 microprocessor" , 10
    EM_SCORE db  "SUNPLUS S+Core" , 10
    EM_DSP24 db  "New Japan Radio (NJR) 24-bit DSP Processor" , 10
    EM_VIDEOCORE3 db  "Broadcom VideoCore III processor" , 10
    EM_LATTICEMICO32 db "Lattice Mico32" , 10
    EM_SE_C17 db  "Seiko Epson C17 family" , 10
    EM_TI_C6000 db  "Texas Instruments TMS320C6000 DSP family" , 10
    EM_TI_C2000 db  "Texas Instruments TMS320C2000 DSP family" , 10
    EM_TI_C5500 db  "Texas Instruments TMS320C55x DSP family" , 10
    EM_TI_PRU db  "TI PRU I/O processor" , 10
    EM_MMDSP_PLUS db  "STMicroelectronics 64bit VLIW Data Signal Processor" , 10
    EM_CYPRESS_M8C db "Cypress M8C microprocessor" , 10
    EM_R32C db  "Renesas R32C series microprocessors" , 10
    EM_TRIMEDIA db  "NXP Semiconductors TriMedia architecture family" , 10
    EM_QDSP6 db  "QUALCOMM DSP6 Processor" , 10
    EM_8051 db  "Intel 8051 and variants" , 10
    EM_STXP7X db  "STMicroelectronics STxP7x family" , 10
    EM_NDS32 db  "Andes Technology compact code size embedded RISC processor family" , 10
    EM_ECOG1X db  "Cyan Technology eCOG1X family" , 10
    EM_MAXQ30 db  "Dallas Semiconductor MAXQ30 Core microcontrollers" , 10
    EM_XIMO16 db  "New Japan Radio (NJR) 16-bit DSP Processor" , 10
    EM_MANIK db  "M2000 Reconfigurable RISC Microprocessor" , 10
    EM_CRAYNV2 db  "Cray Inc. NV2 vector architecture" , 10
    EM_RX db "Renesas RX" , 10
    EM_METAG db  "Imagination Technologies Meta processor architecture" , 10
    EM_MCST_ELBRUS db "MCST Elbrus general purpose hardware architecture" , 10
    EM_ECOG16 db  "Cyan Technology eCOG16 family" , 10
    EM_CR16 db "Xilinx MicroBlaze" , 10
    EM_MICROBLAZE db "Xilinx MicroBlaze" , 10
    EM_MICROBLAZE_OLD db "Xilinx MicroBlaze" , 10
    EM_ETPU db  "Freescale Extended Time Processing Unit" , 10
    EM_SLE9X db  "Infineon Technologies SLE9X core" , 10
    EM_L1OM db  "Intel L1OM" , 10
    EM_K1OM db  "Intel K1OM" , 10
    EM_INTEL182 db  "Intel (reserved)" , 10
    EM_AARCH64 db  "AArch64" , 10
    EM_ARM184 db  "ARM (reserved)" , 10
    EM_AVR32 db  "Atmel Corporation 32-bit microprocessor" , 10
    EM_STM8 db  "STMicroeletronics STM8 8-bit microcontroller" , 10
    EM_TILE64 db  "Tilera TILE64 multicore architecture family" , 10
    EM_TILEPRO db  "Tilera TILEPro multicore architecture family" , 10
    EM_CUDA db  "NVIDIA CUDA architecture" , 10
    EM_TILEGX db  "Tilera TILE-Gx multicore architecture family" , 10
    EM_CLOUDSHIELD db "CloudShield architecture family" , 10
    EM_COREA_1ST db  "KIPO-KAIST Core-A 1st generation processor family" , 10
    EM_COREA_2ND db  "KIPO-KAIST Core-A 2nd generation processor family" , 10
    EM_ARC_COMPACT2 db "ARCv2" , 10
    EM_OPEN8 db  "Open8 8-bit RISC soft processor core" , 10
    EM_RL78 db  "Renesas RL78" , 10
    EM_VIDEOCORE5 db  "Broadcom VideoCore V processor" , 10
    EM_78K0R db  "Renesas 78K0R" , 10
    EM_56800EX db  "Freescale 56800EX Digital Signal Controller (DSC)" , 10
    EM_BA1 db  "Beyond BA1 CPU architecture" , 10
    EM_BA2 db  "Beyond BA2 CPU architecture" , 10
    EM_XCORE db  "XMOS xCORE processor family" , 10
    EM_MCHP_PIC db  "Microchip 8-bit PIC(r) family" , 10
    EM_INTELGT db  "Intel Graphics Technology" , 10
    EM_KM32 db  "KM211 KM32 32-bit processor" , 10
    EM_KMX32 db  "KM211 KMX32 32-bit processor" , 10
    EM_KMX16 db  "KM211 KMX16 16-bit processor" , 10
    EM_KMX8 db  "KM211 KMX8 8-bit processor" , 10
    EM_KVARC db  "KM211 KVARC processor" , 10
    EM_CDP db  "Paneve CDP architecture family" , 10
    EM_COGE db  "Cognitive Smart Memory Processor" , 10
    EM_COOL db  "Bluechip Systems CoolEngine" , 10
    EM_NORC db  "Nanoradio Optimized RISC" , 10
    EM_CSR_KALIMBA db "CSR Kalimba architecture family" , 10
    EM_Z80 db  "Zilog Z80" , 10
    EM_VISIUM db  "CDS VISIUMcore processor" , 10
    EM_FT32 db "FTDI Chip FT32" , 10
    EM_MOXIE db "Moxie" , 10
    EM_AMDGPU db "AMD GPU" , 10
    EM_RISCV db "RISC-V" , 10
    EM_LANAI db  "Lanai 32-bit processor" , 10
    EM_CEVA db  "CEVA Processor Architecture Family" , 10
    EM_CEVA_X2 db  "CEVA X2 Processor Family" , 10
    EM_BPF db  "Linux BPF" , 10
    EM_GRAPHCORE_IPU db "Graphcore Intelligent Processing Unit" , 10
    EM_IMG1 db  "Imagination Technologies" , 10
    EM_NFP db  "Netronome Flow Processor" , 10
    EM_VE db "NEC Vector Engine" , 10
    EM_CSKY db  "C-SKY" , 10
    EM_ARC_COMPACT3_64 db "Synopsys ARCv3 64-bit processor" , 10
    EM_MCS6502 db  "MOS Technology MCS 6502 processor" , 10
    EM_ARC_COMPACT3 db "Synopsys ARCv3 32-bit processor" , 10
    EM_KVX db  "Kalray VLIW core of the MPPA processor family" , 10
    EM_65816 db  "WDC 65816/65C816" , 10
    EM_LOONGARCH db  "LoongArch" , 10
    EM_KF32 db  "ChipON KungFu32" , 10
    EM_MT db "Morpho Techologies MT processor" , 10
    EM_ALPHA db  "Alpha" , 10
    EM_WEBASSEMBLY db "Web Assembly" , 10
    EM_DLX db  "OpenDLX" , 10
    EM_XSTORMY16 db  "Sanyo XStormy16 CPU core" , 10
    EM_IQ2000 db "Vitesse IQ2000" , 10
    EM_M32C_OLD db  "Altera Nios" , 10
    EM_NIOS32 db  "Altera Nios" , 10
    EM_CYGNUS_MEP db "Toshiba MeP Media Engine" , 10
    EM_ADAPTEVA_EPIPHANY db "Adapteva EPIPHANY" , 10
    EM_CYGNUS_FRV db  "Fujitsu FR-V" , 10
    EM_S12Z db "Freescale S12Z" , 10

    EM_ARRAY: dd EM_NONE,EM_M32,EM_SPARC,EM_386,EM_68K,EM_88K,EM_IAMCU,EM_860,EM_MIPS,EM_S370,EM_MIPS_RS3_LE,EM_OLD_SPARCV9,EM_PARISC,EM_VPP550,EM_SPARC32PLUS,EM_960,EM_PPC,EM_NONE,EM_NONE,EM_NONE,EM_PPC64,EM_S390_OLD,EM_S390,EM_SPU,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_V800,EM_FR20,EM_RH32,EM_MCORE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_ARM,EM_OLD_ALPHA,EM_SH,EM_SPARCV9,EM_TRICORE,EM_ARC,EM_H8_300,EM_H8_300H,EM_H8S,EM_H8_500,EM_IA_64,EM_MIPS_X,EM_COLDFIRE,EM_68HC12,EM_MMA,EM_PCP,EM_NCPU,EM_NDR1,EM_STARCORE,EM_ME16,EM_ST100,EM_TINYJ,EM_X86_64,EM_PDSP,EM_PDP10,EM_PDP11,EM_FX66,EM_ST9PLUS,EM_ST7,EM_68HC16,EM_68HC11,EM_68HC08,EM_68HC05,EM_SVX,EM_ST19,EM_VAX,EM_CRIS,EM_JAVELIN,EM_FIREPATH,EM_ZSP,EM_MMIX,EM_HUANY,EM_PRISM,EM_AVR,EM_FR30,EM_D10V,EM_D30V,EM_V850,EM_M32R,EM_MN10300,EM_MN10200,EM_PJ,EM_OR1K,EM_ARC_COMPACT,EM_XTENSA,EM_VIDEOCORE,EM_TMM_GPP,EM_NS32K,EM_TPC,EM_SNP1K,EM_ST200,EM_IP2K,EM_MAX,EM_CR,EM_F2MC16,EM_MSP430,EM_BLACKFIN,EM_SE_C33,EM_SEP,EM_ARCA,EM_UNICORE,EM_EXCESS,EM_DXP,EM_ALTERA_NIOS2,EM_CRX,EM_XGATE,EM_XC16X,EM_M16C,EM_DSPIC30F,EM_CE,EM_M32C,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_TSK3000,EM_RS08,EM_ECOG2,EM_SCORE,EM_DSP24,EM_VIDEOCORE3,EM_LATTICEMICO32,EM_SE_C17,EM_NONE,EM_NONE,EM_TI_C6000,EM_TI_C2000,EM_TI_C5500,EM_TI_PRU,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_MMDSP_PLUS,EM_CYPRESS_M8C,EM_R32C,EM_TRIMEDIA,EM_QDSP6,EM_8051,EM_STXP7X,EM_NDS32,EM_ECOG1X,EM_MAXQ30,EM_XIMO16,EM_MANIK,EM_CRAYNV2,EM_RX,EM_METAG,EM_MCST_ELBRUS,EM_ECOG16,EM_MICROBLAZE_OLD,EM_ETPU,EM_SLE9X,EM_L1OM,EM_K1OM,EM_INTEL182,EM_AARCH64,EM_ARM184,EM_AVR32,EM_STM8,EM_TILE64,EM_TILEPRO,EM_NONE,EM_CUDA,EM_TILEGX,EM_CLOUDSHIELD,EM_COREA_1ST,EM_COREA_2ND,EM_ARC_COMPACT2,EM_OPEN8,EM_RL78,EM_VIDEOCORE5,EM_78K0R,EM_56800EX,EM_BA1,EM_BA2,EM_XCORE,EM_MCHP_PIC,EM_INTELGT,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_KM32,EM_KMX32,EM_KMX16,EM_KMX8,EM_KVARC,EM_CDP,EM_COGE,EM_COOL,EM_NORC,EM_CSR_KALIMBA,EM_Z80,EM_VISIUM,EM_FT32,EM_MOXIE,EM_AMDGPU,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_NONE,EM_RISCV,EM_LANAI,EM_CEVA,EM_CEVA_X2,EM_BPF,EM_GRAPHCORE_IPU,EM_IMG1,EM_NONE,EM_NONE,EM_NONE,EM_NFP,EM_VE,EM_CSKY,EM_ARC_COMPACT3_64,EM_MCS6502,EM_ARC_COMPACT3,EM_KVX,EM_65816,EM_LOONGARCH,EM_KF32,EM_MT,EM_ALPHA,EM_WEBASSEMBLY,EM_DLX,EM_XSTORMY16,EM_IQ2000,EM_M32C_OLD,EM_NIOS32,EM_CYGNUS_MEP,EM_ADAPTEVA_EPIPHANY,EM_CYGNUS_FRV,EM_S12Z
    
    prehex db "0x"

    elf_entry_point db 9,"Entry point address: ",9,9,9,9
    elf_start_program_header db 9,"Start of program headers: ",9,9,9,9
    elf_start_section_header db 9,"Start of section headers: ",9,9,9,9

    elf_desb_start db " (bytes into file) "
    elf_flag db 9,"Flags: ",9,9,9,9,9
    elf_size_this_header db 9,"Size of this headers:  ",9,9,9,9
    elf_size_program_header db 9,"Size of program headers: ",9,9,9,9
    elf_num_program_header db 9,"Number of program headers: ",9,9,9,9
    elf_size_section_header db 9,"Size of section headers: ",9,9,9,9
    elf_num_section_header db 9,"Number of section headers: ",9,9,9,9
    elf_section_header_index db 9,"Section header string table index: ",9,9,9,9
    elf_desb_byte db " (bytes) "

;SectionHeader
    section_header db "Section Headers: ", 10
    section_first_line db "[Nr]",9,"Name",9,9,9,"Type",9,9,9,"Address",9,9,9,"Offset",10
                       db 9,"Size",9,9,9,"EntSize",9,9,9,"Flags",9,"Link",9,"Info",9,"Align",10
    open db "[",0
    close db "]",0
    dot db ".",0

    SHT_NULL db "NULL", 9
    SHT_PROGBITS db "PROGBITS", 0
    SHT_SYMTAB db "SYMTAB", 0
    SHT_STRTAB db "STRTAB", 9
    SHT_RELA db "RELA", 9
    SHT_HASH db "HASH", 9
    SHT_DYNAMIC db "DYNAMIC", 9
    SHT_NOTE db "NOTE", 9
    SHT_NOBITS db "NOBITS", 9
    SHT_REL db "REL", 9
    SHT_SHLIB db "SHLIB", 9
    SHT_DYNSYM db "DYNSYM", 9
        ;/* 12 and 13 are not defined.  */
    SHT_DYNSYM_12 db "sth", 9
    SHT_DYNSYM_13 db "sth", 9
    SHT_INIT_ARRAY db "INIT_ARRAY", 0
    SHT_FINI_ARRAY db "FINI_ARRAY", 0
    SHT_PREINIT_ARRAY db "PREINIT_ARRAY", 0
    SHT_GROUP db "GROUP", 9
    SHT_SYMTAB_SHNDX db "SYMTAB SECTION INDICES", 0
    SHT_RELR db "RELR", 9
    SHT_RELR_END db "sth", 9

    ; from 0 - 19
    SHT_ARRAY dd SHT_NULL,SHT_PROGBITS,SHT_SYMTAB,SHT_STRTAB,SHT_RELA,SHT_HASH,SHT_DYNAMIC,SHT_NOTE,SHT_NOBITS,SHT_REL,SHT_SHLIB,SHT_DYNSYM,SHT_DYNSYM_12,SHT_DYNSYM_13,SHT_INIT_ARRAY,SHT_FINI_ARRAY,SHT_PREINIT_ARRAY,SHT_GROUP,SHT_SYMTAB_SHNDX,SHT_RELR,SHT_RELR_END

    ;0x6fff4700 
    SHT_GNU_INCREMENTAL_INPUTS db "GNU_INCREMENTAL_INPUTS", 0

    ; from 0x6ffffff5 to 0x6ffffffc	
    SHT_GNU_ATTRIBUTES db "GNU_ATTRIBUTES", 0
    SHT_GNU_HASH db "GNU_HASH", 0
    SHT_GNU_LIBLIST db "GNU_LIBLIST", 0
    SHT_CHECKSUM db "CHECKSUM"
    SHT_CHECKSUM_9 db "sth", 9
    SHT_SUNW_move db "SUNW_MOVE", 0
    SHT_SUNW_COMDAT db "SUNW_COMDAT", 0
    SHT_SUNW_syminfo db "SUNW_SYMINFO", 0
    SHT_GNU_verdef db "VERDEF",10
    SHT_GNU_verneed db "VERNEED", 9
    SHT_GNU_versym db "VERSYM", 9
    SHT_GNU_versym_end db "sth", 0
    ;from 0x6ffffff5 to 0x6ffffffc	
    SHT_ARRAY_6ffffffx dd SHT_GNU_ATTRIBUTES,SHT_GNU_HASH,SHT_GNU_LIBLIST,SHT_CHECKSUM,SHT_CHECKSUM_9,SHT_SUNW_move,SHT_SUNW_COMDAT,SHT_SUNW_syminfo,SHT_GNU_verdef,SHT_GNU_verneed,SHT_GNU_versym,SHT_GNU_versym_end
    
    ;from 0x6fff4c00  to 0x6fff4c0c
    SHT_LLVM_ODRTAB db "LLVM_ODRTAB";
    SHT_LLVM_LINKER_OPTIONS db "LLVM_LINKER_OPTIONS";
    SHT_LLVM_ADDRSIG db "LLVM_ADDRSIG";
    SHT_LLVM_DEPENDENT_LIBRARIES db "LLVM_DEPENDENT_LIBRARIES";
    SHT_LLVM_SYMPART db "LLVM_SYMPART";
    SHT_LLVM_PART_EHDR db "LLVM_PART_EHDR";
    SHT_LLVM_PART_PHDR db "LLVM_PART_PHDR";
    SHT_LLVM_BB_ADDR_MAP_V0 db "LLVM_BB_ADDR_MAP_V0";
    SHT_LLVM_CALL_GRAPH_PROFILE db "LLVM_CALL_GRAPH_PROFILE";
    SHT_LLVM_BB_ADDR_MAP db "LLVM_BB_ADDR_MAP";
    SHT_LLVM_OFFLOADING db "LLVM_OFFLOADING";
    SHT_LLVM_LTO db "LLVM_LTO";

    SHT_ARRAY_0x6fff4c0x dd SHT_LLVM_ODRTAB,SHT_LLVM_LINKER_OPTIONS,SHT_NULL,SHT_LLVM_ADDRSIG,SHT_LLVM_DEPENDENT_LIBRARIES,SHT_LLVM_SYMPART,SHT_LLVM_PART_EHDR,SHT_LLVM_PART_PHDR,SHT_LLVM_BB_ADDR_MAP_V0,SHT_LLVM_CALL_GRAPH_PROFILE,SHT_LLVM_BB_ADDR_MAP,SHT_LLVM_OFFLOADING,SHT_LLVM_LTO,SHT_NULL


    e_shstrndx dq 0
    address_shstrtab dq 0
    address_section dq 0
    address_program dq 0
    section_size dq 0

    sh_name_value dq 0
    sh_type_value dq 0
    sh_flags_value dq 0
    sh_info_value dq 0
    sh_addr_value dd 0
    sh_offset_value dd 0
    sh_size_value dd 0
    sh_link_value dd 0
    sh_align_value dq 0
    sh_entsize_value dd 0

    PAD db "W",0
    PAD1 db "W",0

    SHF_WRITE db "W",0
	SHF_ALLOC db "A",0
	SHF_EXECINSTR db "X",0
	SHF_MERGE db "M",0
	SHF_STRINGS db "S",0
	SHF_INFO_LINK db "I",0
	SHF_LINK_ORDER db "L",0
	SHF_OS_NONCONFORMING db "O",0
	SHF_GROUP db "G",0
	SHF_TLS db "T",0
	SHF_EXCLUDE db "E",0
	SHF_COMPRESSED db "C",0
    SHF_MASKOS db "R",0
    SHF_MASKPROC db "p",0
    SHF_ORDERED db "SHF_ORDERED",0

    sh_key_to_flags db "Key to Flags:",10,
                    db 9,"W (write), A (alloc), X (execute), M (merge), S (strings), I (info),",10,
                    db 9,"L (link order), O (extra OS processing required), G (group), T (TLS),",10,
                    db 9,"C (compressed), x (unknown), o (OS specific), E (exclude),",10,
                    db 9,"D (mbind), l (large), p (processor specific)",10
    sh_key_to_flags_end:
;ProgramHeader
    program_header db "Program Headers: ", 10
    program_first_line db "  Type",9,9,"Offset",9,9,9,"VirtAddr",9,9,"PhysAddr",10
                       db 9,9,"FileSiz",9,9,9,"MemSiz",9,9,9,"Flags",9,"Align",10

    PT_NULL db "NULL",9
    PT_LOAD db "LOAD",9
    PT_DYNAMIC db "DYNAMIC",0
    PT_INTERP db "INTERP",0
    PT_NOTE db "NOTE",9
    PT_SHLIB db "SHLIB",0
    PT_PHDR db "PHDR",9
    PT_TLS db "TLS",9
    PT_NUM db "NUM",9

    PT_ARRAY dd PT_NULL,PT_LOAD,PT_DYNAMIC,PT_INTERP,PT_NOTE,PT_SHLIB,PT_PHDR,PT_TLS,PT_NUM,PT_NULL

    PT_GNU_EH_FRAME db "GNU_EH_FRAME";
    PT_GNU_STACK db "GNU_STACK";
    PT_GNU_RELRO db "GNU_RELRO";
    PT_GNU_PROPERTY db "GNU_PROPERTY";
    PT_GNU_SFRAME db "GNU_SFRAME";
    PT_OPENBSD_MUTABLE db "OPENBSD_MUTABLE";
    PT_OPENBSD_RANDOMIZE db "OPENBSD_RANDOMIZE";
    PT_OPENBSD_WXNEEDED db "OPENBSD_WXNEEDED";
    PT_OPENBSD_NOBTCFI db "OPENBSD_NOBTCFI";
    PT_OPENBSD_SYSCALLS db "OPENBSD_SYSCALLS";
    PT_OPENBSD_BOOTDATA db "OPENBSD_BOOTDATA";

    PT_ARRAY_LARGE dd PT_GNU_EH_FRAME,PT_GNU_STACK,PT_GNU_RELRO,PT_GNU_PROPERTY,PT_GNU_SFRAME,PT_NULL,PT_OPENBSD_MUTABLE,PT_OPENBSD_RANDOMIZE,PT_OPENBSD_WXNEEDED,PT_OPENBSD_NOBTCFI,PT_OPENBSD_SYSCALLS,PT_OPENBSD_BOOTDATA,PT_NULL

    newline db 10, 0
    space db " "
    dspace db "  "
    tab db 9, 0
    R db "R"
    W db "W"
    E db "E"

    pt_align_value dd 0
    program_size dd 0
;Section to Segment mapping
    sec_to_seg db "Section to Segment mapping:", 10
    sec_to_seg_segment db "Segment"
    sec_to_seg_section db "Sections..."

    num_program_header db 0
    num_section_header db 0

    sec_to_seg_address_program dq 0
    sec_to_seg_address_section dq 0

    sec_to_seg_program_viradd dq 0
    sec_to_seg_program_memsz dq 0

    sec_to_seg_section_addr dq 0
    sec_to_seg_section_sz dq 0
    sec_to_seg_section_name dq 0
    sec_to_seg_section_flags dq 0

section .bss
    filename resb 256
    ;filepath resb 256
    buffer resb 5000000 ; To store ELF header (5000000 bytes)
    value resb 1
    print resb 1
    output_buffer resb 77
    pt_value resb 4
    pt_offset_value resb 4
    pt_vaddr_value resb 4
    pt_paddr_value resb 4
    pt_filesz_value resb 4
    pt_memsz_value resb 4
    pt_flags_value resb 4
    
section .text
    global _start

_start:
InputOutput:
    ; In prompt yêu cầu nhập đường dẫn
    mov rax, 4              ; syscall write
    mov rbx, 1              ; stdout
    mov rcx, prompt         ; Địa chỉ chuỗi prompt
    mov rdx, 18             ; Độ dài chuỗi
    int 0x80

    ; Đọc đường dẫn file từ stdin
    mov rax, 3              ; syscall read
    mov rbx, 0              ; stdin
    mov rcx, filename       ; Địa chỉ lưu đường dẫn file
    mov rdx, 256            ; Tối đa 256 ký tự
    int 0x80

    ; Xóa newline (nếu có) từ đường dẫn nhập vào
    mov rsi, filename       ; Địa chỉ đường dẫn
strip_newline:
    cmp byte [rsi], 10      ; Kiểm tra newline (\n)
    je  end_strip_newline   ; Nếu gặp newline, kết thúc
    inc rsi                 ; Tăng chỉ số
    cmp byte [rsi], 0       ; Kiểm tra kết thúc chuỗi
    jne strip_newline
end_strip_newline:
    mov byte [rsi], 0       ; Đặt NULL để kết thúc chuỗi

    ; Open file (sys_open)
    mov rbx, filename
    mov rax, 5            ; syscall: open
    mov rcx, 0            ; flags: O_RDONLY
    int 0x80
    test rax, rax
    js exit_error_open    ; If error, exit
    mov rbx, rax          ; Save file descriptor

    ; Read ELF header (sys_read)
    mov rax, 3            ; syscall: read
    mov rcx, buffer       ; Buffer to store ELF header
    mov rdx, 5000000           ; Read 52 bytes
    int 0x80
    test rax, rax
    js exit_error_read    ; If error, exit

    ; Verify ELF magic number (first 4 bytes should be 0x7F 'E' 'L' 'F')
    mov rax, [buffer]     ; Load first 4 bytes of the buffer
    cmp eax, 0x464c457f   ; Compare with ELF magic number
    jne exit_invalid_elf  ; If not matching, exit
    
ELFHeader:

    ; Display ELF Header
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_header    ; "ELF Header: "
    mov rdx, 13           ; Length
    int 0x80
    
    ; Display ELF magic
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_magic    ; "Magic: "
    mov rdx, 9           ; Length
    int 0x80

    ; Display magic bytes
    ;mov rax, 4            ; syscall: write
    ;mov rbx, 1            ; stdout
    ;mov rcx, buffer       ; Pointer to magic bytes
    ;mov rdx, 4            ; Length: 4 bytes
    ;int 0x80
    
    ;Get 16 byte from buffer to convert to hex
    xor rbx, rbx
    xor rax, rax
magic_loop:
    cmp rbx, 16
    je exit_magic_loop
    
    mov al, [buffer + rbx]
   
    push rbx
    push rcx
    push rdx
    push rax
    call bin_to_hex

    mov rax, 4            ; syscall: write
    mov rcx, space        ; space character
    mov rdx, 1            ; Length: 1
    mov rbx, 1            ; stdout
    int 0x80

    pop rax
    pop rdx
    pop rcx
    pop rbx
    
    inc rbx
    jmp magic_loop

exit_magic_loop:    
    ; Print newline
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, newline      ; Newline character
    mov rdx, 1            ; Length: 1
    int 0x80
    
    ; Display Class
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_class    ; "Class: "
    mov rdx, 13           ; Length
    int 0x80

    mov al, byte [buffer + 4]
    cmp al, 2
    je _64bit

    mov rax, 4            	; syscall: write
    mov rbx, 1            	; stdout
    mov rcx, elf_class_32bit    ; "ELF32"
    mov rdx, 6           	; Length
    int 0x80
    
    jmp elf_class_exit
_64bit:
    mov rax, 4            	; syscall: write
    mov rbx, 1            	; stdout
    mov rcx, elf_class_64bit    ; "ELF64"
    mov rdx, 6           	; Length
    int 0x80
    
elf_class_exit:
    ; Display Data
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_data     ; "Data: "
    mov rdx, 12           ; Length
    int 0x80
    
    mov al, byte [buffer + 5]
    cmp al, 0x02
    je big_endian
    
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_data_littleendian	;"2's complement, little endian"
    mov rdx, 30           ; Length
    int 0x80
    
    jmp elf_data_exit
big_endian:
    
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_data_bigendian	;"1's complement, big endian"
    mov rdx, 27           ; Length
    int 0x80
    
elf_data_exit:

    ; Display Version
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_version  ; "Version: "
    mov rdx, 14           ; Length
    int 0x80
    
    mov al, byte [buffer + 6]
    cmp al, 0x01
    je elf_version1
    
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_version_sth  ; "sth"
    mov rdx, 4           ; Length
    int 0x80
    
    jmp elf_version_exit
    
elf_version1:
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_version_1  ; "1 (current)"
    mov rdx, 12           ; Length
    int 0x80
    
elf_version_exit:
    ; Display OS/ABI
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_osabi  ; "OS/ABI: "
    mov rdx, 13           ; Length
    int 0x80
    
    mov al, byte [buffer + 7]
    cmp al, 0
    je none
    cmp al, 1
    je hpux
    cmp al, 2
    je netbsd
    cmp al, 3
    je gnu
    cmp al, 4
    je solaris
    cmp al, 5
    je aix
    cmp al, 6
    je irix
    cmp al, 7
    je freebsd
    cmp al, 8
    je tru64
    cmp al, 9
    je modesto
    cmp al, 10
    je openbsd
    cmp al, 11
    je openvms
    cmp al, 12
    je nsk
    cmp al, 13
    je aros
    cmp al, 14
    je fenixos
    cmp al, 15
    je cloudabi
    cmp al, 16
    je openvos
    cmp al, 17
    je cuda
    
    mov rcx, elf_version_sth
    jmp elf_osabi_exit
none:
    mov rcx, ELFOSABI_NONE
    mov rdx, (ELFOSABI_HPUX - ELFOSABI_NONE)
    jmp elf_osabi_exit
hpux:
    mov rcx, ELFOSABI_HPUX
    mov rdx, (ELFOSABI_NETBSD - ELFOSABI_HPUX)
    jmp elf_osabi_exit
netbsd:
    mov rcx, ELFOSABI_NETBSD
    mov rdx, (ELFOSABI_GNU - ELFOSABI_NETBSD)
    jmp elf_osabi_exit
gnu:
    mov rcx, ELFOSABI_GNU
    mov rdx, (ELFOSABI_SOLARIS - ELFOSABI_GNU)
    jmp elf_osabi_exit
solaris:
    mov rcx, ELFOSABI_SOLARIS
    mov rdx, (ELFOSABI_AIX - ELFOSABI_SOLARIS)
    jmp elf_osabi_exit
aix:
    mov rcx, ELFOSABI_AIX
    mov rdx, (ELFOSABI_IRIX - ELFOSABI_AIX)
    jmp elf_osabi_exit
irix:
    mov rcx, ELFOSABI_IRIX
    mov rdx, (ELFOSABI_FREEBSD - ELFOSABI_IRIX)
    jmp elf_osabi_exit
freebsd:
    mov rcx, ELFOSABI_FREEBSD
    mov rdx, (ELFOSABI_TRU64 - ELFOSABI_FREEBSD)
    jmp elf_osabi_exit
tru64:
    mov rcx, ELFOSABI_TRU64
    mov rdx, (ELFOSABI_MODESTO - ELFOSABI_TRU64)
    jmp elf_osabi_exit
modesto:
    mov rcx, ELFOSABI_MODESTO
    mov rdx, (ELFOSABI_OPENBSD - ELFOSABI_MODESTO)
    jmp elf_osabi_exit    
openbsd:
    mov rcx, ELFOSABI_OPENBSD
    mov rdx, (ELFOSABI_OPENVMS - ELFOSABI_OPENBSD)
    jmp elf_osabi_exit
openvms:
    mov rcx, ELFOSABI_OPENVMS
    mov rdx, (ELFOSABI_NSK - ELFOSABI_OPENVMS)
    jmp elf_osabi_exit
nsk:
    mov rcx, ELFOSABI_NSK
    mov rdx, (ELFOSABI_AROS - ELFOSABI_NSK)
    jmp elf_osabi_exit
aros:
    mov rcx, ELFOSABI_AROS
    mov rdx, (ELFOSABI_FENIXOS - ELFOSABI_AROS)
    jmp elf_osabi_exit    
fenixos:
    mov rcx, ELFOSABI_FENIXOS
    mov rdx, (ELFOSABI_CLOUDABI - ELFOSABI_FENIXOS)
    jmp elf_osabi_exit    
cloudabi:
    mov rcx, ELFOSABI_CLOUDABI
    mov rdx, (ELFOSABI_OPENVOS - ELFOSABI_CLOUDABI)
    jmp elf_osabi_exit
openvos:
    mov rcx, ELFOSABI_OPENVOS
    mov rdx, (ELFOSABI_CUDA - ELFOSABI_OPENVOS)           ; Length
    jmp elf_osabi_exit
cuda:
    mov rcx, ELFOSABI_CUDA
    mov rdx, (elf_abi_version - ELFOSABI_CUDA)           ; Length
    jmp elf_osabi_exit

elf_osabi_exit:
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    int 0x80

    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_abi_version  ; "ABI Version: "
    mov rdx, 18           ; Length
    int 0x80

    xor rax, rax
    mov al, byte [buffer + 8]
    add al, 48
    mov byte [value], al

    mov rcx, value
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rdx, 1           ; Length
    int 0x80

    mov rcx, newline
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rdx, 1           ; Length
    int 0x80

    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_type  ; "Type: "
    mov rdx, 12           ; Length
    int 0x80

    mov ax, word [buffer + 15]
    cmp ax, 0x00
    je etnone
    cmp ax, 0x0100
    je etrel
    cmp ax, 0x0200
    je etexe
    cmp ax, 0x0300
    je etdyn
    cmp ax, 0x0400
    je etcore
    cmp ax, 0xfe
    je etos
    cmp ax, 0xfffe
    je etos
    cmp ax, 0xff
    je etproc
    cmp ax, 0xffff
    je etproc

    mov rcx, elf_version_sth
    mov rdx, (elf_osabi - elf_version_sth)
    jmp elf_type_exit
etnone:
    mov rcx, ET_NONE
    mov rdx, (ET_REL - ET_NONE)
    jmp elf_type_exit
etrel:
    mov rcx, ET_REL
    mov rdx, (ET_EXEC - ET_REL)
    jmp elf_type_exit
etexe:
    mov rcx, ET_EXEC
    mov rdx, (ET_DYN - ET_EXEC)
    jmp elf_type_exit
etdyn:
    mov rcx, ET_DYN
    mov rdx, (ET_CORE - ET_DYN)
    jmp elf_type_exit
etcore:
    mov rcx, ET_CORE
    mov rdx, (ET_OS - ET_CORE)
    jmp elf_type_exit
etos:
    mov rcx, ET_OS
    mov rdx, (ET_PROC - ET_OS)
    jmp elf_type_exit
etproc:
    mov rcx, ET_PROC
    mov rdx, (elf_machine - ET_PROC)

elf_type_exit:
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    int 0x80

    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, elf_machine  ; "Machine: "
    mov rdx, 14           ; Length
    int 0x80

    mov al, byte [buffer + 18]
    mov ah, byte [buffer + 19]
    xor rsi, rsi

elf_type_loop:
    cmp rsi, 259
    je elf_type_loop_exit
    cmp rsi, rax
    je elf_type_loop_exit
    inc rsi
    jmp elf_type_loop

elf_type_loop_exit:
    xor rcx, rcx
    mov rbx, EM_ARRAY

    mov rax, 4
    imul rsi

    add rbx, rax
    mov rcx, [rbx]

    add rbx,4
    mov rdx, [rbx]
    sub rdx, rcx          ; Length

    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    int 0x80

;   Version
    mov rax, 4
    mov rbx, 1
    mov rcx, elf_version
    mov rdx, 14
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rax, rax
    mov al, [buffer + 20]
    push rax
    call bin_to_hex

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80
    
    ; Entry point
    mov rax, 4
    mov rbx, 1
    mov rcx, elf_entry_point
    mov rdx, 25
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rsi, rsi
    mov rsi, 31
    xor rax,rax
    mov [print], rax

elf_entry_point_loop:
    cmp rsi, 24
    jl elf_entry_point_loop_exit
    mov al, byte [buffer + rsi]
    cmp [print], ah
    jne print_entry_point
    cmp al, 0
    jne print_entry_point_true
    cmp rsi, 24                     ;case 0x0
    je print_flag
    jmp print_entry_point_exit

print_entry_point_true:
    mov rcx, 1
    mov [print], rcx

print_entry_point:
    push rax
    call bin_to_hex

print_entry_point_exit:
    dec rsi
    jmp elf_entry_point_loop
elf_entry_point_loop_exit:

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_start_program_header
    mov rdx, 29
    int 0x80

    xor rsi, rsi
    mov rsi, 39

elf_start_program_header_loop:
    cmp rsi, 31
    je elf_start_program_header_exit
    shl rax, 8
    mov al, byte [buffer + rsi]
    dec rsi
    jmp elf_start_program_header_loop

elf_start_program_header_exit:
    mov [output_buffer], rax
    mov [address_program], rax
    call DecToString
    
    mov rax, 4
    mov rbx, 1
    mov rcx, elf_desb_start
    mov rdx, 19
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_start_section_header
    mov rdx, 29
    int 0x80

    xor rsi, rsi
    mov rsi, 47

elf_start_section_header_loop:
    cmp rsi, 39
    je elf_start_section_header_exit
    shl rax, 8
    mov al, byte [buffer + rsi]
    dec rsi
    jmp elf_start_section_header_loop

elf_start_section_header_exit:
    mov [address_section],rax
    
    mov [output_buffer], rax
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_desb_start
    mov rdx, 19
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_flag
    mov rdx, 13
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rsi, rsi
    mov rsi, 51
    xor rax,rax
    mov [print], rax

elf_flag_loop:
    cmp rsi, 48
    jl elf_flag_loop_exit
    mov al, byte [buffer + rsi]
    cmp [print], ah
    jne print_flag
    cmp al, 0
    jne print_flag_true
    cmp rsi, 48                     ;case 0x0
    je print_flag
    jmp print_flag_exit

print_flag_true:
    mov rcx, 1
    mov [print], rcx

print_flag:
    push rax
    call bin_to_hex

print_flag_exit:
    dec rsi
    jmp elf_flag_loop
elf_flag_loop_exit:

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_size_this_header
    mov rdx, 27
    int 0x80

    xor rax, rax
    mov [output_buffer], rax
    mov al, byte [buffer + 52]
    mov ah, byte [buffer + 53]

    mov [section_size], rax
    mov [output_buffer], rax
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_desb_byte
    mov rdx, 9
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_size_program_header
    mov rdx, 28
    int 0x80

    xor rax, rax
    mov [output_buffer], rax
    mov al, byte [buffer + 54]
    mov ah, byte [buffer + 55]
    mov [output_buffer], rax
    mov dword [program_size], eax
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_desb_byte
    mov rdx, 9
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_num_program_header
    mov rdx, 30
    int 0x80
    
    xor rax, rax
    mov [output_buffer], rax
    mov al, byte [buffer + 56]
    mov ah, byte [buffer + 57]
    mov [output_buffer], rax
    mov [num_program_header], rax

    push rax
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_size_section_header
    mov rdx, 28
    int 0x80
    
    xor rax, rax
    mov [output_buffer], rax
    mov al, byte [buffer + 58]
    mov ah, byte [buffer + 59]
    mov [output_buffer], rax
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_desb_byte
    mov rdx, 9
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80
    
    mov rax, 4
    mov rbx, 1
    mov rcx, elf_num_section_header
    mov rdx, 30
    int 0x80
    
    xor rax, rax
    mov [output_buffer], rax
    mov al, byte [buffer + 60]
    mov ah, byte [buffer + 61]
    mov [output_buffer], rax
    mov [num_section_header], rax
    push rax
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, elf_section_header_index
    mov rdx, 37
    int 0x80
    
    xor rax, rax
    mov [output_buffer], rax
    mov al, byte [buffer + 62]
    mov ah, byte [buffer + 63]

    mov [e_shstrndx], rax

    mov [output_buffer], rax
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80
;   SectionHeader
SectionHeader:
    mov rax, 4
    mov rbx, 1
    mov rcx, section_header
    mov rdx, 18
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, section_first_line
    mov rdx, (open - section_first_line)
    int 0x80

    ; Find address of shstrtab
    mov rax, [section_size]             ;64
    mov rbx, [e_shstrndx]               ;29
    imul rbx
    add rax, [address_section]          ;123768
    add rax, 24                         ;Offset
    mov rbx, [buffer + rax]             ; buffer + offset
    add rbx, buffer
    mov [address_shstrtab], rbx

    mov rax, [address_section]
    add rax, buffer
    mov [sh_name_value], rax

    mov rax, [address_section]
    add rax, buffer
    add rax, 4                      ;offset of sh_type
    mov [sh_type_value], rax

    mov rax, [address_section]
    add rax, 16                      ;offset of sh_addr
    mov [sh_addr_value], rax

    mov rax, [address_section]
    add rax, 24                      ;offset of sh_offset
    mov [sh_offset_value], rax

    mov rax, [address_section]
    add rax, 32                      ;offset of sh_size
    mov [sh_size_value], rax

    mov rax, [address_section]
    add rax, 56                      ;offset of sh_entsize
    mov [sh_entsize_value], rax

    mov rax, [address_section]
    add rax, buffer
    add rax, 8                      ;offset of sh_entsize
    mov [sh_flags_value], rax

    mov rax, [address_section]
    add rax, buffer
    add rax, 40                      ;offset of link
    mov [sh_link_value], rax

    mov rax, [address_section]
    add rax, buffer
    add rax, 44                      ;offset of info
    mov [sh_info_value], rax

    mov rax, [address_section]
    add rax, buffer
    add rax, 48                      ;offset of info
    mov [sh_align_value], rax

    xor rsi, rsi
    pop rax

section_header_loop:
    cmp rsi, rax
    je section_header_exit

    push rsi
    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, open
    mov rdx, 2
    int 0x80

    xor rax, rax
    mov [output_buffer], rax
    mov [output_buffer], rsi
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, close
    mov rdx, 2
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_name
    call sh_name

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_type
    call sh_type

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_addr
    call sh_addr

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_offset
    call sh_offset

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_size
    call sh_size

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_entsize
    call sh_entsize

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_flag
    call sh_flags

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_link
    call sh_link

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    ;sh_info
    call sh_info

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    call sh_align

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    pop rax
    pop rsi
    inc rsi

    jmp section_header_loop

section_header_exit:
    mov rax, 4
    mov rbx, 1
    mov rcx, sh_key_to_flags
    mov rdx, (sh_key_to_flags_end - sh_key_to_flags)
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

ProgramHeader:
    mov rax, 4
    mov rbx, 1
    mov rcx, program_header
    mov rdx, 18
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, program_first_line
    mov rdx, 69
    int 0x80

    xor rsi, rsi
    mov rax, 64
    mov dword [pt_value], eax

    mov rax, 72
    mov dword [pt_offset_value], eax
    
    mov rax, 80
    mov dword [pt_vaddr_value], eax

    mov rax, 88
    mov dword [pt_paddr_value], eax

    mov rax, 96
    mov dword [pt_filesz_value], eax

    mov rax, 104
    mov dword [pt_memsz_value], eax

    mov rax, 68
    mov dword [pt_flags_value], eax

    mov rax, 112
    mov dword [pt_align_value], eax

    pop rax

program_header_loop:
    cmp rsi, rax
    je program_header_exit
    push rax
    push rsi

    mov rax, 4
    mov rbx, 1
    mov rcx, dspace
    mov rdx, 2
    int 0x80

;pt_type
    call pt_type 

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

;pt_offset

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rax, rax
    mov eax, dword [pt_offset_value]
    push rax

    call pt_print8b

    pop rax
    add rax, 56
    mov dword [pt_offset_value], eax

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

;pt_vaddr

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rax, rax
    mov eax, dword [pt_vaddr_value]
    push rax

    call pt_print8b

    pop rax
    add rax, 56
    mov dword [pt_vaddr_value], eax

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

;pt_paddr
    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rax, rax
    mov eax, dword [pt_paddr_value]
    push rax

    call pt_print8b

    pop rax
    add rax, 56
    mov dword [pt_paddr_value], eax

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

;pt_filesz

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rax, rax
    mov eax, dword [pt_filesz_value]
    push rax

    call pt_print8b

    pop rax
    add rax, 56
    mov dword [pt_filesz_value], eax

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

;pt_memsz

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    xor rax, rax
    mov eax, dword [pt_memsz_value]
    push rax

    call pt_print8b

    pop rax
    add rax, 56
    mov dword [pt_memsz_value], eax


;pt_flags
    
    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    mov rbx, [pt_flags_value]
    mov sil, byte [buffer + rbx]

pt_flag_read:
    cmp sil, 4
    jl pt_flag_write
    sub sil, 4

    mov rax, 4
    mov rbx, 1
    mov rcx, R
    mov rdx, 1
    int 0x80

pt_flag_write:
    cmp sil, 2
    jl pt_flag_execute
    sub sil, 2

    mov rax, 4
    mov rbx, 1
    mov rcx, W
    mov rdx, 1
    int 0x80

pt_flag_execute:
    cmp sil, 1
    jl pt_flag_exit

    mov rax, 4
    mov rbx, 1
    mov rcx, E
    mov rdx, 1
    int 0x80
    
pt_flag_exit:
    mov rax, 56
    add [pt_flags_value], eax

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 2
    int 0x80

;pt_align

    mov rax, 4
    mov rbx, 1
    mov rcx, prehex
    mov rdx, 2
    int 0x80

    ;thanh cong
    xor rax, rax
    mov eax, dword [pt_align_value]
    push rax

    call pt_print8b

    pop rax
    add rax, 56
    mov dword [pt_align_value], eax

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    pop rsi
    pop rax
    inc rsi

    jmp program_header_loop

program_header_exit:
    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80
    
;Segment to Section mapping

    mov rax, 4
    mov rbx, 1
    mov rcx, sec_to_seg
    mov rdx, 28
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, sec_to_seg_segment
    mov rdx, 7
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, sec_to_seg_section
    mov rdx, 10
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    call sec_to_seg_mapping

    ; Exit program (sys_exit)
    mov rax, 1            ; syscall: exit
    xor rbx, rbx          ; Exit code: 0
    int 0x80

exit_invalid_input:
    ; Handle missing input
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, err_open     ; Error message
    mov rdx, 23           ; Length
    int 0x80
    jmp exit

exit_error_open:
    ; Handle file open error
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, err_open     ; Error message
    mov rdx, 23           ; Length
    int 0x80
    jmp exit

exit_error_read:
    ; Handle file read error
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, err_read     ; Error message
    mov rdx, 23           ; Length
    int 0x80
    jmp exit

exit_invalid_elf:
    ; Handle invalid ELF file
    mov rax, 4            ; syscall: write
    mov rbx, 1            ; stdout
    mov rcx, err_read     ; Error message
    mov rdx, 23           ; Length
    int 0x80
    jmp exit

exit:
    ; Exit program
    mov rax, 1            ; syscall: exit
    xor rbx, rbx          ; Exit code: 0
    int 0x80

bin_to_hex:
    push rbp
    mov rbp, rsp
    
    mov al, [rbp + 16]
    xor rbx, rbx
    xor rcx, rcx

    ; Tách nibble cao
    mov ah, al                       ; Copy byte vào AH
    shr ah, 4                        ; Dịch phải 4 bit để lấy nibble cao
    mov cl, ah
    and cl, 0x0F
    
    mov rax, 4            ; syscall: write
    lea rcx, [hex_table + rcx]          
    mov rdx, 1            ; Length: 1
    mov rbx, 1            ; stdout
    int 0x80
    
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    ; Tách nibble thấp
    mov al, [rbp + 16]                 
    mov cl, al
    and cl, 0x0F		      ; Lấy 4 bit thấp nhất của byte

    mov rax, 4            ; syscall: write
    lea rcx, [hex_table + rcx]          
    mov rdx, 1            ; Length: 1
    mov rbx, 1            ; stdout
    int 0x80
    
    pop rbp
    ret
section .text
    global bin_to_dec          ; Định nghĩa hàm toàn cục

DecToString:
    push rbp
    mov rbp, rsp

    mov rbx, output_buffer + 77			            ; Start from the end of the buffer
    mov byte [rbx], 0			                    ; Null-terminate the string
    dec rbx				                            ; Move one back
    mov rax, [output_buffer]                            ; dividend 
    mov rcx, 10                               ; divisor
    push rsi
    xor rsi,rsi
.convert_result:	
    xor rdx, rdx                              ; remainder
    div rcx                                   ; rax:rcx -> rax:quotient rdx:remainder
    add dl, '0'                               ; convert to string               
    mov byte [rbx], dl                        ; store value
    dec rbx                                   ; move one back
    inc rsi                                    ; lenth of output
    cmp rax, 0                                ; compare to 0
    jne .convert_result                        ; if != 0 move to convert_result
    inc rbx
  
    ; Printing the result
    mov rdx, rsi                               ; Length of the result (1 character)
    mov rcx, rbx                             ; Address of the result
    mov rbx, 1                               ; File descriptor 1 (stdout)
    mov rax, 4                               ; syscall number for write
    int 0x80
    
    pop rsi

    pop rbp
    ret

pt_type:
    push rbp
    mov rbp, rsp

    xor rax, rax

    xor rbx,rbx
    mov bl, 3

.pt_type_loop: 
    cmp bl, 0
    jl .pt_type_loop_exit

    shl rax,8
    xor rsi, rsi
    mov esi, dword [pt_value]
    add rsi, rbx
    mov al, byte [buffer + rsi]

    inc rsi
    sub bl, 1

    jmp .pt_type_loop

.pt_type_loop_exit:

    cmp rax,8
    jg .pt_type_large
    

.pt_type_little:
    mov rbx, 4
    imul rbx

    mov rdx, [PT_ARRAY + rax + 4]
    sub rdx, [PT_ARRAY + rax]

    mov rcx, [PT_ARRAY + rax]
    mov rax,4
    mov rbx,1
    int 0x80

    jmp .pt_type_exit

.pt_type_large:
    and rax, 0x0000000F
    mov rbx, 4
    imul rbx

    mov rdx, [PT_ARRAY_LARGE + rax + 4]
    sub rdx, [PT_ARRAY_LARGE + rax]

    mov rcx, [PT_ARRAY_LARGE + rax]
    mov rax,4
    mov rbx,1
    int 0x80

    jmp .pt_type_exit

.pt_type_exit:

    mov rax, 56
    add [pt_value], rax

    pop rbp
    ret


pt_print8b:
    push rbp
    mov rbp, rsp

    xor rax, rax

    xor rbx,rbx
    mov bl, 7

.pt_print8b_loop: 
    cmp bl, 0
    jl .pt_print8b_loop_exit

    xor rsi, rsi
    mov esi, dword [rbp + 16]
    add rsi, rbx
    xor rax, rax
    mov al, byte [buffer + rsi]

    push rbx
    push rax
    call bin_to_hex
    pop rax
    pop rbx

    inc rsi
    sub bl, 1

    jmp .pt_print8b_loop

.pt_print8b_loop_exit:

    pop rbp
    ret

big_to_little_endian:
    push rbp
    mov rbp, rsp

    ;dia chi cua chuoi
    mov rbx, [rbp + 24]
    ;kich thuoc muon chuyen sang little endian
    mov rsi, [rbp + 16]
    dec rsi             
    xor rax, rax

big_to_little_endian_loop:
    
    cmp rsi, 0
    jl big_to_little_endian_exit

    shl rax, 8
    mov al, byte [rbx + rsi]

    dec rsi
    jmp big_to_little_endian_loop

big_to_little_endian_exit:
    pop rbp
    ret

HexToString:
    push rbp
    mov rbp, rsp

    mov rsi, 1 ;length output (first digit is null)

    mov rbx, output_buffer + 77			            ; Start from the end of the buffer
    mov byte [rbx], 0			                    ; Null-terminate the string
    dec rbx				                            ; Move one back
    mov rax, [output_buffer]                            ; dividend 
    mov rcx, 16                               ; divisor
.convert_result:	

    xor rdx, rdx                              ; remainder
    div rcx                                   ; rax:rcx -> rax:quotient rdx:remainder
    mov dl, byte [hex_table + rdx]                               ; convert to string               
    mov byte [rbx], dl                        ; store value
    dec rbx                                   ; move one back
    cmp rax, 0                                ; compare to 0
    jne .convert_result                        ; if != 0 move to convert_result
    inc rsi
    inc rbx
  
    ; Printing the sum
    mov rdx, rsi                               ; Length of the result (1 character)
    mov rcx, rbx                             ; Address of the result
    mov rbx, 1                               ; File descriptor 1 (stdout)
    mov rax, 4                               ; syscall number for write
    int 0x80
    
    pop rbp
    ret

sh_name:
    push rbp
    mov rbp, rsp

    mov rax, [sh_name_value]

    ;conver from big_to_little_endian
    push rax
    push 4

    call big_to_little_endian

    ;rax store offset value from sh_name table
    mov rbx, [address_shstrtab]
    add rax, rbx

    ;clear the stack
    pop rbx
    pop rbx

    push rax        ;store first character of string
    call print_string_before_null

    ;clear the stack
    pop rbx

    mov rax, [sh_name_value]
    add rax, [section_size]
    mov [sh_name_value], rax

    pop rbp
    ret

print_string_before_null:
    push rbp
    mov rbp, rsp

    mov rax, [rsp + 16]

    ;count num of character before null
    xor rsi, rsi
    xor rbx, rbx
.print_loop:
    mov bl, byte [rax + rsi]
    cmp bl, 0
    je .exit
    inc rsi
    jmp .print_loop

.exit:
    ;print string
    mov rcx, [rsp + 16]

    mov rdx, rsi
    inc rdx

    cmp rdx, 9
    jl .print_name

    mov rdx, 9

.print_name:
    mov rax, 4
    mov rbx, 1
    int 0x80

    cmp rdx, 9
    jl .ins_tab

    mov rax, 4
    mov rbx, 1
    mov rcx, open
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, dot
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, dot
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, dot
    mov rdx, 1
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, close
    mov rdx, 1
    int 0x80

    jmp .exit_funct

.ins_tab:
    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

.exit_funct:

    pop rbp
    ret

print_string_before_null_uncut:
    push rbp
    mov rbp, rsp

    mov rax, [rsp + 16]

    ;count num of character before null
    xor rsi, rsi
    xor rbx, rbx
.print_loop:
    mov bl, byte [rax + rsi]
    cmp bl, 0
    je .exit
    inc rsi
    jmp .print_loop

.exit:
    ;print string
    mov rcx, [rsp + 16]

    mov rdx, rsi
    inc rdx

.print_name:
    mov rax, 4
    mov rbx, 1
    int 0x80

.exit_funct:

    pop rbp
    ret
sh_type:
    push rbp
    mov rbp, rsp

    mov rbx, [sh_type_value]

    push rbx
    push 4      ;p_type length is 4bytes
    call big_to_little_endian

    ;clear stack
    pop rbx
    pop rbx

    ;rax store value of Type
    ; <=19
    cmp rax, 19
    jg .check_0x6fff4700

    shl rax, 2              ;x4
    xor rcx, rcx
    mov ecx, [SHT_ARRAY + rax]

    xor rdx, rdx
    mov edx, [SHT_ARRAY + rax + 4]
    sub edx, [SHT_ARRAY + rax]

    jmp .print_type
    
.check_0x6fff4700:
    cmp rax, 0x6fff4700
    jne .check_0x6fff4c0x

    mov rcx,SHT_GNU_INCREMENTAL_INPUTS
    mov rdx, 23

    jmp .print_type

.check_0x6fff4c0x:
    cmp rax, 0x6fff4c0c
    jg .check_0x6ffffffx
    cmp rax, 0x6fff4c00
    jl .check_0x6ffffffx

    sub rax, 0x6fff4c00         

    shl rax, 2              ;x4
    xor rcx, rcx
    mov ecx, [SHT_ARRAY_0x6fff4c0x + rax]

    xor rdx, rdx
    mov edx, [SHT_ARRAY_0x6fff4c0x + rax + 4]
    sub edx, [SHT_ARRAY_0x6fff4c0x + rax]

    jmp .print_type

.check_0x6ffffffx:
    cmp rax, 0x6fffffff
    jg .default
    cmp rax, 0x6ffffff5
    jl .default
    
    sub rax, 0x6ffffff5        

    shl rax, 2              ;x4
    xor rcx, rcx
    mov ecx, [SHT_ARRAY_6ffffffx + rax]

    xor rdx, rdx
    mov edx, [SHT_ARRAY_6ffffffx + rax + 4]
    sub edx, [SHT_ARRAY_6ffffffx + rax]

    jmp .print_type

.default:
    mov rcx, elf_version_sth
    mov rdx, 4

.print_type:
    mov rax, 4
    mov rbx, 1
    int 0x80 
    
.update_sh_type_value:
    mov rax, [sh_type_value]
    add rax, [section_size]
    mov [sh_type_value], rax

    pop rbp
    ret

sh_addr:
    push rbp
    mov rbp, rsp

    xor rax, rax
    mov eax, dword [sh_addr_value]
    push rax

    call pt_print8b

    pop rax
    add rax, [section_size]
    mov dword [sh_addr_value], eax

    pop rbp
    ret

sh_offset:
    push rbp
    mov rbp, rsp

    xor rax, rax
    mov eax, dword [sh_offset_value]
    push rax

    call pt_print8b

    pop rax
    add rax, [section_size]
    mov dword [sh_offset_value], eax

    pop rbp
    ret

sh_size:
    push rbp
    mov rbp, rsp

    xor rax, rax
    mov eax, dword [sh_size_value]
    push rax

    call pt_print8b

    pop rax
    add rax, [section_size]
    mov dword [sh_size_value], eax

    pop rbp
    ret

sh_entsize:
    push rbp
    mov rbp, rsp

    xor rax, rax
    mov eax, dword [sh_entsize_value]
    push rax

    call pt_print8b

    pop rax
    add rax, [section_size]
    mov dword [sh_entsize_value], eax

    pop rbp
    ret

sh_flags:
    push rbp
    mov rbp, rsp

    mov rbx, [sh_flags_value]

    push rbx
    push 8
    call big_to_little_endian

    ;clear stack
    pop rbx
    pop rbx

    ;rax store value
    mov rbx, 0x8000000
    and rbx, rax
    cmp rbx, 0
    je .SHF_MASKPROC

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_EXCLUDE
    mov rdx, 1
    int 0x80

    pop rax
    
.SHF_MASKPROC:
    mov rbx, 0x00000000F0000000
    and rbx, rax
    cmp rbx, 0
    je .SHF_MASKOS

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_MASKPROC
    mov rdx, 1
    int 0x80

    pop rax

.SHF_MASKOS:
    mov rbx, 0x0FF00000
    and rbx, rax
    cmp rbx, 0
    je .SHF_ORDERED

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_MASKOS
    mov rdx, 1
    int 0x80

    pop rax

.SHF_ORDERED:
    mov rbx, 0x4000000
    and rbx, rax
    cmp rbx, 0
    je .SHF_COMPRESSED

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_ORDERED
    mov rdx, 1
    int 0x80

    pop rax

.SHF_COMPRESSED:
    mov rbx, 0x800
    and rbx, rax
    cmp rbx, 0
    je .SHF_TLS

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_COMPRESSED
    mov rdx, 1
    int 0x80

    pop rax
    
.SHF_TLS:
    mov rbx, 0x400
    and rbx, rax
    cmp rbx, 0
    je .SHF_GROUP

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_TLS
    mov rdx, 1
    int 0x80

    pop rax

.SHF_GROUP:
    mov rbx, 0x200
    and rbx, rax
    cmp rbx, 0
    je .SHF_OS_NONCONFORMING

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_GROUP
    mov rdx, 1
    int 0x80

    pop rax
    
.SHF_OS_NONCONFORMING:
    mov rbx, 0x100
    and rbx, rax
    cmp rbx, 0
    je .SHF_LINK_ORDER

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_OS_NONCONFORMING
    mov rdx, 1
    int 0x80

    pop rax

.SHF_LINK_ORDER:
    mov rbx, 0x80
    and rbx, rax
    cmp rbx, 0
    je .SHF_INFO_LINK

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_LINK_ORDER
    mov rdx, 1
    int 0x80

    pop rax

.SHF_INFO_LINK:
    mov rbx, 0x40
    and rbx, rax
    cmp rbx, 0
    je .SHF_STRINGS

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_INFO_LINK
    mov rdx, 1
    int 0x80

    pop rax

.SHF_STRINGS:
    mov rbx, 0x20
    and rbx, rax
    cmp rbx, 0
    je .SHF_MERGE

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_STRINGS
    mov rdx, 1
    int 0x80

    pop rax

.SHF_MERGE:
    mov rbx, 0x10
    and rbx, rax
    cmp rbx, 0
    je .SHF_EXECINSTR

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_MERGE
    mov rdx, 1
    int 0x80

    pop rax

.SHF_EXECINSTR:
    mov rbx, 0x4
    and rbx, rax
    cmp rbx, 0
    je .SHF_ALLOC

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_EXECINSTR
    mov rdx, 1
    int 0x80

    pop rax

.SHF_ALLOC:
    mov rbx, 0x2
    and rbx, rax
    cmp rbx, 0
    je .SHF_WRITE

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_ALLOC

    mov rdx, 1
    int 0x80

    pop rax

.SHF_WRITE:
    mov rbx, 0x1
    and rbx, rax
    cmp rbx, 0
    je .default

    push rax

    mov rax, 4
    mov rbx, 1
    mov rcx, SHF_WRITE
    mov rdx, 1
    int 0x80

    pop rax

.default:
    mov rax, [sh_flags_value]
    add rax, [section_size]
    mov dword [sh_flags_value], eax

    pop rbp
    ret

sh_link:
    push rbp
    mov rbp, rsp

    xor rax, rax
    mov eax, dword [sh_link_value]

    push rax
    push 4
    call big_to_little_endian

    ;clear stack
    pop rbx
    pop rbx

    ;rax store value
    mov [output_buffer], eax
    call DecToString

    ;update sh_link
    mov rax, [sh_link_value]
    add rax, [section_size]
    mov [sh_link_value], rax

    pop rbp
    ret

sh_info:
    push rbp
    mov rbp, rsp

    mov rax, [sh_info_value]
    push rax
    push 4
    call big_to_little_endian

    ;clear stack
    pop rbx
    pop rbx

    ;rax store value
    mov [output_buffer], eax
    call DecToString

    ;update sh_link
    mov rax, [sh_info_value]
    add rax, [section_size]
    mov [sh_info_value], rax

    pop rbp
    ret

sh_align:
    push rbp
    mov rbp, rsp

    mov rax, [sh_align_value]
    push rax
    push 8
    call big_to_little_endian

    ;clear stack
    pop rbx
    pop rbx

    ;rax store value
    mov [output_buffer], eax
    call DecToString

    ;update sh_link
    mov rax, [sh_align_value]
    add rax, [section_size]
    mov [sh_align_value], rax

    pop rbp
    ret

sec_to_seg_mapping:
    push rbp
    mov rbp, rsp

    mov rax, [address_program]
    add rax, buffer
    mov qword [sec_to_seg_address_program], rax

    xor rsi, rsi
    ;mov sil, byte [num_program_header]

sec_to_seg_mapping_loop:
    cmp sil, byte [num_program_header]
    je sec_to_seg_mapping_loop_exit
    push rsi

    mov [output_buffer], rsi
    call DecToString

    mov rax, 4
    mov rbx, 1
    mov rcx, tab
    mov rdx, 1
    int 0x80

;pt_vaddr
    mov rbx, [address_section]
    add rbx, buffer
    mov [sec_to_seg_address_section], rbx

    mov rax, [sec_to_seg_address_program]
    add rax, 16
    mov [pt_vaddr_value], rax

    push rax
    push 8
    call big_to_little_endian
    pop rbx
    pop rbx

    mov [sec_to_seg_program_viradd], rax

;pt_memsz
    mov rax, [sec_to_seg_address_program]
    add rax, 40
    mov [pt_vaddr_value], rax

    push rax
    push 8
    call big_to_little_endian
    pop rbx
    pop rbx

    mov [sec_to_seg_program_memsz], rax


;section_loop
    xor rsi, rsi

sec_to_seg_section_loop:
    cmp sil, byte [num_section_header]
    je sec_to_seg_section_loop_exit
    push rsi

;sh_addr
    mov rax, [sec_to_seg_address_section]
    add rax, 16
    
    push rax
    push 8
    call big_to_little_endian
    pop rbx
    pop rbx

    mov [sec_to_seg_section_addr], rax


;sh_size
    mov rax, [sec_to_seg_address_section]
    add rax, 32
    
    push rax
    push 8
    call big_to_little_endian
    pop rbx
    pop rbx

    mov [sec_to_seg_section_sz], rax

;sh_name
    mov rax, [sec_to_seg_address_section]
    
    push rax
    push 4
    call big_to_little_endian
    pop rbx
    pop rbx

    mov [sec_to_seg_section_name], rax

;sh_flags
    mov rax, [sec_to_seg_address_section]
    add rax, 8
    
    push rax
    push 8
    call big_to_little_endian
    pop rbx
    pop rbx

    mov [sec_to_seg_section_flags], rax

;compare & print section Name
; (p_vaddr <= sh_addr) and (sh_addr + sh_size <= p_vaddr + p_memsz) and sh_flags contains A (alloc)
    mov rbx, [sec_to_seg_program_viradd]
    cmp rbx, [sec_to_seg_section_addr]
    jg update_sec_to_seg_address_section

    ;and
    mov rax, [sec_to_seg_section_addr]
    add rax, [sec_to_seg_section_sz]

    mov rbx, [sec_to_seg_program_viradd]
    add rbx, [sec_to_seg_program_memsz]

    cmp rax, rbx
    jg update_sec_to_seg_address_section

    mov rax, [sec_to_seg_section_flags]
    and rax, 0x2
    cmp rax, 0
    je update_sec_to_seg_address_section

    mov rax, [sec_to_seg_section_name]
    ;rax store offset value from sh_name table
    mov rbx, [address_shstrtab]
    add rax, rbx

    push rax        ;store first character of string
    call print_string_before_null_uncut

    ;clear the stack
    pop rbx

    mov rax, 4
    mov rbx, 1
    mov rcx, space
    mov rdx, 1
    int 0x80

update_sec_to_seg_address_section:
    xor rax, rax
    mov eax, [section_size]
    add rax, [sec_to_seg_address_section]
    mov [sec_to_seg_address_section], rax

    pop rsi
    inc sil
    jmp sec_to_seg_section_loop

sec_to_seg_section_loop_exit:

    xor rax, rax
    mov eax, dword [program_size]
    add rax, [sec_to_seg_address_program]
    mov [sec_to_seg_address_program], rax

    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    pop rsi
    inc rsi 
    jmp sec_to_seg_mapping_loop

sec_to_seg_mapping_loop_exit:

    pop rbp
    ret
