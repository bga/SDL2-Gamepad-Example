# Copyright 2020 Bga <bga.email@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


CC=g++

space :=
space +=
pathToName = $(subst /,_,$(subst $(space),-,$1))

SELF_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT = $(call pathToName,$(dir $(SELF_PATH)))

TARGET_EXEC ?= $(PROJECT).exe

ARCH ?= i386
PLATFORM ?= windows


BUILD_DIR ?= $(TEMP)/$(PROJECT)
SRC_DIRS ?= ./src

SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s' | grep -Fv '.bak.')
OBJS := $(subst \,/,$(SRCS:%=$(BUILD_DIR)/%.o))
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

#CPPFLAGS ?= $(INC_FLAGS) -MMD -MP
CPPFLAGS += -Wall -Wextra -Wcast-qual
# CPPFLAGS += -Wall -Wextra -Wredundant-decls -Wcast-align -Wundef -Wfloat-equal -Wunreachable-code -Wmissing-include-dirs -Wnoexcept -Wpointer-arith -Wwrite-strings -Wlogical-op -Wlogical-not-parentheses -Wbool-compare -Wint-in-bool-context -Wmisleading-indentation -Wswitch -Wswitch-default -Wswitch-bool -Wnon-virtual-dtor -Wctor-dtor-privacy -Wdelete-non-virtual-dtor
CPPFLAGS += -Wno-unused-variable -Wno-unused-parameter
CPPFLAGS += -D_WIN32 
CPPFLAGS += -I$(PLATFORM)/include -Iinclude -I../../$(PLATFORM)/include -I../../include -I../../../../!cpp/include
CPPFLAGS += -fPIC
# CPPFLAGS += -o .obj/$(@F)
CPPFLAGS += -fdollars-in-identifiers
# LDFLAGS += -mwindows
# LDFLAGS += -subsystem windows
LDFLAGS += -mwindows

ifdef DEBUG
	CPPFLAGS += -ggdb -DDEBUG -Og
else
	CPPFLAGS += -DNDEBUG -O2
endif

#CPPFLAGS += -MMD -MP -MF $(BUILD_DIR)/$(@F).d
CPPFLAGS += -MMD -MP
-include $(DEPS)



# LDFLAGS += -L../../lib/$(PLATFORM)/$(ARCH) -L../../../../!cpp/lib/$(PLATFORM)/$(ARCH) 
LDFLAGS += -L/mingw32/lib -lSDL2 

# all: app

$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o "$@" $(LDFLAGS)

# assembly
$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@


.PHONY: clean list

clean:
	$(RM) -r $(BUILD_DIR)

MKDIR_P ?= mkdir -p

# [https://stackoverflow.com/a/26339924]
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# debugging make
print-%:
	@echo "$*" = "$($*)"
