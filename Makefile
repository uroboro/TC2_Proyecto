export GO_EASY_ON_ME = 1
export TARGET = iphone:clang:8.1
export ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

#DIP: application
APPLICATION_NAME = TC2_Proyecto
TC2_Proyecto_FILES = $(call findfiles,sources) $(ADDITIONAL_FILES)
TC2_Proyecto_FRAMEWORKS = CoreFoundation Foundation MobileCoreServices UIKit CoreGraphics AudioToolbox MediaPlayer

include $(THEOS_MAKE_PATH)/application.mk


ipa: $(APPLICATION_NAME).ipa

%.ipa: %
	$(ECHO_NOTHING)echo "Building $@..."$(ECHO_END)
	$(ECHO_NOTHING)pushd $(THEOS_OBJ_DIR)/ &> /dev/null; mkdir -p Payload; cp -r $<.app Payload; zip -qru $@ Payload; rm -rf Payload; popd &> /dev/null$(ECHO_END)
	$(ECHO_NOTHING)mv $(THEOS_OBJ_DIR)/$@ ./$(ECHO_END)

instapp: $(APPLICATION_NAME).ipa
	$(ECHO_NOTHING)echo "Installing $<..."$(ECHO_END)
	$(ECHO_NOTHING)[[ `which appinst` != "" && `appinst $< &> /dev/null` != 0 ]]$(ECHO_END)
	$(ECHO_NOTHING)[[ `which open` != "" && -f "Resources/Info.plist" ]] && echo "Opening `plutil -key CFBundleDisplayName Resources/Info.plist`..."$(ECHO_END)
	$(ECHO_NOTHING)[[ `which open` != "" ]] && open `plutil -key CFBundleIdentifier Resources/Info.plist`$(ECHO_END)
