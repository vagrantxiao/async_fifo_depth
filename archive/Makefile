

REPO_ROOT := $(shell git rev-parse --show-toplevel)
PXX       := python3
RUN_FILE  := $(REPO_ROOT)/F003_vcoding/util/refactor.py
FILE_IN   := async_fifo_tb.v
FILE_OUT  := async_fifo_tb.v
START     := 1
END       := 448
m         := $(shell date)


all:
	$(PXX) $(RUN_FILE) \
	-i $(FILE_IN) \
	-o $(FILE_OUT) #-s $(START) -e $(END)

git:
	git add .
	git commit -m "$(m)"
	git push origin main

    
