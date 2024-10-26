#QUIET = @

# tools
#CC = $(ARM_SDK_PREFIX)gcc
#CP = $(ARM_SDK_PREFIX)objcopy
#ECHO = echo

# common variables
IDENTIFIER := AM32

# Folders
HAL_FOLDER := Mcu
MAIN_SRC_DIR := Src
MAIN_INC_DIR := Inc

SRC_DIRS_COMMON := $(MAIN_SRC_DIR)

# Default MCU type to F051
# MCU_TYPE ?= f421
TARGET ?= TEKKO32_F421

# additional libs
LIBS := -lc -lm -lnosys

# Compiler options
CFLAGS_COMMON := -DUSE_MAKE
CFLAGS_COMMON += -I$(MAIN_INC_DIR) -O3 -Wall -ffunction-sections
CFLAGS_COMMON += -D$(TARGET)

# Linker options
LDFLAGS_COMMON := -specs=nano.specs $(LIBS) -Wl,--gc-sections -Wl,--print-memory-usage

# Working directories
ROOT := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
PROJECT_DIR     := $(ROOT)/project
BOARD_DIR 		:= $(PROJECT_DIR)/board
STDPERIPH_DIR 	:= $(ROOT)/$(HAL_FOLDER)/f421
OBJECT_DIR      := $(ROOT)/debug
BIN_DIR         := $(ROOT)/debug
$(warning STDPERIPH_DIR := $(STDPERIPH_DIR))

LINKER_DIR 		:= $(ROOT)/$(HAL_FOLDER)/f421
$(warning LINKER_DIR := $(LINKER_DIR))

# C sources
C_SOURCES 	:= $(shell find -L $(STDPERIPH_DIR) -name '*.c')
C_SOURCES 	+= $(shell find -L $(PROJECT_DIR) -name '*.c')
CSOURCES = $(subst ./,,$(C_SOURCES))
$(warning CSOURCES := $(CSOURCES)) $(info  )

# C++ sources
CXX_SOURCES	:= $(shell find -L $(BOARD_DIR) -name '*.cpp')
CXXSOURCES 	:= $(subst ./,,$(CXX_SOURCES))
$(warning CXXSOURCES := $(CXXSOURCES)) $(info  )

# ASM sources
ASM_SOURCES =	$(shell find -L $(PROJECT_DIR) -name '*.s')
ASMSOURCES = $(subst ./,,$(ASM_SOURCES))
$(warning ASMSOURCES := $(ASMSOURCES)) $(info )

# Autodetect inc dirs
INC_DIRS1 	:= $(dir $(shell find -L $(PROJECT_DIR) -name '*.h'))
INC_DIRS1 	+= $(dir $(shell find -L $(STDPERIPH_DIR) -name '*.h'))
INC_DIRS2 	:= $(sort $(INC_DIRS1))
INC_DIRS3 	:= $(subst ./,,$(INC_DIRS2))

INCLUDE_DIRS := $(subst / , ,$(INC_DIRS3))
$(warning INCLUDE_DIRS := $(INCLUDE_DIRS)) $(info  )

# add to .vscode\c_cpp_properties.json
$(warning add to .vscode\c_cpp_properties.json)
SRC := 	$(subst ./,,$(ASMSOURCES)) \
		$(subst ./,,$(CSOURCES)) \
		$(subst ./,,$(CXXSOURCES))

$(info SRC := $(SRC)) $(info  )
SRC_DIRS_1 	:= $(dir $(SRC)) 
SRC_DIRS_2 	:= $(subst / , ,$(SRC_DIRS_1))
SRC_DIRS_3 	:= $(sort $(SRC_DIRS_2))

SRC_DIRS_4 	:= $(addsuffix "__ ,$(addprefix "$${env:myWorkspacePath}/,$(SRC_DIRS_3)))
SRC_DIRS 	:= $(SRC_DIRS_4)

includePath :=	$(addsuffix "__ ,$(addprefix "$${env:myWorkspacePath}/,$(INCLUDE_DIRS)))
includePath +=	$(SRC_DIRS)

$(info "includePath": )
$(info $(includePath)) $(info  )

# Tools
GNU_TYPE = gcc-arm-none-eabi-10.3-2021.10
#GNU_TYPE = arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi
GCC_PATH = $(TOOLS_DIR)/$(GNU_TYPE)/bin

GCC_REQUIRED_VERSION ?= 10.3.1
#GCC_REQUIRED_VERSION ?= 13.2.1

# Tool names
TOOLS_DIR  		:= C:/AT32IDE/platform/tools
ARM_SDK_DIR 	:= $(TOOLS_DIR)/$(GNU_TYPE)

ARM_SDK_PREFIX 	:= $(ARM_SDK_DIR)/bin/arm-none-eabi-
CROSS_CC    	:= $(ARM_SDK_PREFIX)gcc
CROSS_CXX   	:= $(ARM_SDK_PREFIX)g++
CROSS_GDB   	:= $(ARM_SDK_PREFIX)gdb
OBJCOPY     	:= $(ARM_SDK_PREFIX)objcopy
OBJDUMP     	:= $(ARM_SDK_PREFIX)objdump
READELF     	:= $(ARM_SDK_PREFIX)readelf
SIZE        	:= $(ARM_SDK_PREFIX)size

MAKE 	:= C:/msys64/mingw64/bin/make.exe

# Target Output Files
TARGET_HEX 		= $(BIN_DIR)/$(TARGET).hex
TARGET_BIN 		= $(BIN_DIR)/$(TARGET).bin
TARGET_ELF 		= $(OBJECT_DIR)/$(TARGET).elf
TARGET_LST      = $(OBJECT_DIR)/$(TARGET).lst
TARGET_OBJ_DIR  = $(OBJECT_DIR)/$(TARGET)
TARGET_MAP      = $(OBJECT_DIR)/$(TARGET).map
$(warning TARGET_HEX := $(TARGET_HEX)) $(info  )
$(warning TARGET_BIN := $(TARGET_BIN)) $(info  )
$(warning TARGET_ELF := $(TARGET_ELF)) $(info  )
$(warning TARGET_LST := $(TARGET_LST)) $(info  )
$(warning TARGET_MAP := $(TARGET_MAP)) $(info  )

# CFLAGS
# ASM
ASM_DEFS =
ASM_INCLUDES = 
ASM_WARNING =

# C
MCU_FLAGS = -mcpu=cortex-m4 -mthumb
# -mfloat-abi=hard -mfpu=fpv4-sp-d16

# Preprocessor defines -D
C_DEFS :=	TRACE \
			OS_USE_TRACE_SEMIHOSTING_DEBUG \
			AT32F421K8U7 \
			USE_STDPERIPH_DRIVER
			
OPTIMIZATION_FLAGS = -Os -ffunction-sections

WARNING_FLAGS = 

DEBUG_FLAGS := -g

GNU_FLAGS = -std=gnu17

# C++

# compile gcc flags
ASFLAGS =	$(MCU_FLAGS) \
			$(OPTIMIZATION_FLAGS) \
			$(ASM_WARNING) \
			$(DEBUG_FLAGS) \
			$(addprefix -D,$(ASM_DEFS)) \
			-x assembler-with-cpp \
			-MMD -MP -MF"$(@:%.o=%.d)"

MCFLAGS +=	$(MCU_FLAGS) \
			$(OPTIMIZATION_FLAGS) \
			$(WARNING_FLAGS) \
			$(DEBUG_FLAGS) \
			$(addprefix -D,$(C_DEFS)) \
			$(addprefix -I,$(INCLUDE_DIRS)) \
			-MMD -MP -MF"$(@:%.o=%.d)"
			
CFLAGS = $(MCFLAGS) -std=gnu17
CXXFLAGS = $(MCFLAGS) -std=gnu++17 -fabi-version=0

$(warning ASFLAGS := $(ASFLAGS)) $(info  )
$(warning CFLAGS := $(CFLAGS)) $(info  )
$(warning CXXFLAGS := $(CXXFLAGS)) $(info )

# LDFLAGS
# link script
LD_SCRIPT = $(LINKER_DIR)/AT32F421x6_FLASH.ld
$(warning LD_SCRIPT := $(LD_SCRIPT)) $(info )

EXTRA_LD_FLAGS :=	--specs=nano.specs \
					--specs=nosys.specs
#					-u _printf_float \
					-u _scanf_float
					

LD_FLAGS :=	$(MCU_FLAGS) \
			$(OPTIMIZATION_FLAGS) \
			$(WARNING_FLAGS) \
			$(DEBUG_FLAGS) \
			-T$(LD_SCRIPT) \
			-Xlinker --gc-sections \
			-Wl,-gc-sections,-Map,$(TARGET_MAP) \
			-Wl,--print-memory-usage \
			$(EXTRA_LD_FLAGS)
$(warning LD_FLAGS := $(LD_FLAGS)) $(info  )

# Object List
OBJECTS  = 	$(addsuffix .o,$(addprefix $(TARGET_OBJ_DIR)/,$(basename $(ASMSOURCES))))
OBJECTS += 	$(addsuffix .o,$(addprefix $(TARGET_OBJ_DIR)/,$(basename $(CSOURCES))))
OBJECTS += 	$(addsuffix .o,$(addprefix $(TARGET_OBJ_DIR)/,$(basename $(CXXSOURCES))))
#$(warning TARGET_OBJ_DIR := $(TARGET_OBJ_DIR)) $(info  )
#$(warning OBJECTS | $(OBJECTS)) $(info )

# Build

$(TARGET_LST): $(TARGET_ELF)
	$(OBJDUMP) -S --disassemble $< > $@
	
$(TARGET_HEX): $(TARGET_ELF)
	@echo "Creating HEX $(TARGET_HEX)"
	$(OBJCOPY) -O ihex --set-start 0x08000000 $< $@

$(TARGET_BIN): $(TARGET_ELF)
	@echo "Creating BIN $(TARGET_BIN)"
	$(OBJCOPY) -O binary $< $@
	
$(TARGET_ELF): $(OBJECTS)
	@echo "Linking $(TARGET)"
	$(CROSS_CXX) -o $@ $^ $(LD_FLAGS)
	$(SIZE) $(TARGET_ELF)

$(TARGET_OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo %%_cpp $(notdir $<)
	@$(CROSS_CXX) -c -o $@ $(CXXFLAGS) $<
	
$(TARGET_OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo %%_c $(notdir $<)
	@$(CROSS_CC) -c -o $@ $(CFLAGS) $<

$(TARGET_OBJ_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	@echo "%%_s $(notdir $<)"
	@$(CROSS_CC) -c -o $@ $(ASFLAGS) $<

$(TARGET_OBJ_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	@echo "%%_S $(notdir $<)"
	@$(CROSS_CC) -c -o $@ $(ASFLAGS) $<

#################################
# Recipes
#################################
.PHONY: all clean size elf

clean:
	@echo "Cleaning $(TARGET)"
	rm -rf $(TARGET_OBJ_DIR)
	rm -f $(TARGET_ELF) $(TARGET_HEX) $(TARGET_MAP) $(TARGET_LST)
	@echo "Cleaning $(TARGET) succeeded."

all: $(TARGET_HEX) $(TARGET_BIN)

size: 
	@echo "Size $(TARGET)"
	$(SIZE) -A $(TARGET_ELF)

elf: 
	@echo "Size $(TARGET)"
	$(READELF) -S -W $(TARGET_ELF)

# *** EOF ***
# $(error STOP)
# https://habr.com/ru/companies/inforion/articles/460247/
