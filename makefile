RM = rm -r
CXX = g++
ifeq ($(OS), Windows_NT)
  ECHO = echo -e
else
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S), Linux)
    ECHO = echo
  endif
  #MAC IS NOT SUPPORTED YET
  #ifeq ($(UNAME_S), Darwin)
  #endif
endif

#RELEASE FLAGS:
#CXXFLAGS = -s -O3 -std=c++20 -DNDEBUG -D_FORTIFY_SOURCE=2 -fstack-protector-strong
#DEBUG FLAGS:
CXXFLAGS = -g -O2 -std=c++20 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong

WARNINGS = -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Wcast-qual -Wcast-align -Wfloat-equal -Wlogical-op -Wduplicated-cond -Wshift-overflow=2 -Wformat=2
SYSTEM_INCLUDES = -isystemexternal/include -isystemexternal/include/sciter -isystemexternal/include/gtk -isystemexternal/include/graphene -isystemexternal/include/glib -isystemexternal/include/pango -isystemexternal/include/harfbuzz -isystemexternal/include/cairo -isystemexternal/include/gdk-pixbuf
ifeq ($(OS), Windows_NT)
  INCLUDES = -Iprogram/include -Iprogram/include/windows -Iexternal/include -Iexternal/include/sciter
  LIBRARIES = -static -Wl,-Bstatic -lstdc++ -lgcc -lssp -lwinpthread -Wl,-Bdynamic
  EXTERNAL_SOURCES = external/source/sciter-win-main.cpp
  OUTPUT = binary/windows/KeepassClone.exe
else
  ifeq ($(UNAME_S), Linux)
    INCLUDES = -Iprogram/include -Iexternal/include -Iexternal/include/sciter -Iexternal/include/gtk -Iexternal/include/graphene -Iexternal/include/glib -Iexternal/include/pango -Iexternal/include/harfbuzz -Iexternal/include/cairo -Iexternal/include/gdk-pixbuf
    LIBRARIES = -Wl,-rpath,'$$ORIGIN'
    EXTERNAL_SOURCES = external/source/sciter-gtk-main.cpp
    OUTPUT = binary/linux/KeepassClone.out
  endif
  #MAC IS NOT SUPPORTED YET
  #ifeq ($(UNAME_S), Darwin)
  #endif
endif

OBJECTS_DIRECTORY = object
PROGRAM_SOURCES = $(wildcard program/source/*.cpp)
OBJECTS = $(patsubst program/source/%.cpp,$(OBJECTS_DIRECTORY)/%.o,$(PROGRAM_SOURCES)) $(patsubst external/source/%.cpp,$(OBJECTS_DIRECTORY)/%.o,$(EXTERNAL_SOURCES))

COMMANDS_DIRECTORY = compile_commands.json
FORMAT_DIRECTORY = .clang-format
STYLE = BasedOnStyle: LLVM
TAB_WIDTH = IndentWidth: 2
INITIALIZER_WIDTH = ConstructorInitializerIndentWidth: 2
CONTINUATION_WIDTH = ContinuationIndentWidth: 2
BRACES = BreakBeforeBraces: Allman
LANGUAGE = Language: Cpp
LIMIT = ColumnLimit: 100
BLOCKS = AllowShortBlocksOnASingleLine: true
FUNCTIONS = AllowShortFunctionsOnASingleLine: true
IFS = AllowShortIfStatementsOnASingleLine: true
LOOPS = AllowShortLoopsOnASingleLine: true
CASE_LABELS = AllowShortCaseLabelsOnASingleLine: true
PP_DIRECTIVES = IndentPPDirectives: BeforeHash
NAMESPACE_INDENTATION = NamespaceIndentation: All
NAMESPACE_COMMENTS = FixNamespaceComments: false
INDENT_CASE_LABELS = IndentCaseLabels: true
BREAK_TEMPLATE_DECLARATIONS = AlwaysBreakTemplateDeclarations: false

all: compile_commands clang-format object $(OUTPUT)

compile_commands:
	@echo "[" > $(COMMANDS_DIRECTORY)
	@for source in $(PROGRAM_SOURCES); do $(ECHO) "\t{ \"directory\": \"$(CURDIR)\", \"command\": \"$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) $(SYSTEM_INCLUDES) $(LIBRARIES) -c $$source -o $(OBJECTS_DIRECTORY)/$$(basename $$source .cpp).o\", \"file\": \"$$source\" },"; done >> $(COMMANDS_DIRECTORY)
	@for source in $(EXTERNAL_SOURCES); do $(ECHO) "\t{ \"directory\": \"$(CURDIR)\", \"command\": \"$(CXX) $(CXXFLAGS) $(INCLUDES) -c $$source -o $(OBJECTS_DIRECTORY)/$$(basename $$source .cpp).o\", \"file\": \"$$source\" },"; done >> $(COMMANDS_DIRECTORY)
	@sed -i "$$ s/,$$//" $(COMMANDS_DIRECTORY)
	@echo "]" >> $(COMMANDS_DIRECTORY)
	@echo "$(COMMANDS_DIRECTORY) updated."

clang-format:
	@$(ECHO) "---\n$(STYLE)\n$(TAB_WIDTH)\n$(INITIALIZER_WIDTH)\n$(CONTINUATION_WIDTH)\n$(BRACES)\n---\n$(LANGUAGE)\n$(LIMIT)\n$(BLOCKS)\n$(FUNCTIONS)\n$(IFS)\n$(LOOPS)\n$(CASE_LABELS)\n$(PP_DIRECTIVES)\n$(NAMESPACE_INDENTATION)\n$(NAMESPACE_COMMENTS)\n$(INDENT_CASE_LABELS)\n$(BREAK_TEMPLATE_DECLARATIONS)\n..." > $(FORMAT_DIRECTORY)
	@find program -type f \( -name "*.cpp" -o -name "*.hpp" \) -print0 | xargs -0 -I{} sh -c 'clang-format -i "{}"'
	@echo "$(FORMAT_DIRECTORY) updated."

object:
	@if [ ! -d "$(OBJECTS_DIRECTORY)" ]; then mkdir -p $(OBJECTS_DIRECTORY); fi

$(OUTPUT): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) $(SYSTEM_INCLUDES) $(OBJECTS) $(LIBRARIES) -o $(OUTPUT)
$(OBJECTS_DIRECTORY)/%.o: program/source/%.cpp
	$(CXX) $(CXXFLAGS) $(WARNINGS) $(INCLUDES) $(SYSTEM_INCLUDES) -c $< -o $@
$(OBJECTS_DIRECTORY)/%.o: external/source/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SYSTEM_INCLUDES) -c $< -o $@

clean:
	@if [ -d "$(OBJECTS_DIRECTORY)" ]; then $(RM) $(OBJECTS_DIRECTORY); fi
	@if [ -f $(OUTPUT) ]; then $(RM) $(OUTPUT); fi
