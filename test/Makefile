export GO_EASY_ON_ME=1
export TARGET = iphone:clang:8.1
export ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

findfiles = $(foreach ext, c cpp m mm x xm xi xmi, $(wildcard $(1)/*.$(ext)))

#tonegen: tool
TOOL_NAME = tonegen
tonegen_FILES = $(call findfiles,sources)
tonegen_FRAMEWORKS = CoreFoundation AudioToolbox MediaPlayer

#debug files
ifeq ($(debug),1)
$(TOOL_NAME)_FILES += $(call findfiles,debug)
ADDITIONAL_CFLAGS += -include debug/signalcatcher.h
else
ADDITIONAL_CFLAGS += -DSC=""
endif

include $(THEOS_MAKE_PATH)/tool.mk
