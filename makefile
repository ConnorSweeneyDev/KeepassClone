RM = rm -r
CXX = g++

#RELEASE FLAGS:
#CXXFLAGS = -s -O3 -std=c++20 -DNDEBUG -D_FORTIFY_SOURCE=2 -fstack-protector-strong
#DEBUG FLAGS:
CXXFLAGS = -g -O2 -std=c++20 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong

WARNINGS = -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Wcast-qual -Wcast-align -Wfloat-equal -Wlogical-op -Wduplicated-cond -Wshift-overflow=2 -Wformat=2
SYSTEM_INCLUDES = -isystemext/include -isystemext/include/sciter
ifeq ($(OS), Windows_NT)
  INCLUDES = -Iprog/include -Iprog/include/windows -Iext/include -Iext/include/sciter
  LIBRARIES = -lmingw32
  EXT_SOURCES = ext/src/sciter-win-main.cpp
  OUTPUT = bin/windows/KeepassClone.exe
else
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S), Linux)
    INCLUDES = -Iprog/include -Iext/include -Iext/include/sciter -Iext/include/gtk -Iext/include/graphene -Iext/include/glib -Iext/include/pango -Iext/include/harfbuzz -Iext/include/cairo -Iext/include/gdk-pixbuf
    LIBRARIES = -Wl,-rpath,'$$ORIGIN'
    EXT_SOURCES = ext/src/sciter-gtk-main.cpp
    OUTPUT = bin/linux/KeepassClone.out
  endif
  #MAC IS NOT SUPPORTED YET
  #ifeq ($(UNAME_S), Darwin)
  #endif
endif

OBJECTS_DIRECTORY = obj
COMMANDS_DIRECTORY = compile_commands.json
PROG_SOURCES = $(wildcard prog/src/*.cpp)
OBJECTS = $(patsubst prog/src/%.cpp,$(OBJECTS_DIRECTORY)/%.o,$(PROG_SOURCES)) $(patsubst ext/src/%.cpp,$(OBJECTS_DIRECTORY)/%.o,$(EXT_SOURCES))

all: compile_commands object $(OUTPUT)

compile_commands:
	@echo "[" > $(COMMANDS_DIRECTORY)
	@for source in $(PROG_SOURCES); do echo -e "\t{ \"directory\": \"$(CURDIR)\", \"command\": \"$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) $(SYSTEM_INCLUDES) $(LIBRARIES) -c $$source -o $(OBJECTS_DIRECTORY)/$$(basename $$source .cpp).o\", \"file\": \"$$source\" },"; done >> $(COMMANDS_DIRECTORY)
	@for source in $(EXT_SOURCES); do echo -e "\t{ \"directory\": \"$(CURDIR)\", \"command\": \"$(CXX) $(CXXFLAGS) $(INCLUDES) -c $$source -o $(OBJECTS_DIRECTORY)/$$(basename $$source .cpp).o\", \"file\": \"$$source\" },"; done >> $(COMMANDS_DIRECTORY)
	@sed -i "$$ s/,$$//" $(COMMANDS_DIRECTORY)
	@echo "]" >> $(COMMANDS_DIRECTORY)
	@echo "$(COMMANDS_DIRECTORY) updated."

object:
	@if [ ! -d "$(OBJECTS_DIRECTORY)" ]; then mkdir -p $(OBJECTS_DIRECTORY); fi

$(OUTPUT): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) $(SYSTEM_INCLUDES) $(OBJECTS) $(LIBRARIES) -o $(OUTPUT)
$(OBJECTS_DIRECTORY)/%.o: prog/src/%.cpp
	$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) $(SYSTEM_INCLUDES) -c $< -o $@
$(OBJECTS_DIRECTORY)/%.o: ext/src/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SYSTEM_INCLUDES) -c $< -o $@

clean:
	@if [ -d "$(OBJECTS_DIRECTORY)" ]; then $(RM) $(OBJECTS_DIRECTORY); fi
	@if [ -f $(OUTPUT) ]; then $(RM) $(OUTPUT); fi
	@if [ -f prog/include/resources.cpp ]; then $(RM) prog/include/resources.cpp; fi
