CORE_DIR  := $(shell pwd)/..
RTL_DIR   := $(CORE_DIR)/rtl
BHV_DIR   := $(CORE_DIR)/bhv
INC_DIR   := $(RTL_DIR)/include

# Package must be compiled first
PKG       := $(INC_DIR)/cv32e40s_pkg.sv

# All RTL sources (order doesn't matter after package)
RTL_SRC   := $(wildcard $(RTL_DIR)/*.sv)

# Behavioral models needed for simulation
BHV_SRC   := $(BHV_DIR)/cv32e40s_sim_clock_gate.sv \
             $(BHV_DIR)/cv32e40s_sim_sffr.sv \
             $(BHV_DIR)/cv32e40s_sim_sffs.sv

TB        := tb_top.sv
REPO_ROOT := $(abspath ../../..)
CELLIFT_DV_DIR := $(REPO_ROOT)/cellift-meta/design-processing/common/dv

# DPI helpers for ELF/taint preloading into the SV memory model.
CELLIFT_DPI_CPP := \
	$(CELLIFT_DV_DIR)/common_functions.cc \
	$(CELLIFT_DV_DIR)/elfloader.cc \
	$(CELLIFT_DV_DIR)/taintloader.cc

CPP       := sim_main.cpp $(CELLIFT_DPI_CPP)
TOP       := tb_top

VFLAGS    := --sv --cc --exe --trace --top-module $(TOP) \
             -Wno-fatal -Wno-BLKANDNBLK \
             +define+COREV_ASSERT_OFF \
             -I$(INC_DIR)

OBJ_DIR   := obj_dir
SIM       := $(OBJ_DIR)/V$(TOP)

.PHONY: sim run clean

sim: $(SIM)

$(SIM): $(TB) $(CPP) $(PKG) $(RTL_SRC) $(BHV_SRC)
	verilator $(VFLAGS) $(PKG) $(RTL_SRC) $(BHV_SRC) $(TB) $(CPP)
	$(MAKE) -C $(OBJ_DIR) -f V$(TOP).mk

run: $(SIM)
	cp test/firmware.hex . 2>/dev/null || true
	./$(SIM) +trace

clean:
	rm -rf $(OBJ_DIR) trace.vcd firmware.hex
