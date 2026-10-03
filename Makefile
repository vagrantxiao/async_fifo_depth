workspace := $(CURDIR)/out
ooc_dcp := $(worksapce)/ooc.dcp
ooc_tcl := $(CURDIR)/../../infra/tcl/run_ooc.tcl
prj_tcl := $(CURDIR)/script/create_prj.tcl
.PHONY: all show ooc clean

all:
	mkdir -p $(workspace)
	cd $(workspace) && bash ../script/run_xsim.sh
	@# cd $(workspace) && vivado dump.wdb

show:
	cd $(workspace) && vivado dump.wdb

creat_prj:
	mkdir -p $(workspace)
	cd $(workspace) && \
	vivado -mode gui \
	-source $(prj_tcl)

ooc: $(ooc_dcp)

$(ooc_dcp):
	mkdir -p $(workspace)
	cd $(workspace) && \
	vivado -mode batch \
	-source $(ooc_tcl) \
	-tclargs leaf_sv $(CURDIR)/rtl $(CURDIR)/../leaf_interface/rtl
	
	


m := $(shell date)
branch := $(shell git branch --show-current)
git:
	@git add .
	@git commit -m "$(m)"
	@git push origin $(branch)



clean:
	rm -rf $(workspace)
