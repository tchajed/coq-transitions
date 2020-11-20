SRC_DIRS := 'src' $(shell test -d 'vendor' && echo 'vendor')
ALL_VFILES := $(shell find $(SRC_DIRS) -name "*.v")
TEST_VFILES := $(shell find 'src' -name "*Tests.v")
PROJ_VFILES := $(shell find 'src' -name "*.v")
VFILES := $(filter-out $(TEST_VFILES),$(PROJ_VFILES))

COQARGS :=

default: $(VFILES:.v=.vo)
test: $(TEST_VFILES:.v=.vo) $(VFILES:.v=.vo)

.coqdeps.d: $(ALL_VFILES)
	@echo "COQDEP $@"
	@coqdep -f _CoqProject $(ALL_VFILES) > $@

ifneq ($(MAKECMDGOALS), clean)
-include .coqdeps.d
endif

%.vo: %.v
	@echo "COQC $<"
	@coqc $(COQARGS) $(shell cat '_CoqProject') $< -o $@

clean:
	@echo "CLEAN vo glob aux"
	@rm -f $(ALL_VFILES:.v=.vo) $(ALL_VFILES:.v=.glob)
	@find $(SRC_DIRS) -name ".*.aux" -exec rm {} \;
	rm -f .coqdeps.d

.PHONY: default test clean
.DELETE_ON_ERROR:
